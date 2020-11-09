//
//  UserProfileViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

struct UserProfileViewModel {
  
  let userProfile: UserProfile
  
  var tableViewData: [Observable<(lable: String, value: String)>] {
    return [enrollBookCount, completeBookCount, completBookRatio, commentCount, commentPerBook]
  }
  
  lazy var allcase = BehaviorRelay(value: tableViewData)
  
  init(_ userProfile: UserProfile) {
    self.userProfile = userProfile
  }
}

extension UserProfileViewModel {
  
  var enrollBookCount: Observable<(lable: String, value: String)> {
    let label = "등록 권수"
    var enrollBookCount = "0 권"
    if let userEnrollBookCount = userProfile.enrollBookCount {
      enrollBookCount = "\(userEnrollBookCount) 권"
    }
    return Observable<(lable: String, value: String)>.just((label, enrollBookCount))
  }
  
  var completeBookCount: Observable<(lable: String, value: String)> {
    let label = "완독 권수"
    var completeBookCount = "0 권"
    
    if let userCompleteBookCount = userProfile.completeBookCount {
      completeBookCount = "\(userCompleteBookCount) 권"
    }
    
    return Observable<(lable: String, value: String)>.just((label, completeBookCount))
  }
  
  var completBookRatio: Observable<(lable: String, value: String)> {
    let label = "완독률"
    var completeBookCountRatioString = "0 %"
    
    if let userCompleteBookCount = userProfile.completeBookCount,
       let userEnrollBookCount = userProfile.enrollBookCount {
      
      if userEnrollBookCount != 0 {
        let completeRatio = Double(userCompleteBookCount) / Double(userEnrollBookCount) * 100
        let completeRatioText = String(format: "%.1f", arguments: [completeRatio]) + " %"
        
        completeBookCountRatioString = completeRatioText
      }
      
    }
    return Observable<(lable: String, value: String)>.just((label, completeBookCountRatioString))
  }
  
  var commentCount: Observable<(lable: String, value: String)> {
    let label = "comment 수"
    var countString = "0 개"
    if let commentCount = userProfile.commentCount {
      countString = "\(commentCount) 개"
    }
    return Observable<(lable: String, value: String)>.just((label, countString))
  }

  var commentPerBook: Observable<(lable: String, value: String)> {
    let label = "권당 Comment 수"
    var commentPerBookRatioString = "0 개"
    
    if let userCommentCount = userProfile.commentCount,
       let userEnrollBookCount = userProfile.enrollBookCount {
      
      if userEnrollBookCount != 0 {
        let commentCountRatio = Double(userCommentCount) / Double(userEnrollBookCount)
        let commentCountRatioText = String(format: "%.2f 개", arguments: [commentCountRatio])
        commentPerBookRatioString = commentCountRatioText
      }
      
    }
    return Observable<(lable: String, value: String)>.just((label, commentPerBookRatioString))
  }
}

extension UserProfileViewModel {
  
  static func fetchUserProfile() -> Observable<UserProfileViewModel> {
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

