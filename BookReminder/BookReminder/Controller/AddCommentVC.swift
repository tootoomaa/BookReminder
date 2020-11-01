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
  var markedBookInfo: Book?
  var keyboardUpChecker: Bool = false
  var tempKeyboardHeight: CGFloat = 0
  var isMultibuttomActive: Bool = false
  var isDrawing = false
  var isScrolled = false
  var isUserInputText: Bool = false {
    didSet {
      if !isUserInputText {
         addCommentView.configureMultiButton(systemImageName: "plus")
      } else {
        addCommentView.configureMultiButton(systemImageName: "square.and.arrow.up.fill")
      }
    }
  }
  // editing Comment
  var isCommentEditing: Bool = false {
    didSet {
      addCommentView.isCommentEditing = isCommentEditing
      view = addCommentView
    }
  }
  var commentInfo: Comment?
  
  // drwaing
  let colorSet: [UIColor] = [#colorLiteral(red: 0.999956429, green: 0.8100972176, blue: 0.8099586368, alpha: 0.2), #colorLiteral(red: 0.9965302348, green: 1, blue: 0.8521329761, alpha: 0.2), #colorLiteral(red: 0.7270262837, green: 0.7612577081, blue: 1, alpha: 0.2), #colorLiteral(red: 0.7421473861, green: 1, blue: 0.7957901359, alpha: 0.2), #colorLiteral(red: 1, green: 0.5636324883, blue: 0.7579589486, alpha: 0.2)]
  
  var startPoint: CGPoint? //= CGPoint(x: 0, y: 0)
  var lastPoint: CGPoint?// = CGPoint(x: 0, y: 0)
  var strokeColor: CGColor = #colorLiteral(red: 0.999956429, green: 0.8100972176, blue: 0.8099586368, alpha: 0.2)
  var strokes = [Stroke]()
  var backupImage: UIImage?
  
  struct  Stroke {
    let startPoint : CGPoint
    let endPoint : CGPoint
    let strokeColor : CGColor
  }
  
  let deviceSzie = UIScreen.main.bounds
  
  lazy var addCommentView: AddCommentView = {
    let view = AddCommentView()
    view.multiButton.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    view.cameraButton.addTarget(self, action: #selector(tabTakePhoto), for: .touchUpInside)
    view.photoAlbumButton.addTarget(self, action: #selector(tabPhotoAlnum), for: .touchUpInside)
    view.multiButton.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    view.saveButton.addTarget(self, action: #selector(tabSaveButton), for: .touchUpInside)
    view.contentSize = CGSize(width: deviceSzie.width, height: 1000)
    view.pagetextField.delegate = self
    view.isScrollEnabled = true
    view.delegate = self
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
    
    configureLayout()
    
    multiButtonAppear()
  
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
  
  private func configureLayout() {
    
    view.addSubview(addCommentView)
    
    addCommentView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(view)
    }
  }
  
  private func configureSetUI() {
    navigationItem.title = isCommentEditing == false ? markedBookInfo?.title : "Comment 수정"
    view.backgroundColor = .white
  }
  
  // MARK: - Drawing Handler
  private func touchesBeganHandler() {
    addCommentView.passTouchBeginData = { touches in
      if !self.isDrawing {
        self.isDrawing = true
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self.addCommentView.drawnImageView)
        self.startPoint = currentPoint
      }
    }
  }
  
  private func touchesMovedHandler() {
    initializationMultiButton()
    addCommentView.passTouchMoveData = { touches in
      guard self.isDrawing else { return }
      
      guard let touch = touches.first else { return }
      let currentPoint = touch.location(in: self.addCommentView.drawnImageView)
      
      // 움직이는 동안 현제 커서를 이어줌
      self.lastPoint = currentPoint
      
      // 변경되는 커서에 따라서 그림을 계속 그려줌
      UIGraphicsBeginImageContext(self.addCommentView.drawnImageView.frame.size)
      let context = UIGraphicsGetCurrentContext()!
      context.setLineWidth(10)
      context.setLineCap(.round)
      context.beginPath()
      if let startPoint = self.startPoint,
        let lastPoint = self.lastPoint {
        
        context.move(to: startPoint)
        context.addLine(to: lastPoint)
        context.setStrokeColor(self.strokeColor)
        context.strokePath()
        self.addCommentView.drawnImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.addCommentView.setNeedsLayout()
      }
    }
  }
  
  func touchesEndedHandler() {
    addCommentView.passTouchEndData = { touches in
      guard self.isDrawing else { return}
      self.isDrawing = false
      
      guard let touch = touches.first else {return}
      let currentPoint = touch.location(in: self.addCommentView.drawnImageView)
      if let lastPoint = self.lastPoint {
        let stroke = Stroke(startPoint: lastPoint, endPoint: currentPoint, strokeColor: self.strokeColor)
        
        self.strokes.append(stroke)
        self.addCommentView.setNeedsLayout()
        
        self.lastPoint = nil
        self.draw()
      }
    }
  }
  
  func draw() {
    UIGraphicsBeginImageContext(self.addCommentView.drawnImageView.frame.size)
    if let context = UIGraphicsGetCurrentContext() {
      context.setLineWidth(5)
      context.setLineCap(.round)
      
      if let stroke = strokes.last {
        context.beginPath()
        context.move(to: stroke.startPoint)
        context.addLine(to: stroke.endPoint)
        context.setStrokeColor(stroke.strokeColor)
        context.strokePath()
        
        addCommentView.captureImageView.image = addCommentView.captureImageView.screenShot
        UIGraphicsEndImageContext()
        self.addCommentView.setNeedsLayout()
      }
    }
  }
  
  // 이미지 하단의 색이랑 지움 버튼 컨트롤러
  private func drawColorChanger() {
    addCommentView.passColorButtonTag = { tag in
      if (0...4).contains(tag) {
        // 색상 변경
        self.strokeColor = self.colorSet[tag].cgColor
      } else {
        // 이미지 내 줄 삭제
        guard let backupImage = self.backupImage else { return }
        self.addCommentView.captureImageView.image = backupImage
        self.addCommentView.drawnImageView.image = backupImage
      }
    }
  }
  
  // MARK: - Button Handler
  @objc func tabMultiButton() {
    let view = self.addCommentView
    
    guard !isUserInputText else {
      // 사용자가 입력한 텍스트를 입력하는 도중에는 멀티 버튼을 저장 버튼으로 변경
      // save 관련 체크 및 저장 기능
      popSaveAlertController()
      return
    }
    
    // 멀티 버튼 활성화 에니메이션
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
          view.saveButton.center.x -= view.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          view.cameraButton.center.y += view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          view.photoAlbumButton.center.y += view.bounceDistance
          view.photoAlbumButton.center.x += view.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          view.saveButton.center.x += view.bounceDistance
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
          view.saveButton.center.x -= view.bounceDistance
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
          view.saveButton.center.x += view.featureButtonSize*2
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
  
  @objc private func tabSaveButton() {
    popSaveAlertController()
  }
  
  private func popSaveAlertController() {
    // 사용자가 입력상태를 모두 마치고 멀티버튼을 눌렀을때
    if let errorMessage = userInputDataCheker() {
      
      let errorAlert = UIAlertController(title: "Comment 내용 오류", message: errorMessage, preferredStyle: .alert)
      let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
      errorAlert.addAction(okButton)
      present(errorAlert, animated: true, completion: nil)
      
      return
    }
    
    var alertString: String = ""
    if isCommentEditing {
      // 사용자가 Comment 수정 모드로 들어온 경우
      alertString = "수정"
    } else {
      // 사용자가 Comment 추가 모드로 들어온 경우
      alertString = "추가"
    }
    
    let alertController = UIAlertController(title: "Comment", message: "이 Comment을 \(alertString) 하시겠습니까?", preferredStyle: .alert)
    let uploadAction = UIAlertAction(title: "\(alertString)", style: .default) { _ in
      
      guard let uid = Auth.auth().currentUser?.uid else { return }
      guard let markedBookInfo = self.markedBookInfo else { return }
      guard let isbnCode = markedBookInfo.isbn else { return }
      
      if self.isCommentEditing == true {
        // 기존 Comment 수정
        guard let commentInfo = self.commentInfo else { return }
        self.updateBeforeComment(uid: uid, isbnCode: isbnCode, updateCommentInfo: commentInfo)
      } else {
        // 신규 Comment 업데이트
        self.uploadCommentData(uid: uid, isbnCode: isbnCode)
        Database.commentCountHandler(uid: uid, isbnCode: isbnCode, plusMinus: .plus)
      }
      
      self.navigationController?.popViewController(animated: true)
    }
    
    let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: { _ in })
    
    alertController.addAction(uploadAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func multiButtonAppear() {
    //multi Button 에니메이션 처리, 화면 밖에서 안으로 들어옴
    UIView.animate(withDuration: 0.5) {
      [self.addCommentView.cameraButton, self.addCommentView.photoAlbumButton, self.addCommentView.saveButton, self.addCommentView.multiButton].forEach{
        $0.center.x = $0.center.x - 100
      }
    }
  }
  
  // multiButton 에니메이션 초기화
  func initializationMultiButton() {
    let view = self.addCommentView
    
    isMultibuttomActive = false
    
    view.saveButton.center.x = view.multiButton.center.x
    view.photoAlbumButton.center.y = view.multiButton.center.y
    view.photoAlbumButton.center.x = view.multiButton.center.x
    view.cameraButton.center.y = view.multiButton.center.y

    view.multiButton.transform = .identity
  }
  
  @objc func tabPhotoAlnum() {
    imagePicker.sourceType = .savedPhotosAlbum // 차이점 확인하기
    imagePicker.mediaTypes = [kUTTypeImage] as [String] // 이미지 불러오기
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
        view.frame.origin.y -= keyboardHeight
        tempKeyboardHeight = keyboardHeight
        initializationMultiButton()
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
        view.frame.origin.y += keyboardHeight
        tempKeyboardHeight = keyboardHeight
        if !isCommentEditing { // 사진 수정 방지 기능
          isUserInputText = false
        }
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
      let cripImage = info[.cropRect]  as? UIImage
      let selectedImage = cripImage ?? editedImage ?? originalImage
      addCommentView.captureImageView.image = selectedImage
      backupImage = selectedImage                               // 백업 이미지 저장
    }
    dismiss(animated: true, completion: {
      self.touchesBeganHandler()
      self.touchesEndedHandler()
      self.touchesMovedHandler()
      self.drawColorChanger()
    })
  }
}

// MARK: - UITextFieldDelegate
extension AddCommentVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    addCommentView.myTextView.becomeFirstResponder()
    self.addCommentView.frame.origin.y -= 100
    isUserInputText = true
    return true
  }
}

// MARK: - UITextViewDelegate
extension AddCommentVC: UITextViewDelegate {


}

// MARK: - Network Handler
extension AddCommentVC {
  
  private func uploadCommentData(uid: String, isbnCode: String) {
    
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
          "myComment": myComment,
          "captureImageFilename": filename
        ] as Dictionary<String, AnyObject>
        
        DB_REF_COMMENT.child(uid).child(isbnCode).childByAutoId().updateChildValues(value)
      }
    }
  }
  
  private func updateBeforeComment(uid: String, isbnCode: String, updateCommentInfo: Comment) {
    
    // 기존 데이터 사용
    guard let commentUid = updateCommentInfo.commentUid,
          let url = updateCommentInfo.captureImageUrl,
          let creationDate = updateCommentInfo.creationDate,
          let captureImageFilename = updateCommentInfo.captureImageFilename else { return }
          
    // 업데이트 된 데이터 사용
    guard let pageString = addCommentView.pagetextField.text,
          let myComment = addCommentView.myTextView.text else { return }
    
    let value = [
      "captureImageUrl": url,
      "page": pageString,
      "creationDate": creationDate,
      "myComment": myComment,
      "captureImageFilename": captureImageFilename
    ] as Dictionary<String, AnyObject>
    
    DB_REF_COMMENT.child(uid).child(isbnCode).child(commentUid).updateChildValues(value)
  }
}


extension AddCommentVC: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isDrawing {
      addCommentView.isScrollEnabled = false
    } else {
      addCommentView.isScrollEnabled = true
    }
  }
}
