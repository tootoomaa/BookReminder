//
//  AddCommentVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/11.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import MobileCoreServices

class AddCommentVC: UIViewController {
  
  // MARK: - Properties
  var markedBookInfo: BookDetailInfo?
  var keyboardUpChecker: Bool = false
  var tempKeyboardHeight: CGFloat = 0
  var isMultibuttomActive: Bool = false
  var isDrawing = false
  var isUserInputText: Bool = false {
    didSet {
      if !isUserInputText {
        addCommentView.configureMultiButton(systemImageName: "plus")
      } else {
        addCommentView.configureMultiButton(systemImageName: "square.and.arrow.up.fill")
      }
    }
  }
  
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
    view.multiButton.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    //    view..addTarget(self, action: #selector(tabFeatureButton(_:)), for: .touchUpInside)
    view.pagetextField.delegate = self
    
    return view
  }()
  
  lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSetUI()
    
    multiButtonAppear()
    
  }
  
  override func loadView() {
    view = addCommentView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = false
    
    //keyboard 입력에 따른 화면 올리는 Notification 설정
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
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
  
  
  // MARK: - Button Handler
  @objc func tabMultiButton() {
    let view = self.addCommentView
    
    guard !isUserInputText else {
      
      if let errorMessage = userInputDataCheker() {
        
        let errorAlert = UIAlertController(title: "Comment 내용 오류", message: errorMessage, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
        errorAlert.addAction(okButton)
        present(errorAlert, animated: true, completion: nil)
        
        return
      }
      
      let alertController = UIAlertController(title: "Comment", message: "이 Comment을 저장 하시겠습니까?", preferredStyle: .alert)
      let uploadAction = UIAlertAction(title: "저장", style: .default) { _ in
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let markedBookInfo = self.markedBookInfo else { return }
        guard let isbnCode = markedBookInfo.isbn else { return }
        
        self.uploadCommentData(uid: uid, isbnCode: isbnCode)
        self.updateCommentStatics(uid: uid, isbnCode: isbnCode)
        self.navigationController?.popViewController(animated: true)
      }
      let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: { _ in })
    
      alertController.addAction(uploadAction)
      alertController.addAction(cancelAction)
      
      present(alertController, animated: true, completion: nil)
      
      return
    }
    
    if !isMultibuttomActive {
      UIView.animate(withDuration: 0.5) {
        view.multiButton.transform = view.multiButton.transform.rotated(by: -(.pi/4*3))
      }
      //barcode -> bookSearch -> delete
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
          view.cameraButton.center.y -= view.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
          view.photoAlbumButton.center.y -= view.featureButtonSize*1.5
          view.photoAlbumButton.center.x -= view.featureButtonSize*1.5
          //          self.bookSearchButton.transform = .init(scaleX: 2, y: 2)
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
          view.deleteBookButton.center.x -= view.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          view.cameraButton.center.y += view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          view.photoAlbumButton.center.y += view.bounceDistance
          view.photoAlbumButton.center.x += view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          view.deleteBookButton.center.x += view.bounceDistance
        }
      })
    } else {
      UIView.animate(withDuration: 0.5) {
        view.multiButton.transform = view.multiButton.transform.rotated(by: .pi/4*3)
      }
      // delete -> bookSearch -> barcode
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        // 바운드
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
          view.deleteBookButton.center.x -= view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
          view.photoAlbumButton.center.y -= view.bounceDistance
          view.photoAlbumButton.center.x -= view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1) {
          view.cameraButton.center.y -= view.bounceDistance
        }
        // 사라짐
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
          view.deleteBookButton.center.x += view.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
          view.photoAlbumButton.center.y += view.featureButtonSize*1.5
          view.photoAlbumButton.center.x += view.featureButtonSize*1.5
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
          view.cameraButton.center.y += view.featureButtonSize*2
        }
      })
    }
    isMultibuttomActive.toggle()
  }
  
  private func multiButtonAppear() {
    //multi Button 에니메이션 처리
    UIView.animate(withDuration: 0.5) {
      [self.addCommentView.cameraButton, self.addCommentView.photoAlbumButton, self.addCommentView.deleteBookButton, self.addCommentView.multiButton].forEach{
        $0.center.x = $0.center.x - 100
      }
    }
  }
  
  // multiButton 에니메이션 초기화
  func initializationMultiButton() {
    let view = self.addCommentView
    
    isMultibuttomActive = false
    UIView.animate(withDuration: 0.5) {
      
      view.deleteBookButton.center.x += view.featureButtonSize*2 - view.bounceDistance
      view.photoAlbumButton.center.y += view.featureButtonSize*1.5 - view.bounceDistance
      view.photoAlbumButton.center.x += view.featureButtonSize*1.5 - view.bounceDistance
      view.cameraButton.center.y += view.featureButtonSize*2 - view.bounceDistance
      
      view.multiButton.transform = .identity
    }
  }
  
  @objc func tabPhotoAlnum() {
    imagePicker.sourceType = .savedPhotosAlbum // 차이점 확인하기
    imagePicker.mediaTypes = [kUTTypeImage] as [String] // 이미지, 사진 둘다 불러오기
    present(imagePicker, animated: true,completion: {
      self.initializationMultiButton()
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
      self.initializationMultiButton()
    })
  }
  // MARK: - Handler
  
  private func userInputDataCheker() -> String? {
    var checker = false
    var errorMessage = "\n"
    
    if addCommentView.captureImageView.image == nil {
      errorMessage.append("캡쳐한 이미지가 없습니다. \n")
      checker = true
    }
    if addCommentView.pagetextField.text == nil {
      errorMessage.append("Page가 입력되지 않았습니다.\n")
      checker = true
    } else {
      
      if (Int(addCommentView.pagetextField.text!) == nil) {
        errorMessage.append("Page에 숫자를 입력해주세요.\n")
        checker = true
      }
    }
    
    print(addCommentView.myTextView.text.count)
    
    if addCommentView.myTextView.text.count == 0 {
      errorMessage.append("Comment가 입력되지 않았습니다.\n")
      checker = true
    }
    return checker == true ? errorMessage : nil
  }
  
  
  // MARK: - Keyboard Handler
  @objc func keyboardWillAppear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
      if keyboardUpChecker == false {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.addCommentView.frame.origin.y -= keyboardHeight
        tempKeyboardHeight = keyboardHeight
        isUserInputText = true
        keyboardUpChecker = true
      }
    }
  }
  
  @objc func keyboardWillDisappear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      if keyboardUpChecker == true {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.addCommentView.frame.origin.y += keyboardHeight
        tempKeyboardHeight = keyboardHeight
        isUserInputText = false
        keyboardUpChecker = false
      }
    }
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddCommentVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
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

