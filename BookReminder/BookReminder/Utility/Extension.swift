//
//  DatabaseExtension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit



// MARK: - URLComponents Extension
extension URLComponents {

  mutating func setQueryItems(with parameters: [String: String]) {
    self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
  }
  
}

// MARK: - NSAttributedString Extension
extension NSAttributedString {
  
  static func configureAttributedString(systemName: String, setText: String) -> NSAttributedString {
    
    if let symbol = UIImage(systemName: systemName) {
      let imageAttachment = NSTextAttachment(image: symbol)
      
      let fullString = NSMutableAttributedString()
      fullString.append(NSAttributedString(attachment: imageAttachment))
      fullString.append(NSAttributedString(string: "  "))
      fullString.append(NSAttributedString(string: setText))
      
      return fullString
    }
    
    return NSAttributedString.init(string: "nil")
  }
}

// MARK: - UIAlertExtension

extension UIAlertController {
  
  static func defaultSetting(title: String, message: String) -> UIAlertController {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .default) { (_) in }
    
    alertController.addAction(confirmAction)
    
    return alertController
  }
  
  static func okCancelSetting(title: String, message: String, okAction: UIAlertAction) -> UIAlertController {
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    
    let okAction = okAction
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in
      
    }
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }
  
}
