//
//  ScannerView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/31.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerView: UIView {
  // MARK: - Properties
  var scannerVC: ScannerVC?
  var captureSession: AVCaptureSession!
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  let activiyIndicator = UIActivityIndicatorView(style: .large)
  
  let backgroundView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    return view
  }()
  
  let maskWidth = UIScreen.main.bounds.width*0.9
  lazy var mastheight = maskWidth*0.63
  lazy var rect = CGRect(x: UIScreen.main.bounds.width*0.05,
                    y: UIScreen.main.bounds.height/2-mastheight/2,
                    width: maskWidth,
                    height: mastheight)
  
  // MARK: - Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .clear
    
    captureSession = AVCaptureSession()
    
    configureSetUI()
    
    configureBackgroundView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Setting UI
  private func configureSetUI() {
    configurePreviewLayer()
    configureActivityIndicator()
  }
  
  private func configurePreviewLayer() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    previewLayer.videoGravity = .resizeAspectFill
    layer.insertSublayer(previewLayer, at: 0)
  }
  
  private func configureActivityIndicator() {
    addSubview(activiyIndicator)
    activiyIndicator.snp.makeConstraints {
      $0.centerY.centerX.equalToSuperview()
    }
  }
  
  // MARK: - BackgroundView Setting
  private func configureBackgroundView() {
    mask(viewToMask: backgroundView, maskRect: rect, invert: true)
    
    addSubview(backgroundView)
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func mask(viewToMask: UIView, maskRect: CGRect, invert: Bool = false) {
    let maskLayer = CAShapeLayer()
    let path = CGMutablePath()
    if invert { // invert True 시 Mask 반전
      path.addRect(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    path.addRect(maskRect)
    maskLayer.path = path
    if invert {
      maskLayer.fillRule = .evenOdd
    }
    // Set the mask of the view.
    viewToMask.layer.mask = maskLayer
  }
  
}
