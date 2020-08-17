//
//  UserProfileVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/13.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class UserProfileVC: UITableViewController {
  
  // MARK: - Properties
  lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  
  let mainTableHeaderView = MainTableHeaderView()
  
  var userProfileData: User? {
    didSet {
      guard let userProfileData = userProfileData else { return }
      guard let profileImageUrl = userProfileData.profileImageUrl,
            let nickName = userProfileData.nickName else { return }
      
      mainTableHeaderView.configureHeaderView(profileImageUrlString: profileImageUrl, userName: nickName, isHiddenLogoutButton: false)
      
      mainTableHeaderView.logoutButton.addTarget(self,
                                                 action: #selector(tabLogoutButton),
                                                 for: .touchUpInside)
      let guesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageImage))
      mainTableHeaderView.profileImageView.addGestureRecognizer(guesture)
    }
  }
  
  
  let secionData = ["독서 관련", "기타 정보"]
  let aboutBookInfo = [
    ["등록 권수", "완독률", "comment 수", "권당 comment 수"],
    ["현재 버전", "오픈소스 라이센스"]
  ]
  
  lazy var checkDetailMenuString = aboutBookInfo[secionData.count-1].last // 오픈소스 라이센스
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "사용자 프로필"
    
    configureSetUI()
    
    configureLayout()
  }
 
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
  }
  
  private func configureSetUI() {
    
    view.backgroundColor = .gray
    
    tableView.backgroundColor = .white
  }
  
  private func configureLayout() {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.tableHeaderView = mainTableHeaderView
    tableView.tableHeaderView?.frame.size = CGSize(width: view.frame.width, height: 100)
    tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
    tableView.frame = view.frame
    
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
      
      let mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
      
      self.imagePicker.mediaTypes = mediaTypes ?? []
      self.imagePicker.mediaTypes = ["public.image"]
      //    imagePicker.mediaTypes = [kUTTypeImage] as [String]
      
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
  
  // MARK: - TableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return secionData.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return aboutBookInfo[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: UserProfileTableViewCell.identifier,
      for: indexPath
      ) as? UserProfileTableViewCell else { fatalError() }
    
    let titleText = aboutBookInfo[indexPath.section][indexPath.row]
    let isNeedDetailMenu = titleText == checkDetailMenuString ? true : false
    cell.configure(titleText: titleText,
                   contextText: "10",
                   isNeedDetailMenu: isNeedDetailMenu)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 70
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .black
    label.numberOfLines = 2
    label.backgroundColor = .systemGray6
    label.text = "\n   \(secionData[section])"
    return label
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension UserProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
  
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
      
      let profileImageView = mainTableHeaderView.profileImageView
      profileImageView.image = selectedImage
      profileImageView.layer.cornerRadius = (profileImageView.frame.height)/2
      profileImageView.clipsToBounds = true
      
    }
    dismiss(animated: true, completion: {
      
      guard let uid = Auth.auth().currentUser?.uid,
            let userdata = self.userProfileData,
            let nickName = userdata.nickName,
            let email = userdata.email else { return }
      
      guard let userProfileImage = self.mainTableHeaderView.profileImageView.image else { return }
      guard let uploadImageDate = userProfileImage.jpegData(compressionQuality: 0.5) else { return }
      
      let filename = NSUUID().uuidString
      
      STORAGE_REF_USER_PROFILEIMAGE.child(filename).putData(uploadImageDate, metadata: nil) { (metadata, error) in
        if let error = error {
          print("error",error.localizedDescription)
          return
        }
        
        let uploadImageRef = STORAGE_REF_USER_PROFILEIMAGE.child(filename)
        uploadImageRef.downloadURL { (url, error) in
          if let error = error { print("Error", error.localizedDescription); return }
          guard let url = url else { return }
          
          let value = [
            "nickName": nickName,
            "email": email,
            "profileImageUrl": url.absoluteString
          ] as Dictionary<String, AnyObject>
          
          DB_REF_USER.child(uid).updateChildValues(value)
        }
      }
    })
  }
}


