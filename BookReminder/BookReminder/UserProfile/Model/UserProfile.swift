//
//  UserProfile.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

class UserProfile {
  
  var uid: String!
  var commentCount: Int!
  var completeBookCount: Int!
  var enrollBookCount: Int!
  
  init(uid: String, dictionary: Dictionary<String, Int>) {
    self.uid = uid
    
    if let commentCount = dictionary["commentCount"] {
      self.commentCount = commentCount
    }
    
    if let completeBookCount = dictionary["compliteBookCount"] {
      self.completeBookCount = completeBookCount
    }
    
    if let enrollBookCount = dictionary["enrollBookCount"] {
      self.enrollBookCount = enrollBookCount
    }
  }
}
