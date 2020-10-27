//
//  UIAlertConrtoller+Extension.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/27.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

extension UIAlertController {
  
  static func defaultSetting(title: String, message: String) -> UIAlertController {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .default) { (_) in }
    
    alertController.addAction(confirmAction)
    
    return alertController
  }
  
  static func okCancelSetting(title: String, message: String, okAction: UIAlertAction) -> UIAlertController {
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    
    let okAction = okAction
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in
      
    }
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }
  
  static func deleteBookWarning(_ myBookVC: MyBookVC, _ book: Book, _ indexPath: IndexPath) -> UIAlertController {
    
    let message = """
        이 책을 삭제하시겠습니까?\n이 책과 관련한 모든 내용이 삭제 됩니다\n 삭제된 데이터는 복원 불가능 합니다
    """
    let alert = UIAlertController(title: "\(book.title ?? "책") 삭제", message: message, preferredStyle: .alert)
    let addAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }
    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { (_) in
      
      myBookVC.deleteMyBook(indexPath)
      myBookVC.deleteBookAtBookMarkedList(book)
      
    }
    
    let imageView = CustomImageView(frame: CGRect(x: 80, y: 110, width: 140, height: 200))
    imageView.loadImage(urlString: book.thumbnail)
    
    alert.view.addSubview(imageView)
    alert.addAction(addAction)
    alert.addAction(deleteAction)

    if let view = alert.view {
      let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
      let width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
      alert.view.addConstraints([ height, width])
    }
    
    return alert
  }
}
