//
//  ViewController.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class MainVC: UIViewController {
  
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
//    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "SwiftUI")
    imageView.layer.cornerRadius = 25
    imageView.clipsToBounds = true
    return imageView
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "kks"
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
    button.addTarget(self, action: #selector(tabLogoutButton), for: .touchUpInside)
    return button
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "My Book Lists"
    label.font = .systemFont(ofSize: 30, weight: .medium)
    label.textColor = CommonUI.titleTextColor
    return label
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
    
    configureLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
    
  private func configureView() {
    
    view.backgroundColor = .white
    
    view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
  
  private func configureLayout() {
    
    [profileImageView, nameLabel, logoutButton, titleLabel].forEach{
      view.addSubview($0)
    }
    
    let safeGuide = view.safeAreaLayoutGuide

    profileImageView.snp.makeConstraints {
      $0.top.equalTo(safeGuide.snp.top).offset(16)
      $0.leading.equalTo(safeGuide.snp.leading).offset(16)
      $0.height.width.equalTo(50)
    }
    
    nameLabel.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
      $0.top.equalTo(profileImageView.snp.top)
    }
    
    logoutButton.snp.makeConstraints {
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-16)
      $0.centerY.equalTo(profileImageView.snp.centerY)
      $0.height.width.equalTo(50)
    }
    
    titleLabel.snp.makeConstraints{
      $0.top.equalTo(profileImageView.snp.bottom).offset(20)
      $0.leading.equalTo(profileImageView.snp.leading)
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(16)
    }
  }
  
  // MARK: - Handler
  
  @objc private func tabLogoutButton() {
    print("tab Logout Button")
    
    // Firebase 기반 계정 로그아웃
    if (Auth.auth().currentUser?.uid) != nil {
      let firebaseAuth = Auth.auth()
      do { // Firebase 계정 로그아웃
        try firebaseAuth.signOut()
        print("Success logout")
        
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
        
      } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
      }
    } else { //
      
    }
    
  }
}

extension MainVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    <#code#>
  }
}

