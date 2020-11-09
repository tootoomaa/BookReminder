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
    
    let imageView = CustomImageView(frame: CGRect(x: 80, y: 140, width: 140, height: 200))
    imageView.loadProfileImage(urlString: book.thumbnail)
    
    alert.view.addSubview(imageView)
    
    if let view = alert.view {
      let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
      let width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
      alert.view.addConstraints([ height, width])
    }
    
    return alert
  }
  
  static func addBookAlertController(_ searchBookVC: SearchBookVC, _ searchBook: SearchBook, _ indexPath: IndexPath) -> UIAlertController {
    
    let alert = UIAlertController(title: "\(searchBook.title)", message: "이 책을 등록하시겠습니까?", preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "취소", style: .destructive) { (_) in }
    let addAction = UIAlertAction(title: "등록", style: .default) { [weak searchBookVC] _ in
      
      if searchBookVC?.searchBookAddAtMyBooks(searchBook) == false {
        
        let bookAreadyAddedAlert = UIAlertController.defaultSetting(title: "등록 불가", message: "이미 등록된 책입니다.")
        
        searchBookVC?.present(bookAreadyAddedAlert, animated: true, completion: nil)
        
      } else {
        
        searchBookVC?.popViewController()
        
      }
    }
    
    let imageView = CustomImageView(frame: CGRect(x: 87, y: 110, width: 126, height: 180))
    // alert 버튼 및 이미지 설정
    imageView.loadBookImage(urlString: searchBook.book.thumbnail)
    
    alert.view.addSubview(imageView)
    
    alert.addAction(addAction)
    alert.addAction(cancelAction)
    
    if let view = alert.view {
      let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400)
      let width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
      alert.view.addConstraints([ height, width])
    }
    
    return alert
  }
}
