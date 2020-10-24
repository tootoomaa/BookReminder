//
//  UserViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift

struct UserViewModel {
  
  let user: User
  
  init(_ user: User) {
    self.user = user
  }
}

extension UserViewModel {
  
  var uid: Observable<String> {
    return Observable<String>.just(self.user.uid)
  }
  
  var nickName: Observable<String> {
    return Observable<String>.just(self.user.nickName)
  }
  
  var email: Observable<String> {
    return Observable<String>.just(self.user.email)
  }
  
  var profileImageUrl: Observable<String> {
    return Observable<String>.just(self.user.profileImageUrl)
  }
  
}
