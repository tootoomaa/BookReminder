//
//  UserProfileView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class UserProfileView: UIView {
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
  
  let sectionLabel: UILabel = {
    let label = UILabel()
    label.text = "사용자 책 관련 통계"
    label.font = .boldSystemFont(ofSize: 20)
    return label
  }()
  
  let tableView = UITableView(frame: .zero, style: .plain)
  
  // MARK: - Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureTopUISetting()
    configureSectionLabel()
    configureTableViewSetting()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func configureTopUISetting() {
    
    [profileImageView, nameLabel, logoutButton].forEach{
      addSubview($0)
    }
    
    profileImageView.snp.makeConstraints{
      $0.top.equalTo(safeAreaLayoutGuide).offset(20)
      $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
      $0.width.height.equalTo(70)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
      $0.centerY.equalTo(profileImageView)
    }
    
    logoutButton.snp.makeConstraints{
      $0.centerY.equalTo(profileImageView)
      $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
      $0.width.equalTo(80)
      $0.height.equalTo(40)
    }
  }
  
  private func configureSectionLabel() {
    addSubview(sectionLabel)
    sectionLabel.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10)
      $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
      $0.trailing.equalTo(safeAreaLayoutGuide)
      $0.height.equalTo(50)
    }
  }
  
  private func configureTableViewSetting() {
    addSubview(tableView)
    tableView.snp.makeConstraints {
      $0.top.equalTo(sectionLabel.snp.bottom)
      $0.leading.trailing.equalTo(safeAreaLayoutGuide)
      $0.height.equalTo(300)
    }
  }
}
