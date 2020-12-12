//
//  MainWebService.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class MainWebService: MainWebServiceProtocol {
    // MARK: - Fetch About User Marked Book
    func fetchUserMarekedBooIndexList() -> Observable<[String]> {
        
        guard let uid = Auth.auth().currentUser?.uid else {
          return Observable.create { observer -> Disposable in
            observer.onError(NetworkError.failToGetUid)
            return Disposables.create()
          }
        }
        
        return Observable.create { observer -> Disposable in
          DB_REF_MARKBOOKS.child(uid).observe(.value) { snapshot in
            
            if let markedBookIndex = snapshot.value as? [String: Int] {
              
              let isbnCodeArray = markedBookIndex.map { key, value -> String in
                return "\(key)"
              }
              observer.onNext(isbnCodeArray)
            } else {
              observer.onNext([])
            }
          }
          return Disposables.create()
        }
    }
    
    func fetchMarkedBooks(_ isbnCode: String) -> Observable<Book> {
      
      guard let uid = Auth.auth().currentUser?.uid else {
        return Observable.create { observer -> Disposable in
          observer.onNext(Book.empty())
          return Disposables.create()
        }
      }
      
      return Observable.create { [isbn = isbnCode] observer -> Disposable in
        
        DB_REF_USERBOOKS.child(uid).child(isbn).observeSingleEvent(of: .value) { (snapshot) in
          
          let key = snapshot.key
          guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
          
          let bookDetailInfo = Book(isbnCode: key, dictionary: dictionary)
          
          observer.onNext(bookDetailInfo)
        }
        
        return Disposables.create()
      }
    }
    // MARK: - Fetch Abount User Profile Data
    func getUserProfileData(completion: @escaping ((UserViewModel)->Void)) {
      guard let uid = Auth.auth().currentUser?.uid else { return }
      
      DB_REF_USER.child(uid).observe(.value) { (snapshot) in
        if let value = snapshot.value as? Dictionary<String, AnyObject> {
          let userVM = UserViewModel(User(uid: uid, dictionary: value))
          
          completion(userVM)
        }
      }
    }
    
    func fetchMarkedBookCommentCountAt(_ userSelectedMarkedBook: Book) -> Observable<NSAttributedString> {
        
        guard let uid = Auth.auth().currentUser?.uid,
              let isbnCode = userSelectedMarkedBook.isbn else {
            return Observable.just(
                NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "0")
            )
        }
        
        return Observable<NSAttributedString>.create({ observer -> Disposable in
            
            DB_REF_COMMENT_STATICS.child(uid).child(isbnCode).observe(.value) { (snapshot) in
                
                guard let value = snapshot.value as? Int else { return }
                let attributedString = NSAttributedString.configureAttributedString(systemName: "bubble.left.fill", setText: "\(value)")
                observer.onNext(attributedString)
                
            }
                
            return Disposables.create()
        })
    }
    
    func completeMarkedBook(_ userSelectedMarkedBook: Book) -> Observable<Bool> {
        guard let uid = Auth.auth().currentUser?.uid else { return Observable.just(false) }
        
        guard let completeBookIsbnCode = userSelectedMarkedBook.isbn else { return Observable.just(false) }
        
        return Observable.create { observer -> Disposable in
            DB_REF_COMPLITEBOOKS.child(uid).observeSingleEvent(of: .value) { snapshot in
                
                if let completeBookIndexArray = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    if completeBookIndexArray.keys.contains(completeBookIsbnCode) {
                        observer.onNext(false)
                    } else {
                        self.completeBookInformationUpdateToServer(uid, completeBookIsbnCode)
                        observer.onNext(true)
                    }
                }else {
                    self.completeBookInformationUpdateToServer(uid, completeBookIsbnCode)
                    observer.onNext(true)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func completeBookInformationUpdateToServer(_ uid: String, _ ibsn: String) {
        // 신규 등록 되는 책 DB 업데이트
        DB_REF_MARKBOOKS.child(uid).child(ibsn).removeValue() // 북마크에서 제거
        DB_REF_COMPLITEBOOKS.child(uid).updateChildValues([ibsn:1]) // 완료된 책 등록
        Database.userProfileStaticsHanlder(uid: uid,
                                           plusMinus: .plus,
                                           updateCategory: .compliteBookCount,
                                           amount: 1) // 완료 통계 증가
    }
}
