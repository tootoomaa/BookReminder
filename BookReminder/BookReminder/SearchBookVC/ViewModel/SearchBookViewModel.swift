//
//  SearchBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/28.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchBookListViewModel {
  
  var searchBooks: [SearchBookViewModel]
  
  lazy var allcase = BehaviorRelay(value: [SearchBookViewModel]() )
  
  init(_ searchBookList: [SearchBook]) {
    self.searchBooks = searchBookList.compactMap(SearchBookViewModel.init)
  }
}

extension SearchBookListViewModel {
  
  mutating func reloadData() {
    allcase.accept(searchBooks)
  }
  
}

struct SearchBookViewModel {
  
  let searchBook: SearchBook
  
  init(_ searchBook: SearchBook) {
    
    self.searchBook = searchBook
  }
}

extension SearchBookViewModel {
  
  var author: Observable<String> {
    
    var authors: String = ""
    
    self.searchBook.authors.forEach {
      authors.append("\($0) ")
    }
    
    return Observable<String>.just(authors)
  }
  
  var datetime: Observable<String> {
    return Observable<String>.just(self.searchBook.datetime)
  }
  
  var bookName: Observable<String> {
    return Observable<String>.just(self.searchBook.title)
  }
  
  var publish: Observable<String> {
    return Observable<String>.just(self.searchBook.publisher)
  }
  
  var publishDate: Observable<String> {
    return Observable<String>.just(self.searchBook.datetime)
  }
  
}
