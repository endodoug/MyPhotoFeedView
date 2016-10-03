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
  
  var photoToShow: Photo!
  @IBOutlet weak var photoImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    photoToShow.getImage { (image, error) in
      self.photoImageView.image = image
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.7, delay: 1.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
      self.halfHeightConstraint.isActive = false
      self.quarterHeightConstraint.isActive = true
      self.view.layoutIfNeeded()
      }, completion: nil)
  }
}
