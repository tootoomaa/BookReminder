//
//  CollecionViewCustomCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class CollecionViewCustomCell: UICollectionViewCell {
  
  static let identifier = "CollecionViewCustomCell"
  
  let bookThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .gray
    imageView.contentMode = .scaleAspectFit
    
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = UIColor.systemGray3.cgColor
    
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    [bookThumbnailImageView].forEach{
      addSubview($0)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
