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
  var captureImageFilename: String!

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
    
    if let captureImageFilename = dictionary["captureImageFilename"] as? String {
      self.captureImageFilename = captureImageFilename
    }
  }
  
  var sortedInt: Int {
    let value = page.split(separator: "P")
    if let intPage = Int(value[0]) {
      return intPage
    }
    return 999
  }
}

extension Comment {
  static func empty() -> Comment {
    let dicValue = [
      "captureImageUrl" : "",
      "page" : "",
      "creationDate" : "",
      "myComment" : "",
      "captureImageFilename": ""
    ] as Dictionary<String, AnyObject>
    return Comment(commentUid: "", dictionary: dicValue)
  }
}
