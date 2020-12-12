//
//  UserBookViewModel.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import Firebase

// MARK: - Book List Model
struct MarkedBookListModel {
    var books: [MarkedBookModel]
    
    lazy var allcase = BehaviorRelay(value: books)
    
    init(_ books:[Book]) {
        self.books = books.compactMap(MarkedBookModel.init)
    }
}

extension MarkedBookListModel: MainViewModelCommendProtocol {
    
    mutating func reloadData() {
        allcase.accept(books.count == 0 ? [MarkedBookModel(Book.empty())] : books)
    }
    
    func getMarkedBookInfo(_ index: Int) -> Book? {
        guard !self.books.isEmpty else { return nil }
        return books[index].book
    }
    
    func bookAt(_ index: Int) -> MarkedBookModel? {
        guard !self.books.isEmpty else { return nil }
        return books[index]
    }
    
    mutating func addMarkedBook(_ addBook: Book) {
        let addBookModel = MarkedBookModel(addBook)
        self.books.append(addBookModel)
    }
    
    mutating func removeMarkedBook(_ index: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //    guard let isbnCode = removeBookModel.book.isbn else { return }
        
        guard let isbnCode = bookAt(index)?.book.isbn else { return }
        
        /* [ 북마크된 책이 삭제될때 같이 지워져야 되는 사항
         1. 등록 권수 통계 값 -1
         2. 사용자 북마크 북 리스트에서 삭제
         */
        
        self.books.remove(at: index)
        DB_REF_MARKBOOKS.child(uid).child(isbnCode).removeValue()
    }
}

// MARK: - Book Model
struct MarkedBookModel: Equatable {
    
    let book: Book
    
    init(_ book: Book) {
        self.book = book
    }
}

extension MarkedBookModel {
    
    var thumbnail: Observable<String> {
        return Observable<String>.just(self.book.thumbnail)
    }
}
