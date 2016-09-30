//
//  Photo.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import Foundation

class Photo {
  var itemId: String
  var photoName: String?
  var assetName: String!
  
  init(itemId: String, photoName: String, assetName: String) {
    self.itemId = itemId
    self.photoName = photoName
    self.assetName = assetName
  }
}
