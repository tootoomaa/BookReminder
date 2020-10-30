//
//  SearchBookCustomCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class SearchBookCustomCell: UICollectionViewCell {
  
  // MARK: - Properties
  static let identifier = "SearchBookCus"
  
  let textDistance: CGFloat = 20
  
  let bookThumbnailImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.backgroundColor = .gray
    imageView.contentMode = .scaleAspectFit
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = UIColor.systemGray3.cgColor
    imageView.backgroundColor = .systemGray6
    return imageView
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "책이름 :"

    return label
  }()
  
  let nameValueLable: UILabel = {
    let label = UILabel()
    return label
  }()
  
  let publishurLabel: UILabel = {
    let label = UILabel()
    label.text = "출판사 :"
    return label
  }()
  
  let publishurValueLable: UILabel = {
    let label = UILabel()
    return label
  }()
  
  let authorsLabel: UILabel = {
    let label = UILabel()
    label.text = "작가명 :"
    return label
  }()
  
  let authorsValueLable: UILabel = {
    let label = UILabel()
    return label
  }()
  
  let publisherDateLabel: UILabel = {
    let label = UILabel()
    label.text = "출판일 :"
    return label
  }()
  
  let publisherDateValueLable: UILabel = {
    let label = UILabel()
    return label
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.layer.cornerRadius = 20
    self.clipsToBounds = true
    
    backgroundColor = #colorLiteral(red: 1, green: 0.8854463696, blue: 0.9086633325, alpha: 1)
    
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    [bookThumbnailImageView, nameLabel, publishurLabel, authorsLabel, publisherDateLabel,
     nameValueLable, publishurValueLable, authorsValueLable, publisherDateValueLable].forEach{
      addSubview($0)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(20)
      $0.bottom.equalTo(self).offset(-20)
      $0.width.equalTo(bookThumbnailImageView.snp.height).multipliedBy(0.68)
    }
    
    nameLabel.snp.makeConstraints{
      $0.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(textDistance)
      $0.top.equalTo(bookThumbnailImageView.snp.top)
    }
    
    nameValueLable.snp.makeConstraints{
      $0.leading.equalTo(nameLabel.snp.trailing).offset(textDistance/2)
      $0.trailing.equalTo(self.snp.trailing).offset(-10)
      $0.centerY.equalTo(nameLabel)
    }
    
    publishurLabel.snp.makeConstraints{
      $0.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(textDistance)
      $0.top.equalTo(nameLabel.snp.bottom)
      $0.height.equalTo(nameLabel).multipliedBy(1)
    }
    
    publishurValueLable.snp.makeConstraints{
      $0.leading.equalTo(publishurLabel.snp.trailing).offset(textDistance/2)
      $0.trailing.equalTo(self.snp.trailing).offset(-10)
      $0.centerY.equalTo(publishurLabel)
    }
    
    authorsLabel.snp.makeConstraints{
      $0.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(textDistance)
      $0.top.equalTo(publishurLabel.snp.bottom)
      $0.height.equalTo(nameLabel).multipliedBy(1)
    }
    
    authorsValueLable.snp.makeConstraints{
      $0.leading.equalTo(authorsLabel.snp.trailing).offset(textDistance/2)
      $0.trailing.equalTo(self.snp.trailing).offset(-10)
      $0.centerY.equalTo(authorsLabel)
    }
    
    publisherDateLabel.snp.makeConstraints{
      $0.leading.equalTo(bookThumbnailImageView.snp.trailing).offset(textDistance)
      $0.top.equalTo(authorsLabel.snp.bottom)
      $0.bottom.equalTo(bookThumbnailImageView.snp.bottom)
      $0.height.equalTo(nameLabel).multipliedBy(1)
    }
    
    publisherDateValueLable.snp.makeConstraints{
      $0.leading.equalTo(publisherDateLabel.snp.trailing).offset(textDistance/2)
      $0.trailing.equalTo(self.snp.trailing).offset(-10)
      $0.centerY.equalTo(publisherDateLabel)
    }
  }
}
