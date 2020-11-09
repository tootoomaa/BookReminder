//
//  UserProfileVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/13.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import FirebaseAuth // 로그아웃 기능
import MobileCoreServices
import RxSwift
import RxCocoa
import SnapKit

class UserProfileVC: UIViewController {
  
  // MARK: - Properties
  var userVM: UserViewModel?
  var userProfileVM: UserProfileViewModel!
  
  let disposeBag = DisposeBag()
  
  let userProfileView = UserProfileView()
  
  let mainTableHeaderView = MainTableHeaderView()
  
  lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "사용자 프로필"
    
    fetchStaticData()
    
    configureSetUI()
    
    configureTableViewSetting()
    
  }
  
  override func loadView() {
    view = userProfileView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.navigationBar.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.navigationBar.isHidden = true
  }
  
  private func configureSetUI() {
    view.backgroundColor = .white

  }
  // MARK: - Fetch UserStatic Data
  private func fetchStaticData() {
    UserProfileViewModel.fetchUserProfile()
      .subscribe(onNext:{ [weak self] value in
        self?.userProfileVM = value
        self?.userDataBinding()
        self?.tableViewBinding()
      }).disposed(by: disposeBag)
  }
  
  // MARK: - User Data Binding
  private func userDataBinding() {
    userVM?.nickName.asDriver(onErrorJustReturn: "")
      .drive(self.userProfileView.nameLabel.rx.text)
      .disposed(by: disposeBag)
    
    userVM?.profileImageUrl.bind { [weak self] imageUrl in
      self?.userProfileView.profileImageView.loadProfileImage(urlString: imageUrl)
    }.disposed(by: disposeBag)
    
    let imageViewWidth = userProfileView.profileImageView.frame.width
    
    userProfileView.profileImageView.layer.cornerRadius = imageViewWidth/2
    userProfileView.profileImageView.clipsToBounds = true
  }
  
  // MARK: - TableView Setting
  private func configureTableViewSetting() {
    tableViewBasicSetting()
    tableViewHeaderSetting()
  }
  
  private func tableViewBasicSetting() {
    userProfileView.tableView.backgroundColor = .white
    userProfileView.tableView.allowsSelection = false
    userProfileView.tableView.isScrollEnabled = false
  }
  
  private func tableViewHeaderSetting() {
    userProfileView.logoutButton.addTarget(self,
                                               action: #selector(tabLogoutButton),
                                               for: .touchUpInside)

    let profileImageGuesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageImage))
    userProfileView.profileImageView.addGestureRecognizer(profileImageGuesture)
    let nickNameLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabNameLabel))
    userProfileView.nameLabel.addGestureRecognizer(nickNameLabelGuesture)
  }

  // MARK: - TableView Binding
  private func tableViewBinding() {
        
    userProfileView.tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
    
    userProfileVM.allcase
      .bind(to: userProfileView.tableView.rx
              .items(cellIdentifier: UserProfileTableViewCell.identifier,
                     cellType: UserProfileTableViewCell.self)) { row, item, cell in
  
        let disposeBag = DisposeBag()
        
        item.asDriver(onErrorJustReturn: ("", ""))
          .drive { (label, value) in
            cell.titleLabel.text = label
            cell.contextLabel.text = value
          }.disposed(by: disposeBag)
        
      }.disposed(by: disposeBag)
    
  }
  
  // MARK: - Button Handler
  @objc private func tabLogoutButton() {
    print("tab Logout Button")
    
    // Firebase 기반 계정 로그아웃
    if (Auth.auth().currentUser?.uid) != nil {
      let firebaseAuth = Auth.auth()
      do { // Firebase 계정 로그아웃
        try firebaseAuth.signOut()
        print("Success logout")
        
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
        
      } catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
      }
    } else { // // Firebase 외 계정 로그아웃
      
    }
  }
  
  @objc private func tabProfileImageImage() {
    
    let alertController = UIAlertController(title: "사용자 사진 선택", message: nil, preferredStyle: .actionSheet)
    
    let cameraAction = UIAlertAction(title: "사진찍기", style: .default) { (_) in
      // Camera
      guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
      self.imagePicker.sourceType = .camera // sourceType 카메라 선택
      
//      self.imagePicker.mediaTypes = ["public.image"]
      self.imagePicker.sourceType = .camera
      self.imagePicker.mediaTypes = [kUTTypeImage as String]
      
      if UIImagePickerController.isFlashAvailable(for: .rear) {
        self.imagePicker.cameraFlashMode = .off
      }
      
      self.present(self.imagePicker, animated: true)
    }
    
    let albumAction = UIAlertAction(title: "앨범에서 선택", style: .default) { (_) in
      // Album
      self.imagePicker.sourceType = .savedPhotosAlbum // 차이점 확인하기
      self.imagePicker.mediaTypes = [kUTTypeImage] as [String] // 이미지, 사진 둘다 불러오기
      self.present(self.imagePicker, animated: true)
    }
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }

    alertController.addAction(cameraAction)
    alertController.addAction(albumAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  @objc private func tabNameLabel() {
    let alertController = UIAlertController(title: "사용자 이름 변경", message: "변경하실 이름을 입력하세요", preferredStyle: .alert)

    alertController.addTextField()

    let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (_) in
      if let newName = alertController.textFields?.first?.text {
        
        guard let userVM = self?.userVM else {
          self?.presentErrorAlert()
          return
        }
        self?.userProfileView.nameLabel.text = newName
        userVM.saveUserName(newName)
        
      }
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }

    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension UserProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    let mediaType = info[.mediaType] as! NSString
    if UTTypeEqual(mediaType, kUTTypeImage) {
      // handle Image Type
      let originalImage = info[.originalImage] as! UIImage    // 이미지를 가져옴
      let editedImage = info[.cropRect] as? UIImage        // editedImage
      let selectedImage = editedImage ?? originalImage
      
      guard var userVM = userVM else {
        presentErrorAlert()
        return
      }
      
      userProfileView.profileImageView.image = selectedImage
      
      userVM.removeUserProfileImageAtStorage(userVM.user.profileImageUrl)
      userVM.uploadUserProfileImageAtStorage(selectedImage) { newUserDate in
        userVM.user = newUserDate
      }
      
    }
    dismiss(animated: true)
  }
  
  private func presentErrorAlert() {
    present(UIAlertController.defaultSetting(title: "오류", message: "사진 전송에 오류가 발생하였습니다. 다시 시도해주세요!"), animated: true, completion: nil)
  }
}

