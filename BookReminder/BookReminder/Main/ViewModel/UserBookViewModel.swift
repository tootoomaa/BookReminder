//
//  UserBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

struct UserBookListModel {
  let books: [UserBookModel]
  
  init(_ books:[Book]) {
    self.books = books.compactMap(UserBookModel.init)
  }
}

struct UserBookModel {
  
  let book: Book
  
  init(_ book: Book) {
    self.book = book
  }
  
}
