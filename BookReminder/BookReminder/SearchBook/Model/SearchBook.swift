//
//  SearchBook.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/28.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Alamofire

struct SearchBook: Decodable {
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
  var url: String
}

extension SearchBook {
  
  static func empty() -> SearchBook {
    return SearchBook(authors: ["a"], contents: "", datetime: "", isbn: "", price: 0, publisher: "", sale_price: 0, status: "", thumbnail: "", title: "", translators: [""], url: "")
  }
  
}

extension SearchBook {
  
  var value: Dictionary<String, AnyObject> {
    let creationDate = Int(NSDate().timeIntervalSince1970)
    return [
      "authors": self.authors,
      "contents": self.contents,
      "datetime": self.datetime,
      "isbn": self.isbn,
      "price": self.price,
      "publisher": self.publisher,
      "sale_price": self.sale_price,
      "status": self.status,
      "thumbnail": self.thumbnail,
      "title": self.title.trimmingCharacters(in: .whitespaces),
      "translators": self.translators,
      "url": self.url,
      "creationDate": creationDate
    ] as Dictionary<String, AnyObject>
  }
  
  var book: Book {
    return Book(isbnCode: self.isbn, dictionary: self.value)
  }
}

struct Meta: Decodable {
  let is_end: Bool
  let pageable_count: Int
  let total_count: Int
}

struct SearchBookList: Decodable {
  
  var documents: [SearchBook]
  var meta: Meta
  
  enum CodingKeys: String, CodingKey {
    case documents
    case meta
  }
}

enum SearchType: String {
  case isbn = "isbn"
  case bookName = "title"
}

extension SearchBookList {
  
  static func getURLRequset(query: String, _ type: SearchType) -> URLRequest {
    let query = query
    let sort = "accuracy"
    let page = "1"
    let size = String(type == .isbn ? 5 : 30)
    let target = type.rawValue
    
    let authorization = "KakaoAK d4539e8d7741ccecad7ed805bfe1febb"
    
    let queryParams: [String: String] = [
      "query" : query,
      "sort" : sort,
      "page" : page,
      "size" : size,
      "target" : target
    ]
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "dapi.kakao.com"
    urlComponents.path = "/v3/search/book"
    urlComponents.setQueryItems(with: queryParams)
    
    let url = urlComponents.url
    var urlRequest = URLRequest(url: url!)
    
    urlRequest.httpMethod = "GET"
    urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
    
    return urlRequest
  }
}

extension SearchBookList {
  
  static func getSearchBookList(_ searchWord: String) -> Observable<[SearchBook]> {
    let request = SearchBookList.getURLRequset(query: searchWord, .bookName)
    
    return Observable<[SearchBook]>.create { observer -> Disposable in
      
      AF.request(request)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: SearchBookList.self) { result in
          if let searchBooks = result.value {
            observer.onNext(searchBooks.documents)
          }
        }
      return Disposables.create()
    }
    
  }
}
