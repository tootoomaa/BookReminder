//
//  CommentListCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/15.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class CommentListCell: UITableViewCell {
  
  // MARK: - Properties
  static let identifier = "CommentListCell"
  
  let captureImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.backgroundColor = .systemGray4
    return imageView
  }()
  
  let myThinkLabel: UILabel = {
    let label = UILabel()
    label.text = "내 생각.."
    return label
  }()
  
  let pageLabel: UILabel = {
    let label = UILabel()
    label.text = "5p"
    label.font = .boldSystemFont(ofSize: 15)
    label.backgroundColor = .white
    return label
  }()
  
  let myTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .systemGray6
    textView.autocorrectionType = .no
    textView.autocapitalizationType = .none
    textView.autoresizingMask = .flexibleHeight
    textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    textView.font = .systemFont(ofSize: 15)
    textView.layer.cornerRadius = 20
    textView.clipsToBounds = true
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  // MARK: - LifeCycle
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    
    [captureImageView, myTextView, pageLabel].forEach{
      addSubview($0)
    }
    
    captureImageView.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(10)
      $0.bottom.equalTo(self).offset(-10)
      $0.width.equalTo(captureImageView.snp.height)
    }
    
    myTextView.snp.makeConstraints{
      $0.top.bottom.equalTo(captureImageView)
      $0.leading.equalTo(captureImageView.snp.trailing).offset(5)
      $0.trailing.equalTo(self).offset(-5)
    }
    
    pageLabel.snp.makeConstraints{
      $0.top.equalTo(self).offset(20)
      $0.leading.equalTo(self).offset(20)
    }
  }
  
  func configure( captureImageUrl: String, pageString: String, myCommentText: String) {
    
    captureImageView.loadImage(urlString: captureImageUrl)
    pageLabel.text = "\(pageString)P"
    myTextView.text = myCommentText
  }
}
