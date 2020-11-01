//
//  MainTableHeaderView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class MainTableHeaderView: UIView {

  // MARK: - Properties
  let profileImageView: CustomImageView = {
    let imageView = CustomImageView()
    let imageconf = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
    imageView.image = UIImage(systemName: "person.circle",
                              withConfiguration: imageconf)
    imageView.tintColor = CommonUI.titleTextColor
    imageView.layer.cornerRadius = (imageView.frame.height)/2
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "nickName"
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textColor = CommonUI.titleTextColor
    label.isUserInteractionEnabled = true
    return label
  }()
  
  let logoutButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Logout", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = CommonUI.titleTextColor
    button.layer.cornerRadius = 10
    button.sizeToFit()
    return button
  }()

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    
    [profileImageView, nameLabel, logoutButton].forEach{
      addSubview($0)
    }
    
    profileImageView.snp.makeConstraints{
      $0.top.equalTo(self)
      $0.leading.equalTo(self).offset(20)
      $0.width.height.equalTo(70)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
      $0.centerY.equalTo(profileImageView)
    }
    
    logoutButton.snp.makeConstraints{
      $0.centerY.equalTo(profileImageView)
      $0.trailing.equalTo(self).offset(-20)
      $0.width.equalTo(80)
      $0.height.equalTo(40)
    }

  }
  
  func configureHeaderView(profileImageUrlString: String?, userName: String?, isHiddenLogoutButton: Bool) {
    if let profileImageUrlString = profileImageUrlString { // 사용자 데이터에 이미지가 있는 경우 이미지 추가 // 없으면 기본 설정 값
      profileImageView.loadImage(urlString: profileImageUrlString)
      profileImageView.layer.cornerRadius = (profileImageView.frame.size.width)/2
      profileImageView.clipsToBounds = true
    }
    
    if let userName = userName {
      nameLabel.text = userName
    }
  }
}
