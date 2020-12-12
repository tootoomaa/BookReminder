//
//  MainViewModelCommendProtocol.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/06.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

protocol MainViewModelCommendProtocol {
    
    mutating func reloadData()
    
    mutating func bookAt(_ index: Int) -> MarkedBookModel?
    
    mutating func addMarkedBook(_ addBook: Book)
    
    mutating func removeMarkedBook(_ index: Int)
}
