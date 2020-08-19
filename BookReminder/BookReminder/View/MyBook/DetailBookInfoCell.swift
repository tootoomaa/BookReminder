//
//  DetailBookInfoCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class DetailBookInfoCell: UITableViewCell {
  
  // MARK: - Properties
  static let identifier = "DetailBookInfoCell"
  
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
      $0.leading.equalTo(self).offset(20)
      $0.centerY.equalTo(self)
    }
    
    contextLabel.snp.makeConstraints{
      $0.trailing.equalTo(self).offset(-20)
      $0.centerY.equalTo(self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(titleText: String, contextText: String) {
    
    titleLabel.text = titleText
    contextLabel.text = contextText
  }
}
