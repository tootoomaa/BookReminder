//
//  ViewModelBindableType.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/27.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

protocol ViewModelBindableType {
  associatedtype ViewModelType // generic 하게 설정 (각각의 VC에 대한 ViewModel이 다르므로
  
  var viewModel: ViewModelType! { get set }
  
  func bindViewModel()
}

extension ViewModelBindableType where Self: UIViewController {
  // 개별 VC에서 Bind 를 개별 호출할 필요가 없다.
  mutating func bind(viewModel: Self.ViewModelType) {
    
    self.viewModel = viewModel
    loadViewIfNeeded()

    bindViewModel()
  }
}
