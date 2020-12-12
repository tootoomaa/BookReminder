//
//  AddCommentViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/03.
//  Copyright © 2020 김광수. All rights reserved.
//

import Firebase
import UIKit

struct AddCommentViewModel {
  var comment: Comment
    
  var bookIsbnCode: String = ""
  var commentUid: String = ""

  var newPageString: String = ""
  var newMyComment: String = ""
  var newCaptureImageUrl: String = ""
  
  var createDate: Int {
    return Int(NSDate().timeIntervalSince1970)
  }
  
  init(_ comment: Comment) {
    self.comment = comment
    
    commentUid = comment.commentUid ?? ""
    
    newPageString = comment.page ?? ""
    newMyComment = comment.myComment ?? ""
    newCaptureImageUrl = comment.captureImageUrl ?? ""
  }
}

// MARK: - Network Handler
extension AddCommentViewModel {
  
  func uploadNewCommentData(_ uploadImage: UIImage) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    guard let uploadImageDate = uploadImage.jpegData(compressionQuality: 0.5) else { return }
    
    let filename = NSUUID().uuidString
    
    STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { (metadata, error) in
      if let error = error {
        print("error",error.localizedDescription)
        return
      }
      
      let uploadImageRef = STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename)
      uploadImageRef.downloadURL { (url, error) in
        if let error = error { print("Error", error.localizedDescription); return }
        guard let url = url else { return }
        
        let uploadValue = [
          "captureImageUrl": url.absoluteString,
          "page": newPageString,
          "creationDate": createDate,
          "myComment": newMyComment,
        ] as Dictionary<String, AnyObject>
        
        DB_REF_COMMENT.child(uid).child(bookIsbnCode).childByAutoId().updateChildValues(uploadValue)
        Database.commentCountHandler(uid: uid, isbnCode: bookIsbnCode, plusMinus: .plus)
      }
    }
  }
  
  func updateBeforeComment() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let value = [
      "captureImageUrl": newCaptureImageUrl,
      "page": newPageString,
      "creationDate": createDate,
      "myComment": newMyComment,
    ] as Dictionary<String, AnyObject>
    
    DB_REF_COMMENT.child(uid).child(bookIsbnCode).child(commentUid).updateChildValues(value)
  }
  
  func updateBeforeComment(_ uploadImage: UIImage) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    guard let uploadImageDate = uploadImage.jpegData(compressionQuality: 0.5) else { return }
    
    let filename = NSUUID().uuidString
    
    Storage.storage().reference(forURL: newCaptureImageUrl).delete(completion: nil)
    
    STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { (metadata, error) in
      if let error = error {
        print("error",error.localizedDescription)
        return
      }
      
      let uploadImageRef = STORAGE_REF_COMMENT_CAPTUREIMAGE.child(filename)
      uploadImageRef.downloadURL { (url, error) in
        if let error = error { print("Error", error.localizedDescription); return }
        guard let url = url else { return }
        
        let value = [
          "captureImageUrl": url.absoluteString,
          "page": newPageString,
          "creationDate": createDate,
          "myComment": newMyComment,
        ] as Dictionary<String, AnyObject>
        
        DB_REF_COMMENT.child(uid).child(bookIsbnCode).child(commentUid).updateChildValues(value)
      }
    }
  }
}
