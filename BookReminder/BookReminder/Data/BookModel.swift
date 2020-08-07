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



/*
 
 
 
 */
