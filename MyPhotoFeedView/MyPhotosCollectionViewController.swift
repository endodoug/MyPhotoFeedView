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
  let messageCellIdentifier = "messageCell"
  
  let loadingMessage = "Loading photos..."
  var currentMessage: String!
  
  let transitionController = ZoomTransitionController()
  
  private enum SegueIndentifier: String {
    case photoDetail
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.delegate = transitionController
    
    guard let plistUrl = Bundle.main.url(forResource: "imageData", withExtension: "plist") else {
      fatalError("Error retrieving ImagaData")
    }
    
    Photo.getAllPlistPhotos(resourceUrl: plistUrl) { (photos, error) in
      self.photos = photos
      self.collectionView?.reloadData()
      self.collectionViewLayout.invalidateLayout()
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    guard let segueIndentifier = SegueIndentifier(rawValue: identifier) else { return }
    
    switch segueIndentifier {
    case .photoDetail:
      let transitionDelegate = self.navigationController!.delegate as! ZoomTransitionController
      //let controller = segue.destination as! PhotoDetailViewController
      let cell = sender as! PhotoCell
      transitionDelegate.sourceView = cell
      let controller = segue.destination as! PhotoDetailViewController
      controller.photoToShow = cell.photo
    }
  }
}

// MARK: - CollectionView delegate/data source methods

extension MyPhotosCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let photos = photos else { return 1 }
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell
    if let photos = photos, photos.count > 0 {
      let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
      photoCell.photo = photos[indexPath.item]
      cell = photoCell
    } else {
      let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellIdentifier, for: indexPath) as! MessageCell
      messageCell.messageLabel.text = currentMessage
      cell = messageCell
    }
    
    return cell
  }
}





















