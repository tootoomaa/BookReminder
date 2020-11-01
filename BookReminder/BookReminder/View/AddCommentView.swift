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
  
  var colorButtonArray: [UIButton] = []
  
  var isEditingMode = false {
    didSet {
      configureLayout()
      
      [multiButton, cameraButton, photoAlbumButton, saveButton].forEach {
        $0.isHidden = true
      }
      
      colorButtonArray.forEach {
        $0.isHidden = true
      }
      
      pagetextField.isUserInteractionEnabled = false
      myTextView.isUserInteractionEnabled = false
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
    
    configureLayout()
    
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
      let height = isEditingMode == false ? 0 : 40
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
}
