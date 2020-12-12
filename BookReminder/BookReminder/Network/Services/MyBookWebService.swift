//
//  MyBookWebService.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class MyBookWebService: MyBookWebServiceProtocol {
    
    func fetchUserBookList() -> Observable<[Book]> {
      return Observable<[Book]>.create { (observer) -> Disposable in
        guard let uid = Auth.auth().currentUser?.uid else { fatalError("Fail to get Uid") }
        DB_REF_USERBOOKS.child(uid).observeSingleEvent(of: .value) { (snapshot, uid) in
            /*
           case 1 첫 사용자 값, nil
           case 2 인터넷 에러, nil
           */
          guard let bookDetailInfos = snapshot.value as? Dictionary<String, AnyObject> else {
            observer.onNext([])
            return
          }
          
          let newBookArray = bookDetailInfos.map { key, value -> Book in
            guard let newValue = value as? Dictionary<String, AnyObject> else { fatalError("Fail to change Book") }
            return Book(isbnCode: key, dictionary: newValue)
          }.sorted { (book1, book2) -> Bool in
            book1.creationDate > book2.creationDate
          }
          observer.onNext(newBookArray)
        }
        return Disposables.create()
      }
    }

    
}
