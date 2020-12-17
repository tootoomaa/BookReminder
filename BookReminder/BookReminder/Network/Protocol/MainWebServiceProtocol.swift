//
//  MainWebServiceProtocol.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift

protocol MainWebServiceProtocol {
    func fetchUserMarekedBooIndexList() -> Observable<[String]>
    func fetchMarkedBooks(_ isbnCode: String) -> Observable<Book>
    func getUserProfileData(completion: @escaping ((UserViewModel)->Void))
    func completeMarkedBook(_ userSelectedMarkedBook: Book) -> Observable<Bool>
    func completeBookInformationUpdateToServer(_ uid: String, _ ibsn: String)
    func fetchMarkedBookCommentCountAt(_ isbnCode: String) -> Observable<NSAttributedString>
}
