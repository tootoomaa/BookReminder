//
//  AddCommentVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/11.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import MobileCoreServices

class AddCommentVC: UIViewController {
  
  // MARK: - Properties
  var markedBookInfo: BookDetailInfo?
  var keyboardUpChecker: Bool = false
  var userInputTexting: Bool = false
  var isDrawing = false
  
  // drwaing
  var startPoint: CGPoint = CGPoint(x: 0, y: 0)
  var lastPoint: CGPoint = CGPoint(x: 0, y: 0)
  var strokeColor: CGColor = #colorLiteral(red: 0.6670694947, green: 0.4954431057, blue: 0.64269346, alpha: 0.2)
  var strokes = [Stroke]()
  
  struct  Stroke {
    let startPoint : CGPoint
    let endPoint : CGPoint
    let strokeColor : CGColor
  }
  
  lazy var addCommentView: AddCommentView = {
    let view = AddCommentView()
    view.multiButton.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    view.cameraButton.addTarget(self, action: #selector(tabTakePhoto), for: .touchUpInside)
    view.photoAlbumButton.addTarget(self, action: #selector(tabPhotoAlnum), for: .touchUpInside)
    //    view..addTarget(self, action: #selector(tabFeatureButton(_:)), for: .touchUpInside)
    view.pagetextField.delegate = self
    
    return view
  }()
  
  private lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSetUI()

  }
  
  override func loadView() {
    view = addCommentView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = false
    
    //multi Button 에니메이션 처리
    UIView.animate(withDuration: 0.5) {
      [self.addCommentView.cameraButton, self.addCommentView.photoAlbumButton, self.addCommentView.deleteBookButton, self.addCommentView.multiButton].forEach{
        $0.center.x = $0.center.x - 100
      }
    }
    
    //keyboard 입력에 따른 화면 올리는 Notification 설정
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    //multi Button 에니메이션 처리
    UIView.animate(withDuration: 0.5) {
      [self.addCommentView.cameraButton, self.addCommentView.photoAlbumButton, self.addCommentView.deleteBookButton, self.addCommentView.multiButton].forEach{
        $0.center.x = $0.center.x + 100
      }
    }
    
    //keyboard 입력에 따른 화면 올리는 Notification 설정 해제
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func configureSetUI() {
    navigationItem.title = markedBookInfo?.title
    
    view.backgroundColor = .white
  }
  
  // MARK: - Drawing Handler
  
  func touchesBeganHandler() {
    addCommentView.passTouchBeginData = { touches in
      if !self.isDrawing {
        self.isDrawing = true
        
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self.addCommentView.captureImageView)
        self.startPoint = currentPoint
      }
    }
  }
  
  func touchesMovedHandler() {
    addCommentView.passTouchMoveData = { touches in
      guard self.isDrawing else { return print("Aaa") }
      
      guard let touch = touches.first else {return print("cc") }
      let currentPoint = touch.location(in: self.addCommentView.drawImageView)
      
      // 움직이는 동안 현제 커서를 이어줌
      self.lastPoint = currentPoint
      
      // 변경되는 커서에 따라서 그림을 계속 그려줌
      UIGraphicsBeginImageContext(self.addCommentView.drawImageView.frame.size)
      let context = UIGraphicsGetCurrentContext()!
      
      context.setLineWidth(10)
      context.setLineCap(.round)
      context.beginPath()
      context.move(to: self.startPoint)
      context.addLine(to: self.lastPoint)
      context.setStrokeColor(self.strokeColor)
      print(self.lastPoint)
       context.strokePath()
//      self.draw(type: "end")
//      // 현재 콘텍스트에 그려진 이미지를 가지고 와서 이미지 뷰에 할당
         self.addCommentView.drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
//         // 그림 그리기를 끝냄
         UIGraphicsEndImageContext()
      
      self.addCommentView.setNeedsLayout()
    }
  }
  
  func touchesEndedHandler() {
    addCommentView.passTouchEndData = { touches in
      guard self.isDrawing else { return }
      self.isDrawing = false
      
      guard let touch = touches.first else { return }
      
      let currentPoint = touch.location(in: self.addCommentView.drawImageView)

      let stroke = Stroke(startPoint: self.startPoint, endPoint: currentPoint, strokeColor: self.strokeColor)
      self.strokes.append(stroke)
      
      self.draw(type: "end") // 전체 밑줄 그리기
      
      self.addCommentView.setNeedsLayout()
      self.lastPoint = CGPoint(x: 0, y: 0)
      self.startPoint = CGPoint(x: 0, y: 0)
    }
  }
  
  func draw(type: String) {
    UIGraphicsBeginImageContext(self.addCommentView.drawImageView.frame.size)
    let context = UIGraphicsGetCurrentContext()!
    
    context.setLineWidth(10)
    context.setLineCap(.round)
    context.beginPath()
  
    if type == "move" {
      context.move(to: startPoint)
      context.addLine(to: lastPoint)
      context.setStrokeColor(self.strokeColor)
      // 추가하 선을 콘텍스트에 그림
      context.strokePath()
    } else {
//      for strok in strokes {
      if let strok = strokes.last {
        let render = UIGraphicsImageRenderer(size: addCommentView.captureImageView.bounds.size)
        let image = render.image { context in
          context.cgContext.draw((addCommentView.captureImageView.image?.cgImage!)!, in: addCommentView.captureImageView.frame)
//          context.cgContext.setFillColor(UIColor.red.cgColor)
//          context.cgContext.setStrokeColor(UIColor.black.cgColor)
          context.cgContext.setLineWidth(10)
          context.cgContext.addRect(view.frame)
          context.cgContext.drawPath(using: .fillStroke)
        }
        // 커서의 위치를 (50,50)으로 이동
        context.move(to: strok.startPoint)
        // 시작 위치에서 (250,250)까지 선 추가
        context.addLine(to: strok.endPoint)
        // 선 색상 설정
        context.setStrokeColor(self.strokeColor)
        // 추가하 선을 콘텍스트에 그림
        
        self.addCommentView.drawImageView.image = image
        print("Draw")
        
        context.strokePath()
      }
    }
    
    // 현재 콘텍스트에 그려진 이미지를 가지고 와서 이미지 뷰에 할당
    // 그림 그리기를 끝냄
    UIGraphicsEndImageContext()
  }
  
  
  func erase() {
    strokes = []
    strokeColor = UIColor.black.cgColor
//    setNeedsDisplay() // ditampilkan ke layar
  }
  
  
  
  @objc func tabPhotoAlnum() {
    imagePicker.sourceType = .savedPhotosAlbum // 차이점 확인하기
    imagePicker.mediaTypes = [kUTTypeImage] as [String] // 이미지, 사진 둘다 불러오기
    //        imagePicker.mediaTypes = [kUTTypeImage as String] // 사진만 보여질 경우
    //        imagePicker.mediaTypes = [kUTTypeMovie as String] // 동영상만 보여질 경우
    /*
     photoLibray - 앨범을 선택하는 화면을 표시 후, 선택한 앨범에서 사진 선택
     camera - 새로운 사진 촬영
     savedPhotosAlbum - 최근에 찍은 사진들을 나열
     */
    
    present(imagePicker, animated: true,completion: {
      self.addCommentView.initializationMultiButton()
      self.touchesBeganHandler()
      self.touchesEndedHandler()
      self.touchesMovedHandler()
    })
  }
  
  @objc func tabTakePhoto() {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
    imagePicker.sourceType = .camera // sourceType 카메라 선택
    
    let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
    
    imagePicker.mediaTypes = mediaTypes ?? []
    imagePicker.mediaTypes = ["public.image"]
    //    imagePicker.mediaTypes = [kUTTypeImage] as [String]
    
    if UIImagePickerController.isFlashAvailable(for: .rear) {
      imagePicker.cameraFlashMode = .off
    }
    
    present(imagePicker, animated: true,completion: {
      self.addCommentView.initializationMultiButton()
    })
  }
  
  @objc func keyboardWillAppear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
      if keyboardUpChecker == false {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.addCommentView.frame.origin.y -= keyboardHeight
        keyboardUpChecker = true
      }
    }
  }
  
  @objc func keyboardWillDisappear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      self.addCommentView.frame.origin.y += keyboardHeight
      keyboardUpChecker = false
    }
  }
}

extension AddCommentVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    
    let mediaType = info[.mediaType] as! NSString
    if UTTypeEqual(mediaType, kUTTypeImage) {
      // handle Image Type
      let originalImage = info[.originalImage] as! UIImage    // 이미지를 가져옴
      let editedImage = info[.editedImage] as? UIImage        // editedImage
      let selectedImage = editedImage ?? originalImage
      addCommentView.captureImageView.image = selectedImage
    }
    dismiss(animated: true, completion: {
      self.touchesBeganHandler()
      self.touchesEndedHandler()
      self.touchesMovedHandler()
    })
  }
}

extension AddCommentVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    addCommentView.myTextView.becomeFirstResponder()
    return true
  }
}

