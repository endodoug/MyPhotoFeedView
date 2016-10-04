//
//  MyPhotosCollectionViewController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class MyPhotosCollectionViewController: UICollectionViewController {
  
  @IBOutlet weak var sourceSegmentController: UISegmentedControl!
  
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
  
  enum PhotoSource {
    case plist
    case flickr
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
    
    setupAccessibility()
    
  }
  
  func setupAccessibility() {
    let segment: NSString = "Plist"
    segment.accessibilityLabel = "P list"
    sourceSegmentController.setTitle(segment as String, forSegmentAt: 0)
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
      controller.photoProvider = cell.photoProvider
    }
  }
  
  private func setPhotoProvider() {
    currentMessage = loadingMessage
    photos = nil
    collectionView!.reloadData()
    collectionViewLayout.invalidateLayout()
    
    let photoResult: PhotosResult = { [weak self] (photos, error) in
      guard error == nil else {
        if let error = error as? PhotoServiceError {
          self?.currentMessage = error.rawValue
        } else if let error = error as? NSError {
          self?.currentMessage = error.localizedDescription
        } else {
          self?.currentMessage = "Sorry, there was an error."
        }
        self?.photos = nil
        self?.collectionView?.reloadData()
        self?.collectionViewLayout.invalidateLayout()
        return
      }
      self?.photos = photos
      self?.collectionView?.reloadData()
      self?.collectionViewLayout.invalidateLayout()
    }
    
    if sourceSegmentController.selectedSegmentIndex == 1 {
      FlickrPhotoProvider().getAllPhotos(completion: photoResult)
    } else {
      guard let plistUrl = Bundle.main.url(forResource: "imageData", withExtension: "plist") else {
        fatalError("Error retrieving ImageData")
      }
      PlistPhotoProvider(resourceUrl: plistUrl).getAllPhotos(completion: photoResult)
    }
  }
  
  func selectSource(_ provider: PhotoSource) {
    switch provider {
    case .plist:
      sourceSegmentController.selectedSegmentIndex = 0
    case .flickr:
      sourceSegmentController.selectedSegmentIndex = 1
    }
    setPhotoProvider()
  }
  
  @IBAction func sourceSegmentControllerChanged(_ sender: UISegmentedControl) {
    setPhotoProvider()
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
      
      if sourceSegmentController.selectedSegmentIndex == 1 {
        photoCell.photoProvider = FlickrPhotoProvider()
      } else {
        guard let plistUrl = Bundle.main.url(forResource: "imageData", withExtension: "plist") else {
          fatalError("Error retrieving imageData")
        }
        photoCell.photoProvider = PlistPhotoProvider(resourceUrl: plistUrl)
      }
      
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





















