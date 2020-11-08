//
//  Book.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/05.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import RxSwift

struct Book: Equatable {
  var authors: [String]!
  var contents: String!
  var datetime: String!
  var isbn: String!
  var price: Int!
  var publisher: String!
  var sale_price: Int!
  var status: String!
  var thumbnail: String!
  var title: String!
  var translators: [String]?
  var url: String!
  var creationDate: Int!
  
  init( isbnCode: String, dictionary: Dictionary<String, AnyObject>) {
    
    self.isbn = isbnCode
    
    if let authors = dictionary["authors"] as? [String] {
      self.authors = authors
    }
    
    if let contents = dictionary["contents"] as? String {
      self.contents = contents
    }
    
    if let datetime = dictionary["datetime"] as? String {
      self.datetime = datetime
    }
    
    if let price = dictionary["price"] as? Int {
      self.price = price
    }
    
    if let publisher = dictionary["publisher"] as? String {
      self.publisher = publisher
    }
    
    if let sale_price = dictionary["sale_price"] as? Int {
      self.sale_price = sale_price
    }
    
    if let status = dictionary["status"] as? String {
      self.status = status
    }
    
    if let thumbnail = dictionary["thumbnail"] as? String {
      self.thumbnail = thumbnail
    }
    
    if let title = dictionary["title"] as? String {
      self.title = title
    }
    
    if let translators = dictionary["translators"] as? [String] {
      self.translators = translators
    }
    
    if let url = dictionary["url"] as? String {
      self.url = url
    }
    
    if let creationDate = dictionary["creationDate"] as? Int {
      self.creationDate = creationDate
    }
  }
  
  static func == (lhs: Book, rhs: Book) -> Bool {
    lhs.isbn == rhs.isbn
  }
}

extension Book {
  
  static func returnDictionaryValue(documents: Book) -> Dictionary<String, AnyObject> {
    //    guard let documents = documents else { fatalError() }
    let bookDicValue = [
      "authors": documents.authors!,
      "contents": documents.contents!,
      "datetime": documents.datetime!,
      "isbn": documents.isbn!,
      "price": documents.price!,
      "publisher": documents.publisher!,
      "sale_price": documents.sale_price!,
      "status": documents.status!,
      "thumbnail": documents.thumbnail!,
      "title": documents.title!,
      "translators": documents.translators ?? [],
      "url": documents.url!,
      "creationDate": documents.creationDate ?? NSDate().timeIntervalSince1970
    ] as Dictionary<String, AnyObject>
    return bookDicValue
  }
}

// MARK: - Fetch BookS
extension Book {
  
  static func empty() -> Book {
    return Book(isbnCode: "NoData", dictionary: Dictionary<String, AnyObject>())
  }
  
  static func fetchUserBookList() -> Observable<[Book]> {
    return Observable<[Book]>.create { (observer) -> Disposable in
      guard let uid = Auth.auth().currentUser?.uid else { fatalError("Fail to get Uid") }
      DB_REF_USERBOOKS.child(uid).observeSingleEvent(of: .value) { (snapshot, uid) in
        
          /*
         case 1 첫 사용자 값, nil
         case 2 인터넷 에러, nil
         */
        guard let bookDetailInfos = snapshot.value as? Dictionary<String, AnyObject> else {
          observer.onNext([])
          return
        }
        
        let newBookArray = bookDetailInfos.map { key, value -> Book in
          guard let newValue = value as? Dictionary<String, AnyObject> else { fatalError("Fail to change Book") }
          return Book(isbnCode: key, dictionary: newValue)
        }.sorted { (book1, book2) -> Bool in
          book1.creationDate > book2.creationDate
        }
        observer.onNext(newBookArray)
      }
      return Disposables.create()
    }
  }
  
}

// MARK: - fetch Marked books

enum fetchError: Error {
  case getUidError
  case valueValidationError
}

extension Book {
  
  static func fetchMarkedBookIndex() -> Observable<[String]> {
    
    guard let uid = Auth.auth().currentUser?.uid else {
      return Observable.create { observer -> Disposable in
        observer.onNext([])
        observer.onCompleted()
        return Disposables.create()
      }
    }
    
    return Observable.create { observer -> Disposable in      
//      DB_REF_MARKBOOKS.child(uid).observeSingleEvent(of: .value) { snapshot in
      DB_REF_MARKBOOKS.child(uid).observe(.value) { snapshot in
        
        if let markedBookIndex = snapshot.value as? [String: Int] {
          
          let isbnCodeArray = markedBookIndex.map { key, value -> String in
            return "\(key)"
          }
          observer.onNext(isbnCodeArray)
        }
      }
      return Disposables.create()
    }
  }
  
  static func fetchMarkedBooks(_ isbnCode: String) -> Observable<Book> {
    
    guard let uid = Auth.auth().currentUser?.uid else {
      return Observable.create { observer -> Disposable in
        observer.onNext(Book.empty())
        return Disposables.create()
      }
    }
    
    return Observable.create { [isbn = isbnCode] observer -> Disposable in
      
      DB_REF_USERBOOKS.child(uid).child(isbn).observeSingleEvent(of: .value) { (snapshot) in
        
        let key = snapshot.key
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        
        let bookDetailInfo = Book(isbnCode: key, dictionary: dictionary)
        
        observer.onNext(bookDetailInfo)
      }
      
      return Disposables.create()
    }
  }
}
