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

  let profileImageButton: UIButton = {
    let button = UIButton()
    let imageconf = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
    button.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus",
                            withConfiguration: imageconf), for: .normal)
    button.imageView?.tintColor = CommonUI.titleTextColor
//    imageView.layer.cornerRadius = 35
//    imageView.clipsToBounds = true
    return button
  }()
  
//    let profileImageView: UIImageView = {
//      let imageView = UIImageView()
//      imageView.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
//      imageView.tintColor = CommonUI.titleTextColor
//  //    imageView.layer.cornerRadius = 3]5
//  //    imageView.clipsToBounds = true
//      return imageView
//    }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "nickName"
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textColor = CommonUI.titleTextColor
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
  
  let detailProfileButton: UIButton = {
    let button = UIButton()
    let sysImageConf = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    button.setImage(UIImage(systemName: "line.horizontal.3", withConfiguration: sysImageConf), for: .normal)
    button.imageView?.tintColor = CommonUI.titleTextColor
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
    
    [profileImageButton, nameLabel, logoutButton, detailProfileButton].forEach{
      addSubview($0)
    }
    
    profileImageButton.snp.makeConstraints{
      $0.top.leading.equalTo(20)
      $0.width.height.equalTo(70)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(profileImageButton.snp.trailing).offset(20)
      $0.centerY.equalTo(profileImageButton)
    }
    
    logoutButton.snp.makeConstraints{
      $0.centerY.equalTo(profileImageButton)
      $0.trailing.equalTo(self).offset(-20)
      $0.width.equalTo(80)
      $0.height.equalTo(40)
    }
    
    detailProfileButton.snp.makeConstraints{
      $0.centerY.equalTo(profileImageButton)
      $0.trailing.equalTo(self).offset(-20)
    }
  }
  
  func configureHeaderView(image: Data?, userName: String?, isHiddenLogoutButton: Bool) {
    if let image = image { // 사용자 데이터에 이미지가 있는 경우 이미지 추가 // 없으면 기본 설정 값
      profileImageButton.setImage(UIImage(data: image), for: .normal)
      profileImageButton.imageView?.layer.cornerRadius = 35
      profileImageButton.imageView?.clipsToBounds = true
    }
    if let userName = userName {
      nameLabel.text = userName
    }
    
    logoutButton.isHidden = isHiddenLogoutButton
    detailProfileButton.isHidden = !isHiddenLogoutButton
  }
}
