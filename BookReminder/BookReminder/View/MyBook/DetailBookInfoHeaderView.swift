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
  
  let blurView: UIVisualEffectView = {
    let blurEffet = UIBlurEffect(style: .systemThinMaterial)
    return UIVisualEffectView(effect: blurEffet)
  }()
  
  let bookThumbnailImageView: CustomImageView = {
    let imageView = CustomImageView()
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    blurView.alpha = 1
    backgroundColor = .systemGray4
    
    [blurView, bookThumbnailImageView].forEach{
      addSubview($0)
    }
    
    blurView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.equalTo(self).offset(10)
      $0.bottom.equalTo(self).offset(-10)
      $0.centerX.equalTo(self.snp.centerX)
      $0.width.equalTo(bookThumbnailImageView.snp.height).multipliedBy(0.68)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(thumbnailImageUrl: String) {
    bookThumbnailImageView.loadImage(urlString: thumbnailImageUrl)
  }
}
