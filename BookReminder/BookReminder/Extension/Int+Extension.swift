//
//  Int+Extension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/30.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

extension Int {
  func toPriceString() -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    guard let priceWithDot = numberFormatter.string(from: NSNumber(value: self)) else { fatalError() }
    
    return "\(priceWithDot) 원"
  }
}
