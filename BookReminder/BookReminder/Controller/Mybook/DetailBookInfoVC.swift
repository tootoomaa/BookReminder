//
//  DetailBookInfoVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class DetailBookInfoVC: UITableViewController {
  
  // MARK: - Properties
  let bookThumbnailImageView: CustomImageView = {
    let imageView = CustomImageView()
    return imageView
  }()
  
  var detailBookInfo: Book? {
    didSet {
      guard let detailBookInfo = detailBookInfo else { return }
      guard let bookThumnailImageUrl = detailBookInfo.thumbnail else { return }
      
      tableHeaderView.configure(thumbnailImageUrl: bookThumnailImageUrl)
      bookThumbnailImageView.loadImage(urlString: bookThumnailImageUrl)
      
      configureNavigation()
      
      bookDetilInfoDictonaryValue = Book.returnDictionaryValue(documents: detailBookInfo)
      tableView.reloadData()
    }
  }
  let tableHeaderView = DetailBookInfoHeaderView()
  let tableFooterView = DetailBookInfoFooterView()
  
  let secionData = ["책 관련 정보", "줄거리"]
  var bookDetilInfoDictonaryValue: Dictionary<String, AnyObject>?
  let bookInfoCategoryIndex: [String] = ["저자명", "출판사", "출간일", "isbn코드", "가격"]
  let bookInfoCategoryDic: [String: String] = [
    "저자명":"authors", "출판사":"publisher", "출간일":"datetime", "isbn코드":"isbn", "가격":"price",
  ]
  
  private struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 40
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    configureNavigation()
    
    configureTableView()
  }
  
  private func configureNavigation() {
    navigationController?.navigationBar.prefersLargeTitles = true
    
    title = detailBookInfo?.title ?? "Large Title"
    
    // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
    guard let navigationBar = self.navigationController?.navigationBar else { return }
    navigationBar.addSubview(bookThumbnailImageView)
    bookThumbnailImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
    bookThumbnailImageView.clipsToBounds = true
    bookThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      bookThumbnailImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor,
                                                    constant: -Const.ImageRightMargin),
      bookThumbnailImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor,
                                                     constant: -Const.ImageBottomMarginForLargeState),
      bookThumbnailImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
      bookThumbnailImageView.widthAnchor.constraint(equalTo: bookThumbnailImageView.heightAnchor)
    ])
  }
  
  private func configureTableView() {
    
    tableView.backgroundColor = .white
    
    tableView.tableHeaderView = tableHeaderView
    tableView.tableHeaderView?.frame.size = CGSize(width: view.frame.width, height: 300)
//    tableView.tableFooterView = tableFooterView
//    tableView.tableFooterView?.frame.size = CGSize(width: view.frame.width, height: 200)
    tableView.register(DetailBookInfoCell.self, forCellReuseIdentifier: DetailBookInfoCell.identifier)
    tableView.register(DetailBookShortStoryCell.self, forCellReuseIdentifier: DetailBookShortStoryCell.identifier)
  }
  
  // MARK: - Handler
  private func moveAndResizeImage(for height: CGFloat) {
    let coeff: CGFloat = {
      let delta = height - Const.NavBarHeightSmallState
      let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
      return delta / heightDifferenceBetweenStates
    }()
    
    let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
    
    let scale: CGFloat = {
      let sizeAddendumFactor = coeff * (1.0 - factor)
      return min(1.0, sizeAddendumFactor + factor)
    }()
    
    // Value of difference between icons for large and small states
    let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
    
    let yTranslation: CGFloat = {
      /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
      let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
      return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
    }()
    
    let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
    
    bookThumbnailImageView.transform = CGAffineTransform.identity
      .scaledBy(x: scale, y: scale)
      .translatedBy(x: xTranslation, y: yTranslation)
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let height = navigationController?.navigationBar.frame.height else { return }
    moveAndResizeImage(for: height)
  }
  
  
  
  // MARK: - TableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return secionData.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return bookInfoCategoryIndex.count
    } else {
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = UITableViewCell()
      
    guard let bookDetilInfoDictonaryValue = bookDetilInfoDictonaryValue else { fatalError() }
    
    if indexPath.section == 0 {
      guard let mycell = tableView.dequeueReusableCell(
        withIdentifier: DetailBookInfoCell.identifier,
        for: indexPath) as? DetailBookInfoCell else { fatalError() }
      
      let searchTitle = bookInfoCategoryIndex[indexPath.row]
      if let searchDicTitle = bookInfoCategoryDic[searchTitle] {
        
        if let value = bookDetilInfoDictonaryValue[searchDicTitle] as? [String] {
          var authorString = ""
          value.forEach{
            authorString.append("\($0) ")
          }
          mycell.configure(titleText: searchTitle, contextText: authorString)
        }
        
        if let value = bookDetilInfoDictonaryValue[searchDicTitle] as? String {
          if searchTitle == "출간일" {
            let newValue = value.split(separator: "T")
            mycell.configure(titleText: searchTitle, contextText: String(newValue[0]))
          } else {
            mycell.configure(titleText: searchTitle, contextText: value)
          }
        } else {
          mycell.configure(titleText: searchTitle, contextText: "없음")
        }
        
        if let value = bookDetilInfoDictonaryValue[searchDicTitle] as? Int {
          mycell.configure(titleText: searchTitle, contextText: "\(value) 원")
        }
      }
      cell = mycell
    } else {
      guard let mycell = tableView.dequeueReusableCell(withIdentifier: DetailBookShortStoryCell.identifier, for: indexPath) as? DetailBookShortStoryCell else { fatalError() }
      
      mycell.configure(context: bookDetilInfoDictonaryValue["contents"] as! String)
      cell = mycell
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 50
    } else {
      return 200
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 15)
    label.textColor = .black
    label.numberOfLines = 2
    label.backgroundColor = .white
    label.text = "\n   \(secionData[section])"
    return label
  }
}

