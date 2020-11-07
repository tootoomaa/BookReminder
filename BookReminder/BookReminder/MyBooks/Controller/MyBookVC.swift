//
//  SearchBookVC.swift
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

class MyBookVC: UIViewController {
  
  // MARK: - Properties
  
  let myBookView = MyBookView()
  
  let disposeBag = DisposeBag()
  
  var myBookListVM: MyBookListViewModel!
  
  var bookScanedCode: String = ""
  var bookDetailInfoArray: [Book] = []
  
  var filterOn: Bool = false
  var filterdBookArray: [Book] = []
  
  var userSelectedCellForDelete: IndexPath?
  
  enum MyBookCellButtonTitle: String {
    case bookMark = "mark"
    case comment = "comment"
    case info = "info"
  }
  
  struct Standard {
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let lineSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let rowCount: Int = 3
  }
  
  lazy var saveNewBookClosure:((String, [String: AnyObject]) -> ())? = { [weak self] isbnCode, bookDicValue in
    if self?.myBookListVM == nil {
      self?.myBookListVM = MyBookListViewModel([Book(isbnCode: isbnCode, dictionary: bookDicValue)])
      self?.myBookListVM.reloadData()
      return
    }
    
    if let isSameBookExsist = self?.myBookListVM.checkSameBook(isbnCode) {
      if isSameBookExsist {
        self?.presentDefaultAlertC("중복 등록", "해당 도서는 이미 등록된 도서입니다.")
      } else {
        self?.myBookListVM.addMyBook(Book(isbnCode: isbnCode, dictionary: bookDicValue),
                                          value: bookDicValue)
        self?.myBookView.initializationMultiButton()
      }
    }
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    activityIndicatorStartAnimation()
    fetchInitialData()
    configureUI()
    configureMultiButtonAction()
    settingSearchBar()
  }
  
  override func loadView() {
    view = myBookView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    let view = self.myBookView
    UIView.animate(withDuration: 0.5) {
      [view.barcodeButton, view.bookSearchButton, view.deleteBookButton, view.multiButton].forEach{
        $0.center.x = $0.center.x - 100
      }
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    myBookView.initializationMultiButton()
    let view = self.myBookView
    UIView.animate(withDuration: 0.5) {
      [view.barcodeButton, view.bookSearchButton, view.deleteBookButton, view.multiButton].forEach{
        $0.center.x = $0.center.x + 100
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
  }
  
  private func hideKeyBoard() {
    self.view.endEditing(true)
  }
  
  private func configureUI() {
    navigationItem.title = "My Books"
    view.backgroundColor = .white
  }
  
  // MARK: - Network
  private func fetchInitialData() {
    Book.fetchUserBookList()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] value in
        self?.myBookListVM = MyBookListViewModel(value)
        self?.configureCollectionView()
        self?.activityIndicatorStopAnimation()
    }).disposed(by: disposeBag)
  }
  
  // MARK: - Configure CollectionView Binding
  private func configureCollectionView() {
    collectionViewBasicSetting()
    collectionViewDataBinding()
    collectionViewDelegate()
    collectionViewWillDisplayCell()
    changeCompleteBookObserveBinding()
    conbineUserGuideLabelShow()
  }
  
  private func collectionViewBasicSetting() {
    myBookView.collectionView.backgroundColor = .white
    myBookView.collectionView.isMultipleTouchEnabled = false
    myBookView.collectionView.register(MyBookCustomCell.self, forCellWithReuseIdentifier: MyBookCustomCell.identifier)
  }
  
  private func collectionViewDataBinding() {
    myBookView.collectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    myBookListVM.allcase
      .bind(to: myBookView.collectionView.rx
              .items(cellIdentifier: MyBookCustomCell.identifier,
                     cellType: MyBookCustomCell.self)) { index, myBook, cell in
        
        cell.bookThumbnailImageView.loadImage(urlString: myBook.book.thumbnail)
        cell.bookDetailInfo = myBook.book
        // cell 내에서 버튼 눌렸을 경우 리턴 받아옴
        cell.passButtonName = { [weak self] buttonName, bookDetailInfo, isMarked in
          self?.tabBookDetailButton(buttonName, bookDetailInfo, isMarked)
        }
      }.disposed(by: disposeBag)
  }
  
