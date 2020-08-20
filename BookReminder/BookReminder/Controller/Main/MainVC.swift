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
  var userProfileData: User?                  // 사용자 프로필 데이터
  var markedBookList: [BookDetailInfo] = [] { // 사용자의 북마크된 책 리스트
    didSet {
      if markedBookList.count != 0 {          // 사용자가 북마크된 책을 모두 제거한 경우 오류 방지
        userSelectedBookIndex = IndexPath(row: 0, section: 0) // 북마크 제거시 첫 북마크 책으로 변경
        fetchMarkedBookCommentCount()         // comment Count 재설정
      }
    }
  }
  var markedBookCommentCountList: [Int] = [] 
  var userSelectedBookIndex: IndexPath = IndexPath(row: 0, section: 0) {
    didSet {
      fetchMarkedBookCommentCount()           // 사용자가 선택한 markedBookList의 값을 통한 comment 수 가져옴
    }
  }
  
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
    
//    if (Auth.auth().currentUser?.uid) != nil {
//      let firebaseAuth = Auth.auth()
//      do { // Firebase 계정 로그아웃
//        try firebaseAuth.signOut()
//        print("Success logout")
//
//        let loginVC = LoginVC()
//        loginVC.modalPresentationStyle = .fullScreen
//        present(loginVC, animated: true)
//
//      } catch let signOutError as NSError {
//        print ("Error signing out: %@", signOutError)
//      }
//    }
    
    configureView()
    
    fetUserProfileData()
    
    fetchMarkedBookList()
    
    configureLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
    guard let profileData = userProfileData else { return }
    if let nickName = profileData.nickName,
      let imageUrl = profileData.profileImageUrl {
    mainTableHeaderView.configureHeaderView(profileImageUrlString: imageUrl,
                                            userName: nickName,
                                            isHiddenLogoutButton: true)
    }
  }
  
  private func configureView() {
    
    view.backgroundColor = .white
    tableView.backgroundColor = .white
    
    view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageButton))
    mainTableHeaderView.profileImageView.addGestureRecognizer(gesture)
    mainTableHeaderView.profileImageView.addGestureRecognizer(gesture)
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
  
  func fetUserProfileData() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    DB_REF_USER.child(uid).observe(.value) { (snapshot) in
      if let value = snapshot.value as? Dictionary<String, AnyObject> {
        
        let userData = User(uid: uid, dictionary: value)
        
        if let profileImageUrl = userData.profileImageUrl,
          let nickName = userData.nickName {
          // 사용자 데이터가 있는 경우
          self.mainTableHeaderView.configureHeaderView(profileImageUrlString: profileImageUrl,
                                                  userName: nickName,
                                                  isHiddenLogoutButton: true)
        } else {
          // 사용자 데이터 없는 경우
          self.mainTableHeaderView.configureHeaderView(profileImageUrlString: nil,
                                                       userName: "사용자",
                                                       isHiddenLogoutButton: true)
        }
        self.userProfileData = userData
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
  
  private func fetchMarkedBookCommentCount() {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let isbnCode = markedBookList[userSelectedBookIndex.item].isbn else { return }
    guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BookInfoCell else { return }
    
    DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observe(.value) { (snapshot) in
      
      guard let value = snapshot.value as? Int else { return }
      cell.commentLabel.attributedText = .configureAttributedString(systemName: "bubble.left.fill",
                                                                    setText: "\(value)")
    }
  }
  
  // MARK: - Button Handler
  @objc private func tabProfileImageButton() {
    presentUserProfileVC()
  }
  
  @objc private func tabDetailProfileButton() {
    presentUserProfileVC()
  }
  
  private func presentUserProfileVC() {
    let userProfileVC = UserProfileVC(style: .grouped)
    userProfileVC.userProfileData = self.userProfileData
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  @objc private func tabAddCommentButton() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
    let addCommentVC = AddCommentVC()
    addCommentVC.markedBookInfo = markedBookList[userSelectedBookIndex.item]
    navigationController?.pushViewController(addCommentVC, animated: true)
  }
  
  @objc private func tabCommentListEditButton() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
    let commentListVC = CommentListVC(style: .plain)
    commentListVC.markedBookInfo = markedBookList[userSelectedBookIndex.item]
    navigationController?.pushViewController(commentListVC, animated: true)
  }
  
  @objc private func tabCompliteButton() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
    
    let okAction = UIAlertAction(title: "완독 처리", style: .destructive) { (_) in
      let deleteBookIndex = self.userSelectedBookIndex.item
      guard let uid = Auth.auth().currentUser?.uid,
            let isbnCode = self.markedBookList[deleteBookIndex].isbn else { return }
      
      DB_REF_COMPLITEBOOKS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
        guard (snapshot.value as? Dictionary<String, AnyObject>) == nil else {
          self.present(UIAlertController.defaultSetting(title: "오류", message: "이미 완독된 책 입니다"),
                       animated: true, completion: nil)
          return
        }
        // 신규 등록 되는 책 DB 업데이트
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue() // 북마크에서 제거
        DB_REF_COMPLITEBOOKS.child(uid).updateChildValues([isbnCode:1]) // 완료된 책 등록
        Database.userProfileStaticsHanlder(uid: uid, plusMinus: .plus, updateCategory: .compliteBookCount, amount: 1) // 완료 통계 증가
        
        // 북마크 북 제거
        self.markedBookList.remove(at: deleteBookIndex)
        // TableView reload
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        
        // myBook 재설정
        guard let window = UIApplication.shared.delegate?.window,
          let tabBarController = window?.rootViewController as? UITabBarController else { return }
        
        guard let naviController = tabBarController.viewControllers?[1] as? UINavigationController,
          let myBookVC = naviController.visibleViewController as? MyBookVC else { return }
        
        myBookVC.collectionView.reloadData()
      }
      
    }
    let message = "해당 책을 완독 처리하시겠습니까?\n 완독한 책은 Main메뉴에서 삭제됩니다."
    guard let title = markedBookList[userSelectedBookIndex.row].title else { return }
    let alertController = UIAlertController.okCancelSetting(title: "\(title) 완독", message: message, okAction: okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  // main 페이지에서 북마크 된 책 북마크 제거
  @objc private func tabBookMarkLabel() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
   
    let index = userSelectedBookIndex.item
    let bookInfo = markedBookList[index]
    if let bookTitle = bookInfo.title,
      let bookIsbnCode = bookInfo.isbn {
      
      let okAction = UIAlertAction(title: "북마크 제거", style: .destructive) { (_) in
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DB_REF_MARKBOOKS.child(uid).child(bookIsbnCode).removeValue()
        self.markedBookList.remove(at: index)
        self.tableView.reloadData()
      }
      
      let alert = UIAlertController.okCancelSetting(title: "북마크 제거", message: "\(bookTitle) 책을 북마크에서 제거 합니다.", okAction: okAction)
      present(alert, animated: true, completion: nil)
    }
  }
  
  @objc private func tabCommentLabel() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
    let commentListVC = CommentListVC(style: .plain)
    commentListVC.markedBookInfo = markedBookList[userSelectedBookIndex.item]
    navigationController?.pushViewController(commentListVC, animated: true)
  }
  
  private func popErrorAlertController() {
    present(UIAlertController.defaultSetting(title: "오류", message: "북마크된 책이 선택되지 않았습니다."),
            animated: true,
            completion: nil)
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
      
      let tabBookMarkLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabBookMarkLabel))
      let tabCommentLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabCommentLabel))
      
      myCell.bookMarkLabel.addGestureRecognizer(tabBookMarkLabelGuesture)
      myCell.commentLabel.addGestureRecognizer(tabCommentLabelGuesture)
      myCell.commentAddButton.addTarget(self, action: #selector(tabAddCommentButton), for: .touchUpInside)
      myCell.commentEditButton.addTarget(self, action: #selector(tabCommentListEditButton), for: .touchUpInside)
      myCell.compliteButton.addTarget(self, action: #selector(tabCompliteButton), for: .touchUpInside)
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
