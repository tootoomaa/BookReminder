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
  
  var multibuttomActive: Bool = false
  let multiButtonSize: CGFloat = 70
  let featureButtonSize: CGFloat = 50
  let bounceDistance: CGFloat = 25
  
  private lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  
  let captureImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .systemGray4
    return imageView
  }()
  
  lazy var multiButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
    let buttonImage = UIImage(systemName: "plus", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = CommonUI.mainBackgroudColor
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = multiButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    return button
  }()
  
  lazy var cameraButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "camera.fill", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.999982059, green: 0.6622204781, blue: 0.1913976967, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabTakePhoto), for: .touchUpInside)
    return button
  }()
  
  lazy var photoAlbumButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "photo.fill", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.8973528743, green: 0.9285049438, blue: 0.7169274688, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabPhotoAlnum), for: .touchUpInside)
    return button
  }()
  
  
  lazy var deleteBookButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "delete.right", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.5455855727, green: 0.8030222058, blue: 0.8028761148, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    //    button.addTarget(self, action: #selector(tabFeatureButton(_:)), for: .touchUpInside)
    return button
  }()
  
  let myThinkLabel: UILabel = {
    let label = UILabel()
    label.text = "내 생각.."
    return label
  }()
  
  lazy var pagetextField: UITextField = {
    let textfield = UITextField()
    textfield.layer.borderWidth = 2
    textfield.layer.borderColor = UIColor.systemGray3.cgColor
    textfield.autocorrectionType = .no
    textfield.autocapitalizationType = .none
    textfield.keyboardType = .numbersAndPunctuation
    textfield.textAlignment = .center
    textfield.returnKeyType = .next
    textfield.delegate = self
    return textfield
  }()
  
  let pageLabel: UILabel = {
    let label = UILabel()
    label.text = "Page"
    return label
  }()
  
  let myTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .systemGray6
    textView.autocorrectionType = .no
    textView.autocapitalizationType = .none
    textView.autoresizingMask = .flexibleHeight
    textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    textView.font = .systemFont(ofSize: 15)
    return textView
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSetUI()
    
    configureLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = false
    
    //multi Button 에니메이션 처리
    UIView.animate(withDuration: 0.5) {
      [self.cameraButton, self.photoAlbumButton, self.deleteBookButton, self.multiButton].forEach{
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
      [self.cameraButton, self.photoAlbumButton, self.deleteBookButton, self.multiButton].forEach{
        $0.center.x = $0.center.x + 100
      }
    }
    
    //keyboard 입력에 따른 화면 올리는 Notification 설정 해제
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
  }

  private func hideKeyBoard() {
    self.view.endEditing(true)
  }
  
  private func configureSetUI() {
    navigationItem.title = markedBookInfo?.title
    
    view.backgroundColor = .white
  }
  
  private func configureLayout() {
    
    [captureImageView, myThinkLabel, pagetextField, pageLabel, myTextView].forEach{
      view.addSubview($0)
    }
    
    [cameraButton, photoAlbumButton, deleteBookButton, multiButton].forEach{
      view.addSubview($0)
    }
    
    let safeGuide = view.safeAreaLayoutGuide
    
    captureImageView.snp.makeConstraints{
      $0.top.equalTo(safeGuide.snp.top).offset(16)
      $0.leading.equalTo(safeGuide.snp.leading).offset(16)
      $0.trailing.equalTo(safeGuide).offset(-16)
      $0.height.equalTo(captureImageView.snp.width).multipliedBy(0.7)
    }
    
    // stakcView
    let stackView = configureStakcView()
    stackView.snp.makeConstraints{
      $0.top.equalTo(captureImageView.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(captureImageView)
    }
    
    myThinkLabel.snp.makeConstraints{
      $0.top.equalTo(stackView.snp.bottom).offset(20)
      $0.leading.equalTo(stackView)
      $0.height.equalTo(40)
    }
    
    pageLabel.snp.makeConstraints{
      $0.top.equalTo(stackView.snp.bottom).offset(20)
      $0.trailing.equalTo(stackView)
      $0.height.equalTo(40)
    }
    
    pagetextField.snp.makeConstraints{
      $0.top.equalTo(stackView.snp.bottom).offset(20)
      $0.trailing.equalTo(pageLabel.snp.leading).offset(-10)
      $0.centerY.equalTo(pageLabel.snp.centerY)
      $0.width.equalTo(50)
      $0.height.equalTo(30)
    }
    
    myTextView.snp.makeConstraints{
      $0.top.equalTo(myThinkLabel.snp.bottom).offset(5)
      $0.leading.trailing.equalTo(captureImageView)
      $0.bottom.equalTo(safeGuide).offset(-10)
    }
    
    //multi Button
    multiButton.snp.makeConstraints{
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-20)
      $0.bottom.equalTo(safeGuide.snp.bottom).offset(-20)
      $0.width.height.equalTo(multiButtonSize)
    }
    
    [cameraButton, photoAlbumButton, deleteBookButton].forEach{
      $0.snp.makeConstraints{
        $0.centerX.equalTo(multiButton.snp.centerX)
        $0.centerY.equalTo(multiButton.snp.centerY)
        $0.width.height.equalTo(featureButtonSize)
      }
    }
  }
  
  private func configureStakcView() -> UIStackView {
    var stackViewArray: [UIView] = []
    
    [#colorLiteral(red: 0.999956429, green: 0.8100972176, blue: 0.8099586368, alpha: 1), #colorLiteral(red: 0.9965302348, green: 1, blue: 0.8521329761, alpha: 1), #colorLiteral(red: 0.7270262837, green: 0.7612577081, blue: 1, alpha: 1), #colorLiteral(red: 0.7421473861, green: 1, blue: 0.7957901359, alpha: 1), #colorLiteral(red: 1, green: 0.5636324883, blue: 0.7579589486, alpha: 1), "clear"].forEach{
      let button = UIButton()
      if let imageName = $0 as? String {
        let imageConfigrue = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        button.setImage(UIImage(systemName: imageName,
                                withConfiguration: imageConfigrue),
                        for: .normal)
        button.backgroundColor = .white
        button.imageView?.tintColor = .black
      } else {
        button.backgroundColor = $0 as? UIColor
      }
      
      button.layer.cornerRadius = 10
      button.clipsToBounds = true
      
      stackViewArray.append(button)
    }
    
    let stackView = UIStackView(arrangedSubviews: stackViewArray)
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 20
    stackView.alignment = .center
    view.addSubview(stackView)
    return stackView
  }
  
  // MARK: - Handler
  
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
  
  @objc func tabMultiButton() {
    
    if !multibuttomActive {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: -(.pi/4*3))
      }
      //barcode -> bookSearch -> delete
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
          self.cameraButton.center.y -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
          self.photoAlbumButton.center.y -= self.featureButtonSize*1.5
          self.photoAlbumButton.center.x -= self.featureButtonSize*1.5
          //          self.bookSearchButton.transform = .init(scaleX: 2, y: 2)
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
          self.deleteBookButton.center.x -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          self.cameraButton.center.y += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          self.photoAlbumButton.center.y += self.bounceDistance
          self.photoAlbumButton.center.x += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          self.deleteBookButton.center.x += self.bounceDistance
        }
      })
      
    } else {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: .pi/4*3)
      }
      // delete -> bookSearch -> barcode
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        // 바운드
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
          self.deleteBookButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
          self.photoAlbumButton.center.y -= self.bounceDistance
          self.photoAlbumButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1) {
          self.cameraButton.center.y -= self.bounceDistance
        }
        // 사라짐
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
          self.deleteBookButton.center.x += self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
          self.photoAlbumButton.center.y += self.featureButtonSize*1.5
          self.photoAlbumButton.center.x += self.featureButtonSize*1.5
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
          self.cameraButton.center.y += self.featureButtonSize*2
        }
        
      })
    }
    multibuttomActive.toggle()
  }
  
  // multiButton 에니메이션 초기화
  func initializationMultiButton() {
    multibuttomActive = false
    UIView.animate(withDuration: 0.5) {
      
      self.deleteBookButton.center.x += self.featureButtonSize*2 - self.bounceDistance
      self.photoAlbumButton.center.y += self.featureButtonSize*1.5 - self.bounceDistance
      self.photoAlbumButton.center.x += self.featureButtonSize*1.5 - self.bounceDistance
      self.cameraButton.center.y += self.featureButtonSize*2 - self.bounceDistance
      
      self.multiButton.transform = .identity
      //      [self.multiButton, self.bookSearchButton, self.barcodeButton, self.deleteBookButton].forEach{
      //        $0.transform = .identity
      //      }
    }
  }
  
  @objc func keyboardWillAppear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  {
      if keyboardUpChecker == false {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.view.frame.origin.y -= keyboardHeight
        keyboardUpChecker = true
      }
    }
  }
  
  @objc func keyboardWillDisappear( noti: NSNotification ) {
    if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      self.view.frame.origin.y += keyboardHeight
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
      captureImageView.image = selectedImage
    }
    
    dismiss(animated: true, completion: nil)
  }
}

extension AddCommentVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    myTextView.becomeFirstResponder()
    return true
  }
  
}
