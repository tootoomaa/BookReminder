//
//  CollecionViewCustomCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class CollecionViewCustomCell: UICollectionViewCell {
  
  // MARK: - Properties
  static let identifier = "CollecionViewCustomCell"
  
  let bookThumbnailImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.backgroundColor = .gray
    imageView.contentMode = .scaleAspectFit
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = UIColor.systemGray3.cgColor
    return imageView
  }()
  
  let selectedimageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "checkmark.circle.fill")
//    imageView.tintColor = .systemPink
    imageView.tintColor = CommonUI.mainBackgroudColor
    imageView.layer.cornerRadius = 25
    imageView.backgroundColor = .white
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    [bookThumbnailImageView, selectedimageView].forEach{
      addSubview($0)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
    
    selectedimageView.snp.makeConstraints{
      $0.trailing.bottom.equalTo(bookThumbnailImageView).offset(-5)
      $0.width.height.equalTo(50)
    }
  }
  
  func configureCell(imageURL: String) {
    bookThumbnailImageView.loadImage(urlString: imageURL)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
