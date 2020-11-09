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
import RxSwift
import RxCocoa

class AddCommentVC: UIViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  var addCommentVM: AddCommentViewModel?
  
  var keyboardUpChecker: Bool = false
  var tempKeyboardHeight: CGFloat = 0
  var isDrawing = false
  var isChangeCaptureImage = false
  var isUserInputText: Bool = false {
    didSet {
      if !isUserInputText {
        addCommentView.configureMultiButton(systemImageName: "plus")
      } else {
        addCommentView.configureMultiButton(systemImageName: "square.and.arrow.up.fill")
      }
      addCommentView.isUserInputText = self.isUserInputText
    }
  }
  
  // editing Comment
  var isCommentEditing: Bool = false {
    didSet {
      addCommentView.isCommentEditing = isCommentEditing
      navigationItem.title = "Comment"
    }
  }
  
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
  
  // MARK: - Life Cycle
  init( _ markedBookIsbnCode: String, _ comment: Comment?) {
    super.init(nibName: nil, bundle: nil)
    if let comment = comment {
      self.addCommentVM = AddCommentViewModel(comment)
    } else {
      let comment = Comment(commentUid: "", dictionary: Dictionary<String, AnyObject>())
      self.addCommentVM = AddCommentViewModel(comment)
    }
    
    self.addCommentVM?.bookIsbnCode = markedBookIsbnCode
    viewBinding()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    configureMultiButtonAction()
    
    multiButtonAppear()
  }
  
  override func loadView() {
    view = addCommentView
    addCommentView.frame = view.frame
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
  
  // MARK: - View Binding
  private func viewBinding() {
    
    addCommentView.pagetextField.rx.value.changed
      .subscribe(onNext: { [weak self] inputText in
        
        if let inputText = inputText {
          self?.addCommentVM?.newPageString = inputText
        }
        
      }).disposed(by: disposeBag)
    
    addCommentView.myTextView.rx.value.changed
      .subscribe(onNext: { [weak self] inputText in
        
        if let inputText = inputText {
          self?.addCommentVM?.newMyComment = inputText
        }
        
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Configure Buttom Actions
  private func configureMultiButtonAction() {
    addCommentView.passSaveButtonTap = { [weak self] in
      self?.popSaveAlertController()
    }
    addCommentView.cameraButton.addTarget(self, action: #selector(tabTakePhoto), for: .touchUpInside)
    addCommentView.photoAlbumButton.addTarget(self, action: #selector(tabPhotoAlnum), for: .touchUpInside)
    addCommentView.saveButton.addTarget(self, action: #selector(tabSaveButton), for: .touchUpInside)
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
    addCommentView.initializationMultiButton()
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
  
  @objc private func tabSaveButton() {
    popSaveAlertController()
  }
  
  private func popSaveAlertController() {
    // 사용자가 입력상태를 모두 마치고 멀티버튼을 눌렀을때
    if let errorMessage = userInputDataCheker() {
      let title = "Comment 내용 오류"
      let errorAlert = UIAlertController.defaultSetting(title: title, message: errorMessage)
      present(errorAlert, animated: true, completion: nil)
      return
    }
    
    var alertTitleString: String = ""
    if addCommentVM?.commentUid != "" {
      alertTitleString = "수정"
    } else {
      // 사용자가 Comment 추가 모드로 들어온 경우
      alertTitleString = "추가"
    }

    let alertController = UIAlertController(title: "\(alertTitleString)", message: "이 Comment을 \(alertTitleString) 하시겠습니까?", preferredStyle: .alert)
    
    let uploadAction = UIAlertAction(title: "\(alertTitleString)", style: .default) { [weak self] _ in
      
      guard let uploadImage = self?.addCommentView.captureImageView.image else {
        self?.presentErrorAlertVC()
        return
      }
      
      if self?.addCommentVM?.commentUid == "" {
        // 신규 Comment 등록
        self?.addCommentVM?.uploadNewCommentData(uploadImage)
        
        self?.navigationController?.popViewController(animated: true)
      } else {
        // 기존 Comment 수정
        
        self?.isChangeCaptureImage == true ?
          self?.addCommentVM?.updateBeforeComment(uploadImage) :
          self?.addCommentVM?.updateBeforeComment()
        
        self?.navigationController?.popViewController(animated: true)
      }
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
  @objc func tabPhotoAlnum() {
    imagePicker.sourceType = .savedPhotosAlbum // 차이점 확인하기
    imagePicker.mediaTypes = [kUTTypeImage] as [String] // 이미지 불러오기
    present(imagePicker, animated: true,completion: {
      self.addCommentView.initializationMultiButton()
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
    
    present(imagePicker, animated: true,completion: { [weak self] in
      self?.addCommentView.initializationMultiButton()
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
  
  private func presentErrorAlertVC() {
    let title = "네트워트 오류 발생"
    let message = "네트워크 문제로 오류가 발생하였습니다. 잠시후에 재시도 부탁드립니다."
    
    present(UIAlertController.defaultSetting(title: title, message: message),
            animated: true,
            completion: nil)
  }
  
  // MARK: - Keyboard Handler
  @objc func keyboardWillAppear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
      if keyboardUpChecker == false {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        view.frame.origin.y -= keyboardHeight
        tempKeyboardHeight = keyboardHeight
        addCommentView.initializationMultiButton()
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
      print("Change Imgae!!!!!")
      self.isChangeCaptureImage = true
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

extension AddCommentVC: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isDrawing {
      addCommentView.isScrollEnabled = false
    } else {
      addCommentView.isScrollEnabled = true
    }
  }
}
