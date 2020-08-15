//
//  Comment.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/14.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

class Comment {

  var commentUid: String!
  var captureImageUrl: String!
  var page: String!
  var myComment: String!
  var creationDate: Int!

  init(commentUid: String, dictionary: Dictionary<String, AnyObject>) {
    
    self.commentUid = commentUid
    
    if let captureImageUrl = dictionary["captureImageUrl"] as? String {
      self.captureImageUrl = captureImageUrl
    }
    
    if let page = dictionary["page"] as? String {
      self.page = page
    }
    
    if let creationDate = dictionary["creationDate"] as? Int {
      self.creationDate = creationDate
    }
    
    if let myComment = dictionary["myComment"] as? String {
      self.myComment = myComment
    }
  }
}
