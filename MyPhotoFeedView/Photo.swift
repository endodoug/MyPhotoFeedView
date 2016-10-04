//
//  Photo.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class Photo:NSObject {
  var itemId: String
  var photoName: String?
  var assetName: String!
  var photoUrl: URL!
  var photoImage: UIImage?
  public var usePhotoForThumb = false
  
  init(itemId: String, assetName: String, photoName: String? = nil) {
    self.itemId = itemId
    self.assetName = assetName
    self.photoName = photoName
  }
  
  init(dictionary values: Dictionary<String, Any>) {
    guard let link = values["link"] as? String else {
      fatalError("Photo item could not be created: " + values.description)
    }
    itemId = link
    
    guard let media = values["media"] as? Dictionary<String, Any>,
      let urlString = media["m"] as? String, let url = URL(string: urlString) else {
        fatalError("Photo item could not be created: " + values.description)
    }
    photoUrl = url
    
    if let title = values["title"] as? String {
      photoName = title
    }
    super.init()
  }
  
}
