//
//  PhotoDetailViewController.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 10/1/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
  
  var photoToShow: Photo!
  @IBOutlet weak var photoImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    photoToShow.getImage { (image, error) in
      self.photoImageView.image = image
    }
    
  }
}
