//
//  LoginView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/11/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices // apple login
import KakaoSDKAuth
import KakaoOpenSDK

class LoginView: UIView {
  // MARK: - Properties
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
    return button
  }()
  
  lazy var googleLoginButton: UIButton = {
    let button = UIButton()
    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    button.setTitle("     Sign in With Google", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .white
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.cornerRadius = 10
    button.layer.masksToBounds = true
    return button
  }()
  
  let googleLogoImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.image = UIImage(named: "googleLogo1")
    return imageView
  }()
  
  let appleLoginButton: ASAuthorizationAppleIDButton = {
    let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureLayout()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureLayout() {
    
    let padding: CGFloat = 50
    
    // 상단 뷰
    [titleLabel, bottomView].forEach{
      addSubview($0)
    }
    
    titleLabel.snp.makeConstraints{
      $0.top.equalTo(snp.top).offset(padding*1.5)
      $0.centerX.equalTo(snp.centerX)
    }
    
    bottomView.snp.makeConstraints{
      $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
      $0.leading.equalTo(snp.leading)
      $0.trailing.equalTo(snp.trailing)
      $0.bottom.equalTo(snp.bottom)
    }
    
    // 하단 뷰
    bottomView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15)
    
    [loginTextLabel, googleLoginButton, appleLoginButton, googleLogoImageView].forEach{
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
    
    googleLoginButton.snp.makeConstraints{
      $0.top.equalTo(appleLoginButton.snp.bottom).offset(20)
      $0.centerX.equalTo(loginTextLabel.snp.centerX)
      $0.height.equalTo(56)
      $0.width.equalTo(330)
    }
    
    googleLogoImageView.snp.makeConstraints{
      $0.centerX.equalTo(googleLoginButton.snp.centerX).offset(-95)
      $0.centerY.equalTo(googleLoginButton.snp.centerY)
      $0.width.height.equalTo(15)
    }
  }
}