// MARK: - UITextFieldDelegate
extension AddCommentVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    addCommentView.myTextView.becomeFirstResponder()
    isUserInputText = true
    return true
  }
}

// MARK: - Network Handler
extension AddCommentVC {
  
  private func uploadCommentData(uid: String, isbnCode: String) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let markedBookInfo = markedBookInfo else { return }
    guard let isbnCode = markedBookInfo.isbn else { return }
    guard let uploadImage = addCommentView.captureImageView.image,
          let pageString = addCommentView.pagetextField.text,
          let myComment = addCommentView.myTextView.text else { return }
    
    guard let uploadImageDate = uploadImage.jpegData(compressionQuality: 0.5) else { return }
    
    let creationDate = Int(NSDate().timeIntervalSince1970)
    let filename = NSUUID().uuidString
    
    STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { (metadata, error) in
      if let error = error {
        print("error",error.localizedDescription)
        return
      }
      
      let uploadImageRef = STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename)
      uploadImageRef.downloadURL { (url, error) in
        if let error = error { print("Error", error.localizedDescription); return }
        guard let url = url else { return }
        
        let value = [
          "captureImageUrl": url.absoluteString,
          "page": pageString,
          "creationDate": creationDate,
          "myComment": myComment
        ] as Dictionary<String, AnyObject>
        
        DB_REF_COMMENT.child(uid).child(isbnCode).childByAutoId().updateChildValues(value)
      }
    }
  }
  
  private func updateCommentStatics(uid: String, isbnCode: String) {
    
    DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let commentCount = snapshot.value as? Int else { return }
      DB_REF_COMMENT_STATICS.child(uid).updateChildValues([isbnCode: commentCount + 1])
      
    }
  }
}

