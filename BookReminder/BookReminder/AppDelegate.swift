//
//  AppDelegate.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import KakaoSDKCommon
import KakaoOpenSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    KakaoSDKCommon.initSDK(appKey: "9fa3b96b5ff7ed8383316d152dde1824")
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = TabBarVC()
    window?.makeKeyAndVisible()
    
    return true
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    
    if KOSession.handleOpen(url) {
      return true
    }
    return true
  }
  
  internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    
    if KOSession.handleOpen(url) {
      return true
    }
    return true
  }
  
}

