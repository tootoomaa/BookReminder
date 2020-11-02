//
//  UserViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct UserViewModel {
  
  var user: User
  
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

extension UserViewModel {
  
  func saveUserName(_ newName: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let value = [
      "nickName": newName,
      "email": self.email,
      "profileImageUrl": self.profileImageUrl
      ] as Dictionary<String, AnyObject>
    
    DB_REF_USER.updateChildValues([uid: value])
  }
  
  func removeUserProfileImageAtStorage(_ imgUrl: String) {
    
    Storage.storage().reference(forURL: imgUrl).delete(completion: nil)
    
  }
  
  func uploadUserProfileImageAtStorage(_ newProfileImage: UIImage, completiion: @escaping((User) -> Void)) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    guard let uploadImageDate = newProfileImage.jpegData(compressionQuality: 0.3) else { return }

    let filename = NSUUID().uuidString
    
    STORAGE_REF_USER_PROFILEIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { metadate, error in
      
      let uploadImageRef = STORAGE_REF_USER_PROFILEIMAGE.child(filename)
      
      uploadImageRef.downloadURL { (newProfileImgURL, error) in
        if let error = error { print("Error", error.localizedDescription); return }
        guard let newProfileImgURL = newProfileImgURL else { return }
        
        let value = [
          "nickName": user.nickName,
          "email": user.email,
          "profileImageUrl": newProfileImgURL.absoluteString
        ] as Dictionary<String, AnyObject>
        
        DB_REF_USER.child(uid).updateChildValues(value)
        completiion(User(uid: uid, dictionary: value))
      }
    }
    
  }
}
