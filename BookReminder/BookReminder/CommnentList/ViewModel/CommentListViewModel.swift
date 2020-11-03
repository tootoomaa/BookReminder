//
//  CommentListViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth

// MARK: - CommentListViewModel
struct CommentListViewModel {
  
  var commentList: [CommentViewModel]
  
  lazy var allcase = BehaviorRelay<[CommentViewModel]>(value: commentList)
  
  init(_ comments: [Comment]) {
    self.commentList = comments.compactMap(CommentViewModel.init)
  }
}

extension CommentListViewModel {
  
  mutating func deleteComment(_ isbnCode: String, _ indexPath: IndexPath) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let comment = commentList[indexPath.row].comment
    
    DB_REF_COMMENT.child(uid).child(isbnCode).child(comment.commentUid).removeValue()
    Database.commentCountHandler(uid: uid, isbnCode: isbnCode, plusMinus: .down)
    Storage.storage().reference(forURL: comment.captureImageUrl).delete(completion: nil)
    
    commentList.remove(at: indexPath.row)
    
    reloadData()
  }
  
  mutating func reloadData() {
    allcase.accept(commentList)
  }
  
}

// MARK: - CommentViewModel
struct CommentViewModel {
  
  let comment: Comment
  
  init(_ comment: Comment) {
    self.comment = comment
  }
}

extension CommentViewModel {
  
  var captureImageUrl: Observable<String> {
    return Observable<String>.just(comment.captureImageUrl)
  }
  
  var myComment: Observable<String> {
    return Observable<String>.just(comment.myComment)
  }
  
  var page: Observable<String> {
    return Observable<String>.just(comment.page)
  }
  
  var creationDate: Observable<Int> {
    return Observable<Int>.just(comment.creationDate)
  }
}

extension CommentViewModel {
  
  static func fetchUserComments(_ selectedBook: Book) -> Observable<[Comment]>{
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
          print("non VBalu")
          observer.onNext([])
        }
      }
      
      return Disposables.create()
    }
  }
  
  static func fetchUpdatedUserComments(_ selectedBook: Book) -> Observable<[Comment]>{
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
