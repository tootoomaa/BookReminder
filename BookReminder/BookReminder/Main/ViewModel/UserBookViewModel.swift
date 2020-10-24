//
//  UserBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift

struct UserBookListModel {
  let books: [UserBookModel]
  
  init(_ books:[Book]) {
    self.books = books.compactMap(UserBookModel.init)
  }
}

extension UserBookListModel {
  
  func bookAt(_ index: Int) -> UserBookModel {
    return books[index]
  }
  
}

struct UserBookModel {
  
  let book: Book
  
  init(_ book: Book) {
    self.book = book
  }
  
}

extension UserBookModel {
  
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
