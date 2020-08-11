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

class MyBookVC: UIViewController {
  
  // MARK: - Properties
  
  var multibuttomActive: Bool = false
  let multiButtonSize: CGFloat = 70
  
  let featureButtonSize: CGFloat = 50
  let bounceDistance: CGFloat = 25
  
  var bookScanedCode: String = ""
  var bookDetailInfoArray: [BookDetailInfo] = []
  
  var filterOn: Bool = false
  var filterdBookArray: [BookDetailInfo] = []
  
  
  lazy var searchBar: UISearchBar = {
    let sBar = UISearchBar(frame: .zero)
    sBar.placeholder = "  책 검색.."
    sBar.backgroundColor = .white
    //    sBar.layer.borderColor = UIColor.gray.cgColor
    //    sBar.layer.borderWidth = 2
    sBar.barStyle = .default
    sBar.barTintColor = .none
    sBar.searchBarStyle = .minimal
    sBar.delegate = self
    sBar.showsCancelButton = false
    return sBar
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  lazy var multiButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
    let buttonImage = UIImage(systemName: "plus", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = CommonUI.mainBackgroudColor
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = multiButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    return button
  }()
  
  lazy var barcodeButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "barcode", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.999982059, green: 0.6622204781, blue: 0.1913976967, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabBarcodeButton(_:)), for: .touchUpInside)
    return button
  }()
  
  lazy var bookSearchButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.8973528743, green: 0.9285049438, blue: 0.7169274688, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabSearchButton(_:)), for: .touchUpInside)
    return button
  }()
  
  
  lazy var deleteBookButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "delete.right", withConfiguration: imageConfigure)
    
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.5455855727, green: 0.8030222058, blue: 0.8028761148, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(tabFeatureButton(_:)), for: .touchUpInside)
    return button
  }()
  
  struct Standard {
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let lineSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let rowCount: Int = 3
  }
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchUserBookIndex()
    
    configureUI()
    
    configureLayout()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.5) {
      [self.barcodeButton, self.bookSearchButton, self.deleteBookButton, self.multiButton].forEach{
        $0.center.x = $0.center.x - 100
      }
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    initializationMultiButton()
    UIView.animate(withDuration: 0.5) {
      [self.barcodeButton, self.bookSearchButton, self.deleteBookButton, self.multiButton].forEach{
        $0.center.x = $0.center.x + 100
      }
    }
  }
  
  private func configureUI() {
    
    navigationItem.title = "My Books"
    
    view.backgroundColor = .white
    
    collectionView.backgroundColor = .white
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.isMultipleTouchEnabled = false
    collectionView.register(MyBookCustomCell.self, forCellWithReuseIdentifier: MyBookCustomCell.identifier)
  }
  
  private func configureLayout() {
    let safeGuide = view.safeAreaLayoutGuide
    
    [searchBar, collectionView, barcodeButton, bookSearchButton, deleteBookButton, multiButton].forEach{
      view.addSubview($0)
    }
    
    searchBar.snp.makeConstraints{
      $0.top.equalTo(safeGuide.snp.top).offset(20)
      $0.leading.equalTo(safeGuide.snp.leading).offset(10)
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-10)
      $0.height.equalTo(40)
    }
    
    collectionView.snp.makeConstraints{
      $0.top.equalTo(searchBar.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalTo(safeGuide)
    }
    
    multiButton.snp.makeConstraints{
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-20)
      $0.bottom.equalTo(safeGuide.snp.bottom).offset(-20)
      $0.width.height.equalTo(multiButtonSize)
    }
    
    [barcodeButton, bookSearchButton, deleteBookButton].forEach{
      $0.snp.makeConstraints{
        $0.centerX.equalTo(multiButton.snp.centerX)
        $0.centerY.equalTo(multiButton.snp.centerY)
        $0.width.height.equalTo(featureButtonSize)
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    hideKeyBoard()
  }
  
  private func hideKeyBoard() {
    self.view.endEditing(true)
  }
  
  // MARK: - Handler
  @objc func tabMultiButton() {
    
    if !multibuttomActive {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: -(.pi/4*3))
      }
      //barcode -> bookSearch -> delete
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
          self.barcodeButton.center.y -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
          self.bookSearchButton.center.y -= self.featureButtonSize*1.5
          self.bookSearchButton.center.x -= self.featureButtonSize*1.5
          //          self.bookSearchButton.transform = .init(scaleX: 2, y: 2)
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
          self.deleteBookButton.center.x -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          self.barcodeButton.center.y += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          self.bookSearchButton.center.y += self.bounceDistance
          self.bookSearchButton.center.x += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          self.deleteBookButton.center.x += self.bounceDistance
        }
      })
      
    } else {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: .pi/4*3)
      }
      // delete -> bookSearch -> barcode
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        // 바운드
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
          self.deleteBookButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
          self.bookSearchButton.center.y -= self.bounceDistance
          self.bookSearchButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1) {
          self.barcodeButton.center.y -= self.bounceDistance
        }
        // 사라짐
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
          self.deleteBookButton.center.x += self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
          self.bookSearchButton.center.y += self.featureButtonSize*1.5
          self.bookSearchButton.center.x += self.featureButtonSize*1.5
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
          self.barcodeButton.center.y += self.featureButtonSize*2
        }
        
      })
    }
    multibuttomActive.toggle()
  }
  
  // multiButton 에니메이션 초기화
  func initializationMultiButton() {
    multibuttomActive = false
    UIView.animate(withDuration: 0.5) {
      
      self.deleteBookButton.center.x += self.featureButtonSize*2 - self.bounceDistance
      self.bookSearchButton.center.y += self.featureButtonSize*1.5 - self.bounceDistance
      self.bookSearchButton.center.x += self.featureButtonSize*1.5 - self.bounceDistance
      self.barcodeButton.center.y += self.featureButtonSize*2 - self.bounceDistance
      
      self.multiButton.transform = .identity
//      [self.multiButton, self.bookSearchButton, self.barcodeButton, self.deleteBookButton].forEach{
//        $0.transform = .identity
//      }
    }
  }
  
  @objc private func tabFeatureButton(_ sender: UIButton) {
    
    guard let buttonName = sender.currentTitle else { return }
    print(buttonName)
    
  }
  
  
  //search handler
  @objc private func tabSearchButton(_ sender: UIButton) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let searchBookVC = SearchBookVC()
    searchBookVC.passBookInfoClosure = { isbnCode, bookDicValue in
      DispatchQueue.main.async {
        // DB 업데이트
        DB_REF_USERBOOKS.child(uid).updateChildValues([isbnCode: bookDicValue])
        // book model 생성
        let bookDetailInfo = BookDetailInfo(isbnCode: isbnCode, dictionary: bookDicValue)
        self.bookDetailInfoArray.append(bookDetailInfo)
        
        self.bookDetailInfoArray.sort { (book1, book2) -> Bool in
          book1.creationDate > book2.creationDate
        }
        
        self.collectionView.reloadData()
        self.initializationMultiButton()
      }
    }
    navigationController?.pushViewController(searchBookVC, animated: true)
    // 멀티 버튼 초기화
    initializationMultiButton()
  }
  
  // Barcode handler
  @objc private func tabBarcodeButton(_ sender: UIButton) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let scannerVC = ScannerVC()
    scannerVC.modalPresentationStyle = .popover
    // 스켄을 통한 데이터 받기
    scannerVC.passBookInfoClosure = { isbnCode, bookDicValue in
      DispatchQueue.main.async {
        // DB 업데이트
        DB_REF_USERBOOKS.child(uid).updateChildValues([isbnCode: bookDicValue])
        // book model 생성
        let bookDetailInfo = BookDetailInfo(isbnCode: isbnCode, dictionary: bookDicValue)
        self.bookDetailInfoArray.append(bookDetailInfo)
        self.collectionView.reloadData()
        self.initializationMultiButton()
      }
    }
    
    // 바코드 스켄창 띄우기
    present(scannerVC, animated: true) {
      // 멀티 버튼 초기화
      self.initializationMultiButton()
    }
  }
  
  
  // fetch User Book Data
  private func fetchUserBookIndex() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    DB_REF_USERBOOKS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let bookDetailInfos = snapshot.value as? Dictionary<String, AnyObject> else { return }
      for bookInfo in bookDetailInfos {
        
        guard let value = bookInfo.value as? Dictionary<String, AnyObject> else {
          return print("Fail to change detail Book info ")
        }
        
        let bookDetailInfo = BookDetailInfo(isbnCode: bookInfo.key, dictionary: value)
        
        DispatchQueue.main.async {
          self.bookDetailInfoArray.append(bookDetailInfo)
          
          self.bookDetailInfoArray.sort { (book1, book2) -> Bool in
            book1.creationDate > book2.creationDate
          }
          
          self.collectionView.reloadData()
        }
      }
    }
  }
  
  // cell 에서 리턴 받은 버튼에 종류에 따라서 처리
  private func tabBookDetailButton(buttonName: String, bookDetailInfo: BookDetailInfo, isMarked: Bool) {
    // mark: 즐겨찾기, comment: 코멘트, info: 자세한 설명 화면
    
    if buttonName == "mark" {
      
      guard let window = UIApplication.shared.delegate?.window,
        let tabBarController = window?.rootViewController as? UITabBarController else { return }
      
      guard let naviController = tabBarController.viewControllers?.first as? UINavigationController,
            let mainVC = naviController.visibleViewController as? MainVC else { return }
      
      guard let isbnCode = bookDetailInfo.isbn,
            let uid = Auth.auth().currentUser?.uid else { return }
      
      if !isMarked  {
        DB_REF_MARKBOOKS.child(uid).updateChildValues([isbnCode:1])
        mainVC.markedBookList.append(bookDetailInfo)
      } else {
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue()
        if let index = mainVC.markedBookList.firstIndex(of: bookDetailInfo) {
          mainVC.markedBookList.remove(at: index)
        }
      }
      mainVC.tableView.reloadData()
      
    } else if buttonName == "comment" {
      print("Tab Comment Button in myBookVC")
      
    } else if buttonName == "info" {
      print("Tab info Button in myBookVC")
    }
  }
}

