//
//  CollectionViewNoDataCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/11.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class CollectionViewNoDataCell: UICollectionViewCell {
 
  static let identifier = "CollectionViewNoDataCell"
  
  let noDataLabel: UILabel = {
    let label = UILabel()
    label.text = " 북마크된 책이없습니다\n MyBooks 탭에서 책을 추가해주세요!"
    label.font = .boldSystemFont(ofSize: 15)
    label.textColor = .black
    label.backgroundColor = .systemGray5
    label.alpha = 0.5
    label.numberOfLines = 2
    label.layer.cornerRadius = 20
    label.textAlignment = .center
    label.clipsToBounds = true
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(noDataLabel)
    
    noDataLabel.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
