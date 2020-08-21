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
      let profileImageGuesture = UITapGestureRecognizer(target: self, action: #selector(tabProfileImageImage))
      mainTableHeaderView.profileImageView.addGestureRecognizer(profileImageGuesture)
      let nickNameLabelGuesture = UITapGestureRecognizer(target: self, action: #selector(tabNameLabel))
      mainTableHeaderView.nameLabel.addGestureRecognizer(nickNameLabelGuesture)
    }
  }
  
  let secionData = ["독서 관련", "기타 정보"]
  let aboutBookInfo = [
    ["등록 권수", "완독 수" ,"완독률", "comment 수", "권당 comment 수"],
    ["현재 버전", "오픈소스 라이센스"]
  ]
  var aboutBookInfoValue = [
    ["0", "0", "0", "0", "0"],
    ["1.0","오픈소스 라이센스"]
  ]
  
  var userProfileValue: [String: Int] = [:] {
    didSet {
      if let commentCount = userProfileValue["commentCount"],
        let compliteBookCount = userProfileValue["compliteBookCount"],
        let enrollBookCount = userProfileValue["enrollBookCount"] {
      
        aboutBookInfoValue[0] = []
        
        aboutBookInfoValue[0].append("\(enrollBookCount) 권 ")
        aboutBookInfoValue[0].append("\(compliteBookCount) 권 ")
        
        var compliteRatio = 0
        if enrollBookCount != 0 {
          compliteRatio = Int(Double(compliteBookCount) / Double(enrollBookCount) * 100.0)
        }
        aboutBookInfoValue[0].append("\(compliteRatio) % ")
        aboutBookInfoValue[0].append("\(commentCount) 개 ")
        
        var commentRatio: Double = 0.0
        if enrollBookCount != 0 {
          commentRatio = Double(commentCount) / Double(enrollBookCount)
          let text = String(format: "%.2f 개", arguments: [commentRatio])
          aboutBookInfoValue[0].append(text)
        }
        aboutBookInfoValue[0].append("평균 \(commentRatio) 개 ")
        
        tableView.reloadData()
      }
    }
  }

  lazy var checkDetailMenuString = aboutBookInfo[secionData.count-1].last // 오픈소스 라이센스
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "사용자 프로필"
    
    fetchStaticData()
    
    configureSetUI()
    
    configureLayout()
  }
 
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.navigationBar.isHidden = false
    let imageView =  mainTableHeaderView.profileImageView
    imageView.layer.cornerRadius = (imageView.frame.size.height)/2
    imageView.clipsToBounds = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.popViewController(animated: true)
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
    
    let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
      guard let uid = Auth.auth().currentUser?.uid else { return }
      guard let userProfileData = self.userProfileData else { return }
      
      if let email = userProfileData.email,
        let profileImageUrl = userProfileData.profileImageUrl {
        
        if let text = alertController.textFields?.first?.text {
          self.mainTableHeaderView.nameLabel.text = text
          
          let value = [
            "nickName": text,
            "email": email,
            "profileImageUrl": profileImageUrl
            ] as Dictionary<String, AnyObject>
          
          self.userProfileData = User(uid: uid, dictionary: value)
          
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
    guard let uid = Auth.auth().currentUser?.uid else { return }
    DB_REF_USERPROFILE.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionaryValue = snapshot.value as? [String: Int] else { return }
      self.userProfileValue = dictionaryValue
    }
  }
  
  // MARK: - TableViewDataSource
  override func numberOfSections(in tableView: UITableView) -> Int {
    return secionData.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 1 { // 오픈소스 라이브러리 메뉴 제거
      return aboutBookInfo[section].count - 1
    }
    
    return aboutBookInfo[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: UserProfileTableViewCell.identifier,
      for: indexPath
      ) as? UserProfileTableViewCell else { fatalError() }
    
    let titleText = aboutBookInfo[indexPath.section][indexPath.row]
    let contextText = aboutBookInfoValue[indexPath.section][indexPath.row]
    
    let isNeedDetailMenu = titleText == checkDetailMenuString ? true : false

    cell.configure(titleText: titleText,
                   contextText: contextText,
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
      profileImageView.layer.cornerRadius = (profileImageView.frame.size.height)/2
      profileImageView.clipsToBounds = true
    }
    
    dismiss(animated: true, completion: {
      
      guard let uid = Auth.auth().currentUser?.uid,
            let userdata = self.userProfileData,
            let nickName = userdata.nickName,
            let email = userdata.email else { return }
      
      guard let userProfileImage = self.mainTableHeaderView.profileImageView.image else { return }
      guard let uploadImageDate = userProfileImage.jpegData(compressionQuality: 0.3) else { return }
      
      let filename = NSUUID().uuidString
      
      if let beforeImageURL = self.userProfileData?.profileImageUrl {
        if beforeImageURL != "" {
          Storage.storage().reference(forURL: beforeImageURL).delete(completion: nil)
        }
      }
      
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
          
          self.userProfileData = User(uid: uid, dictionary: value)
          
          DB_REF_USER.child(uid).updateChildValues(value)
        }
      }
    })
  }
}

