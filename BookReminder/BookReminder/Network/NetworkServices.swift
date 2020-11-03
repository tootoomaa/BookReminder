//
//  NetworkServices.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

class NetworkServices {
  
  func fetchBookInfomationFromKakao(type: SearchType,
                                    forSearch query: String,
                                    complitionHandler: @escaping (String, [String : AnyObject]) -> ()) {
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
    
    if let url = urlComponents.url {
      
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = "GET"
      urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
      
      URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error {
          print("error", error.localizedDescription)
          return
        }
        
        guard let data = data else { return print("Data is nil") }
        
        do {
          
          let bookInfo = try JSONDecoder().decode(SearchBookList.self, from: data)
          
          if type == .isbn {
            let creationDate = Int(NSDate().timeIntervalSince1970)
            let documents = bookInfo.documents[0]
            let isbnCode = documents.isbn
            
            let bookDetailValue = [
              "authors": documents.authors,
              "contents": documents.contents,
              "datetime": documents.datetime,
              "isbn": documents.isbn,
              "price": documents.price,
              "publisher": documents.publisher,
              "sale_price": documents.sale_price,
              "status": documents.status,
              "thumbnail": documents.thumbnail,
              "title": documents.title,
              "translators": documents.translators,
              "url": documents.url,
              "creationDate": creationDate
              ] as Dictionary<String, AnyObject>
            
            complitionHandler(isbnCode, bookDetailValue)
          } else if type == .bookName {
            
            let creationDate = Int(NSDate().timeIntervalSince1970)
            
            let count = bookInfo.documents.count
            guard count != 0 else { return print("Count",count)}
            for bookDetailInfo in bookInfo.documents {
              
              let documents = bookDetailInfo
              let isbnCode = documents.isbn
              
              let bookDetailValue = [
                "authors": documents.authors,
                "contents": documents.contents,
                "datetime": documents.datetime,
                "isbn": documents.isbn,
                "price": documents.price,
                "publisher": documents.publisher,
                "sale_price": documents.sale_price,
                "status": documents.status,
                "thumbnail": documents.thumbnail,
                "title": documents.title,
                "translators": documents.translators,
                "url": documents.url,
                "creationDate": creationDate
                ] as Dictionary<String, AnyObject>
              
              complitionHandler(isbnCode, bookDetailValue)
            }
          }
          
        } catch {
          print("get fail to get BookInfo in ",self)
        }
        
      }.resume()
    }
  }
}
