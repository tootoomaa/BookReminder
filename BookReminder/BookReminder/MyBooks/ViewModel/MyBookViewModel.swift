//
//  MyBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/26.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth

struct MyBookListViewModel {
  let myBooks: [MyBookViewModel]
  
  init(_ books: [Book]) {
    self.myBooks = books.compactMap(MyBookViewModel.init)
  }
}

struct MyBookViewModel {
  let book: Book
  
  init(_ book: Book) {
    self.book = book
  }
}
