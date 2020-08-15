//
//  UserProfileVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/13.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class UserProfileVC: UITableViewController {
  
  var userProfileData: User?
  var userProfileImageData: Data?
  let mainTableHeaderView = MainTableHeaderView()
  
  let secionData = ["독서 관련", "기타 정보"]
  let aboutBookInfo = [
    ["등록 권수", "완독률", "comment 수", "권당 comment 수"],
    ["현재 버전", "오픈소스 라이센스"]
  ]
  
  lazy var checkDetailMenuString = aboutBookInfo[secionData.count-1].last
  
  let tableSectionLabel: UILabel = {
    let label = UILabel()
    label.text = "test"
    label.font = .systemFont(ofSize: 20)
    label.textColor = .white
    label.backgroundColor = .gray
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "사용자 프로필"
    
    configureSetUI()
    
    configureLayout()
    
  }
 
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  
  private func configureSetUI() {
    
    view.backgroundColor = .gray
    
    tableView.backgroundColor = .white
    
    if let userProfileData = userProfileData {
      mainTableHeaderView.configureHeaderView(image: userProfileImageData,
                                              userName: userProfileData.nickName,
                                              isHiddenLogoutButton: false)
      mainTableHeaderView.logoutButton.addTarget(self,
                                                 action: #selector(tabLogoutButton),
                                                 for: .touchUpInside)
    }
  }
  
  private func configureLayout() {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.tableHeaderView = mainTableHeaderView
    tableView.tableHeaderView?.frame.size = CGSize(width: view.frame.width, height: 100)
    
    tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
//    view.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    tableView.frame = view.frame
    
  }
  
  // MARK: - Button Handler
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
    } else { // // Firebase 외 계정 로그아웃
      
    }
  }
  
  // MARK: - TableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return secionData.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return aboutBookInfo[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: UserProfileTableViewCell.identifier,
      for: indexPath
      ) as? UserProfileTableViewCell else { fatalError() }
    
    let titleText = aboutBookInfo[indexPath.section][indexPath.row]
    let isNeedDetailMenu = titleText == checkDetailMenuString ? true : false
    cell.configure(titleText: titleText,
                   contextText: "10",
                   isNeedDetailMenu: isNeedDetailMenu)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 70
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    label.numberOfLines = 2
    label.backgroundColor = .systemGray6
    label.text = "\n   \(secionData[section])"
    return label
  }
}




