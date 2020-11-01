//
//  UserProfileVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/13.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
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
    
    userDataBinding()
    
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
  // MARK: - User Data Binding
  private func userDataBinding() {
    guard let userVM = userVM else { return }
    userVM.nickName.asDriver(onErrorJustReturn: "")
      .drive(self.userProfileView.nameLabel.rx.text)
      .disposed(by: disposeBag)
    
    userVM.profileImageUrl.bind { [weak self] imageUrl in
      self?.userProfileView.profileImageView.loadImage(urlString: imageUrl)
    }.disposed(by: disposeBag)
  }
  
  // MARK: - TableView Setting
  private func configureTableViewSetting() {
    tableViewBasicSetting()
    tableViewHeaderSetting()
  }
  
  private func tableViewBasicSetting() {
    userProfileView.tableView.backgroundColor = .white
    userProfileView.tableView.allowsSelection = false
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
    guard let userData = userVM?.user else { return }
    let alertController = UIAlertController(title: "사용자 이름 변경", message: "변경하실 이름을 입력하세요", preferredStyle: .alert)

    alertController.addTextField()

    let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
      guard let uid = Auth.auth().currentUser?.uid else { return }

      if let email = userData.email,
        let profileImageUrl = userData.profileImageUrl {

        if let text = alertController.textFields?.first?.text {
          self.mainTableHeaderView.nameLabel.text = text

          let value = [
            "nickName": text,
            "email": email,
            "profileImageUrl": profileImageUrl
            ] as Dictionary<String, AnyObject>

          
          
          DB_REF_USER.updateChildValues([uid: value])
        }
      }
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in }

    alertController.addAction(okAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Handler
  private func fetchStaticData() {
    UserProfileViewModel.fetchUserProfile()
      .subscribe(onNext:{ [weak self] value in
        self?.userProfileVM = value
        self?.tableViewBinding()
      }).disposed(by: disposeBag)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension UserProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
//
//  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//    picker.dismiss(animated: true, completion: nil)
//  }
//
//  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//    let mediaType = info[.mediaType] as! NSString
//    if UTTypeEqual(mediaType, kUTTypeImage) {
//      // handle Image Type
//      let originalImage = info[.originalImage] as! UIImage    // 이미지를 가져옴
//      let editedImage = info[.cropRect] as? UIImage        // editedImage
//      let selectedImage = editedImage ?? originalImage
//
//      let profileImageView = mainTableHeaderView.profileImageView
//      profileImageView.image = selectedImage
//      profileImageView.layer.cornerRadius = (profileImageView.frame.size.height)/2
//      profileImageView.clipsToBounds = true
//    }
//
//    dismiss(animated: true, completion: {
//
//      guard let uid = Auth.auth().currentUser?.uid,
//            let userdata = self.userProfileData,
//            let nickName = userdata.nickName,
//            let email = userdata.email else { return }
//
//      guard let userProfileImage = self.mainTableHeaderView.profileImageView.image else { return }
//      guard let uploadImageDate = userProfileImage.jpegData(compressionQuality: 0.3) else { return }
//
//      let filename = NSUUID().uuidString
//
//      if let beforeImageURL = self.userProfileData?.profileImageUrl {
//        if beforeImageURL != "" {
//          Storage.storage().reference(forURL: beforeImageURL).delete(completion: nil)
//        }
//      }
//
//      STORAGE_REF_USER_PROFILEIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { (metadata, error) in
//        if let error = error {
//          print("error",error.localizedDescription)
//          return
//        }
//
//        let uploadImageRef = STORAGE_REF_USER_PROFILEIMAGE.child(filename)
//        uploadImageRef.downloadURL { (url, error) in
//          if let error = error { print("Error", error.localizedDescription); return }
//          guard let url = url else { return }
//
//          let value = [
//            "nickName": nickName,
//            "email": email,
//            "profileImageUrl": url.absoluteString
//          ] as Dictionary<String, AnyObject>
//
//          self.userProfileData = User(uid: uid, dictionary: value)
//
//          DB_REF_USER.child(uid).updateChildValues(value)
//        }
//      }
//    })
//  }
}

