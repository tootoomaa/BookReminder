//
//  TabBarVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/07.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import FirebaseAuth

class TabBarVC: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    checkLogined()
    
    configureViewController()
    
  }
  
  func configureViewController() {
    let mainVC = MainVC()
    let myBookVC = MyBookVC()
    let mainVCReactor = MainVCReactor()
    
    mainVC.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "bookmark"), tag: 0)
    mainVC.reactor = mainVCReactor
    myBookVC.tabBarItem = UITabBarItem(title: "MyBooks", image: UIImage(systemName: "book"), tag: 1)
    
    let mainVCNavi = UINavigationController(rootViewController: mainVC)
    let myBookNavi = UINavigationController(rootViewController: myBookVC)
    
    viewControllers = [mainVCNavi, myBookNavi]
  }
  
  private func checkLogined() {
    DispatchQueue.main.async {
      if Auth.auth().currentUser?.uid == nil {
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
      }
    }
    return
  }
}
