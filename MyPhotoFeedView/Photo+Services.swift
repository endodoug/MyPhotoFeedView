//
//  Photo+Services.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import Foundation

typealias PhotosResult = ([Photo]?, Error?) -> Void

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
}
