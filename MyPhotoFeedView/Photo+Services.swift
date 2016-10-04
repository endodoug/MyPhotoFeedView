//
//  Photo+Services.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import Foundation
import UIKit

enum PhotoServiceError: String, Error {
  case NotImplemented = "This feature has not been implemented yet."
  case URLParsing = "Sorry, there was an error getting the photos."
  case JSONStructure = "Sorry, the photo service returned something different than expected."
}

extension Photo {
  class func getAllPlistPhotos(resourceUrl: URL, completion: @escaping PhotosResult) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let items = NSArray(contentsOf: resourceUrl) as? [Dictionary<String, Any>] else { return print("items did not load") }
      var photos = [Photo]()
      for (count, anyItem) in items.enumerated() {
        let resourceName = anyItem["name"] as! String
        let title = anyItem["title"] as! String
        let photo = Photo(itemId: "\(count)", photoName: title, assetName: resourceName)
        photos.append(photo)
      }
      DispatchQueue.main.async {
        completion(photos, nil)
      }
    }
  }
  
  class func getAllFeedPhotos(completion: PhotosResult) {
    //
  }
  
  func getThumbnail(completion: @escaping ImageResult) {
      getImage(withPrefix: "thumb", completion: completion)
    }
    
    func getImage(completion: @escaping ImageResult) {
      getImage(withPrefix: "photo", completion: completion)
    }
    
    private func getImage(withPrefix prefix: String, completion: @escaping ImageResult) {
      guard let name = self.assetName else {
        completion(nil, nil, nil)
        return
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      let image = UIImage(named: "\(prefix)\(name)")
      DispatchQueue.main.async {
        completion(nil, image, nil)
      }
    }
    
  }

  
}






















