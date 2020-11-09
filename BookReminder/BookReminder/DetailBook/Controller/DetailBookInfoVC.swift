//
//  DetailBookInfoVC.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/17.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DetailBookInfoVC: UIViewController {
  
  // MARK: - Properties
  var userSelectedBook: Book?
  var detailBookVM: DetailBookViewModel!
  let disposeBag = DisposeBag()
  
  let tableView = UITableView(frame: .zero, style: .grouped)
  let tableHeaderView = DetailBookInfoHeaderView()
  let tableFooterView = DetailBookInfoFooterView()
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let userSelectedBook = userSelectedBook else { return }
    detailBookVM = DetailBookViewModel(userSelectedBook)
    
    configureView()
    configureTableView()
  }
  
  private func configureView() {
    view.backgroundColor = .white
    view.addSubview(tableView)
    tableView.frame = view.frame
  }
  
  // MARK: - TableView Binding
  private func configureTableView() {
    tableView.backgroundColor = .white
    tableView.rowHeight = 50
    
    tableHeaderViewSetting()
    tableFooterViewSetting()
    tableviewBinding()
  }
  
  private func tableHeaderViewSetting() {
    tableView.tableHeaderView = tableHeaderView
    tableHeaderView.bookThumbnailImageView.loadBookImage(urlString: detailBookVM.book.thumbnail)
    tableView.tableHeaderView?.frame.size = CGSize(width: view.frame.width, height: 300)
  }
  
  private func tableFooterViewSetting() {
    tableView.tableFooterView = tableFooterView
    tableView.tableFooterView?.frame.size = CGSize(width: view.frame.width, height: 300)
    
    detailBookVM.summary
      .bind(to: tableFooterView.myTextView.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func tableviewBinding() {
    tableView.register(DetailBookInfoCell.self, forCellReuseIdentifier: DetailBookInfoCell.identifier)
    tableView.register(DetailBookShortStoryCell.self, forCellReuseIdentifier: DetailBookShortStoryCell.identifier)
    
    detailBookVM.allcase
      .bind(to: tableView.rx.items) { tableView , row, displayValue -> UITableViewCell in
        let indexPath = IndexPath(row: row, section: 0)
        let disposebag = DisposeBag()
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailBookInfoCell.identifier, for: indexPath) as! DetailBookInfoCell

        displayValue.subscribe(onNext: { label , value in

          cell.titleLabel.text = label
          cell.contextLabel.text = value
        }).disposed(by: disposebag)

        return cell
      }.disposed(by: disposeBag)
  }
}
