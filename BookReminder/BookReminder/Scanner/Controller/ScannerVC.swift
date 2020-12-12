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
  let scannerView = ScannerView()
  
  let networkServices = KakaoWebService()
  var saveBookClosure:((String, [String: AnyObject]) -> ())? // handle Result return closure
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureCameraSetting()
    
  }
  
  override func loadView() {
    view = scannerView
    scannerView.frame = view.frame
    scannerView.scannerVC = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if (scannerView.captureSession?.isRunning == false) {
      scannerView.captureSession.startRunning()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (scannerView.captureSession?.isRunning == true) {
      scannerView.captureSession.stopRunning()
    }
  }
  
  private func configureCameraSetting() {
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    let videoInput: AVCaptureDeviceInput
    
    do {
      videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    if (scannerView.captureSession.canAddInput(videoInput)) {
      scannerView.captureSession.addInput(videoInput)
    } else {
      failed()
      return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if (scannerView.captureSession.canAddOutput(metadataOutput)) {
      scannerView.captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
    } else {
      failed()
      return
    }
    
    scannerView.captureSession.startRunning()
  }
  
  // MARK: - Handler
  func failed() {
    let scanFailAlert = UIAlertController.defaultSetting(title: "스켄이 불가능합니다.",
                                                         message: "이 앱은 해당 바코드 대한 스캔기능을 지원하지 않습니다. 바코드를 확인해주세요")
    present(scanFailAlert, animated: true)
    scannerView.captureSession = nil
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    scannerView.captureSession.stopRunning()
    
    if let metadataObject = metadataObjects.first {
      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
      guard let stringValue = readableObject.stringValue else { return }
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
      found(code: stringValue)
    }
  }
  
  func found(code: String) {
    scannerView.activiyIndicator.startAnimating()
    networkServices.fetchBookInfomationFromKakao(type: .isbn, forSearch: code) { (isbnCode, bookDetailInfo) in
      guard let passBookInfoClosure = self.saveBookClosure else {
        return print("fail to get Closure")
      }
      passBookInfoClosure(isbnCode, bookDetailInfo)
    }
    self.dismiss(animated: true, completion: { [weak self] in
      self?.scannerView.activiyIndicator.stopAnimating()
    })
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
}





