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
import RxSwift
import RxCocoa
import RxDataSources

class MainVC: UIViewController {
  
  // MARK: - Properties
  let mainView = MainView()
  
  var userVM: UserViewModel!
  var userBookListVM: MarkedBookListModel!
  
  let dispoeBag = DisposeBag()
  
  lazy var allcase = BehaviorRelay(value: self.userBookListVM.books.sorted(by: { (markedbook1, markedbook2) -> Bool in
    return markedbook1.book.creationDate > markedbook2.book.creationDate
  }))
  
  var markedBookList: [Book] = []
  
  var userSelectedBookIndex: IndexPath = IndexPath(row: 0, section: 0) {
    didSet {
      setupSelectedMarkedBookCommentCount()
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
    getInitalData()

    configureViewGesture()
  }
  
  override func loadView() {
    view = mainView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }

  private func configureViewGesture() {
    let imageViewGesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageButton))
    let nameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageButton))
    mainView.profileImageView.addGestureRecognizer(imageViewGesture)
    mainView.nameLabel.addGestureRecognizer(nameLabelGesture)
    mainView.detailProfileButton.addTarget(self, action: #selector(tabDetailProfileButton), for: .touchUpInside)
    
    let tabBookMarkLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabBookMarkLabel))
    let tabCommentLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabCommentLabel))
    
    mainView.mainConrtollMenu.bookMarkLabel.addGestureRecognizer(tabBookMarkLabelGuesture)
    mainView.mainConrtollMenu.commentLabel.addGestureRecognizer(tabCommentLabelGuesture)
    mainView.mainConrtollMenu.commentAddButton.addTarget(self, action: #selector(tabAddCommentButton), for: .touchUpInside)
    mainView.mainConrtollMenu.commentEditButton.addTarget(self, action: #selector(tabCommentListEditButton), for: .touchUpInside)
    mainView.mainConrtollMenu.compliteButton.addTarget(self, action: #selector(tabCompliteButton), for: .touchUpInside)
  }
  
  // MARK: - Network handler
  private func getInitalData() {
    mainView.activityIndicator.startAnimating()
    
    let fetchGroup = DispatchGroup()
    
    fetchGroup.enter()
    DispatchQueue.main.async {
      User.getUserProfileData { [weak self] (userVM) in
        self?.userVM = userVM
        fetchGroup.leave()
      }
    }
    
    DispatchQueue.main.async {
      guard let uid = Auth.auth().currentUser?.uid else { return }
      DB_REF_MARKBOOKS.child(uid).observe(.value) { (snapshot) in
        guard let value = snapshot.value as? [String: Int] else { return }
        value.keys.forEach{
          fetchGroup.enter()
          Database.fetchBookDetailData(uid: uid, isbnCode: $0) { [weak self] (bookDetailInfo) in
            self?.markedBookList.append(bookDetailInfo)
            self?.markedBookList.sort { (book1, book2) -> Bool in
              book1.creationDate > book2.creationDate
            }
            fetchGroup.leave()
          }
        }
      }
    }
   
    fetchGroup.notify(queue: .main) {
      self.updateInitialUserDataAtUI()
    }
  }
  
  private func updateInitialUserDataAtUI() {
    self.userBookListVM = MarkedBookListModel(markedBookList)
    
    userVM.nickName.asDriver(onErrorJustReturn: "NickName")
      .drive(mainView.nameLabel.rx.text)
      .disposed(by: dispoeBag)
    
    mainView.profileImageView.loadImage(urlString: userVM.user.profileImageUrl)
    mainView.profileImageView.clipsToBounds = true
    
    setupSelectedMarkedBookCommentCount()
    
    configureCollectionView()
    configureCollectionViewDataSource()
    configureCollectionViewDelegate()
    
    self.mainView.activityIndicator.stopAnimating()
  }
  
  private func setupSelectedMarkedBookCommentCount() {
    userBookListVM.fetchMarkedBookCommentCountAt(userSelectedBookIndex)?
      .asDriver(onErrorJustReturn: NSAttributedString(string: ""))
      .drive(mainView.mainConrtollMenu.commentLabel.rx.attributedText)
      .disposed(by: dispoeBag)
  }
  
  func configureCollectionView() {
    mainView.collectionView.backgroundColor = .white
    mainView.collectionView.allowsMultipleSelection = false
    
    mainView.collectionView.rx.setDelegate(self)
      .disposed(by: dispoeBag)
    
    mainView.collectionView.register(CollecionViewCustomCell.self,
                            forCellWithReuseIdentifier: CollecionViewCustomCell.identifier)
  }
  
  private func configureCollectionViewDataSource() {
    allcase
      .do( onNext: { model in
        self.userSelectedBookIndex = IndexPath(row: 0, section: 0)
      })
      .bind(to: mainView.collectionView.rx
              .items(cellIdentifier: CollecionViewCustomCell.identifier,
                     cellType: CollecionViewCustomCell.self)) { index, book, cell in
        cell.bookThumbnailImageView.loadImage(urlString: book.book.thumbnail)
      }.disposed(by: dispoeBag)
  }
  
  private func configureCollectionViewDelegate() {
    mainView.collectionView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = self?.mainView.collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { fatalError() }
        if cell.selectedimageView.isHidden == true {
          cell.selectedimageView.isHidden.toggle()
          self?.userSelectedBookIndex = indexPath
        }
      }).disposed(by: dispoeBag)
    
    mainView.collectionView.rx
      .itemDeselected
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = self?.mainView.collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
        cell.selectedimageView.isHidden = true
      }).disposed(by: dispoeBag)
    
    mainView.collectionView.rx
      .willDisplayCell
      .subscribe(onNext: { event in
        guard let cell = event.cell as? CollecionViewCustomCell else { return }
        if event.at == self.userSelectedBookIndex || cell.isSelected {
          cell.selectedimageView.isHidden = false
          cell.isSelected = true
        } else {
          cell.selectedimageView.isHidden = true
          cell.isSelected = false
        }
      }).disposed(by: dispoeBag)
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
      
      DB_REF_COMPLITEBOOKS.child(uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
        guard (snapshot.value as? Dictionary<String, AnyObject>) == nil else {
          self?.present(UIAlertController.defaultSetting(title: "오류", message: "이미 완독된 책 입니다"),
                       animated: true, completion: nil)
          return
        }
        // 신규 등록 되는 책 DB 업데이트
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue() // 북마크에서 제거
        DB_REF_COMPLITEBOOKS.child(uid).updateChildValues([isbnCode:1]) // 완료된 책 등록
        Database.userProfileStaticsHanlder(uid: uid, plusMinus: .plus, updateCategory: .compliteBookCount, amount: 1) // 완료 통계 증가
        
        // 북마크 북 제거
        self?.markedBookList.remove(at: deleteBookIndex)
        
        // myBook 재설정
        guard let window = UIApplication.shared.delegate?.window,
          let tabBarController = window?.rootViewController as? UITabBarController else { return }
        
        guard let naviController = tabBarController.viewControllers?[1] as? UINavigationController,
          let myBookVC = naviController.visibleViewController as? MyBookVC else { return }
        
        myBookVC.myBookView.collectionView.reloadData()
      }
      
    }
    let message = "해당 책을 완독 처리하시겠습니까?\n 완독한 책은 Main메뉴에서 삭제됩니다."
    guard let title = markedBookList[userSelectedBookIndex.row].title else { return }
    let alertController = UIAlertController.okCancelSetting(title: "\(title) 완독", message: message, okAction: okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @objc private func tabBookMarkLabel() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
   
    let bookInfo = userBookListVM.bookAt(userSelectedBookIndex.row).book
    if let bookTitle = bookInfo.title,
      let bookIsbnCode = bookInfo.isbn {
      
      let okAction = UIAlertAction(title: "북마크 제거", style: .destructive) { [weak self] (_) in
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DB_REF_MARKBOOKS.child(uid).child(bookIsbnCode).removeValue()
        self?.userBookListVM.removeBook(bookInfo)
        self?.allcase.accept((self?.userBookListVM.books)!)
      }
      
      let alert = UIAlertController.okCancelSetting(title: "북마크 제거", message: "\(bookTitle) 책을 북마크에서 제거 합니다.", okAction: okAction)
      present(alert, animated: true, completion: nil)
    }
  }
  
  @objc private func tabCommentLabel() {
    guard (markedBookList.first?.title) != nil else {popErrorAlertController(); return} // 책 정보 체크
    let commentListVC = CommentListVC(style: .plain)
    commentListVC.markedBookInfo = userBookListVM.bookAt(userSelectedBookIndex.row).book
    navigationController?.pushViewController(commentListVC, animated: true)
  }
  
  private func popErrorAlertController() {
    present(UIAlertController.defaultSetting(title: "오류 ", message: "북마크된 책이 선택되지 않았습니다."),
            animated: true,
            completion: nil)
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
    return CGSize(width: 138, height: 200)
  }
}
