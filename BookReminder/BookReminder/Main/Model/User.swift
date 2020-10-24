//
//  User.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import FirebaseAuth

class User {

  var uid: String!
  var nickName: String!
  var email: String!
  var profileImageUrl: String!

  init(uid:String, dictionary: Dictionary<String, AnyObject> ) {
    self.uid = uid

    if let nickName = dictionary["nickName"] as? String {
      self.nickName = nickName
    }

    if let email = dictionary["email"] as? String {
      self.email = email
    }
    
    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
      self.profileImageUrl = profileImageUrl
    }
  }
}

extension User {
  
  static func getUserProfileData(completion: @escaping ((UserViewModel)->Void)) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    DB_REF_USER.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      if let value = snapshot.value as? Dictionary<String, AnyObject> {
        
        let userVM = UserViewModel(User(uid: uid, dictionary: value))
        completion(userVM)
        
      }
    }
  }
  
}
