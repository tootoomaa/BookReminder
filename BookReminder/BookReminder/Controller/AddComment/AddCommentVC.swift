//
//  AddCommentVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/11.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class AddCommentVC: UIViewController {
  
  var markedBookInfo: BookDetailInfo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    navigationItem.title = markedBookInfo?.title
    
    view.backgroundColor = .white
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
}
