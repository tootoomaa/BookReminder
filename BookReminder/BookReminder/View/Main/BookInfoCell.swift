//
//  BookInfoCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class BookInfoCell: UITableViewCell {
  
  // MARK: - Properties
  static let identifier = "BookInfoCell"
  
  let myBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = CommonUI.subBackgroundColor
    view.layer.cornerRadius = 25
    view.clipsToBounds = true
    return view
  }()
  
  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = .white
    
    addSubview(myBackgroundView)
    
    myBackgroundView.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(10)
      $0.bottom.trailing.equalTo(self).offset(-10)
    }
    
    let statusStackView = configureStackView(commentCount: 10, readBookPercent: 10)
    
    [statusStackView].forEach{
      myBackgroundView.addSubview($0)
    }
    
    statusStackView.snp.makeConstraints{
      $0.top.equalTo(myBackgroundView.snp.top).offset(10)
      $0.leading.equalTo(myBackgroundView.snp.leading).offset(20)
      $0.trailing.equalTo(myBackgroundView.snp.trailing).offset(-20)
      $0.centerX.equalTo(myBackgroundView.snp.centerX)
      $0.height.equalTo(100)
    }
    
  }
  
  func configureStackView(commentCount: Int, readBookPercent: Int) -> UIStackView {
    // 1번 - 사용자 코멘트 겟수 - 그림 􀈎 square.and.pencil
    // 2번 - 책 읽은 진행 - 그림  􀉚  book
    
    var uiViewList = [UIView]()
    
    for index in 0..<2 {
      let symbol = UIImage(systemName: (index == 1) ? "square.and.pencil" : "book")!
      let imageAttachment = NSTextAttachment(image: symbol)
      
      let fullString = NSMutableAttributedString()
      fullString.append(NSAttributedString(attachment: imageAttachment))
      fullString.append(NSAttributedString(string: " "))
      
      fullString.append(NSAttributedString(string: (index == 1) ? "위치 정보" : "추가 정보"))
      
      let headerLabel = UILabel()
      headerLabel.font = .preferredFont(forTextStyle: .footnote)
      headerLabel.textColor = .white //.label
      headerLabel.attributedText = fullString
//      headerLabel.sizeToFit()
      headerLabel.backgroundColor = CommonUI.titleTextColor
      headerLabel.textAlignment = .center
//      headerLabel.frame.origin = .init(x: 16, y: 16)
      uiViewList.append(headerLabel)
    }
    
    let stackView = UIStackView(arrangedSubviews: uiViewList)
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .fillEqually
    stackView.spacing = 20

    return stackView
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
