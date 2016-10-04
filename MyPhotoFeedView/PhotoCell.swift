//
//  PhotoCell.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 9/29/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var progressView: UIProgressView!
  var photoProvider: PhotoProvider!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    photoImageView.layer.cornerRadius = 25
    photoImageView.clipsToBounds = true
    photoImageView.layer.borderColor = UIColor.black.cgColor
    photoImageView.layer.borderWidth = 2
    
    isAccessibilityElement = true
    accessibilityLabel = "Photo"
    accessibilityTraits |= UIAccessibilityTraitButton
  }

  
  var photo: Photo? {
    didSet {
      accessibilityLabel = photo?.photoName ?? "Photo"
      
      photoProvider.getThumbForPhoto(photo, progressBlock:
        { [weak self] (progress) in
          if (progress > 0 && progress < 1) {
            self?.progressView.progress = progress
            self?.progressView.isHidden = false
          } else {
            self?.progressView.isHidden = true
          }
        }, completion: { [weak self] (originalUrl, image, error) in
          
          guard error == nil else {
            self?.photoImageView.image = UIImage(named: "Broken")
            return
          }
          guard image != nil else {
            self?.photoImageView.image = UIImage(named: "Downloading")
            return
          }
          self?.photoImageView.image = image
        }
      )
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    photo = nil
  }
  
}
