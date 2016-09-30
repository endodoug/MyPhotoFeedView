//
//  MyPhotosCollectionViewController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class MyPhotosCollectionViewController: UICollectionViewController {
  // optional arrary of Photo - will be loaded on VDL
  var photos: [Photo]?
  let cellIdentifier = "photoCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let plistUrl = Bundle.main.url(forResource: "imageData", withExtension: "plist") else {
      fatalError("Error retrieving ImagaData")
    }
    
    Photo.getAllPlistPhotos(resourceUrl: plistUrl) { (photos, error) in
      self.photos = photos
      self.collectionView?.reloadData()
      self.collectionViewLayout.invalidateLayout()
      
    }
    
    print(photos?.description)
  }
}

extension MyPhotosCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let photos = photos else { return 0 }
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell
    guard let photos = photos, photos.count > 0 else { fatalError() }
    let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
    photoCell.photo = photos[indexPath.item]
    cell = photoCell
    return cell
  }
}
