//
//  DatabaseExtension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Database
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
}
