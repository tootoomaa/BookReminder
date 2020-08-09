//
//  Constraint.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase


// Storage
let STORAGE_REF = Storage.storage().reference()
let STORAGE_REF_BOOKTHUNBNAIL = Storage.storage().reference().child("bookThumbnail")

// Database
let DB_REF = Database.database().reference()
let DB_REF_USER = Database.database().reference().child("user")
let DB_REF_USERBOOKS = Database.database().reference().child("userBooks")
let DB_REF_MARKBOOKS = Database.database().reference().child("markBooks")
