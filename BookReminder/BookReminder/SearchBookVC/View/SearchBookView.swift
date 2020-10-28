//
//  SearchBookView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/28.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class SearchBookView: UIView {
  // MARK: - Properties
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
  
  let resultResearchButton: UIButton = {
    let button = UIButton()
    button.setTitle("결과내검색", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .systemGray5
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
    return sBar
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureLayout()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    let safeGuide = safeAreaLayoutGuide
    
    [mainCategoryButton, searchBar, collectionView].forEach{
      addSubview($0)
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
    
    bringSubviewToFront(self.mainCategoryButton)
  }
  
}
