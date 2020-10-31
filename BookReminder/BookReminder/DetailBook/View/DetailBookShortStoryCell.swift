//
//  DetailBookShortStoryCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class DetailBookShortStoryCell: UITableViewCell {

  static let identifier = "DetailBookShortStoryCell"
  
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
    return textView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    [myTextView].forEach{
      addSubview($0)
    }

    myTextView.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(5)
      $0.trailing.bottom.equalTo(self).offset(-5)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(context: String) {
    myTextView.text = context
  }
}
