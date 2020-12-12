//
//  UserProfileWebService.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class UserProfileWebService: UserProfileWebServiceProtocol {
    
    func fetchUserProfile() -> Observable<UserProfileViewModel> {
      return Observable.create { observer -> Disposable in
        guard let uid = Auth.auth().currentUser?.uid else { fatalError("Fail to get UID") }
        
        DB_REF_USERPROFILE.child(uid).observe(.value) { (snapshot) in
          
          guard let dictionaryValue = snapshot.value as? [String: Int] else { fatalError("Fail to get Dictionary Value") }
          let userVM = UserProfileViewModel(UserProfile(uid: snapshot.key, dictionary: dictionaryValue))
          observer.onNext(userVM)
          
        }
        return Disposables.create()
      }
    }
}
