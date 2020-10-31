//
//  DetailBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/30.
//  Copyright © 2020 김광수. All rights reserved.
//

import RxSwift
import RxCocoa

class DetailBookViewModel {
  let book: Book
  
  lazy var allcase = BehaviorSubject(value: displayValue)
  
  var displayValue: [Observable<(label:String, value: String)>] {
    return [authors, publisher, publishDatetime, isbnCode, price]
  }
  
  init(_ book: Book) {
    self.book = book
  }
}

extension DetailBookViewModel {
  // ["저자명", "출판사", "출간일", "isbn코드", "가격"]
  var authors: Observable<(label: String, value: String)> {
    let labelValue = "저자명"
    var authorValue = ""
    if !book.authors.isEmpty { authorValue = book.authors[0] }
    return Observable<(label: String, value: String)>.just((labelValue, authorValue))
  }
  
  var publisher: Observable<(label: String, value: String)> {
    let labelValue = "출판사"
    return Observable<(label: String, value: String)>.just((labelValue, book.publisher))
  }
  
  var publishDatetime: Observable<(label: String, value: String)> {
    let labelValue = "출간일"
    let tempData = book.datetime
    var returnValue = ""
    if let date = tempData?.split(separator: "T") {
      returnValue = String(date[0])
    }
    return Observable<(label: String, value: String)>.just((labelValue, returnValue))
  }
  
  var isbnCode: Observable<(label: String, value: String)> {
    let labelValue = "isbn코드"
    let tempData = book.isbn
    var returnValue = ""
    if let date = tempData?.split(separator: " ") {
      returnValue = String(date[0])
    }
    return Observable<(label: String, value: String)>.just((labelValue, returnValue))
  }
  
  var price: Observable<(label: String, value: String)> {
    let labelValue = "가격"
    let priceString = book.price.toPriceString()
    return Observable<(label: String, value: String)>.just((labelValue, priceString))
  }
  
  var summary: Observable<String> {
    return Observable<String>.just(book.contents)
  }
}
