//
//  SearchBookVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class MyBookVC: UIViewController {
  
  // MARK: - Properties
  
  var multibuttomActive: Bool = false
  
  let multiButtonSize: CGFloat = 70
  let featureButtonSize: CGFloat = 50
  let bounceDistance: CGFloat = 25
  
  var bookScanedCode: String = ""
  var bookInfo: [Book] = []
  
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
    button.addTarget(self, action: #selector(tabFeatureButton(_:)), for: .touchUpInside)
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
    static let myEdgeInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    static let lineSpacing: CGFloat = 10
    static let itemSpacing: CGFloat = 10
    static let myheight: CGFloat = 174
    static let rowCount: Int = 3
  }
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    configureJSON()
    configureUI()
    
    configureLayout()
  }
  
  private func configureJSON() {
    
    let query = "9791135485121"
    let sort = "accuracy"
    let page = "1"
    let size = "5"
    let target = "isbn"
    
    let authorization = "KakaoAK d4539e8d7741ccecad7ed805bfe1febb"
    
    let queryParams: [String: String] = [
      "query" : query,
      "sort" : sort,
      "page" : page,
      "size" : size,
      "target" : target
    ]
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "dapi.kakao.com"
    urlComponents.path = "/v3/search/book"
    urlComponents.setQueryItems(with: queryParams)
    
    if let url = urlComponents.url {
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "GET"
      urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
      
      URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error {
          print("error", error.localizedDescription)
          return
        }
        
        guard let data = data else { return print("Data is nil") }
        print("data",data)
        
//        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//          print("-=========-")
//          print(jsonData["documents"])
//          print("-=========-")
//        }

        do {
          let bookInfo = try JSONDecoder().decode(Book.self, from: data)
          print(bookInfo.documents)
          print(bookInfo.meta)
        } catch {
          print("eRror")
        }
        
      }.resume()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    // multiButton 에니메이션 초기화
    multibuttomActive = false
    UIView.animate(withDuration: 0.1) {
      [self.multiButton, self.bookSearchButton, self.barcodeButton, self.deleteBookButton].forEach{
        $0.transform = .identity
      }
    }
  }
  
  private func configureUI() {
    view.backgroundColor = .white
    
    collectionView.backgroundColor = .white
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
    view.endEditing(true)
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
  
  @objc private func tabFeatureButton(_ sender: UIButton) {
    
    guard let buttonName = sender.currentTitle else { return }
    print(buttonName)
    
  }
  
  @objc private func tabBarcodeButton(_ sender: UIButton) {
    
    let scannerVC = ScannerVC()
    scannerVC.passBookInfoClosure = { bookInfo in
      DispatchQueue.main.async {
        self.bookInfo.append(bookInfo)
        print("bookInfo Vlaue in MyBookVC bookInfo",self.bookInfo)
        self.collectionView.reloadData()
      }
    }
    present(scannerVC, animated: true)
  }
  
}

extension MyBookVC: UISearchBarDelegate {
  
  
}

// MARK: - UIcollecionViewDataSource
extension MyBookVC: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 30
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    
    cell.backgroundColor = .red
    
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
    
    let width = (UIScreen.main.bounds.width - Standard.myEdgeInset.left - Standard.myEdgeInset.right - Standard.itemSpacing * CGFloat(Standard.rowCount - 1))/CGFloat(Standard.rowCount)
    let height = Standard.myheight
    return CGSize(width: width, height: height)
  }
  
}
