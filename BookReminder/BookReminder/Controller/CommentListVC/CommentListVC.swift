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
  var markedBookInfo: BookDetailInfo?
  var commentList: [Comment] = []
  var naviTitleString: String = ""
  
  // MARK: - Life Cycle
  override init(style: UITableView.Style) {
    super.init(style: .plain)
    
    naviTitleString.append("\(markedBookInfo?.title)'s ")
    naviTitleString.append("Comment List")
    
    title = naviTitleString
    
    configureTableView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
   
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.navigationBar.isHidden = false
    
    fetchUserCommentDate()
  }
  
  private func configureTableView() {
    
    tableView.frame = view.frame
    tableView.allowsSelection = false
    
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
  
  // MARK: - handle Network
  func fetchUserCommentDate() {
    
    guard let uid = Auth.auth().currentUser?.uid else { return print("no uid" ) }
    guard let isbnCode = markedBookInfo?.isbn else { return print("no isbn code")}
    
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



