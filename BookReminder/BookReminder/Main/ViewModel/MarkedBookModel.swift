//
//  UserBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

// MARK: - Book List Model
struct MarkedBookListModel {
  var books: [MarkedBookModel]
  
  lazy var allcase = BehaviorRelay(value: books)
  
  init(_ books:[Book]) {
    self.books = books.compactMap(MarkedBookModel.init)
  }
}

extension MarkedBookListModel {
  
  mutating func reloadData() {
    allcase.accept(books.count == 0 ? [MarkedBookModel(Book.empty())] : books)
  }
  
  func bookAt(_ index: Int) -> MarkedBookModel? {
    guard !self.books.isEmpty else { return nil }
    return books[index]
  }
  
  mutating func addMarkedBook(_ addBook: Book) {
    let addBookModel = MarkedBookModel(addBook)
    self.books.append(addBookModel)
  }
  
  mutating func removeMarkedBook(_ removeBookModel: MarkedBookModel) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let isbnCode = removeBookModel.book.isbn else { return }
    
    /* [ 북마크된 책이 삭제될때 같이 지워져야 되는 사항
     1. 등록 권수 통계 값 -1
     2. 사용자 북마크 북 리스트에서 삭제
     */
    if let index = self.books.firstIndex(of: removeBookModel) {
      DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue()
      self.books.remove(at: index)
    }
  }
}

extension MarkedBookListModel {
  
  func fetchMarkedBookCommentCountAt(_ index: IndexPath) -> Observable<NSAttributedString>? {
    if let uid = Auth.auth().currentUser?.uid, !self.books.isEmpty {
      
      guard let isbnCode = self.books.first?.book.isbn else {
        return Observable<NSAttributedString>.just(NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "0"))
      }
    
      return Observable<NSAttributedString>.create({ (observer) -> Disposable in
        DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observe(.value) { (snapshot) in
          
          guard let value = snapshot.value as? Int else { return }
          let attributedString = NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "\(value)")
          observer.onNext(attributedString)
        }
        return Disposables.create()
      })
    } else {
      return Observable<NSAttributedString>.just(NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "0"))
    }
  }
}

// MARK: - Book Model
struct MarkedBookModel: Equatable{
  
  let book: Book
  
  init(_ book: Book) {
    self.book = book
  }
}

extension MarkedBookModel {
  
  var thumbnail: Observable<String> {
    return Observable<String>.just(self.book.thumbnail)
  }
}
