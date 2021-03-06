//
//  PhotoDetailViewController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 10/1/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
  
  @IBOutlet weak var quarterHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var halfHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoImageView: PhotoMotionView!
  
  var photoToShow: Photo!
  var photoProvider: PhotoProvider!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    photoProvider.getImageForPhoto(photoToShow, progressBlock: nil, completion: { (originalUrl, image, error) in
      self.photoImageView.image = image
    })
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.7, delay: 1.0, options: .curveEaseInOut, animations: {
      self.halfHeightConstraint.isActive = false
      self.quarterHeightConstraint.isActive = true
      self.view.layoutIfNeeded()
      }, completion: nil)
  }
}
