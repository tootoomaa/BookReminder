//
//  BookModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/05.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

struct Book: Decodable {
  
  var documents: [BookInfo]
  var meta: Meta
  
  struct BookInfo: Decodable {
    let authors: [String]
    let contents: String
    let datetime: String
    let isbn: String
    let price: Int
    let publisher: String
    let sale_price: Int
    let status: String
    let thumbnail: String
    let title: String
    let translators: [String]
    let url: String
  }
  
  struct Meta: Decodable {
    let is_end: Bool
    let pageable_count: Int
    let total_count: Int
  }
  
  enum CodingKeys: String, CodingKey {
    case documents
    case meta
  }
}

class BookDetailInfo: Equatable {
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
  
  static func == (lhs: BookDetailInfo, rhs: BookDetailInfo) -> Bool {
    lhs.isbn == rhs.isbn
  }
  
  static func returnDictionaryValue(documents: BookDetailInfo) -> Dictionary<String, AnyObject> {
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
      "translators": documents.translators ?? "",
      "url": documents.url!,
      "creationDate": documents.creationDate!
      ] as Dictionary<String, AnyObject>
    return bookDicValue
  }
}


