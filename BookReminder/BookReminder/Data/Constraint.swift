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
let STORAGE_REF_PROFILEIMAGE = Storage.storage().reference().child("profileImage")
let STORAGE_REF_COMMENT_CAPTUREIMAGE = Storage.storage().reference().child("comment")
let STORAGE_REF_USER_PROFILEIMAGE = Storage.storage().reference().child("userProfileImage")

// Database
let DB_REF = Database.database().reference()
let DB_REF_USER = DB_REF.child("user")
let DB_REF_USERBOOKS = DB_REF.child("userBooks")
let DB_REF_MARKBOOKS = DB_REF.child("markBooks")
let DB_REF_COMMENT = DB_REF.child("comments")
let DB_REF_COMMENT_STATICS = DB_REF.child("commnet-statics")
let DB_REF_COMPLITEBOOKS = DB_REF.child("compliteBooks")
let DB_REF_COMPLITEBOOKS_STATICS = DB_REF.child("compliteBooks-staitcs")
let DB_REF_USERPROFILE = DB_REF.child("userProfile")
