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
  
  var menuActive: Bool = false
  var userSelectSearchCategory: String = "책이름"
  var searchedBookList: [Book] = []
  
  var saveBookClosure:((String, [String: AnyObject]) -> ())? // handle Result return closure
  
  var bookInfoLargeOn: Bool = false
  
  let disposeBag = DisposeBag()
  let searchBookView = SearchBookView()
  var searchBookListVM: SearchBookListViewModel!
  
  struct Standard {
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let lineSpacing: CGFloat = 10
    static let itemSpacing: CGFloat = 10
    static let rowCount: Int = 3
  }
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBookView.searchBar.delegate = self
    
    configuerUI()
    
    configureButtonAction()
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
  
  private func configuerUI() {
    
    navigationItem.title = "Search Book"
    
    view.backgroundColor = .white
    
    searchBookView.collectionView.backgroundColor = .white
    searchBookView.collectionView.dataSource = self
    searchBookView.collectionView.delegate = self
    searchBookView.collectionView.register(SearchBookCustomCell.self,
                            forCellWithReuseIdentifier: SearchBookCustomCell.identifier)
    
  }
  
  private func configureButtonAction() {
    searchBookView.resultResearchButton.addTarget(self, action: #selector(tabEtcCategoryButton(_:)), for: .touchUpInside)
  }
  
  // MARK: - Handler
  @objc private func tabEtcCategoryButton(_ sender: UIButton) {
    
    guard let buttonTitle = sender.currentTitle else { return }
    
    if buttonTitle == "책이름" {
      
    } else if buttonTitle == "결과재검색" {
      
    }
    
    let attributedString = NSAttributedString.configureAttributedString(
      systemName: "arrowtriangle.down.fill",
      setText: buttonTitle
    )
    searchBookView.mainCategoryButton.setAttributedTitle(attributedString, for: .normal)
    menuActive = false
  }
  
  private func hideKeyBoard() {
    self.view.endEditing(true)
  }
}

// MARK: - UISearchBarDelegate
extension SearchBookVC: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    hideKeyBoard()
    
    guard let searchString = searchBar.searchTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
    
    SearchBookList.getSearchBookList(searchString)
      .subscribe(onNext: {
        self.searchBookListVM = SearchBookListViewModel($0)
        self.searchBookView.collectionView.reloadData()
      }).disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegate
extension SearchBookVC: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    hideKeyBoard()
    guard let cell = collectionView.cellForItem(at: indexPath) as? SearchBookCustomCell else { return }
    guard let bookName = searchedBookList[indexPath.item].title else { return }
    
    let alert = UIAlertController(title: "\(bookName)", message: "이 책을 등록하시겠습니까?", preferredStyle: .alert)
    let addAction = UIAlertAction(title: "등록", style: .default) { (_) in
      
      guard let isbnCode = self.searchedBookList[indexPath.item].isbn else { return }
      guard let passBookInfoClosure = self.saveBookClosure else { return }
      
      let documents = self.searchedBookList[indexPath.item]
      let creationDate = Int(NSDate().timeIntervalSince1970)
      
      let value = [
      "authors": documents.authors!,
      "contents": documents.contents!,
      "datetime": documents.datetime!,
      "isbn": documents.isbn!,
      "price": documents.price!,
      "publisher": documents.publisher!,
      "sale_price": documents.sale_price!,
      "status": documents.status!,
      "thumbnail": documents.thumbnail!,
      "title": documents.title!,
      "translators": documents.translators!,
      "url": documents.url!,
      "creationDate": creationDate
      ] as Dictionary<String, AnyObject>
      
      passBookInfoClosure(isbnCode, value)
      self.navigationController?.popViewController(animated: true)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .destructive) { (_) in }
    
    let imageView = UIImageView(frame: CGRect(x: 80, y: 100, width: 140, height: 200))
    // alert 버튼 및 이미지 설정
    imageView.image = cell.bookThumbnailImageView.image
    alert.view.addSubview(imageView)
    
    alert.addAction(addAction)
    alert.addAction(cancelAction)

    if let view = alert.view {
      let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
      let width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
      alert.view.addConstraints([ height, width])
    }
    
    present(alert, animated: true)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    hideKeyBoard()
  }
}

// MARK: - UIcollecionViewDataSource
extension SearchBookVC: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searchBookListVM == nil ? 0 : searchBookListVM.searchBooks.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchBookCustomCell.identifier, for: indexPath) as? SearchBookCustomCell else { fatalError() }
    
    searchBookListVM.searchBooks[indexPath.item].author
      .asDriver(onErrorJustReturn: "Loading..")
      .drive(cell.authorsValueLable.rx.text)
      .disposed(by: disposeBag)
    
    searchBookListVM.searchBooks[indexPath.item].bookName
      .asDriver(onErrorJustReturn: "Loading..")
      .drive(cell.nameValueLable.rx.text)
      .disposed(by: disposeBag)
    
    searchBookListVM.searchBooks[indexPath.item].publish
      .asDriver(onErrorJustReturn: "Loading..")
      .drive(cell.publishurValueLable.rx.text)
      .disposed(by: disposeBag)
    
    searchBookListVM.searchBooks[indexPath.item].datetime
      .asDriver(onErrorJustReturn: "Loading..")
      .drive(cell.publisherDateValueLable.rx.text)
      .disposed(by: disposeBag)
    
    let imgUrl = searchBookListVM.searchBooks[indexPath.item].searchBook.thumbnail
    if imgUrl == "" {
      cell.bookThumbnailImageView.image = UIImage(systemName: "xmark.octagon")
    } else {
      cell.bookThumbnailImageView.loadImage(urlString: imgUrl)
    }
    
    return cell
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
