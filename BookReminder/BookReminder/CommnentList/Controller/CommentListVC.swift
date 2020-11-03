//
//  CommentListVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/15.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

class CommentListVC: UIViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  var commentListVM: CommentListViewModel!
  
  let tableView = UITableView(frame: .zero, style: .plain)
  
  var userSelectedBook: Book?
  var isCommentEditing: Bool?
  var isInitailDataLoaded = false
  
  var commentList: [Comment] = []
  
  let activityIndicator: UIActivityIndicatorView = {
    let activityView = UIActivityIndicatorView()
    activityView.color = CommonUI.mainBackgroudColor
    activityView.hidesWhenStopped = true
    activityView.style = .large
    return activityView
  }()
  
  // MARK: - Life Cycle
  init(_ userSelectedBook: Book, _ isCommentEditing: Bool) {
    super.init(nibName: nil, bundle: nil)
    self.userSelectedBook = userSelectedBook
    self.isCommentEditing = isCommentEditing
    self.title = isCommentEditing == false ? userSelectedBook.title : "Comment 수정"
  }
  
  override func viewDidLoad() {
    fetchUserCommentDate()
    configureUISetting()
    configureActivityIndicatorView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureActivityIndicatorView() {
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    activityIndicator.startAnimating()
    if isInitailDataLoaded == true {
      guard let book = userSelectedBook else { return }
      CommentViewModel.fetchUpdatedUserComments(book)
        .subscribe(onNext:{ [weak self] value in
          
          let newArrayValue = value.map { comment -> CommentViewModel in
            return CommentViewModel(comment)
          }
          self?.commentListVM.allcase.accept(newArrayValue)
          self?.activityIndicator.stopAnimating()
        }).disposed(by: disposeBag)
    }
    navigationController?.navigationBar.isHidden = false
  }
  
  // MARK: - Configure TableView Binding
  private func configureUISetting() {
    
    view.backgroundColor = .white
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
    }
    
    tableView.addSubview(activityIndicator)
    
    activityIndicator.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
    }
  }
  
  private func configureTableView() {
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    tableView.rowHeight = 150
    
    tableViewBinding()
    tableViewSelectItemBinding()
    tableViewDeleteItemBinding()
  }
  
  private func tableViewBinding() {
    tableView.register(CommentListCell.self, forCellReuseIdentifier: CommentListCell.identifier)
    
    commentListVM.allcase.bind(to: tableView.rx.items(cellIdentifier: CommentListCell.identifier, cellType: CommentListCell.self)) { row, item, cell in
      let disposeBag = DisposeBag()
      
      item.captureImageUrl
        .subscribe { imageUrl in
          cell.captureImageView.loadImage(urlString: imageUrl)
        }.disposed(by: disposeBag)
      
      item.page.asDriver(onErrorJustReturn: "")
        .drive(cell.pageLabel.rx.text)
        .disposed(by: disposeBag)
      
      item.myComment.asDriver(onErrorJustReturn: "")
        .drive(cell.myTextView.rx.text)
        .disposed(by: disposeBag)
      
    }.disposed(by: disposeBag)
  }
  
  private func tableViewSelectItemBinding() {
    guard let isCommentEditing = isCommentEditing else { return }
    tableView.rx
      .itemSelected.bind { [weak self] in
        if let comment = self?.commentListVM.commentList[$0.row],
           let isbnCode = self?.userSelectedBook?.isbn {
          let addCommentVC = AddCommentVC(isbnCode, comment.comment)
          addCommentVC.isCommentEditing = isCommentEditing
          
          let disposeBag = DisposeBag()
          let view = addCommentVC.addCommentView
          
          view.captureImageView.loadImage(urlString: comment.comment.captureImageUrl)
          
          comment.page.asDriver(onErrorJustReturn: "")
            .drive(view.pagetextField.rx.text)
            .disposed(by: disposeBag)
          
          comment.myComment.asDriver(onErrorJustReturn: "")
            .drive(view.myTextView.rx.text)
            .disposed(by: disposeBag)
          
          self?.navigationController?.pushViewController(addCommentVC, animated: true)
        }
      }.disposed(by: disposeBag)
  }
  
  private func tableViewDeleteItemBinding() {
    tableView.rx.itemDeleted
      .subscribe(onNext: { [weak self] indexPath in
        if let isbnCode = self?.userSelectedBook?.isbn {
          self?.commentListVM.deleteComment(isbnCode, indexPath)
        }
      }).disposed(by: disposeBag)
  }
  
  // MARK: - handle Network
  func fetchUserCommentDate() {
    guard let book = userSelectedBook else { return }
    activityIndicator.startAnimating()
    CommentViewModel.fetchUserComments(book)
      .subscribe(onNext: { [weak self] value in
        self?.commentListVM = CommentListViewModel(value)
        self?.configureTableView()
        self?.commentListVM.reloadData()
        self?.isInitailDataLoaded = true
        self?.activityIndicator.stopAnimating()
      }).disposed(by: disposeBag)
    
  }
}
