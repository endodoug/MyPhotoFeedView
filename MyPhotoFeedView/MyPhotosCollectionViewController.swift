//
//  MyPhotosCollectionViewController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MyPhotosCollectionViewController: UICollectionViewController {
  // optional arrary of Photo - will be loaded on VDL
  var photos: [Photo]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let plistUrl = Bundle.main.url(forResource: "ImageData", withExtension: "plist") else {
      fatalError("Error retrieving ImagaData")
    }
    
    Photo.getAllPlistPhotos(resourceUrl: plistUrl) { (photos, error) in
      self.photos = photos
      self.collectionView?.reloadData()
      self.collectionViewLayout.invalidateLayout()
      
    }
  }
}
