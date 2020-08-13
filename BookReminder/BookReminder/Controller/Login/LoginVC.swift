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
import AuthenticationServices // apple login
import CryptoKit

class LoginVC: UIViewController {
  
  // MARK: - Properites
  fileprivate var currentNonce: String? // 에플 로그인을 위한 nonce값
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Book\nReminder"
    label.font = .systemFont(ofSize: 50, weight: .bold)
    label.numberOfLines = 2
    label.textColor = .white
    return label
  }()
  
  let bottomView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  let loginTextLabel: UILabel = {
    let label = UILabel()
    label.text = "소셜 계정 연동 하기"
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textAlignment = .center
    label.backgroundColor = .white
    label.textColor = .black
    return label
  }()
  
  lazy var kakaoLoginButton: KOLoginButton = {
    let button = KOLoginButton()
    //    button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
    //    button.imageView?.contentMode = .scaleAspectFit
    button.layer.cornerRadius = 10
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(tapKakaoLoginButton), for: .touchUpInside)
    return button
  }()
  
  let appleLoginButton: ASAuthorizationAppleIDButton = {
    let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    button.addTarget(self, action: #selector(tapAppleLoginbutton), for: .touchUpInside)
    return button
  }()

  // MARK: - Inti
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = CommonUI.titleTextColor
    
    configureLayout()
    
  }
  
  private func configureLayout() {
    
    let padding: CGFloat = 50
//    let bottomViewPadding: CGFloat = padding*0.7
    
    // 상단 뷰
    [titleLabel, bottomView].forEach{
      view.addSubview($0)
    }
    
    titleLabel.snp.makeConstraints{
      $0.top.equalTo(view.snp.top).offset(padding*1.5)
      $0.centerX.equalTo(view.snp.centerX)
    }
    
    bottomView.snp.makeConstraints{
      $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
      $0.leading.equalTo(view.snp.leading)
      $0.trailing.equalTo(view.snp.trailing)
      $0.bottom.equalTo(view.snp.bottom)
    }
    
    // 하단 뷰
    bottomView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15)
    
    [loginTextLabel, kakaoLoginButton, appleLoginButton ].forEach{
      bottomView.addSubview($0)
    }
    
    loginTextLabel.snp.makeConstraints{
      $0.top.equalTo(bottomView.layoutMargins.top)
      $0.leading.equalTo(bottomView.snp.leading)
      $0.trailing.equalTo(bottomView.snp.trailing)
      $0.centerX.equalTo(bottomView.snp.centerX)
      $0.height.equalTo(90)
    }
    
    appleLoginButton.snp.makeConstraints{
      $0.top.equalTo(loginTextLabel.snp.bottom).offset(30)
      $0.centerX.equalTo(loginTextLabel.snp.centerX)
      $0.height.equalTo(56)
      $0.width.equalTo(330)
    }
    
    kakaoLoginButton.snp.makeConstraints{
      $0.top.equalTo(appleLoginButton.snp.bottom).offset(20)
      $0.centerX.equalTo(loginTextLabel.snp.centerX)
      $0.height.equalTo(56)
      $0.width.equalTo(330)
    }

  }
  
  // MARK: - Handler
  
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
          
          // user Data check
          DB_REF.child("user").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.value != nil {
              guard let email = authResult.user.email else { return print("fail to get imformation") }
              
              let value = [
                "nickName": "사용자",
                "email": email
              ] as Dictionary<String, AnyObject>
              
              DB_REF_USER.updateChildValues([uid: value])
              
              self.dismiss(animated: true)
              
            }
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
