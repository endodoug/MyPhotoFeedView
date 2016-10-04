//
//  NetworkClient.swift
//  FlickrFeed
//
//  Created by Christopher Griffith on 8/24/16.
//  Copyright © 2016 AltU. All rights reserved.
//

import UIKit

enum NetworkClientError: Error {
	case imageData
}

typealias NetworkResult = (Any?, Error?) -> Void

class NetworkClient: NSObject {

	var urlSession:URLSession
	var backgroundSession:URLSession!
	var completionHandlers = [URL: ImageResult]()
	var progressHandlers = [URL: ProgressBlock]()
	static let sharedInstance = NetworkClient()
	
	override init() {
		let configuration = URLSessionConfiguration.default
		let queue = OperationQueue()
		queue.qualityOfService = .userInitiated
		urlSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
		super.init()
		let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.altutraining.FlickrFeed")
		backgroundSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
	}
	
	// MARK: Service methods
	
	func getURL(_ url:URL, completion:@escaping NetworkResult) {
		let request = URLRequest(url: url)
		let task = urlSession.dataTask(with: request) { [unowned self] (data, response, error) in
			guard let data = data else {
				OperationQueue.main.addOperation {
					completion(nil, error)
				}
				return
			}
			self.parseJSON(data, completion: completion)
		}
		task.resume()
	}
	
	func getImage(_ url:URL, completion:ImageResult) {
		// TODO: Implement
	}
	
	func getImageInBackground(_ url:URL, downloadProgressBlock:ProgressBlock?, completion:ImageResult?) -> URLSessionDownloadTask {
		
		completionHandlers[url] = completion
		progressHandlers[url] = downloadProgressBlock
		let request = URLRequest(url: url)
		let task = backgroundSession.downloadTask(with: request)
		task.resume()
		return task
	}
	
	// MARK: JSON Helpers
	func parseJSON(_ data: Data, completion: @escaping NetworkResult) {
		do {
			let fixedData = fixedJSONData(data)
			let parseResults = try JSONSerialization.jsonObject(with: fixedData, options: [])
			if let dictionary = parseResults as? Dictionary<AnyHashable, Any> {
				OperationQueue.main.addOperation {
					completion(dictionary, nil)
				}
			} else if let array = parseResults as? [Dictionary<AnyHashable, Any>] {
				OperationQueue.main.addOperation {
					completion(array, nil)
				}
			}
		} catch let parseError {
			OperationQueue.main.addOperation {
				completion(nil, parseError)
			}
		}
	}
	
	func fixedJSONData(_ data: Data) -> Data {
		guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else { return data }
		let fixedString = jsonString.replacingOccurrences(of: "\\'", with: "'")
		if let fixedData = fixedString.data(using: String.Encoding.utf8) {
			return fixedData
		} else {
			return data
		}
	}
	
	func completProgressForURL(_ url: URL) {
		if let progress = progressHandlers[url] {
			progressHandlers[url] = nil
			OperationQueue.main.addOperation {
				progress(1)
			}
		}
	}
}

extension NetworkClient:URLSessionDelegate, URLSessionDownloadDelegate {
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error,
			let url = task.originalRequest?.url,
			let completion = completionHandlers[url] {
			completProgressForURL(url)
			completionHandlers[url] = nil
			OperationQueue.main.addOperation {
				completion(url, nil, error)
			}
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		if let url = downloadTask.originalRequest?.url,
			let progress = progressHandlers[url] {
			let percentDone = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
			OperationQueue.main.addOperation {
				progress(percentDone)
			}
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		if let data = try? Data(contentsOf: location),
			let image = UIImage(data: data) {
			
			if let url = downloadTask.originalRequest?.url,
				let completion = completionHandlers[url] {
				completProgressForURL(url)
				completionHandlers[url] = nil
				OperationQueue.main.addOperation {
					completion(url, image, nil)
				}
			}
		} else {
			if let url = downloadTask.originalRequest?.url,
				let completion = completionHandlers[url] {
				completProgressForURL(url)
				completionHandlers[url] = nil
				OperationQueue.main.addOperation {
					completion(url, nil, NetworkClientError.imageData)
				}
			}
		}
	}
}







