//
//  ViewController.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class MainVC: UIViewController {
  // MARK: - Properties
  let mainView = MainView()
  
  var userVM: UserViewModel!
  var markedBookListVM: MarkedBookListModel!
  
  let dispoeBag = DisposeBag()
  var collectionViewDelegateBag = Disposables.create()
  
  var tempMarkedBooksIndex: [String] = []
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
    markedBookListVM = MarkedBookListModel([Book.empty()])
    configureCollectionViewOptionSetting()
    
    getUserData()
    getMarkedBookList()
    configureButtonBinding()
  }
  
  override func loadView() {
    view = mainView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  
  // MARK: - Network handler
  private func getUserData() {
    mainView.activityIndicator.startAnimating()
    
    User.getUserProfileData { [weak self] (userVM) in
      self?.userVM = userVM
      self?.initialUserDataBinding()
    }
  }
  
  private func getMarkedBookList() {
    Book.fetchMarkedBookIndex()
      .subscribe {
        self.tempMarkedBooksIndex = $0
        
        if $0.isEmpty {
          
          self.markedBookListVM.books = [MarkedBookModel(Book.empty())]
          self.colletionViewBinding()
          self.markedBookListVM.reloadData()
          self.mainView.activityIndicator.stopAnimating()
          
        } else {
          $0.forEach { isbnCode in
            
            Book.fetchMarkedBooks(isbnCode).subscribe(onNext: { [unowned self] value in
              
              self.tempMarkedBookList.append(value)
              
              if self.tempMarkedBookList.count == self.tempMarkedBooksIndex.count {
                
                self.tempMarkedBookList.sort(by: { $0.creationDate > $1.creationDate })
                
                let markedBookModels = tempMarkedBookList.map { book -> MarkedBookModel in
                  return MarkedBookModel(book)
                }
                
                self.markedBookListVM.books = markedBookModels
                self.colletionViewBinding()
                self.markedBookListVM.reloadData()
                
                self.tempMarkedBookList.removeAll()
                self.mainView.activityIndicator.stopAnimating()
              }
              
            }).disposed(by: self.dispoeBag)
          }
        }
      } onError: { error in
        print(error)
      }.disposed(by: dispoeBag)
  }
  
  // MARK: - UserData Binding
  private func initialUserDataBinding() {
    self.markedBookListVM = MarkedBookListModel(tempMarkedBookList)
    
    userVM.nickName.asDriver(onErrorJustReturn: "NickName")
      .drive(mainView.nameLabel.rx.text)
      .disposed(by: dispoeBag)
    
    mainView.profileImageView.loadImage(urlString: userVM.user.profileImageUrl)
    
    let imageViewWidth = mainView.profileImageView.frame.width
    
    mainView.profileImageView.layer.cornerRadius = imageViewWidth/2
    mainView.profileImageView.clipsToBounds = true
  }
  
  private func setupSelectedMarkedBookCommentCount() {
    markedBookListVM.fetchMarkedBookCommentCountAt(userSelectedBookIndex)?
      .asDriver(onErrorJustReturn: NSAttributedString(string: ""))
      .drive(mainView.mainConrtollMenu.commentLabel.rx.attributedText)
      .disposed(by: dispoeBag)
  }
  
  // MARK: - collectionView Setting
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
  
  // MARK: - CollectionView Binding
  
  private func colletionViewBinding() {
    configureCollectionViewDataSource()
    configureCollectionViewDelegate()
    configureCollectionViewWillAppear()
    setupSelectedMarkedBookCommentCount()
  }
  
  private func configureCollectionViewDataSource() {
    
    collectionViewDelegateBag.dispose()
    
    collectionViewDelegateBag = markedBookListVM.allcase
      .bind(to: mainView.collectionView.rx.items) { [weak self] (collectionView, item, markedBook) -> UICollectionViewCell in
        let indexPath = IndexPath(item: item, section: 0)
        
        if self?.markedBookListVM.allcase.value.first?.book == Book.empty() {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewNoDataCell.identifier,
                                                        for: indexPath) as! CollectionViewNoDataCell
          return cell
        } else {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollecionViewCustomCell.identifier,
                                                        for: indexPath) as! CollecionViewCustomCell
          if item == 0 {
            cell.isSelected = true
          }
          
          cell.bookThumbnailImageView.loadImage(urlString: markedBook.book.thumbnail)
          return cell
        }
      }
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
        
        // 화면 로딩 후 첫번째 클릭된 cell이 0번째가 아닌 경우, 0번째 체크 이미지가 사라지지 않는 오류 수정 ( bug: #43 )
        if self?.userSelectedBookIndex != IndexPath(row: 0, section: 0) {
          guard let firstCell = self?.mainView.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as?
                  CollecionViewCustomCell else { return }
          firstCell.selectedimageView.isHidden = true
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
        if event.at == self.userSelectedBookIndex {
          cell.selectedimageView.isHidden = false
          cell.isSelected = true
        } else {
          cell.selectedimageView.isHidden = true
          cell.isSelected = false
        }
      }).disposed(by: dispoeBag)
  }
  
  // MARK: - Configure Button Binder
  
  private func configureButtonBinding() {
    userProfileTapGuesture()
    addCommentButtonBinding()
    commentEditButtonBinding()
    completeButtonBinding()
    deleteBookMarkButtonBinding()
    showCommentsButtonBind()
  }
  
  private func userProfileTapGuesture() {
    let imageViewGesture = UITapGestureRecognizer()
    mainView.profileImageView.addGestureRecognizer(imageViewGesture)
    
    imageViewGesture.rx.event.bind (onNext: { [weak self] recognizer in
      self?.presentUserProfileVC()
    }).disposed(by: dispoeBag)
    
    let nameLabelGesture = UITapGestureRecognizer()
    mainView.nameLabel.addGestureRecognizer(nameLabelGesture)
    
    nameLabelGesture.rx.event.bind (onNext: { [weak self] recognizer in
      self?.presentUserProfileVC()
    }).disposed(by: dispoeBag)
    
    mainView.detailProfileButton.rx.tap
      .bind { [weak self] in
        self?.presentUserProfileVC()
      }.disposed(by: dispoeBag)
  }
  
  private func presentUserProfileVC() {
    let userProfileVC = UserProfileVC()
    userProfileVC.userVM = self.userVM
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  private func addCommentButtonBinding() {
    mainView.mainConrtollMenu.commentAddButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let index = self?.userSelectedBookIndex.item else { return }
        
        if let book = self?.markedBookListVM.bookAt(index)?.book {
          let addCommentVC = AddCommentVC(book.isbn, nil)
          addCommentVC.isCommentEditing = true
          self?.navigationController?.pushViewController(addCommentVC, animated: true)
        } else {
          self?.popErrorAlertController()
        }
      }).disposed(by: dispoeBag)
  }
  
  private func commentEditButtonBinding() {
    mainView.mainConrtollMenu.commentEditButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let index = self?.userSelectedBookIndex.item else { return }
        
        if let book = self?.markedBookListVM.bookAt(index)?.book {
          let commentListVC = CommentListVC(book, true)
          self?.navigationController?.pushViewController(commentListVC, animated: true)
        } else {
          self?.popErrorAlertController()
        }
      }).disposed(by: dispoeBag)
  }
  
  private func completeButtonBinding() {
    mainView.mainConrtollMenu.compliteButton.rx.tap
      .subscribe(onNext: { [unowned self] in
        
        let okAction = UIAlertAction(title: "완독 처리", style: .destructive) { [unowned self] (_) in
          
          self.markedBookListVM.completeBook(self.userSelectedBookIndex)
            .subscribe(onNext: {
              
              if $0 == false { // 오류 메시지
                self.present(UIAlertController.defaultSetting(title: "오류", message: "이미 완독된 책 입니다"),
                             animated: true, completion: nil)
              } else { // 완료 성공 - > 리로드
                markedBookListVM.reloadData()
              }
              
            }).disposed(by: dispoeBag)
        }
        
        let message = "해당 책을 완독 처리하시겠습니까?\n 완독한 책은 Main메뉴에서 삭제됩니다."
        let alertController = UIAlertController.okCancelSetting(title: "완독 처리", message: message, okAction: okAction)
        self.present(alertController, animated: true, completion: nil)
        
      }).disposed(by: dispoeBag)
  }
  
  private func deleteBookMarkButtonBinding() {
    let bookMarkTapGuesture = UITapGestureRecognizer()
    mainView.mainConrtollMenu.bookMarkLabel.addGestureRecognizer(bookMarkTapGuesture)
    
    bookMarkTapGuesture.rx.event
      .bind (onNext: { [weak self] recognizer in
        guard let index = self?.userSelectedBookIndex.item else { return }
        
        if let bookModel = self?.markedBookListVM.bookAt(index) {
          
          let okAction = UIAlertAction(title: "북마크 제거", style: .destructive) { [weak self] (_) in
            
            self?.markedBookListVM.removeMarkedBook(bookModel)
            self?.userSelectedBookIndex = IndexPath(row: 0, section: 0)
            self?.markedBookListVM.reloadData()
          }
          
          let alert = UIAlertController.okCancelSetting(title: "북마크 제거", message: "\(bookModel.book.title ?? "") 책을 북마크에서 제거 합니다.", okAction: okAction)
          
          self?.present(alert, animated: true, completion: nil)
          
        } else {
          self?.popErrorAlertController()
        }
        
      }).disposed(by: dispoeBag)
  }
  
  private func showCommentsButtonBind() {
    let commentLabelTapGuesture = UITapGestureRecognizer()
    mainView.mainConrtollMenu.commentLabel.addGestureRecognizer(commentLabelTapGuesture)
    
    commentLabelTapGuesture.rx.event
      .bind (onNext: { [weak self] _ in
        guard let index = self?.userSelectedBookIndex.item else { return }
        
        if let book = self?.markedBookListVM.bookAt(index)?.book {
          
          let commentListVC = CommentListVC(book, false)
          commentListVC.isCommentEditing = false
          self?.navigationController?.pushViewController(commentListVC, animated: true)
          
        } else {
          
          self?.popErrorAlertController()
          
        }
      }).disposed(by: dispoeBag)
  }
  
  // MARK: - Handler
  
  private func popErrorAlertController() {
    present(UIAlertController.defaultSetting(title: "오류 ", message: "북마크된 책이 선택되지 않았습니다."),
            animated: true,
            completion: nil)
  }
  
  private func reloadMyBookCollectionView() {
    guard let window = UIApplication.shared.delegate?.window,
          let tabBarController = window?.rootViewController as? UITabBarController else { return }
    
    guard let naviController = tabBarController.viewControllers?[1] as? UINavigationController,
          let myBookVC = naviController.visibleViewController as? MyBookVC else { return }
    
    myBookVC.myBookListVM.reloadData()
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
