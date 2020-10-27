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

class MainVC: UIViewController, ViewModelBindableType {
  // MARK: - Properties
  let mainView = MainView()
  
  var userVM: UserViewModel!
  var markedBookListVM: MarkedBookListModel!
  
  var viewModel: MarkedBookListModel!
  
  let dispoeBag = DisposeBag()
  
  var tempMarkedBookList: [Book] = []
  
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
  
  func bindViewModel() {
    
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
    
    let tabBookMarkLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tapBookMarkLabel))
    let tabCommentLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tapCommentLabel))
    
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
            self?.tempMarkedBookList.append(bookDetailInfo)
            self?.tempMarkedBookList.sort { (book1, book2) -> Bool in
              book1.creationDate > book2.creationDate
            }
            fetchGroup.leave()
          }
        }
      }
    }
   
    fetchGroup.notify(queue: .main) {
      self.initialUserDataBinding()
      self.colletionViewBinding()
    }
  }
  
  // MARK: - UserData Binding
  private func initialUserDataBinding() {
    self.markedBookListVM = MarkedBookListModel(tempMarkedBookList)
    
    userVM.nickName.asDriver(onErrorJustReturn: "NickName")
      .drive(mainView.nameLabel.rx.text)
      .disposed(by: dispoeBag)
    
    mainView.profileImageView.loadImage(urlString: userVM.user.profileImageUrl)
    mainView.profileImageView.clipsToBounds = true
    
    setupSelectedMarkedBookCommentCount()
    
    self.mainView.activityIndicator.stopAnimating()
  }
  
  private func setupSelectedMarkedBookCommentCount() {
    markedBookListVM.fetchMarkedBookCommentCountAt(userSelectedBookIndex)?
      .asDriver(onErrorJustReturn: NSAttributedString(string: ""))
      .drive(mainView.mainConrtollMenu.commentLabel.rx.attributedText)
      .disposed(by: dispoeBag)
  }
  
  // MARK: - CollectionView Binding
  
  private func colletionViewBinding() {
    configureCollectionViewOptionSetting()
    configureCollectionViewDataSource()
    configureCollectionViewDelegate()
    configureCollectionViewWillAppear()
  }
  
  private func configureCollectionViewOptionSetting() {
    mainView.collectionView.backgroundColor = .white
    mainView.collectionView.allowsMultipleSelection = false
    
    mainView.collectionView.rx.setDelegate(self)
      .disposed(by: dispoeBag)
    
    mainView.collectionView.register(CollecionViewCustomCell.self,
                            forCellWithReuseIdentifier: CollecionViewCustomCell.identifier)
    
    mainView.collectionView.register(CollectionViewNoDataCell.self,
                                     forCellWithReuseIdentifier: CollectionViewNoDataCell.identifier)
  }
  
  private func configureCollectionViewDataSource() {
    markedBookListVM.allcase
      .bind(to: mainView.collectionView.rx.items) { [weak self] (collectionView, item, markedBook) -> UICollectionViewCell in
        let indexPath = IndexPath(item: item, section: 0)

        if self?.markedBookListVM.allcase.value.first?.book == Book.empty() {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewNoDataCell.identifier,
                                                        for: indexPath) as! CollectionViewNoDataCell
          return cell
        } else {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollecionViewCustomCell.identifier,
                                                        for: indexPath) as! CollecionViewCustomCell
          cell.bookThumbnailImageView.loadImage(urlString: markedBook.book.thumbnail)
          return cell
        }
      }.disposed(by: dispoeBag)
  }
  
  private func configureCollectionViewDelegate() {
    mainView.collectionView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = self?.mainView.collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
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
  }
  
  private func configureCollectionViewWillAppear() {
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
    guard (markedBookListVM.books.first?.book.title) != nil else { popErrorAlertController(); return }
    
    let addCommentVC = AddCommentVC()
    addCommentVC.markedBookInfo = markedBookListVM.bookAt(userSelectedBookIndex.row).book
    navigationController?.pushViewController(addCommentVC, animated: true)
  }
  
  @objc private func tabCommentListEditButton() {
    guard (markedBookListVM.books.first?.book.title) != nil else { popErrorAlertController(); return }
    
    let commentListVC = CommentListVC(style: .plain)
    commentListVC.markedBookInfo = markedBookListVM.bookAt(userSelectedBookIndex.row).book
    navigationController?.pushViewController(commentListVC, animated: true)
  }
  
  @objc private func tabCompliteButton() {
    guard (markedBookListVM.books.first?.book.title) != nil else { popErrorAlertController(); return }
    
    let okAction = UIAlertAction(title: "완독 처리", style: .destructive) { [weak self] (_) in
      guard let deleteBookIndex = self?.userSelectedBookIndex.item,
            let uid = Auth.auth().currentUser?.uid,
            let deleteBook = self?.markedBookListVM.bookAt(deleteBookIndex),
            let isbnCode = deleteBook.book.isbn else { return }
      
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
        guard let deleteBook = self?.markedBookListVM.bookAt(deleteBookIndex) else { return }
        self?.markedBookListVM.removeMarkedBook(deleteBook.book)
        
        // myBook 재설정
        self?.reloadMyBookCollectionView()
      }
      
    }
    let message = "해당 책을 완독 처리하시겠습니까?\n 완독한 책은 Main메뉴에서 삭제됩니다."
    guard let title = markedBookListVM.books[userSelectedBookIndex.row].book.title else { return }
    let alertController = UIAlertController.okCancelSetting(title: "\(title) 완독", message: message, okAction: okAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func reloadMyBookCollectionView() {
    guard let window = UIApplication.shared.delegate?.window,
      let tabBarController = window?.rootViewController as? UITabBarController else { return }
    
    guard let naviController = tabBarController.viewControllers?[1] as? UINavigationController,
      let myBookVC = naviController.visibleViewController as? MyBookVC else { return }
    
    myBookVC.myBookListVM.reloadData()
  }
  
  @objc private func tapBookMarkLabel() {
    guard (markedBookListVM.books.first?.book.title) != nil else { popErrorAlertController(); return }
    
    let bookInfo = markedBookListVM.bookAt(userSelectedBookIndex.row).book
    let okAction = UIAlertAction(title: "북마크 제거", style: .destructive) { [weak self] (_) in
      self?.markedBookListVM.removeMarkedBook(bookInfo)
      self?.markedBookListVM.reloadData()
    }
    
    let alert = UIAlertController.okCancelSetting(title: "북마크 제거", message: "\(bookInfo.title ?? "") 책을 북마크에서 제거 합니다.", okAction: okAction)
    present(alert, animated: true, completion: nil)
  }
  
  @objc private func tapCommentLabel() {
    guard (markedBookListVM.books.first?.book.title) != nil else { popErrorAlertController(); return }
    let commentListVC = CommentListVC(style: .plain)
    commentListVC.markedBookInfo = markedBookListVM.bookAt(userSelectedBookIndex.row).book
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
    
    var mySize = CGSize(width: 0, height: 0)
    
    if markedBookListVM.allcase.value.first?.book == Book.empty() {
      
      let width: CGFloat = UIScreen.main.bounds.width - 10 - 10
      let height: CGFloat = 200
      
      mySize = CGSize(width: width, height: height)
      
    } else {
      mySize = CGSize(width: 138, height: 200)
    }
    
    return mySize
  }
}
