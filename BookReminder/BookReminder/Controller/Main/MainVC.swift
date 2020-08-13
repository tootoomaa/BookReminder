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
  var userProfileData: User?
  var userProfileImageData: Data?
  var markedBookList: [BookDetailInfo] = []
  var userSelectedBookIndex: IndexPath = IndexPath(row: 0, section: 0)
  
  
  lazy var mainTableHeaderView: MainTableHeaderView = {
    let view = MainTableHeaderView()
    
    view.detailProfileButton.addTarget(self, action: #selector(tabDetailProfileButton), for: .touchUpInside)
    return view
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.tableHeaderView = mainTableHeaderView
    tableView.tableHeaderView?.frame.size = CGSize(width: view.frame.width, height: 100)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.register(MainVCBookListCell.self, forCellReuseIdentifier: MainVCBookListCell.identifier)
    tableView.register(BookInfoCell.self, forCellReuseIdentifier: BookInfoCell.identifier)
    return tableView
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
    
    fetUserProfileData()
    
    fetchMarkedBookList()
    
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
    
    [tableView].forEach{
      view.addSubview($0)
    }
    
    tableView.snp.makeConstraints{
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  // MARK: - Network handler
  
  private func fetUserProfileData() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    DB_REF_USER.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      
      if let value = snapshot.value as? Dictionary<String, AnyObject> {
        print(value)
        let userData = User(uid: uid, dictionary: value)
        
        if let imageURL = URL(string: userData.profileImageUrl) {
          URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
              print("error", error.localizedDescription)
            }
            if let data = data,
              let nickName = userData.nickName {
              // 사용자 데이터가 있는 경우
              DispatchQueue.main.async {
                self.mainTableHeaderView.configureHeaderView(image: data,
                                                             userName: nickName,
                                                             isHiddenLogoutButton: true)
              }
              
              self.userProfileData = userData
            }
          }.resume()
        } else {
          // 사용자 데이터 없는 경우
          print("no use data")
          self.mainTableHeaderView.configureHeaderView(image: nil,
                                                       userName: "사용자",
                                                       isHiddenLogoutButton: true)
          self.userProfileData = userData
        }
      }
    }
  }
  
  private func fetchMarkedBookList() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    DB_REF_MARKBOOKS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      guard let value = snapshot.value as? [String: Int] else { return }
      value.keys.forEach{
        Database.fetchBookDetailData(uid: uid, isbnCode: $0) { (bookDetailInfo) in
          self.markedBookList.append(bookDetailInfo)
          self.markedBookList.sort { (book1, book2) -> Bool in
            book1.creationDate > book2.creationDate
          }
          self.tableView.reloadData()
        }
      }
    }
  }
  
  // MARK: - Button Handler
  @objc private func tabDetailProfileButton() {
    let userProfileVC = UserProfileVC(style: .grouped)
    userProfileVC.userProfileData = self.userProfileData
    userProfileVC.userProfileImageData = self.userProfileImageData
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  @objc private func tabAddCommentButton() {
    print("tab tabAddCommentButton")
    
    guard (markedBookList.first?.title) != nil else { return }
    let addCommentVC = AddCommentVC()
    addCommentVC.markedBookInfo = markedBookList[userSelectedBookIndex.item]
    navigationController?.pushViewController(addCommentVC, animated: true)
  }
}

// MARK: - UITableViewDataSource
extension MainVC: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
    
    if indexPath.row == 0 {
      // collectionView 있는 Cell 책 정보들
      guard let myCell = tableView.dequeueReusableCell(
        withIdentifier: MainVCBookListCell.identifier,
        for: indexPath
        ) as? MainVCBookListCell else { fatalError() }
      
      myCell.markedBookList = markedBookList
      myCell.passSelectedCellInfo = { indexPath in
        self.userSelectedBookIndex = indexPath
      }
      
      cell = myCell
      
    } else if indexPath.row == 1 {
      // 특정 책에 대한 상세한 정보
      guard let myCell = tableView.dequeueReusableCell(
        withIdentifier: BookInfoCell.identifier,
        for: indexPath
        ) as? BookInfoCell else { fatalError() }
      
      myCell.commentAddButton.addTarget(self, action: #selector(tabAddCommentButton), for: .touchUpInside)
      
      cell = myCell
    }
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension MainVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let rowHeight = CGFloat(indexPath.row == 0 ? 230 : 200)
    return rowHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40))
    let sectionTitleLabel = UILabel()
    sectionTitleLabel.font = .boldSystemFont(ofSize: 30)
    sectionTitleLabel.textColor = CommonUI.titleTextColor
    
    if section == 0 {
      sectionTitleLabel.text = "Reading..."
    }
    
    view.addSubview(sectionTitleLabel)
    sectionTitleLabel.frame = view.frame
    view.backgroundColor = .white
    
    self.view.bringSubviewToFront(sectionTitleLabel)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
}
