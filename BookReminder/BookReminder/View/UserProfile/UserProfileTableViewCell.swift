//
//  UserProfileTableViewCell.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/15.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit

class UserProfileTableViewCell: UITableViewCell {

  static let identifier = "UserProfileTalbeViewCell"
  
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
  
  let detailContextButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    [titleLabel, contextLabel, detailContextButton].forEach{
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
    
    detailContextButton.snp.makeConstraints{
      $0.trailing.equalTo(self).offset(-30)
      $0.centerY.equalTo(self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(titleText: String, contextText: String, isNeedDetailMenu: Bool) {
    
    titleLabel.text = titleText
    contextLabel.text = contextText
    
    detailContextButton.isHidden = !isNeedDetailMenu
    contextLabel.isHidden = isNeedDetailMenu
    
  }
}
