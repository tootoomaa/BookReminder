//
//  SearchBookVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import RxSwift
import RxCocoa

class SearchBookVC: UIViewController {
  
  // MARK: - Properties
  var saveBookClosure:((String, [String: AnyObject]) -> ())? // handle Result return closure
  
  var bookInfoLargeOn: Bool = false
  
  let disposeBag = DisposeBag()
  let searchBookView = SearchBookView()
  var searchBookListVM = SearchBookListViewModel([SearchBook]())
  
  struct Standard {
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let lineSpacing: CGFloat = 10
    static let itemSpacing: CGFloat = 10
    static let rowCount: Int = 3
  }
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configureSearchBar()
    configuerUI()
  }
  
  override func loadView() {
    view = searchBookView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    searchBookView.searchBar.becomeFirstResponder()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
  }
  
  private func hideKeyBoard() {
    self.view.endEditing(true)
  }
  
  private func configuerUI() {
    navigationItem.title = "Search Book"
    view.backgroundColor = .white
  }
  
  // MARK: - Configure collectionView
  private func configureCollectionView() {
    collectionViewBasicSetting()
    collectionViewCellSetting()
    collectionviewDelegateSetting()
  }
  
  private func collectionViewBasicSetting() {
    searchBookView.collectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
    
    searchBookView.collectionView.register(SearchBookCustomCell.self,
                            forCellWithReuseIdentifier: SearchBookCustomCell.identifier)
  }
  
  private func collectionViewCellSetting() {
    searchBookListVM.allcase
      .bind(to: searchBookView.collectionView.rx
              .items(cellIdentifier: SearchBookCustomCell.identifier, cellType: SearchBookCustomCell.self)) { item, model, cell in
        let disposeBag = DisposeBag()
        model.author
          .asDriver(onErrorJustReturn: "Loading..")
          .drive(cell.authorsValueLable.rx.text)
          .disposed(by: disposeBag)
        
        model.bookName
          .asDriver(onErrorJustReturn: "Loading..")
          .drive(cell.nameValueLable.rx.text)
          .disposed(by: disposeBag)
        
        model.publish
          .asDriver(onErrorJustReturn: "Loading..")
          .drive(cell.publishurValueLable.rx.text)
          .disposed(by: disposeBag)
        
        model.datetime
          .asDriver(onErrorJustReturn: "Loading..")
          .drive(cell.publisherDateValueLable.rx.text)
          .disposed(by: disposeBag)
        
        let imgUrl = model.searchBook.thumbnail
        if imgUrl == "" {
          cell.bookThumbnailImageView.image = UIImage(systemName: "xmark.octagon")
        } else {
          cell.bookThumbnailImageView.loadImage(urlString: imgUrl)
        }
        
      }.disposed(by: disposeBag)
  }
  
  private func collectionviewDelegateSetting() {
    searchBookView.collectionView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        
        if let self = self {
          let book = self.searchBookListVM.allcase.value[indexPath.item].searchBook
          let alertController = UIAlertController.addBookAlertController(self, book, indexPath)
          self.present(alertController, animated: true, completion: nil)
          
        }
          
      }).disposed(by: disposeBag)
  }
  
  func searchBookAddAtMyBooks(_ searchBook: SearchBook) -> Bool {
    
    guard let myBookVC = navigationController?.viewControllers.first as? MyBookVC else { fatalError("Fail to TypeCasting: MyBookVC in SearchBookVC") }
    guard !myBookVC.myBookListVM.checkSameBook(searchBook.isbn) else { return false }
    myBookVC.myBookListVM.addMyBook(searchBook.book, value: searchBook.value)
    return true
  }
  
  func popViewController() {
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Configure SearchBar
  private func configureSearchBar() {
    searchBookView.searchBar.rx.searchButtonClicked
      .subscribe(onNext: { [weak self] _ in
        if let searchText = self?.searchBookView.searchBar.text {
          self?.searchBookByText(searchText)
        }
      }).disposed(by: disposeBag)
  }
  
  private func searchBookByText(_ searchText: String) {
    hideKeyBoard()
    SearchBookList.getSearchBookList(searchText)
      .subscribe(onNext: { [weak self] bookList in
        if var searchBookListVM = self?.searchBookListVM {
          searchBookListVM.searchBooks = bookList.compactMap(SearchBookViewModel.init)
          searchBookListVM.reloadData()
        }
      }).disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate
extension SearchBookVC: UICollectionViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    hideKeyBoard()
  }
}

// MARK: - UICollecionViewDelegateFlowLayout
extension SearchBookVC: UICollectionViewDelegateFlowLayout {
  
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
    
    let width = UIScreen.main.bounds.width - 40
    
    return CGSize(width: width, height: 200)
  }
}
