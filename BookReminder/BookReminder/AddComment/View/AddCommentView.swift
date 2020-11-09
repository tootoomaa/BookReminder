//
//  AddCommentView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class AddCommentView: UIScrollView {
  
  // MARK: - Properties
  let multiButtonSize: CGFloat = 70
  let featureButtonSize: CGFloat = 50
  let bounceDistance: CGFloat = 25
  
  var passTouchBeginData: ((Set<UITouch>) -> ())?
  var passTouchMoveData: ((Set<UITouch>) -> ())?
  var passTouchEndData: ((Set<UITouch>) -> ())?
  var passColorButtonTag: ((Int)->())?
  var passSaveButtonTap: (()->())?
  
  var isMultibuttomActive: Bool = false
  var isUserInputText: Bool = false
  
  var colorButtonArray: [UIButton] = []
  
  var isCommentEditing = false {
    didSet {
      configureLayout()
      
      [multiButton, cameraButton, photoAlbumButton, saveButton].forEach {
        $0.isHidden = !isCommentEditing
      }
      
      colorButtonArray.forEach {
        $0.isHidden = !isCommentEditing
      }
      pagetextField.isEnabled = isCommentEditing
      pagetextField.isUserInteractionEnabled = isCommentEditing
      myTextView.isEditable = isCommentEditing
      myTextView.isUserInteractionEnabled = isCommentEditing
    }
  } // Comment 수정 모드를 통해 들어온 경우 stackview 제거
    
  let captureImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.backgroundColor = .systemGray4
    return imageView
  }()
  
  let drawnImageView: DrawnImageView = {
    let imageView = DrawnImageView(frame: .zero)
    imageView.backgroundColor = .none
    return imageView
  }()
  
  lazy var multiButton: UIButton = {
    let button = UIButton()
    button.imageView?.tintColor = .white
    button.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    button.backgroundColor = CommonUI.mainBackgroudColor
    button.layer.cornerRadius = multiButtonSize/2
    button.clipsToBounds = true
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
    return button
  }()
  
  lazy var saveButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "square.and.arrow.up.fill", withConfiguration: imageConfigure)
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.5455855727, green: 0.8030222058, blue: 0.8028761148, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
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
    textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    textView.font = .systemFont(ofSize: 15)
    textView.layer.cornerRadius = 20
    textView.clipsToBounds = true
    return textView
  }()
  
  // MARK: - Inti
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  
    backgroundColor = .white
    self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    configureMultiButton(systemImageName: "plus")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // touch Handler
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
    guard let passTouchBeginData = passTouchBeginData else { return }
    passTouchBeginData(touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let passTouchMoveData = passTouchMoveData else { return }
    passTouchMoveData(touches)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let passTouchEndData = passTouchEndData else { return }
    passTouchEndData(touches)
  }
  
  private func hideKeyBoard() {
    self.endEditing(true)
  }
  
  private func configureLayout() {
    
    [captureImageView, myThinkLabel, pagetextField, pageLabel, myTextView].forEach{
      self.addSubview($0)
    }
    
    captureImageView.addSubview(drawnImageView)
    
    captureImageView.snp.makeConstraints{
      $0.top.leading.equalTo(contentLayoutGuide).offset(20)
      $0.height.equalTo(captureImageView.snp.width).multipliedBy(1)
      $0.width.equalTo(UIScreen.main.bounds.width-40)
    }
    
    drawnImageView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(captureImageView)
    }
    
    // stakcView
    let stackView = configureStakcView()
    stackView.snp.makeConstraints{
      $0.top.equalTo(captureImageView.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(captureImageView)
      let height = isCommentEditing == false ? 0 : 40
      $0.height.equalTo(CGFloat(height))
    }

    [cameraButton, photoAlbumButton, saveButton, multiButton].forEach{
      self.addSubview($0)
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
      $0.bottom.equalTo(self.contentLayoutGuide).offset(-10)
      $0.height.equalTo(300)
    }
    
    //multi Button
    multiButton.snp.makeConstraints{
      $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-20)
      $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.width.height.equalTo(multiButtonSize)
    }
    
    [cameraButton, photoAlbumButton, saveButton].forEach{
      $0.snp.makeConstraints{
        $0.centerX.equalTo(multiButton.snp.centerX)
        $0.centerY.equalTo(multiButton.snp.centerY)
        $0.width.height.equalTo(featureButtonSize)
      }
    }
  }
  
  private func configureStakcView() -> UIStackView {
    var stackViewArray: [UIView] = []
    var count = 0
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
        
        // selected Sataue
        let imageConfigrue = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        button.setImage(UIImage(systemName: "checkmark", withConfiguration: imageConfigrue), for: .selected)
        button.imageView?.tintColor = .gray
        // nomal Status
        button.setTitle("", for: .normal)
        button.isSelected = false
      }
      if count == 0 {
        button.isSelected = true
      }
      button.layer.cornerRadius = 10
      button.clipsToBounds = true
      button.tag = count
      count += 1
      button.addTarget(self, action: #selector(tabColorButton(_:)), for: .touchUpInside)
      colorButtonArray.append(button)
      stackViewArray.append(button)
    }
    
    let stackView = UIStackView(arrangedSubviews: stackViewArray)
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 20
    stackView.alignment = .center
    self.addSubview(stackView)
    return stackView
  }
  
  // MARK: - configure MultiButton
  func configureMultiButton(systemImageName: String) {
    
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
    let buttonImage = UIImage(systemName: systemImageName, withConfiguration: imageConfigure)
    multiButton.setImage(buttonImage, for: .normal)
    multiButton.layer.cornerRadius = multiButtonSize/2
    multiButton.clipsToBounds = true
  }
  
  @objc private func tabColorButton(_ sender: UIButton) {
    guard let passColorButtonTag = passColorButtonTag else { return }
    passColorButtonTag(sender.tag)
    
    for index in 0..<colorButtonArray.count {
      colorButtonArray[index].isSelected = index == sender.tag ? true : false
    }
  }
  
  // MARK: - MultiButton Animation
  @objc func tabMultiButton() {
    
    guard !isUserInputText else {
      // 사용자가 입력한 텍스트를 입력하는 도중에는 멀티 버튼을 저장 버튼으로 변경
      // save 관련 체크 및 저장 기능
      if let passSaveButtonTap = passSaveButtonTap {
        passSaveButtonTap()
      }
      return
    }
    
    // 멀티 버튼 활성화 에니메이션
    if !isMultibuttomActive {
      UIView.animate(withDuration: 0.5) { [ unowned self] in
        self.multiButton.transform = self.multiButton.transform.rotated(by: -(.pi/4*3))
      }
      //barcode -> bookSearch -> delete
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) { [ unowned self] in
          self.cameraButton.center.y -= featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
          self.photoAlbumButton.center.y -= self.featureButtonSize*1.5
          self.photoAlbumButton.center.x -= self.featureButtonSize*1.5
          //          self.bookSearchButton.transform = .init(scaleX: 2, y: 2)
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
          self.saveButton.center.x -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          self.cameraButton.center.y += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          self.photoAlbumButton.center.y += self.bounceDistance
          self.photoAlbumButton.center.x += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          self.saveButton.center.x += self.bounceDistance
        }
      })
    } else {
      UIView.animate(withDuration: 0.5) { [unowned self] in
        self.multiButton.transform = multiButton.transform.rotated(by: .pi/4*3)
      }
      // delete -> bookSearch -> barcode
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        // 바운드
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) { [unowned self] in
          self.saveButton.center.x -= self.bounceDistance
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
          self.saveButton.center.x += self.featureButtonSize*2
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
    isMultibuttomActive.toggle()
  }
  
  func initializationMultiButton() {
    isMultibuttomActive = false
    
    saveButton.center.x = multiButton.center.x
    photoAlbumButton.center.y = multiButton.center.y
    photoAlbumButton.center.x = multiButton.center.x
    cameraButton.center.y = multiButton.center.y

    multiButton.transform = .identity
  }
}

