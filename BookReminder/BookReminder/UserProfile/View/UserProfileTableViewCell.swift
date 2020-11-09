//
//  UserProfileTableViewCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {
  static let identifier = "UserProfileTableViewCell"
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "labelText"
    return label
  }()
  
  let contextLabel: UILabel = {
    let label = UILabel()
    label.text = "context"
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    [titleLabel, contextLabel].forEach{
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints{
      $0.leading.equalTo(safeAreaLayoutGuide).offset(20)
      $0.centerY.equalTo(safeAreaLayoutGuide)
    }
    
    contextLabel.snp.makeConstraints{
      $0.trailing.equalTo(safeAreaLayoutGuide).offset(-20)
      $0.centerY.equalTo(safeAreaLayoutGuide)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
