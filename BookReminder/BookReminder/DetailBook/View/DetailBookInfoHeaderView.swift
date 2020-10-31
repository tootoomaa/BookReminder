//
//  DetailBookInfoHeaderView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class DetailBookInfoHeaderView: UIView {
  
  let bookThumbnailImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.layer.borderWidth = 2
    imageView.layer.borderColor = UIColor.black.cgColor
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    [bookThumbnailImageView].forEach{
      addSubview($0)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.equalTo(self).offset(10)
      $0.bottom.equalTo(self).offset(-10)
      $0.centerX.equalTo(self.snp.centerX)
      $0.width.equalTo(bookThumbnailImageView.snp.height).multipliedBy(0.68)
    }
  }
}
