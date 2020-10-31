//
//  DetailBookInfoFooterView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class DetailBookInfoFooterView: UIView {

  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "줄거리"
    return label
  }()

  let myTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .systemGray6
    textView.autocorrectionType = .no
    textView.autocapitalizationType = .none
    textView.autoresizingMask = .flexibleHeight
    textView.isSelectable = false
    textView.isUserInteractionEnabled = false
    textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    textView.font = .systemFont(ofSize: 15)
    textView.layer.cornerRadius = 20
    textView.clipsToBounds = true
    return textView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    [titleLabel, myTextView].forEach{
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(10)
    }
    
    myTextView.snp.makeConstraints{
      $0.top.equalTo(titleLabel.snp.bottom).offset(10)
      $0.leading.equalTo(self).offset(10)
      $0.trailing.bottom.equalTo(self).offset(-10)
    }
  }
}
