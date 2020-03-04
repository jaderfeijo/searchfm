//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import UIKit
import HTTPStatusCodes

/// Loads an image asynchronouly from a remote URL and coordinates
/// thread-safe access to the image resource across multiple
/// requesters.
class AsyncImageLoader {
	
	typealias ImageLoadResult = (Result<UIImage, Error>) -> Void
	
	let url: URL
	let session: URLSession
	
	private(set)
	var image: UIImage? = nil
	
	private var task: URLSessionTask? = nil
	private var callbacks: [ImageLoadResult] = []
	
	init(url: URL, session: URLSession = .shared) {
		self.url = url
		self.session = session
	}
	
	func loadImageAsync(_ callback: @escaping ImageLoadResult) {
		DispatchQueue.main.async {
			if let image = self.image {
				callback(.success(image))
				return
			}
			
			self.callbacks.append(callback)
			
			guard self.task == nil else {
				return
			}
			
			let task = self.session.dataTask(with: self.url) { data, response, error in
				DispatchQueue.main.async {
					if error != nil {
						self.triggerCallbacks(.failure(.resourceUnreachable))
						return
					}
					
					if let httpResponse = response as? HTTPURLResponse {
						if let statusCode = HTTPStatusCode(HTTPResponse: httpResponse) {
							if statusCode.isSuccess {
								if let data = data {
									if let image = UIImage(data: data) {
										self.image = image
										self.triggerCallbacks(.success(image))
										return
									} else {
										self.triggerCallbacks(.failure(.invalidResponse))
										return
									}
								} else {
									self.triggerCallbacks(.failure(.invalidResponse))
									return
								}
							} else {
								self.triggerCallbacks(.failure(.serviceError(statusCode)))
								return
							}
						} else {
							self.triggerCallbacks(.failure(.invalidResponse))
							return
						}
					}
				}
			}
			self.task = task
			task.resume()
		}
	}
	
	private func triggerCallbacks(_ result: Result<UIImage, Error>) {
		DispatchQueue.main.async {
			for callback in self.callbacks {
				callback(result)
			}
			self.callbacks = []
		}
	}
}

extension AsyncImageLoader {
	enum Error: Swift.Error {
		case resourceUnreachable
		case resourceNotFound
		case serviceError(HTTPStatusCode)
		case invalidResponse
	}
}
