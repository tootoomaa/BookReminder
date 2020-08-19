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
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    return view
  }()
  
  let statusBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = CommonUI.titleTextColor
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    return view
  }()
  
  let commentLabel: UILabel = {
    let label = UILabel()
    let fullString = NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "0")
    label.font = .systemFont(ofSize: 15)
    label.textColor = .white
    label.attributedText = fullString
    label.textAlignment = .center
    label.isUserInteractionEnabled = true
    return label
  }()
  
  let seperateView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  let bookMarkLabel: UILabel = {
    let label = UILabel()
    let fullString = NSAttributedString.configureAttributedString(systemName: "bookmark.fill", setText: "북마크 제거")
    label.font = .systemFont(ofSize: 15)
    label.textColor = .white
    label.attributedText = fullString
    label.textAlignment = .center
    label.isUserInteractionEnabled = true
    return label
  }()
  
  let commentAddButton: UIButton = {
    let button = UIButton()
    let fullString = NSAttributedString.configureAttributedString(systemName: "plus.bubble.fill", setText: "추가")
    button.setAttributedTitle(fullString, for: .normal)
    button.backgroundColor = .white
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    return button
  }()
  
  let commentEditButton: UIButton = {
    let button = UIButton()
    let fullString = NSAttributedString.configureAttributedString(systemName: "pencil.and.ellipsis.rectangle", setText: "수정")
    button.setAttributedTitle(fullString, for: .normal)
    button.backgroundColor = .white
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    return button
  }()
  
  let compliteButton: UIButton = {
    let button = UIButton()
    let fullString = NSAttributedString.configureAttributedString(systemName: "checkmark.seal.fill",
                                                                  setText: "완독")
    button.setAttributedTitle(fullString, for: .normal)
    button.backgroundColor = .white
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    return button
  }()
  
  
  
  // MARK: - Init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = .white
    
    configureLayout()
    
  }
  
  private func configureLayout() {
    
    addSubview(myBackgroundView)
    
    myBackgroundView.snp.makeConstraints{
      $0.top.leading.equalTo(self).offset(10)
      $0.bottom.trailing.equalTo(self).offset(-10)
    }
    
    [statusBackgroundView, commentAddButton, commentEditButton, compliteButton].forEach{
      myBackgroundView.addSubview($0)
    }
    
    statusBackgroundView.snp.makeConstraints{
      $0.top.equalTo(myBackgroundView.snp.top).offset(20)
      $0.leading.equalTo(myBackgroundView.snp.leading).offset(20)
      $0.trailing.equalTo(myBackgroundView.snp.trailing).offset(-20)
      $0.centerX.equalTo(myBackgroundView.snp.centerX)
    }
    
    commentAddButton.snp.makeConstraints{
      $0.top.equalTo(statusBackgroundView.snp.bottom).offset(20)
      $0.leading.equalTo(myBackgroundView.snp.leading).offset(20)
      $0.bottom.equalTo(myBackgroundView.snp.bottom).offset(-20)
      $0.height.equalTo(statusBackgroundView)
    }
    
    commentEditButton.snp.makeConstraints{
      $0.top.equalTo(statusBackgroundView.snp.bottom).offset(20)
      $0.leading.equalTo(commentAddButton.snp.trailing).offset(20)
      $0.bottom.equalTo(myBackgroundView.snp.bottom).offset(-20)
      $0.width.equalTo(commentAddButton)
    }
    
    compliteButton.snp.makeConstraints{
      $0.top.equalTo(statusBackgroundView.snp.bottom).offset(20)
      $0.leading.equalTo(commentEditButton.snp.trailing).offset(20)
      $0.trailing.equalTo(myBackgroundView.snp.trailing).offset(-20)
      $0.bottom.equalTo(myBackgroundView.snp.bottom).offset(-20)
      $0.width.equalTo(commentEditButton)
    }
  
    let seperateview1 = seperateView
    
    [commentLabel, seperateview1, bookMarkLabel].forEach{
      statusBackgroundView.addSubview($0)
    }
    
    //10*2 20*2 //
    commentLabel.snp.makeConstraints{
      $0.leading.equalTo(statusBackgroundView.snp.leading)
      $0.centerY.equalTo(statusBackgroundView.snp.centerY)
    }
    
    seperateview1.snp.makeConstraints{
      $0.leading.equalTo(commentLabel.snp.trailing)
      $0.centerY.centerX.equalTo(statusBackgroundView)
      $0.height.equalTo(10)
      $0.width.equalTo(1)
    }
    
    bookMarkLabel.snp.makeConstraints{
      $0.leading.equalTo(seperateview1.snp.trailing)
      $0.trailing.equalTo(statusBackgroundView.snp.trailing)
      $0.centerY.equalTo(statusBackgroundView.snp.centerY)
      $0.width.equalTo(commentLabel.snp.width)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