// MARK: - UISearchBarDelegate
extension MyBookVC: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    filterdBookArray = []
    collectionView.reloadData()
    
    searchBar.showsCancelButton = true
    filterOn = true
    guard let searchText = searchBar.searchTextField.text else { return }
    let filteredSearchText = searchText.trimmingCharacters(in: .whitespaces)
    for book in bookDetailInfoArray {
      if book.title.contains(filteredSearchText) {
        filterdBookArray.append(book)
        collectionView.reloadData()
      }
    }
    
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    hideKeyBoard()
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    filterOn = false
    searchBar.showsCancelButton = false
    collectionView.reloadData()
    hideKeyBoard()
  }
}

// MARK: - UICollectionViewDelegate
extension MyBookVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    // 선택한 cell의 블러효과 활성화
    guard let cell = collectionView.cellForItem(at: indexPath) as? MyBookCustomCell else { return }
    cell.blurView.alpha = cell.blurView.alpha == 1 ? 0 : 1
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? MyBookCustomCell else { return }
    cell.blurView.alpha = 0
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let cell = cell as? MyBookCustomCell else { return }
    guard let isbnCode = cell.isbnCode else { return }
    
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
    
  }
}


// MARK: - UIcollecionViewDataSource
extension MyBookVC: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return filterOn ? filterdBookArray.count : bookDetailInfoArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyBookCustomCell.identifier, for: indexPath) as? MyBookCustomCell else { fatalError() }
    
    let array = filterOn ? filterdBookArray : bookDetailInfoArray
    
    cell.configure(bookDetailInfo: array[indexPath.item])
    // cell 내에서 버튼 눌렸을 경우 리턴 받아옴
    cell.passButtonName = { buttonName, bookDetailInfo, isMarked in
      self.tabBookDetailButton(buttonName: buttonName, bookDetailInfo: bookDetailInfo, isMarked: isMarked)
    }
    
    return cell
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
