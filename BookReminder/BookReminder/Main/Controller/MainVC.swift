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
  let mainView = MainView()
  
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
  
  // MARK: - Life Cycle
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
    configureCollectionViewSetting()
    
    configureViewGesture()
    
    fetUserProfileData()
    
    fetchMarkedBookList()
  }
  
  override func loadView() {
    view = mainView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
  
  private func configureCollectionViewSetting() {
    mainView.collectionView.backgroundColor = .white
    mainView.collectionView.dataSource = self
    mainView.collectionView.delegate = self
    mainView.collectionView.allowsMultipleSelection = false
    mainView.collectionView.register(CollecionViewCustomCell.self,
                            forCellWithReuseIdentifier: CollecionViewCustomCell.identifier)
    
    mainView.collectionView.register(CollectionViewNoDataCell.self,
                            forCellWithReuseIdentifier: CollectionViewNoDataCell.identifier)
    
  }
  
  private func configureViewGesture() {
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageButton))
    mainView.profileImageView.addGestureRecognizer(gesture)
    mainView.profileImageView.addGestureRecognizer(gesture)
  }
  
  // MARK: - Network handler
  
  func fetUserProfileData() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    DB_REF_USER.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      if let value = snapshot.value as? Dictionary<String, AnyObject> {
        
        let userData = User(uid: uid, dictionary: value)
        
        if let profileImageUrl = userData.profileImageUrl,
          let nickName = userData.nickName {
          // 사용자 데이터가 있는 경우
//          self.mainTableHeaderView.configureHeaderView(profileImageUrlString: profileImageUrl,
//                                                  userName: nickName,
//                                                  isHiddenLogoutButton: true)
        } else {
          // 사용자 데이터 없는 경우
//          self.mainTableHeaderView.configureHeaderView(profileImageUrlString: nil,
//                                                       userName: "사용자",
//                                                       isHiddenLogoutButton: true)
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
//          self.tableView.reloadData()
        }
      }
    }
  }
  
  private func fetchMarkedBookCommentCount() {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let isbnCode = markedBookList[userSelectedBookIndex.item].isbn else { return }
//    guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BookInfoCell else { return }
    
    DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observe(.value) { (snapshot) in
      
      guard let value = snapshot.value as? Int else { return }
//      cell.commentLabel.attributedText = .configureAttributedString(systemName: "bubble.left.fill",
//                                                                    setText: "\(value)")
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
//        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        
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
//        self.tableView.reloadData()
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

// MARK: - UICollectionViewDelegate
extension MainVC: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Mark 된 책 선택시 해당 책의 정보를 mainVC로 넘겨줌
//    guard let passSelectedCellInfo = passSelectedCellInfo else { return }
    guard let cell = collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
    // 책 선택시 체크 표시, 무조건 하나는 선택해야 하기 때문에 동일한 책 선택시 선택 해제 불가능
    if cell.selectedimageView.isHidden == true {
      cell.selectedimageView.isHidden.toggle()
//      selectedBookIndexPath = indexPath

    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
    // 책 선택 해제시 체크 표시 없애기
    cell.selectedimageView.isHidden = true
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // Cell 재사용에 따른 체크 표시 수정
//    guard let castedCell = cell as? CollecionViewCustomCell else { return }
//    if indexPath == selectedBookIndexPath || castedCell.isSelected {
//      castedCell.selectedimageView.isHidden = false
//      castedCell.isSelected = true
//    } else {
//      castedCell.selectedimageView.isHidden = true
//      castedCell.isSelected = false
//    }
  }
}

// MARK: - UICollectionViewDataSource
extension MainVC: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return markedBookList.count == 0 ? 1 : markedBookList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var cell = UICollectionViewCell()
    
    if markedBookList.count != 0 {
      guard let myCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CollecionViewCustomCell.identifier,
        for: indexPath) as? CollecionViewCustomCell else { fatalError() }
      
      if let imageURL = markedBookList[indexPath.item].thumbnail {
        myCell.configureCell(imageURL: imageURL)
      }
      cell = myCell
    } else {
      guard let myCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CollectionViewNoDataCell.identifier,
        for: indexPath) as? CollectionViewNoDataCell else { fatalError() }
      cell = myCell
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainVC: UICollectionViewDelegateFlowLayout {
 
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var mySize = CGSize(width: 0, height: 0)
    
    if markedBookList.count == 0 {
      
      let width: CGFloat = UIScreen.main.bounds.width - 10 - 10
      let height: CGFloat = 200
      
      mySize = CGSize(width: width, height: height)
      
    } else {
      mySize = CGSize(width: 138, height: 200)
    }
    
    return mySize
  }
}


/*
 let tabBookMarkLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabBookMarkLabel))
 let tabCommentLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabCommentLabel))
 
 myCell.bookMarkLabel.addGestureRecognizer(tabBookMarkLabelGuesture)
 myCell.commentLabel.addGestureRecognizer(tabCommentLabelGuesture)
 myCell.commentAddButton.addTarget(self, action: #selector(tabAddCommentButton), for: .touchUpInside)
 myCell.commentEditButton.addTarget(self, action: #selector(tabCommentListEditButton), for: .touchUpInside)
 myCell.compliteButton.addTarget(self, action: #selector(tabCompliteButton), for: .touchUpInside)
 */