  private func collectionViewDelegate() {
    
    myBookView.collectionView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = self?.myBookView.collectionView.cellForItem(at: indexPath) as? MyBookCustomCell else { return }
        cell.blurView.alpha = cell.blurView.alpha == 1 ? 0 : 1
        self?.userSelectedCellForDelete = indexPath
      }).disposed(by: disposeBag)
    
    myBookView.collectionView.rx
      .itemDeselected
      .subscribe(onNext: { [weak self] indexPath in
        guard let cell = self?.myBookView.collectionView.cellForItem(at: indexPath) as? MyBookCustomCell else { return }
        cell.blurView.alpha = 0
      }).disposed(by: disposeBag)
  }
  
  private func collectionViewWillDisplayCell() {
    myBookView.collectionView.rx
      .willDisplayCell
      .subscribe(onNext: { cell, indexPath in
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cell = cell as? MyBookCustomCell else { return }
        guard let isbnCode = cell.bookDetailInfo?.isbn else { return }
        
        cell.blurView.alpha = 0
        
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
          let value = snapshot.value as? Int
          if value == 1 {
            cell.markImage.isHidden = false
            cell.markButton.isSelected = true
          } else {
            cell.markImage.isHidden = true
            cell.markButton.isSelected = false
          }
        }
        
        DB_REF_COMPLITEBOOKS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
          let value = snapshot.value as? Int
          if value == 1 {
            cell.compliteImage.isHidden = false
          } else {
            cell.compliteImage.isHidden = true
          }
        }
        
      }).disposed(by: disposeBag)
  }
  
  private func conbineUserGuideLabelShow() {
    myBookListVM.allcase
      .subscribe(onNext:{ [weak self] in
        self?.myBookView.isBookOverCount = $0.count >= 3 ? false : true
      }).disposed(by: disposeBag)
  }
  // MARK: - Setting SearchBar
  private func settingSearchBar() {
    
    myBookView.searchBar.rx.value.changed
      .bind { [weak self] in
        guard let searchText = $0 else { return }
        
        if let filteredBooks = searchText == "" ?
            self?.myBookListVM.myBooks :
            self?.myBookListVM.myBooks.filter({ ($0.book.title).contains(searchText) }) {
          self?.myBookListVM.filteredMyBooks = filteredBooks
          self?.myBookListVM.allcase.accept(filteredBooks)
        }
        
      }.disposed(by: disposeBag)
      
    myBookView.searchBar.rx.cancelButtonClicked
      .bind { [weak self] in
        self?.myBookView.searchBar.text = ""
        self?.hideKeyBoard()
      }.disposed(by: disposeBag)
  }
  
  // MARK: - MultiButton Binding
  private func configureMultiButtonAction() {
    configureMultiSearchBookButtonAction()
    configureMultiBarCodeScanButtonAction()
    configureMultiDeleteButtonAction()
  }
  
  private func configureMultiSearchBookButtonAction() {
    myBookView.bookSearchButton.rx.tap
      .bind { [weak self] in
        let searchBookVC = SearchBookVC()
        searchBookVC.saveBookClosure = self?.saveNewBookClosure
        self?.navigationController?.pushViewController(searchBookVC, animated: true)
        self?.myBookView.initializationMultiButton()
      }.disposed(by: disposeBag)
  }
  
  private func configureMultiBarCodeScanButtonAction() {
    myBookView.barcodeButton.rx.tap
      .bind { [weak self] in
        let scannerVC = ScannerVC()
        scannerVC.modalPresentationStyle = .popover
        scannerVC.saveBookClosure = self?.saveNewBookClosure
        self?.present(scannerVC, animated: true) {
          // 멀티 버튼 초기화
          self?.myBookView.initializationMultiButton()
        }
      }.disposed(by: disposeBag)
  }
  
  private func configureMultiDeleteButtonAction() {
    myBookView.deleteBookButton.rx.tap
      .bind { [weak self] in
        guard let deleteBookIndex = self?.userSelectedCellForDelete else {
          self?.presentDefaultAlertC("삭제 오류", "삭제 할 책을 선택해주세요")
          return
        }
        
        if let self = self {
          guard let deleteBookInfo = self.myBookListVM.bookAt(deleteBookIndex.item) else { return }
          let bookInfo = deleteBookInfo.book
          
          let alert = UIAlertController.deleteBookWarning(self, bookInfo, deleteBookIndex)
          
          let addAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }
          let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { (_) in
            
            guard let index = self.userSelectedCellForDelete,
                  let deleteBookModel = self.myBookListVM.bookAt(index.item) else { return }
            self.deleteMyBook(index)
            self.deleteBookAtBookMarkedList(deleteBookModel.toMarkedBookModel())
            
          }
          alert.addAction(addAction)
          alert.addAction(deleteAction)
          
          self.present(alert, animated: true)
        }
      }.disposed(by: disposeBag)
  }
  
  private func changeCompleteBookObserveBinding() {
    
    myBookListVM.checkCompleteBookChange()
      .subscribe(onNext: { [weak self] _ in
        self?.myBookListVM.reloadData()
      }).disposed(by: disposeBag)
    
  }
  
  // MARK: - Hander
  private func presentDefaultAlertC(_ title: String, _ message: String) {
    present(UIAlertController.defaultSetting(title: title, message: message),
            animated: true)
  }
  
  func deleteMyBook(_ deleteBookIndex: IndexPath) {
    myBookListVM.removeMyBook(deleteBookIndex)
    userSelectedCellForDelete = nil
  }
  
  func deleteBookAtBookMarkedList(_ deleteBookInfo: MarkedBookModel) {
    // bookMarked Book Remove
    guard let window = UIApplication.shared.delegate?.window,
          let tabBarController = window?.rootViewController as? UITabBarController else { return }
    
    guard let naviController = tabBarController.viewControllers?.first as? UINavigationController,
      let mainVC = naviController.visibleViewController as? MainVC else { return }
    
    mainVC.markedBookListVM.removeMarkedBook(deleteBookInfo)
    mainVC.markedBookListVM.reloadData()
  }
  
  private func activityIndicatorStartAnimation() {
    myBookView.activityIndicator.startAnimating()
  }
  
  private func activityIndicatorStopAnimation() {
    myBookView.activityIndicator.stopAnimating()
  }
  
  // MARK: - Cell Button handelr
  private func tabBookDetailButton(_ buttonName: String, _ bookDetailInfo: Book, _ isMarked: Bool) {
    // mark: 즐겨찾기, comment: 코멘트, info: 자세한 설명 화면
    if buttonName == MyBookCellButtonTitle.bookMark.rawValue {
      
      guard let window = UIApplication.shared.delegate?.window,
        let tabBarController = window?.rootViewController as? UITabBarController else { return }
      
      guard let naviController = tabBarController.viewControllers?.first as? UINavigationController,
            let mainVC = naviController.visibleViewController as? MainVC else { return }
      
      guard let isbnCode = bookDetailInfo.isbn,
            let uid = Auth.auth().currentUser?.uid else { return }
      
      if !isMarked  {
        DB_REF_MARKBOOKS.child(uid).updateChildValues([isbnCode:1])
        mainVC.markedBookListVM.addMarkedBook(bookDetailInfo)
      } else {
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue()
        mainVC.markedBookListVM.removeMarkedBook(MarkedBookModel(bookDetailInfo))
      }
      mainVC.markedBookListVM.allcase.accept(mainVC.markedBookListVM.books)

    } else if buttonName == MyBookCellButtonTitle.comment.rawValue {
      
      let commentList = CommentListVC(bookDetailInfo, false)
      navigationController?.pushViewController(commentList, animated: true)
      
    } else if buttonName == MyBookCellButtonTitle.info.rawValue {
      
      let detailBookInfoVC = DetailBookInfoVC()
      detailBookInfoVC.userSelectedBook = bookDetailInfo
      navigationController?.pushViewController(detailBookInfoVC, animated: true)
      
    }
  }
}

// MARK: - UICollecionViewDelegateFlowLayout
extension MyBookVC: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return Standard.lineSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return Standard.itemSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return Standard.myEdgeInset
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let width = (UIScreen.main.bounds.width - Standard.myEdgeInset.left - Standard.myEdgeInset.right - 2 * Standard.itemSpacing * CGFloat(Standard.rowCount - 1))/CGFloat(Standard.rowCount)
    
    let height = width * 1.45
    return CGSize(width: width, height: height)
  }
}
