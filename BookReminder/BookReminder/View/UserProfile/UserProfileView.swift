////
////  UserProfileView.swift
////  BookReminder
////
////  Created by 김광수 on 2020/08/13.
////  Copyright © 2020 김광수. All rights reserved.
////
//
//import UIKit
//
//class UserProfileView: UIView {
//  
//  let profileImageView: UIImageView = {
//    let imageView = UIImageView()
//    imageView.image = UIImage(systemName: "person.circle.fill")
//    imageView.tintColor = CommonUI.titleTextColor
//    imageView.layer.cornerRadius = 50
//    imageView.clipsToBounds = true
//    return imageView
//  }()
//  
//  let nameLabel: UILabel = {
//    let label = UILabel()
//    label.text = "nickName"
//    label.font = .systemFont(ofSize: 20, weight: .medium)
//    label.textColor = CommonUI.titleTextColor
//    return label
//  }()
//  
//  let logoutButton: UIButton = {
//    let button = UIButton(type: .system)
//    button.setTitle("Logout", for: .normal)
//    button.setTitleColor(.white, for: .normal)
//    button.backgroundColor = CommonUI.titleTextColor
//    button.sizeToFit()
//    return button
//  }()
//  
//  // MARK: - Init
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    
//    configureLayout()
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  private func configureLayout() {
//    
//    let safeGuide = self.safeAreaLayoutGuide
//    
//    [profileImageView, nameLabel, logoutButton].forEach{
//      addSubview($0)
//    }
//    
//    profileImageView.snp.makeConstraints{
//      $0.top.equalTo(30)
//      $0.leading.equalTo(20)
//      $0.width.height.equalTo(100)
//    }
//    
//    nameLabel.snp.makeConstraints{
//      $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
//      $0.centerY.equalTo(profileImageView)
//    }
//    
//    logoutButton.snp.makeConstraints{
//      $0.centerY.equalTo(profileImageView)
//      $0.trailing.equalTo(safeGuide).offset(-30)
//    }
//  }
//}
