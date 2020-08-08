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

  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "SwiftUI")
    imageView.layer.cornerRadius = 25
    imageView.clipsToBounds = true
    return imageView
  }()
  
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
    button.sizeToFit()
    return button
  }()
  
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
      $0.top.leading.equalTo(self).offset(20)
      $0.width.height.equalTo(50)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
      $0.centerY.equalTo(profileImageView)
    }
    
    logoutButton.snp.makeConstraints{
      $0.top.equalTo(self).offset(20)
      $0.trailing.equalTo(self).offset(-20)
      $0.width.equalTo(100)
      $0.height.equalTo(40)
    }
  }
  
}
