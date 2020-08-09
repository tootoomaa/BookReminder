//
//  ScannerVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/05.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  // MARK: - Properties
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  var passBookInfoClosure:((String, Book) -> ())? // handle Result return closure
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.black
    captureSession = AVCaptureSession()
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    let videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    if (captureSession.canAddInput(videoInput)) {
      captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if (captureSession.canAddOutput(metadataOutput)) {
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
    } else {
      failed()
      return
    }
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    
    captureSession.startRunning()
  }
  
  func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if (captureSession?.isRunning == false) {
      captureSession.startRunning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (captureSession?.isRunning == true) {
      captureSession.stopRunning()
    }
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    captureSession.stopRunning()
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      found(code: stringValue)
    }
    
    
  }
  
  func found(code: String) {
    getBookInfoByISBN(forSearch: code) { (bookInfo) in
      guard let passBookInfoClosure = self.passBookInfoClosure else {
        return print("fail to get Closure")
      }
      passBookInfoClosure(code, bookInfo)
    }
    self.dismiss(animated: true)
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  private func getBookInfoByISBN(forSearch isbn: String, complitionHandler: @escaping (Book) -> ()) {
    
    let query = isbn
    let sort = "accuracy"
    let page = "1"
    let size = "5"
    let target = "isbn"
    
    let authorization = "KakaoAK d4539e8d7741ccecad7ed805bfe1febb"
    
    let queryParams: [String: String] = [
      "query" : query,
      "sort" : sort,
      "page" : page,
      "size" : size,
      "target" : target
    ]
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "dapi.kakao.com"
    urlComponents.path = "/v3/search/book"
    urlComponents.setQueryItems(with: queryParams)
    
    if let url = urlComponents.url {
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "GET"
      urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
      
      URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error {
          print("error", error.localizedDescription)
          return
        }
        
        guard let data = data else { return print("Data is nil") }
        
        do {
          let bookInfo = try JSONDecoder().decode(Book.self, from: data)
          complitionHandler(bookInfo)
        } catch {
          print("get fail to get BookInfo in ",self)
        }
        
      }.resume()
    }
  }
}


