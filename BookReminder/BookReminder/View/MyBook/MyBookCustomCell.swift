//
//  MyBookCustomCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class MyBookCustomCell: UICollectionViewCell {
  
  // MARK: - Properites
  static let identifier = "MyBoolCell"
  var bookDetailInfo: BookDetailInfo?
  var passButtonName: ((String, BookDetailInfo, Bool)->())?
  var isbnCode: String?
  
  let bookThumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .gray
    imageView.contentMode = .scaleAspectFit
    
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = UIColor.systemGray3.cgColor
    
    return imageView
  }()
  
  let blurView: UIVisualEffectView = {
    let blurEffet = UIBlurEffect(style: .dark)
    return UIVisualEffectView(effect: blurEffet)
  }()
  
  let markImage: UIImageView = {
    let imageView = UIImageView()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
    let bookmarkImage = UIImage(systemName: "bookmark.fill", withConfiguration: imageConfigure)
    imageView.image = bookmarkImage
    imageView.isHidden = true
    imageView.tintColor = .systemPink
    return imageView
  }()
  
  let compliteImage: UIImageView = {
    let imageView = UIImageView()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .medium)
    let bookmarkImage = UIImage(systemName: "checkmark.seal.fill", withConfiguration: imageConfigure)
    imageView.image = bookmarkImage
    imageView.isHidden = true
    imageView.backgroundColor = .white
    imageView.tintColor = .systemBlue
    imageView.layer.cornerRadius = 15
    imageView.clipsToBounds = true
    return imageView
  }()
  
  lazy var markButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
    let bookmarkImage = UIImage(systemName: "bookmark", withConfiguration: imageConfigure)
    let fillBookmarkImage = UIImage(systemName: "bookmark.fill", withConfiguration: imageConfigure)
    button.addTarget(self, action: #selector(tabButtonHander(_:)), for: .touchUpInside)
    button.isSelected = false
    button.setImage(bookmarkImage, for: .normal)
    button.setImage(fillBookmarkImage, for: .selected)
    button.tintColor = .white
    return button
  }()
  
  lazy var commentButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
    let bookmarkImage = UIImage(systemName: "bubble.left.fill", withConfiguration: imageConfigure)
    button.addTarget(self, action: #selector(tabButtonHander(_:)), for: .touchUpInside)
    button.setImage(bookmarkImage, for: .normal)
    button.tintColor = .white
    return button
  }()
  
  lazy var infoButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
    let bookmarkImage = UIImage(systemName: "info.circle.fill", withConfiguration: imageConfigure)
    button.addTarget(self, action: #selector(tabButtonHander(_:)), for: .touchUpInside)
    button.setImage(bookmarkImage, for: .normal)
    button.tintColor = .white
    return button
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    blurView.alpha = 0
  
    [bookThumbnailImageView, markImage, compliteImage, blurView].forEach{
      addSubview($0)
    }
    
    bookThumbnailImageView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
    
    blurView.snp.makeConstraints{
      $0.top.leading.trailing.bottom.equalTo(self)
    }
    
    markImage.snp.makeConstraints{
      $0.top.equalTo(self)
      $0.trailing.equalTo(self).offset(-5)
    }
    
    compliteImage.snp.makeConstraints{
      $0.trailing.bottom.equalTo(self).offset(-5)
    }
    
    let buttonView = [markButton, commentButton, infoButton]
    
    let stackview = UIStackView(arrangedSubviews: buttonView)
    stackview.distribution = .equalSpacing
    stackview.axis = .vertical
    stackview.spacing = 20
    stackview.alignment = .center
    
    blurView.contentView.addSubview(stackview)
    stackview.snp.makeConstraints{
      $0.centerY.centerX.equalTo(blurView)
    }
    
  }
  
  func configure(bookDetailInfo: BookDetailInfo) {
    
    isbnCode = bookDetailInfo.isbn
    self.bookDetailInfo = bookDetailInfo
    guard let urlString = bookDetailInfo.thumbnail else { return }
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("error",error.localizedDescription)
        return
      }
      
      guard let data = data else { return }
      
      DispatchQueue.main.async {
        self.bookThumbnailImageView.image = UIImage(data: data)
      }
      
    }.resume()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // 책 내부의 디테일 엑션 버튼 전달
  @objc func tabButtonHander(_ sender: UIButton) {
    
    let buttonName = sender == markButton ? "mark" : sender == commentButton ? "comment" : "info"
    if buttonName == "mark" {
      sender.isSelected.toggle()
      markImage.isHidden.toggle()
    }
    
    guard let passButtonName = passButtonName,
          let bookDetailInfo = bookDetailInfo else { return }
    passButtonName(buttonName, bookDetailInfo, markImage.isHidden)
    
  }
}
