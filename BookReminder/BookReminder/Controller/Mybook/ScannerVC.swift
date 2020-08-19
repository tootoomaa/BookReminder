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
  
  let networkServices = NetworkServices()
  var passBookInfoClosure:((String, [String: AnyObject]) -> ())? // handle Result return closure
  
  let activiyIndicator = UIActivityIndicatorView(style: .large)
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    captureSession = AVCaptureSession()
    
    configureSetUI()
    
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
    
    captureSession.startRunning()
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
  
  private func configureSetUI() {
    
    view.backgroundColor = UIColor.black
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.frame
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    
    view.addSubview(activiyIndicator)
    activiyIndicator.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      activiyIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activiyIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  // MARK: - Handler
  func failed() {
    let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
    captureSession = nil
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
    activiyIndicator.startAnimating()
    networkServices.fetchBookInfomationFromKakao(type: .isbn, forSearch: code) { (isbnCode, bookDetailInfo) in
      guard let passBookInfoClosure = self.passBookInfoClosure else {
        return print("fail to get Closure")
      }
      passBookInfoClosure(isbnCode, bookDetailInfo)
    }
    self.dismiss(animated: true, completion: {
      self.activiyIndicator.stopAnimating()
    })
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  // 화면 중앙의 바코드 스캔 영역 생성
  func mask(viewToMask: UIView, maskRect: CGRect, invert: Bool = false) {
    let maskLayer = CAShapeLayer()
    let path = CGMutablePath()
    if (invert) { // invert True 시 Mask 반전
      path.addRect(CGRect(x:0,y:0,width:view.frame.size.width, height:view.frame.size.height))
    }
    path.addRect(maskRect)

    maskLayer.path = path
    if (invert) {
      maskLayer.fillRule = .evenOdd
    }

    // Set the mask of the view.
    viewToMask.layer.mask = maskLayer;
  }
  
}


