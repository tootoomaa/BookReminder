//
//  MyBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/26.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import Firebase

struct MyBookListViewModel {
  
  var myBooks: [MyBookViewModel]
  
  lazy var allcase = BehaviorRelay(value: myBooks)
  
  init(_ books: [Book]) {
    self.myBooks = books.compactMap(MyBookViewModel.init)
  }
}

extension MyBookListViewModel {
  func checkSameBook(_ isbnCode: String) -> Bool {
    var isSameBook = false
    self.myBooks.forEach {
      if $0.book.isbn == isbnCode { isSameBook = true }
    }
    return isSameBook
  }
  
  func bookAt(_ index: Int) -> MyBookViewModel {
    return myBooks[index]
  }
  
  mutating func reloadData() {
    allcase.accept(myBooks)
  }
  
  mutating func addMyBook(_ newbook: Book, value: Dictionary<String, AnyObject>) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    self.myBooks.insert(MyBookViewModel(newbook), at: 0)
    
    guard let isbnCode = newbook.isbn else { return }
    DB_REF_COMMENT_STATICS.child(uid).updateChildValues([isbnCode:0])
    DB_REF_USERBOOKS.child(uid).updateChildValues([isbnCode: value])
    Database.userProfileStaticsHanlder(uid: uid,
                                       plusMinus: .plus,
                                       updateCategory: .enrollBookCount,
                                       amount: 1)
  }
  
  mutating func removeMyBook(_ removeBookIndex: IndexPath) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    
    Database.bookDeleteHandler(uid: uid, deleteBookData: myBooks[removeBookIndex.item].book)
    
    self.myBooks.remove(at: removeBookIndex.item)
  }
}

struct MyBookViewModel {
  let book: Book
  
  init(_ book: Book) {
    self.book = book
  }
}
