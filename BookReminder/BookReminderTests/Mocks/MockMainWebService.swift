//
//  MockMainWebService.swift
//  BookReminderTests
//
//  Created by 김광수 on 2020/12/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
@testable import BookReminder

class MockMainWebService: MainWebServiceProtocol {
    
    func fetchUserMarekedBooIndexList() -> Observable<[String]> {
        
        return Observable<[String]>.just(["1234", "12354", "123467"])
        
    }
    
    func fetchMarkedBooks(_ isbnCode: String) -> Observable<Book> {
        
        return Observable<Book>.just(Book.empty())
        
    }
    
    func getUserProfileData(completion: @escaping ((UserViewModel)->Void)) {
        
//        completion(UserViewModel.init(User())2
    }
}
