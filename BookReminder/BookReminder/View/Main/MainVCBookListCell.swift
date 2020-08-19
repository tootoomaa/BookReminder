//
//  CollectionViewCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class MainVCBookListCell: UITableViewCell {
  
  // MARK: - Properties
  static let identifier = "BookListCell"
  
  var passSelectedCellInfo: ((IndexPath)->())?
  var selectedBookIndexPath: IndexPath?
  
  var markedBookList: [BookDetailInfo] = [] {
    didSet {
      collectionView.reloadData()
      
      selectedBookIndexPath = IndexPath(item: 0, section: 0)
      collectionView.selectItem(at: selectedBookIndexPath, animated: false, scrollPosition: .bottom)
    }
  }

  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  // MARK: - Inti
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = .yellow
    
    collectionView.backgroundColor = .white
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.allowsMultipleSelection = false
    collectionView.register(CollecionViewCustomCell.self,
                            forCellWithReuseIdentifier: CollecionViewCustomCell.identifier)
    
    collectionView.register(CollectionViewNoDataCell.self,
                            forCellWithReuseIdentifier: CollectionViewNoDataCell.identifier)
    
    addSubview(collectionView)
    
    collectionView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UICollectionViewDelegate
extension MainVCBookListCell: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Mark 된 책 선택시 해당 책의 정보를 mainVC로 넘겨줌
    guard let passSelectedCellInfo = passSelectedCellInfo else { return }
    guard let cell = collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
    // 책 선택시 체크 표시, 무조건 하나는 선택해야 하기 때문에 동일한 책 선택시 선택 해제 불가능
    if cell.selectedimageView.isHidden == true {
      cell.selectedimageView.isHidden.toggle()
      selectedBookIndexPath = indexPath
      passSelectedCellInfo(indexPath)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CollecionViewCustomCell else { return }
    // 책 선택 해제시 체크 표시 없애기
    cell.selectedimageView.isHidden = true
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // Cell 재사용에 따른 체크 표시 수정
    guard let castedCell = cell as? CollecionViewCustomCell else { return }
    if indexPath == selectedBookIndexPath || castedCell.isSelected {
      castedCell.selectedimageView.isHidden = false
      castedCell.isSelected = true
    } else {
      castedCell.selectedimageView.isHidden = true
      castedCell.isSelected = false
    }
  }
}

// MARK: - UICollectionViewDataSource
extension MainVCBookListCell: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return markedBookList.count == 0 ? 1 : markedBookList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var cell = UICollectionViewCell()
    
    if markedBookList.count != 0 {
      guard let myCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CollecionViewCustomCell.identifier,
        for: indexPath) as? CollecionViewCustomCell else { fatalError() }
      
      if let imageURL = markedBookList[indexPath.item].thumbnail {
        myCell.configureCell(imageURL: imageURL)
      }
      cell = myCell
    } else {
      guard let myCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CollectionViewNoDataCell.identifier,
        for: indexPath) as? CollectionViewNoDataCell else { fatalError() }
      cell = myCell
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainVCBookListCell: UICollectionViewDelegateFlowLayout {
 
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
    
    if markedBookList.count == 0 {
      
      let width: CGFloat = UIScreen.main.bounds.width - 10 - 10
      let height: CGFloat = 200
      
      mySize = CGSize(width: width, height: height)
      
    } else {
      mySize = CGSize(width: 138, height: 200)
    }
    
    return mySize
  }
}
