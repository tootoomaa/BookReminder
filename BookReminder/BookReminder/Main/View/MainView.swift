//
//  MainView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit

class MainView: UIView {
  
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
  
  let detailProfileButton: UIButton = {
    let button = UIButton()
    let sysImageConf = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    button.setImage(UIImage(systemName: "line.horizontal.3", withConfiguration: sysImageConf), for: .normal)
    button.imageView?.tintColor = CommonUI.titleTextColor
    return button
  }()
  
  let sectionTitleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 30)
    label.textColor = CommonUI.titleTextColor
    label.text = "  Reading..."
    return label
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  let mainConrtollMenu = MainControllMenu()
  
  // MARK: - Life cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    configureTopHeaderView()
    
    configureCollectionView()
    
    configureMainConrollMenu()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureTopHeaderView() {
    
    [profileImageView, nameLabel, detailProfileButton, sectionTitleLabel].forEach{
      addSubview($0)
    }
    
    profileImageView.snp.makeConstraints{
      $0.top.equalTo(safeAreaLayoutGuide).offset(10)
      $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
      $0.width.height.equalTo(70)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(profileImageView.snp.trailing).offset(20)
      $0.centerY.equalTo(profileImageView)
    }

    
    detailProfileButton.snp.makeConstraints{
      $0.centerY.equalTo(profileImageView)
      $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
    }
    
    sectionTitleLabel.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10)
      $0.leading.equalTo(safeAreaLayoutGuide).offset(10)
      $0.height.equalTo(60)
    }
  }
  
  private func configureCollectionView() {
    addSubview(collectionView)

    collectionView.snp.makeConstraints{
      $0.top.equalTo(sectionTitleLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(safeAreaLayoutGuide)
      $0.height.equalTo(200)
    }
  }
  
  private func configureMainConrollMenu() {
    
    addSubview(mainConrtollMenu)
    
    mainConrtollMenu.snp.makeConstraints {
      $0.top.equalTo(collectionView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(180)
    }
  }
}

