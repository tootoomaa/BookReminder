//
//  MainVCReactor.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class MainVCReactor: Reactor {
  
  enum Action {
//    case fetchUserBooks
    case selectMarkedBook(Int)
  }
  
  // station을 변경하는 가장 작은 단위
  enum Mutation {
    case userBookIndexs([String])
    case chageCommentCountLable(NSAttributedString)
    case isLoding(Bool)
  }
  
  // VM을 통해서 변경할 요소들의 집합
  struct State {
    var userBookListIndex: [String] = []
    var userMarkedBookList: [Book] = []
    var userSelectIndex: Int = 0
    var userSelectedBook: Book = Book.empty()
    var isLoading: Bool = false
    var bookCountAttString: NSAttributedString = NSAttributedString(string: "0")
  }
  
  var initialState: State = State()
  var mainWebService = MainWebService()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    
//    case .fetchUserBooks:
//      return Observable.concat([
//        Observable.just(Mutation.isLoding(true)),
//        mainWebService.fetchUserMarekedBooIndexList()
//          .map { Mutation.userBookIndexs($0) }
//          .catchErrorJustReturn( Mutation.userBookIndexs([])),
//
//
//        })
//
//        Observable.just(Mutation.isLoding(false))
//      ])
    
    case .selectMarkedBook(let index):
      let book = initialState.userMarkedBookList[index]
      return Observable.concat([
        Observable.just(Mutation.isLoding(true)),
        mainWebService.fetchMarkedBookCommentCountAt(book.isbn)
          .map{ Mutation.chageCommentCountLable($0) }
          .catchErrorJustReturn( Mutation.chageCommentCountLable(NSAttributedString(string: "0"))),
        Observable.just(Mutation.isLoding(false))
      ])
        
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    
    case .userBookIndexs(let bookIndexs):
      newState.userBookListIndex = bookIndexs
    
    case .isLoding(let isLoading):
      newState.isLoading = isLoading

    case .chageCommentCountLable(let commentAttString):
      newState.bookCountAttString = commentAttString
    }
    
    return newState
  }
}
