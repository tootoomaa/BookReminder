//
//  MyBookView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/10/26.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit

class MyBookView: UIView {
  // MARK: - Properties
  var multibuttomActive: Bool = false
  
  lazy var safeGuide = safeAreaLayoutGuide
  
  let featureButtonSize: CGFloat = 50
  let bounceDistance: CGFloat = 25
  let multiButtonSize: CGFloat = 70
  
  let searchBar: UISearchBar = {
    let sBar = UISearchBar(frame: .zero)
    sBar.placeholder = " 등록된 책 검색.."
    sBar.backgroundColor = .white
    sBar.barStyle = .default
    sBar.barTintColor = .none
    sBar.searchBarStyle = .minimal
    sBar.showsCancelButton = false
    return sBar
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()
  
  lazy var multiButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
    let buttonImage = UIImage(systemName: "plus", withConfiguration: imageConfigure)
    button.addTarget(self, action: #selector(tabMultiButton), for: .touchUpInside)
    button.imageView?.tintColor = .white
    button.backgroundColor = CommonUI.mainBackgroudColor
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = multiButtonSize/2
    button.clipsToBounds = true
    return button
  }()
  
  lazy var barcodeButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "barcode", withConfiguration: imageConfigure)
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.999982059, green: 0.6622204781, blue: 0.1913976967, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    
    return button
  }()
  
  lazy var bookSearchButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfigure)
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.8973528743, green: 0.9285049438, blue: 0.7169274688, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    return button
  }()
  
  lazy var deleteBookButton: UIButton = {
    let button = UIButton()
    let imageConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
    let buttonImage = UIImage(systemName: "delete.right", withConfiguration: imageConfigure)
    button.imageView?.tintColor = .white
    button.backgroundColor = #colorLiteral(red: 0.5455855727, green: 0.8030222058, blue: 0.8028761148, alpha: 1)
    button.setImage(buttonImage, for: .normal)
    button.layer.cornerRadius = featureButtonSize/2
    button.clipsToBounds = true
    return button
  }()
  
  // MARK: - Life Cycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureLayout()
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure UI
  private func configureLayout() {
    searchBarSetting()
    collectionViewSetting()
    multibuttonSetting()
  }
  
  private func searchBarSetting() {
    addSubview(searchBar)
    searchBar.snp.makeConstraints{
      $0.top.equalTo(safeGuide.snp.top).offset(20)
      $0.leading.equalTo(safeGuide.snp.leading).offset(10)
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-10)
      $0.height.equalTo(40)
    }
  }
  
  private func collectionViewSetting() {
    addSubview(collectionView)
    collectionView.backgroundColor = .white
    collectionView.snp.makeConstraints{
      $0.top.equalTo(searchBar.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalTo(safeGuide)
    }
  }
  
  private func multibuttonSetting() {
    [barcodeButton, bookSearchButton, deleteBookButton, multiButton].forEach{
      addSubview($0)
    }
    
    multiButton.snp.makeConstraints{
      $0.trailing.equalTo(safeGuide.snp.trailing).offset(-20)
      $0.bottom.equalTo(safeGuide.snp.bottom).offset(-20)
      $0.width.height.equalTo(multiButtonSize)
    }
    
    [barcodeButton, bookSearchButton, deleteBookButton].forEach{
      $0.snp.makeConstraints{
        $0.centerX.equalTo(multiButton.snp.centerX)
        $0.centerY.equalTo(multiButton.snp.centerY)
        $0.width.height.equalTo(featureButtonSize)
      }
    }
  }
  
  // MARK: - Configure Button Animation
  @objc func tabMultiButton() {
    if !multibuttomActive {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: -(.pi/4*3))
      }
      //barcode -> bookSearch -> delete
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
          self.barcodeButton.center.y -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
          self.bookSearchButton.center.y -= self.featureButtonSize*1.5
          self.bookSearchButton.center.x -= self.featureButtonSize*1.5
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
          self.deleteBookButton.center.x -= self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
          self.barcodeButton.center.y += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
          self.bookSearchButton.center.y += self.bounceDistance
          self.bookSearchButton.center.x += self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1) {
          self.deleteBookButton.center.x += self.bounceDistance
        }
      })
      
    } else {
      UIView.animate(withDuration: 0.5) {
        self.multiButton.transform = self.multiButton.transform.rotated(by: .pi/4*3)
      }
      // delete -> bookSearch -> barcode
      UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: [], animations: {
        // 바운드
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
          self.deleteBookButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
          self.bookSearchButton.center.y -= self.bounceDistance
          self.bookSearchButton.center.x -= self.bounceDistance
        }
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1) {
          self.barcodeButton.center.y -= self.bounceDistance
        }
        // 사라짐
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
          self.deleteBookButton.center.x += self.featureButtonSize*2
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
          self.bookSearchButton.center.y += self.featureButtonSize*1.5
          self.bookSearchButton.center.x += self.featureButtonSize*1.5
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
          self.barcodeButton.center.y += self.featureButtonSize*2
        }
        
      })
    }
    multibuttomActive.toggle()
  }
  
  func initializationMultiButton() {
    DispatchQueue.main.async {
      self.multibuttomActive = false
      self.deleteBookButton.center.x += self.featureButtonSize*2 - self.bounceDistance
      self.bookSearchButton.center.y += self.featureButtonSize*1.5 - self.bounceDistance
      self.bookSearchButton.center.x += self.featureButtonSize*1.5 - self.bounceDistance
      self.barcodeButton.center.y += self.featureButtonSize*2 - self.bounceDistance
      self.multiButton.transform = .identity
    }
  }
}
