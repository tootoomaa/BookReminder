//
//  CommendListWebService.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class CommentListWebService: CommentWebServiceProtocol {
    
    func fetchUserComments(_ selectedBook: Book) -> Observable<[Comment]> {
      return Observable<[Comment]>.create { observer -> Disposable in
        
        guard let uid = Auth.auth().currentUser?.uid else { fatalError("Fail to get Uid") }
        guard let isbnCode = selectedBook.isbn else { fatalError("Fail to get Book isbnCode") }
        
        DB_REF_COMMENT.child(uid).child(isbnCode).observeSingleEvent(of: .value) { (snapshot) in
          
          if let value = snapshot.value as? Dictionary<String, AnyObject> {
            
            let commentList = value.map { key, value -> Comment in
              return Comment(commentUid: key, dictionary: value as! Dictionary<String, AnyObject>)
            }.sorted {
              $0.sortedInt > $1.sortedInt
            }
            
            observer.onNext(commentList)
          } else {
            observer.onNext([])
          }
        }
        
        return Disposables.create()
      }
    }
    
    func fetchUpdatedUserComments(_ selectedBook: Book) -> Observable<[Comment]> {
      return Observable<[Comment]>.create { observer -> Disposable in
        
        guard let uid = Auth.auth().currentUser?.uid else { fatalError("Fail to get Uid") }
        guard let isbnCode = selectedBook.isbn else { fatalError("Fail to get Book isbnCode") }
        
        DB_REF_COMMENT.child(uid).child(isbnCode).observe(.value) { (snapshot) in
          
          if let value = snapshot.value as? Dictionary<String, AnyObject> {
            
            let commentList = value.map { key, value -> Comment in
              return Comment(commentUid: key, dictionary: value as! Dictionary<String, AnyObject>)
            }.sorted {
              $0.sortedInt > $1.sortedInt
            }
            
            observer.onNext(commentList)
          } else {
            print("non VBalu")
            observer.onNext([])
          }
        }
        
        return Disposables.create()
      }
    }
}
