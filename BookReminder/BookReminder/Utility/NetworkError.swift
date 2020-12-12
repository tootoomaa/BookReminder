//
//  NetworkError.swift
//  BookReminder
//
//  Created by 김광수 on 2020/12/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

enum NetworkError: Error {
  case failToGetUid
  case networkError
  case indexError
}
