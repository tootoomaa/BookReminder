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
  
  
}
