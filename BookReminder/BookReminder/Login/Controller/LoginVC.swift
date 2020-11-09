//
//  LoginVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import SnapKit
import KakaoSDKAuth
import KakaoOpenSDK
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleDataTransport
import AuthenticationServices // apple login
import CryptoKit

class LoginVC: UIViewController {
  
  // MARK: - Properites
  fileprivate var currentNonce: String? // 에플 로그인을 위한 nonce값
  
  let loginView = LoginView()
  
  // MARK: - Inti
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = CommonUI.titleTextColor
    
    GIDSignIn.sharedInstance().presentingViewController = self
    GIDSignIn.sharedInstance().delegate = self
    
    configureButtonAction()
  }
  
  override func loadView() {
    view = loginView
  }
  
  private func configureButtonAction() {
    loginView.appleLoginButton.addTarget(self, action: #selector(tapAppleLoginbutton), for: .touchUpInside)
    loginView.googleLoginButton.addTarget(self, action: #selector(tabGoogleLoginButton), for: .touchUpInside)
    loginView.kakaoLoginButton.addTarget(self, action: #selector(tapKakaoLoginButton), for: .touchUpInside)
  }
  
  // MARK: - Handler
  @objc private func tabGoogleLoginButton() {
    GIDSignIn.sharedInstance().signIn()
    
    if GIDSignIn.sharedInstance().currentUser != nil {
      GIDSignIn.sharedInstance().signIn()
    }
  }
  
  @objc private func tapKakaoLoginButton() {
    
    guard let session = KOSession.shared() else { return }
    
    if session.isOpen() {
      session.close()
    }
    
    session.open { (error) in
      if error != nil || !session.isOpen() { return }
      KOSessionTask.userMeTask(completion: { (error, user) in
        guard let user = user else { return }
        guard let email = user.account?.email,
          let nickname = user.nickname else { return }
        
        print(email)
        print(nickname)
        
        self.dismiss(animated: true, completion: nil)
      })
    }
  }
  
  @objc private func tapAppleLoginbutton() {
    let nonce = randomNonceString()
    currentNonce = nonce
    
    let appleLoginRequest = ASAuthorizationAppleIDProvider().createRequest()
    appleLoginRequest.requestedScopes = [.fullName, .email]
    appleLoginRequest.nonce = sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [appleLoginRequest])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
    authorizationController.performRequests()
  }
  
  // MARK: - Apple SignIn with Firebase feature func
  @available (iOS 13, *)
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
  
  @available (iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
}

// MARK: - ASAuthorizationControllerDelegate [ APPLE SINGIN ]
extension LoginVC: ASAuthorizationControllerDelegate {
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    // 인증이 성공한 뒤 처리 사항
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      
      // Initialize a Firebase credential
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
          // Error handler
          print(error.localizedDescription)
          return
        } else {
          // Login Process
          guard let authResult = authResult else { return }
          let uid = authResult.user.uid
          
          // user static Profile data update
          DB_REF_USERPROFILE.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value as? Dictionary<String, AnyObject>) == nil {
              let value = [
                "commentCount": 0,
                "compliteBookCount": 0,
                "enrollBookCount": 0
                ] as Dictionary<String, AnyObject>
              
              DB_REF_USERPROFILE.updateChildValues([uid: value])
            }
          }
          
          // user Data check
          DB_REF.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? Dictionary<String, AnyObject>) == nil {
              guard let email = authResult.user.email else { return }
              
              let value = [
                "nickName": "사용자",
                "email": email,
                "profileImageUrl": ""
                ] as Dictionary<String, AnyObject>
              
              DB_REF_USER.updateChildValues([uid: value])
            } else {
              print("사용자의 데이터가 이미 존제합니다")
            }
            
            guard let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarVC else { return }
            tabBarVC.configureViewController()
            
            self.dismiss(animated: true)
          })
        }
      }
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // 에러 발생 시 처리 사항
    print("Sign in with Applec Error: \(Error.self)")
  }
}

extension LoginVC: GIDSignInDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      print("Error",error.localizedDescription)
      return
    }
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { (authResult, error) in
      // ...
      if let err = error {
        print("LoginViewController:    error = \(err)")
        return
      } else {
        print("sing in gogole at Appdelgate  ")
        // Login Process
        guard let authResult = authResult else { return }
        let uid = authResult.user.uid
        
        // user static Profile data update
        DB_REF_USERPROFILE.child(uid).observeSingleEvent(of: .value) { (snapshot) in
          if (snapshot.value as? Dictionary<String, AnyObject>) == nil {
            let value = [
              "commentCount": 0,
              "compliteBookCount": 0,
              "enrollBookCount": 0
              ] as Dictionary<String, AnyObject>
            
            DB_REF_USERPROFILE.updateChildValues([uid: value])
          }
        }
        
        // user Data check
        DB_REF.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
          if (snapshot.value as? Dictionary<String, AnyObject>) == nil {
            print("Data Is nil")
            guard let email = authResult.user.email else { return }
            guard let name = authResult.user.displayName else { return }
            
            print(name)
            print(email)
            let value = [
              "nickName": name,
              "email": email,
              "profileImageUrl": ""
              ] as Dictionary<String, AnyObject>
            
            print(value)
            DB_REF_USER.updateChildValues([uid: value])
          }
          
          guard let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarVC else { return }
          tabBarVC.configureViewController()
          
          self.dismiss(animated: true)
        })
      }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
      if let clintID = signIn.clientID {
        print("AppDelegate:signIn:clintID : \(clintID)")
      }
    }
  }
}
