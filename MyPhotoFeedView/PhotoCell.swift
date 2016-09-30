//
//  PhotoCell.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet var photoImageView: UIImageView!
  
  var photo: Photo? {
    didSet {
      photo?.getThumbnail(completion: { [weak self] (image, error) in
        guard error == nil else {
          self?.photoImageView.image = UIImage(named: "Broken")
          return
        }
        self?.photoImageView.image = image
        })
    }
  }
}
