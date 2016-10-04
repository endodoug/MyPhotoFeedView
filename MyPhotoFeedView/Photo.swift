//
//  Photo.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class Photo {
  var itemId: String
  var photoName: String?
  var assetName: String!
  var photoUrl: URL!
  var photoImage: UIImage?
  public var usePhotoForThumb = false
  
  init(itemId: String, photoName: String, assetName: String) {
    self.itemId = itemId
    self.photoName = photoName
    self.assetName = assetName
  }
}
