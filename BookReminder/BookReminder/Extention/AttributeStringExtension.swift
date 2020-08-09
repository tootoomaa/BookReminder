//
//  AttributeStringExtension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/08.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit


extension NSAttributedString {
  
  static func configureAttributedString(systemName: String, setText: String) -> NSAttributedString {
    
    if let symbol = UIImage(systemName: systemName) {
      let imageAttachment = NSTextAttachment(image: symbol)
      
      let fullString = NSMutableAttributedString()
      fullString.append(NSAttributedString(attachment: imageAttachment))
      fullString.append(NSAttributedString(string: "    "))
      fullString.append(NSAttributedString(string: setText))
      
      return fullString
    }
    
    return NSAttributedString.init(string: "nil")
  }
}
