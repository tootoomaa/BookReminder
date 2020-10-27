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

class SearchBookVC: UIViewController {
  
  // MARK: - Properties
  
  var menuActive: Bool = false
  var userSelectSearchCategory: String = "책이름"
  let networkServices = NetworkServices()
  var searchedBookList: [Book] = []
  
  var saveBookClosure:((String, [String: AnyObject]) -> ())? // handle Result return closure
  
  var bookInfoLargeOn: Bool = false
  
  lazy var mainCategoryButton: UIButton = {
    let button = UIButton()
    let attributedString = NSAttributedString.configureAttributedString(
      systemName: "arrowtriangle.down.fill",
      setText: "책이름"
    )
    button.setAttributedTitle(attributedString, for: .normal)
    button.backgroundColor = .white
    return button
  }()
  
  let bookNameCategoryButton: UIButton = {
    let button = UIButton()
    button.setTitle("책이름", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.textAlignment = .right
    button.backgroundColor = .systemGray5
    button.addTarget(self, action: #selector(tabEtcCategoryButton(_:)), for: .touchUpInside)
    return button
  }()
  
  let resultResearchButton: UIButton = {
    let button = UIButton()
    button.setTitle("결과내검색", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .systemGray5
    button.addTarget(self, action: #selector(tabEtcCategoryButton(_:)), for: .touchUpInside)
    return button
  }()
  
  lazy var searchBar: UISearchBar = {
    let sBar = UISearchBar(frame: .zero)
    sBar.placeholder = " 검색.."
    sBar.backgroundColor = .white
    sBar.barStyle = .default
    sBar.barTintColor = .none
    sBar.searchBarStyle = .minimal
    sBar.autocorrectionType = .no
    sBar.autocapitalizationType = .none
    sBar.delegate = self
    return sBar
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  struct Standard {
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let lineSpacing: CGFloat = 10
    static let itemSpacing: CGFloat = 10
    static let rowCount: Int = 3
  }
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configuerUI()
    
    configureLayout()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.searchBar.becomeFirstResponder()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
  }
  
  private func configuerUI() {
    
    navigationItem.title = "Search Book"
    
    view.backgroundColor = .white
    
    collectionView.backgroundColor = .white
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(SearchBookCustomCell.self,
                            forCellWithReuseIdentifier: SearchBookCustomCell.identifier)
    
  }
  
  private func configureLayout() {
    let safeGuide = view.safeAreaLayoutGuide
    
    [mainCategoryButton, searchBar, collectionView].forEach{
      view.addSubview($0)
    }
    
    mainCategoryButton.snp.makeConstraints{
      $0.top.equalTo(safeGuide.snp.top).offset(20)
      $0.leading.equalTo(safeGuide.snp.leading).offset(5)
      $0.height.equalTo(40)
      $0.width.equalTo(110)
    }
    
    searchBar.snp.makeConstraints{
      $0.centerY.equalTo(mainCategoryButton.snp.centerY)
      $0.leading.equalTo(mainCategoryButton.snp.trailing).offset(5)
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-10)
      $0.height.equalTo(40)
    }
    
    collectionView.snp.makeConstraints{
      $0.top.equalTo(searchBar.snp.bottom).offset(20)
      $0.leading.equalTo(safeGuide).offset(20)
      $0.trailing.equalTo(safeGuide).offset(-20)
      $0.bottom.equalTo(safeGuide)
    }
    
    self.view.bringSubviewToFront(self.mainCategoryButton)
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
    mainCategoryButton.setAttributedTitle(attributedString, for: .normal)
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
    searchedBookList = []
    
    guard let searchString = searchBar.searchTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
    networkServices.fetchBookInfomationFromKakao(type: .bookName, forSearch: searchString) { (isbnCode, bookDicValue) in
      DispatchQueue.main.async {
        // book model 생성
        let bookDetailInfo = Book(isbnCode: isbnCode, dictionary: bookDicValue)
        self.searchedBookList.append(bookDetailInfo)
        
        self.searchedBookList.sort { (book1, book2) -> Bool in
          book1.datetime > book2.datetime
        }
        
        self.collectionView.reloadData()
      }
    } 
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
    return searchedBookList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchBookCustomCell.identifier, for: indexPath) as? SearchBookCustomCell else { fatalError() }
    
    cell.configure(bookDetailInfo: searchedBookList[indexPath.item])
    
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
