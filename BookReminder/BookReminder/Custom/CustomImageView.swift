//
//  CustomImageView.swift
//  BookReminder
//
//  Created by 김광수 on 2020/08/15.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
  
  var lastImageUsedToLoadImage: String?
  
  func loadProfileImage(urlString: String) {
    
    self.image = nil
    
    lastImageUsedToLoadImage = urlString
    
    // 이전에 저장되어 있던 이미지 일 경우 즉시 저장
    if let cachedImage = imageCache[urlString] {
      self.image = cachedImage
      return
    }
    
    guard let url = URL(string: urlString) else {
      let imageconf = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
      self.image = UIImage(systemName: "person.circle",
                                withConfiguration: imageconf)
      self.tintColor = CommonUI.titleTextColor
      self.contentMode = .scaleAspectFill
      self.isUserInteractionEnabled = true
      return print("Fail to get imageURLSTring to URL")
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Error", error.localizedDescription)
        return
      }
      
      guard let imageData = data else { return }
      let photoImage = UIImage(data: imageData)
      
      imageCache[url.absoluteString] = photoImage
      
      DispatchQueue.main.async {
        self.image = photoImage
      }
    }.resume()
  }
  
  func loadBookImage(urlString: String) {
    
    self.image = nil
    
    lastImageUsedToLoadImage = urlString
    
    // 이전에 저장되어 있던 이미지 일 경우 즉시 저장
    if let cachedImage = imageCache[urlString] {
      self.image = cachedImage
      return
    }
    
    guard let url = URL(string: urlString) else {
      let imageconf = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
      self.image = UIImage(systemName: "xmark.octagon",
                                withConfiguration: imageconf)
      self.tintColor = CommonUI.titleTextColor
      self.contentMode = .scaleAspectFit
      self.isUserInteractionEnabled = true
      return print("Fail to get imageURLSTring to URL")
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Error", error.localizedDescription)
        return
      }
      
      guard let imageData = data else { return }
      let photoImage = UIImage(data: imageData)
      
      imageCache[url.absoluteString] = photoImage
      
      DispatchQueue.main.async {
        self.image = photoImage
      }
    }.resume()
  }
  
}
