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
        self?.present(UIAlertController.defaultSetting(
                        title: "중복 등록",
                        message: "해당 도서는 이미 등록된 도서입니다."),
                      animated: true,
                      completion: nil)
      } else {
        self?.myBookListVM.addMyBook(Book(isbnCode: isbnCode, dictionary: bookDicValue),
                                          value: bookDicValue)
        self?.myBookListVM.reloadData()
        self?.myBookView.initializationMultiButton()
      }
    }
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    myBookView.searchBar.delegate = self
    
    fetchInitialData()
    
    configureUI()
    
    configureButtonAction()
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
  
  private func configureButtonAction() {
    myBookView.barcodeButton.addTarget(self, action: #selector(tabBarcodeButton(_:)), for: .touchUpInside)
    myBookView.bookSearchButton.addTarget(self, action: #selector(tabSearchButton(_:)), for: .touchUpInside)
    myBookView.deleteBookButton.addTarget(self, action: #selector(tabDeleteButton(_:)), for: .touchUpInside)
  }
  

  
  // MARK: - Network
  private func fetchInitialData() {
    Book.fetchUserBookList()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] value in
        self?.myBookListVM = MyBookListViewModel(value)
        self?.configureCollectionView()
    },
      onError: { (error) in
        print("Error", error.localizedDescription)
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Configure CollectionView Binding
  private func configureCollectionView() {
    configureCollectionViewBasicSetting()
    configureCollectionViewDataBinding()
    configureCollectionViewDelegate()
    configureCollectionViewWillDisplayCell()
  }
  
  private func configureCollectionViewBasicSetting() {
    myBookView.collectionView.backgroundColor = .white
    myBookView.collectionView.isMultipleTouchEnabled = false
    myBookView.collectionView.register(MyBookCustomCell.self, forCellWithReuseIdentifier: MyBookCustomCell.identifier)
  }
  
  private func configureCollectionViewDataBinding() {
    myBookView.collectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    myBookListVM.allcase
      .bind(to: myBookView.collectionView.rx
              .items(cellIdentifier: MyBookCustomCell.identifier,
                     cellType: MyBookCustomCell.self)) { index, myBook, cell in
        
        cell.bookThumbnailImageView.loadImage(urlString: myBook.book.thumbnail)
        cell.bookDetailInfo = myBook.book
        // cell 내에서 버튼 눌렸을 경우 리턴 받아옴
        cell.passButtonName = { buttonName, bookDetailInfo, isMarked in
          self.tabBookDetailButton(buttonName: buttonName, bookDetailInfo: bookDetailInfo, isMarked: isMarked)
        }
      }.disposed(by: disposeBag)
  }
  
  private func configureCollectionViewDelegate() {
    
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
  
  private func configureCollectionViewWillDisplayCell() {
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
  
  // MARK: - Button Handler  
  //search handler
  @objc private func tabSearchButton(_ sender: UIButton) {
    
    let searchBookVC = SearchBookVC()
    searchBookVC.saveBookClosure = saveNewBookClosure
    navigationController?.pushViewController(searchBookVC, animated: true)
    myBookView.initializationMultiButton()
  }
  
  @objc private func tabBarcodeButton(_ sender: UIButton) {
    
    let scannerVC = ScannerVC()
    scannerVC.modalPresentationStyle = .popover
    scannerVC.saveBookClosure = saveNewBookClosure
    present(scannerVC, animated: true) {
      // 멀티 버튼 초기화
      self.myBookView.initializationMultiButton()
    }
  }
  
  @objc private func tabDeleteButton(_ sender: UIButton) {
    guard let deleteBookIndex = userSelectedCellForDelete else {
      present(UIAlertController.defaultSetting(title: "삭제 오류", message: "삭제할 책을 선택해주세요"),
              animated: true,completion: nil); return }
    
    let deleteBookInfo = myBookListVM.bookAt(deleteBookIndex.item)
    let bookInfo = deleteBookInfo.book
    
    present(UIAlertController.deleteBookWarning(self, bookInfo, deleteBookIndex), animated: true)
  }
  
  func deleteMyBook(_ deleteBookIndex: IndexPath) {
    myBookListVM.removeMyBook(deleteBookIndex)
    myBookListVM.reloadData()
    userSelectedCellForDelete = nil
  }
  
  func deleteBookAtBookMarkedList(_ deleteBookInfo: Book) {
    // bookMarked Book Remove
    guard let window = UIApplication.shared.delegate?.window,
          let tabBarController = window?.rootViewController as? UITabBarController else { return }
    
    guard let naviController = tabBarController.viewControllers?.first as? UINavigationController,
      let mainVC = naviController.visibleViewController as? MainVC else { return }
    
    mainVC.markedBookListVM.removeMarkedBook(deleteBookInfo)
    mainVC.markedBookListVM.reloadData()
  }
  
  // cell 에서 리턴 받은 버튼에 종류에 따라서 처리
  private func tabBookDetailButton(buttonName: String, bookDetailInfo: Book, isMarked: Bool) {
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
        mainVC.markedBookListVM.removeMarkedBook(bookDetailInfo)
      }
      mainVC.markedBookListVM.allcase.accept(mainVC.markedBookListVM.books)

    } else if buttonName == MyBookCellButtonTitle.comment.rawValue {
      
      let commentList = CommentListVC(style: .plain)
      commentList.markedBookInfo = bookDetailInfo
      navigationController?.pushViewController(commentList, animated: true)
      
    } else if buttonName == MyBookCellButtonTitle.info.rawValue {
      let detailBookInfoVC = DetailBookInfoVC()
      detailBookInfoVC.detailBookInfo = bookDetailInfo
      navigationController?.pushViewController(detailBookInfoVC, animated: true)
    }
  }
}

// MARK: - UISearchBarDelegate
extension MyBookVC: UISearchBarDelegate {
  
//  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//    filterdBookArray = []
//    myBookView.collectionView.reloadData()
//    
//    searchBar.showsCancelButton = true
//    filterOn = true
//    guard let searchText = searchBar.searchTextField.text else { return }
//    let filteredSearchText = searchText.trimmingCharacters(in: .whitespaces)
//    for book in bookDetailInfoArray {
//      if book.title.contains(filteredSearchText) {
//        filterdBookArray.append(book)
//        myBookView.collectionView.reloadData()
//      }
//    }
//  }
//  
//  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//    hideKeyBoard()
//  }
//
//  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//    searchBar.text = ""
//    filterOn = false
//    searchBar.showsCancelButton = false
//    myBookView.collectionView.reloadData()
//    hideKeyBoard()
//  }
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
