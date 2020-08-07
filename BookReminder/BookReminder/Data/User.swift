//
//  User.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//


class User {

  var uid: String!
  var nickName: String!
  var email: String!

  init(uid:String, dictionary: Dictionary<String, AnyObject> ) {
    self.uid = uid

    if let nickName = dictionary["nickName"] as? String {
      self.nickName = nickName
    }

    if let email = dictionary["email"] as? String {
      self.email = email
    }
  }
}
