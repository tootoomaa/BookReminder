//
//  MyBookWebServiceProtocol.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift

protocol MyBookWebServiceProtocol {
    
    func fetchUserBookList() -> Observable<[Book]>
    
}
