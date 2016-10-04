//
//  PhotoProvider.swift
//  MyPhotoFeedView
//
//  Created by doug harper on 10/3/16.
//  Copyright © 2016 Doug Harper. All rights reserved.
//

import UIKit

typealias PhotosResult = ([Photo]?, Error?) -> Void
typealias ImageResult = (URL?, UIImage?, Error?) -> Void
typealias ProgressBlock = (Float) -> Void

protocol PhotoProvider {
  func getAllPhotos(completion: @escaping PhotosResult)
  func getThumbForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult)
  func getImageForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult)
}

class FlickrPhotoProvider: PhotoProvider {
  
  var imageTask: URLSessionDownloadTask?
  
  required init() {
    
  }
  
	 func getAllPhotos(completion: @escaping PhotosResult) {
    Photo.getAllFeedPhotos(completion: completion)
  }
  
	 func getThumbForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult) {
    // TODO: Get sizes from Flickr
    getImageForPhoto(photo, progressBlock: progressBlock, completion: completion)
  }
  
	 func getImageForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult) {
    imageTask?.cancel()
    guard let photoUrl = photo?.photoUrl else {
      completion(nil, nil, nil)
      return
    }
    imageTask = NetworkClient.sharedInstance.getImageInBackground(photoUrl, downloadProgressBlock: progressBlock, completion: completion)
  }
}

class PlistPhotoProvider: PhotoProvider {
  
  private var resourceUrl: URL
  //	var retainClosure: (() -> Void)?
  
  required init(resourceUrl: URL) {
    self.resourceUrl = resourceUrl
    //		retainClosure = { print(self) }
  }
  
  func getAllPhotos(completion: @escaping PhotosResult) {
    Photo.getAllPlistPhotos(resourceUrl: self.resourceUrl, completion: completion)
  }
  
  func getThumbForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult) {
    // If photoName is not present then what to do?
    getImage(withPrefix: "thumb", forPhoto: photo, useCache: photo?.usePhotoForThumb ?? false, progressBlock: progressBlock, completion: completion)
  }
  
  func getImageForPhoto(_ photo: Photo?, progressBlock: ProgressBlock?, completion: @escaping ImageResult) {
    getImage(withPrefix: "photo", forPhoto: photo, useCache: true, progressBlock: progressBlock, completion: completion)
  }
  
  private func getImage(withPrefix prefix: String, forPhoto photo: Photo?, useCache: Bool, progressBlock: ProgressBlock?, completion: @escaping ImageResult) {
    
    if useCache, let image = photo?.photoImage {
      completion(nil, image, nil)
      return
    }
    
    guard let name = photo?.assetName else {
      completion(photo?.photoUrl, nil, nil)
      return
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      guard let image = UIImage(named: "\(prefix)\(name)") else { return }
      DispatchQueue.main.async {
        completion(photo?.photoUrl, image, nil)
      }
    }
  }
}
