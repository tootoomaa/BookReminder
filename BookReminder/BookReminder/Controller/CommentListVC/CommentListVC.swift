//
//  CommentListVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/15.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class CommentListVC: UITableViewController {
  
  // MARK: - Properties
  let naviTitlelabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 2
    return label
  }()
  
  var markedBookInfo: BookDetailInfo? {
    didSet {
      guard let bookTitle = markedBookInfo?.title else { return }
      var naviTitleString = ""
      naviTitleString.append("\(bookTitle)'s")
      naviTitleString.append("\nComment List")
      naviTitlelabel.text = naviTitleString
      navigationItem.titleView = naviTitlelabel
    }
  }
  
  var commentList: [Comment] = []
  
  // MARK: - Life Cycle
  override init(style: UITableView.Style) {
    super.init(style: .plain)
    
    configureTableView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
   
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
    commentList = []
    fetchUserCommentDate()
  }
  
  private func configureTableView() {
    
    tableView.frame = view.frame
    
    tableView.register(CommentListCell.self, forCellReuseIdentifier: CommentListCell.identifier)
    
  }
  
  // MARK: - UITableViewDatasource
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: CommentListCell.identifier,
      for: indexPath) as? CommentListCell else { fatalError() }
    
    let commentInfo = commentList[indexPath.row]
    
    cell.configure(captureImageUrl: commentInfo.captureImageUrl,
                   pageString: commentInfo.page,
                   myCommentText: commentInfo.myComment)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentList.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 150
  }
  
  // MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let addCommentVC = AddCommentVC()
    guard let view = addCommentVC.view as? AddCommentView else { return }
    guard let cell = tableView.cellForRow(at: indexPath) as? CommentListCell else { return }
    
    view.myTextView.text = cell.myTextView.text
    view.captureImageView.image = cell.captureImageView.image
    
    addCommentVC.commentInfo = commentList[indexPath.row]
    addCommentVC.isEditingMode = true   // 신규 Comment 추가가 아닌 기존 Comment 수정
    addCommentVC.isUserInputText = true // 내용만 멀티 버튼 고정
    addCommentVC.markedBookInfo = markedBookInfo
    
    if let sepString = cell.pageLabel.text?.split(separator: "P") {
      view.pagetextField.text = String(sepString[0])
    }
    navigationController?.pushViewController(addCommentVC, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let deleteAction = UIContextualAction(style: .normal, title: "DELETE") {
      (action, sourceView, actionPerformed) in

      guard let uid = Auth.auth().currentUser?.uid else { return }
      let deleteCommentData = self.commentList[indexPath.row]
      if let deleteCommentUid = deleteCommentData.commentUid,
        let isbnCode = self.markedBookInfo?.isbn {
        // 사용자 comment 삭제 및 comment 통계 삭제
        DB_REF_COMMENT.child(uid).child(isbnCode).child(deleteCommentUid).removeValue()
        Database.commentCountHandler(uid: uid, isbnCode: isbnCode, plusMinus: .down)
      }
      
      self.commentList.remove(at: indexPath.row)
      self.tableView.reloadData()
      
      
      
      actionPerformed(true)
    }
    deleteAction.backgroundColor = .red
    
    let configure = UISwipeActionsConfiguration(actions: [deleteAction])
    configure.performsFirstActionWithFullSwipe = false
    return configure
  }
  
  // MARK: - handle Network
  func fetchUserCommentDate() {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let isbnCode = markedBookInfo?.isbn else { return }
    
    Database.fetchCommentDataList(uid: uid, isbnCode: isbnCode, complition: { (comment) in
      self.commentList.append(comment)
      
      self.commentList.sort { (comment1, comment2) -> Bool in
        guard let com1 = Int(comment1.page),
              let com2 = Int(comment2.page) else { return false }
        return com1 > com2
      }
      self.tableView.reloadData()
    })
  }
}



