//
//  Database+Extension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/25.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Database Extension
extension Database {
  // uid와 isbn 코드를 통한 책 정보 추출
  static func fetchBookDetailData(uid: String, isbnCode: String, complition: @escaping(Book) -> ()) {
    
    DB_REF_USERBOOKS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      let key = snapshot.key
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      
      let bookDetailInfo = Book(isbnCode: key, dictionary: dictionary)
      
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
  
  enum UpDownController: String {
    case plus
    case down
  }
  
  enum UserProfileStatics: String {
    case commentCount
    case compliteBookCount
    case enrollBookCount
  }
  
  static func commentCountHandler(uid: String, isbnCode: String, plusMinus: UpDownController) {
    DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      guard let commentCount = snapshot.value as? Int else { return }
      if plusMinus == .plus {
        DB_REF_COMMENT_STATICS.child(uid).updateChildValues([isbnCode: commentCount + 1])
      } else if plusMinus == .down {
        DB_REF_COMMENT_STATICS.child(uid).updateChildValues([isbnCode: commentCount - 1])
      }
    }
    userProfileStaticsHanlder(uid: uid, plusMinus: plusMinus, updateCategory: .commentCount, amount: 1)
  }
  
  static func userProfileStaticsHanlder(uid: String, plusMinus: UpDownController, updateCategory: UserProfileStatics, amount: Int) {
    DB_REF_USERPROFILE.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      guard var value = snapshot.value as? Dictionary<String, Int> else { return print("Fail to get data")}
      guard let count = value[updateCategory.rawValue] else { return }
     
      if plusMinus == .plus {
        value.updateValue(count+amount, forKey: updateCategory.rawValue)
      } else {
        value.updateValue(count-amount, forKey: updateCategory.rawValue)
      }
      
      DB_REF_USERPROFILE.child(uid).updateChildValues(value)
    }
  }
  
  static func bookDeleteHandler(uid: String, deleteBookData: Book) {
    guard let isbnCode = deleteBookData.isbn else { return }
    
    /*
     1. 코멘트 별 이미지 삭제
     2. 코멘트 카운트 감소
     3. 코멘트 정보 삭제
     
     4. 책 등록 정보 삭제
     5. 책 등록 카운드 정보 다운
     
     6. 북마트 되어 있다면 삭제
     
     7. 책 완독 등록되 었을시 완독권수 -1
     */
    
    // 코멘트 관련 내용 삭제
    DB_REF_COMMENT.child(uid).child(isbnCode).observeSingleEvent(of: .value) { snapshot in
      
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      
      // 1. 코멘트별 이미지 삭제
      dictionary.forEach{
        guard let commentDicData = $0.value as? Dictionary<String, AnyObject> else { return }
        let comment = Comment(commentUid: $0.key, dictionary: commentDicData)
        
        if let imageURL = comment.captureImageUrl {
          Storage.storage().reference(forURL: imageURL).delete(completion: nil)
        }
      }
      
      DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
        // 2. 총 코맨트 갯수 감소
        guard let deleteBookCommentCount = snapshot.value as? Int else { return }
        userProfileStaticsHanlder(uid: uid,
                                  plusMinus: .down,
                                  updateCategory: .commentCount,
                                  amount: deleteBookCommentCount)
        // 3. 코멘트 정보 삭제 ( 글, comment uid 등 )
        DB_REF_COMMENT.child(uid).child(isbnCode).removeValue()
      }
    }
    
    
    //[책 정보 삭제]
    // 4. 책 등록 정보 삭제
    DB_REF_USERBOOKS.child(uid).child(isbnCode).removeValue()
    // 5. 책 등록 카운드 정보 다운
    userProfileStaticsHanlder(uid: uid,
                              plusMinus: .down,
                              updateCategory: .enrollBookCount,
                              amount: 1)
    // 6.북마크된 경우 삭제
    DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue()
    
    // 완료된 경우 처리 방법
    DB_REF_COMPLITEBOOKS.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
      
      // 완독 된 책이면 1 감소
      if (snapshot.value as? Int) != nil {
        userProfileStaticsHanlder(uid: uid, plusMinus: .down, updateCategory: .compliteBookCount, amount: 1)
        DB_REF_COMPLITEBOOKS.child(uid).child(isbnCode).removeValue()
      }
    }
  }
}
