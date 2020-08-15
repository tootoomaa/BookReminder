//
//  DatabaseExtension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase
import UIKit

// MARK: - Database Extension
extension Database {
  
  
  
  // uid와 isbn 코드를 통한 책 정보 추출
  static func fetchBookDetailData(uid: String, isbnCode: String, complition: @escaping(BookDetailInfo) -> ()) {
    
    DB_REF_USERBOOKS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      let key = snapshot.key
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      
      let bookDetailInfo = BookDetailInfo(isbnCode: key, dictionary: dictionary)
      
      complition(bookDetailInfo)
    }
  }
  
  static func fetchCommentDataList(uid: String, isbnCode: String, complition: @escaping(Comment) -> ()) {
    
    DB_REF_COMMENT.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let value = snapshot.value as? Dictionary<String, AnyObject> else { return }
      
      value.forEach{
        guard let dictionary = $0.value as? Dictionary<String, AnyObject> else { return }
        let comment = Comment(commentUid: $0.key, dictionary: dictionary)
        complition(comment)
      }
    }
  }
}

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

