//
//  UserBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift

struct MarkedBookListModel {
  var books: [MarkedBookModel]
  
  init(_ books:[Book]) {
    self.books = books.compactMap(MarkedBookModel.init)
  }
}

extension MarkedBookListModel {
  
  func bookAt(_ index: Int) -> MarkedBookModel {
    return books[index]
  }
  
  mutating func addBook(_ addBook: Book) {
    let addBookModel = MarkedBookModel(addBook)
    self.books.append(addBookModel)
  }
  
  mutating func removeBook(_ removeBook: Book) {
    let removeBookModel = MarkedBookModel(removeBook)
    if let index = self.books.firstIndex(of: removeBookModel) {
      self.books.remove(at: index)
    }
  }
}

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
  
//  var authors: [String]!
//  var contents: String!
//  var datetime: String!
//  var isbn: String!
//  var price: Int!
//  var publisher: String!
//  var sale_price: Int!
//  var status: String!
//  var thumbnail: String!
//  var title: String!
//  var translators: [String]?
//  var url: String!
//  var creationDate: Int!
  
}
