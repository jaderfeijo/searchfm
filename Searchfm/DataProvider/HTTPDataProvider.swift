//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import HTTPStatusCodes

class HTTPDataProvider: DataProvider {
	
	let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func performRequest(_ request: Request, callback: @escaping (Result<Response, DataProviderError>) -> Void) -> Cancellable {
		let httpRequest = URLRequest.with(request: request)
		
		let task = session.dataTask(with: httpRequest) { body, response, error in
			if let error = error {
				let cocoaError = error as NSError
				if !(cocoaError.domain == NSURLErrorDomain && cocoaError.code == -999) { // task was cancelled
					callback(.failure(.serviceUnreachable))
				}
			} else if let httpResponse = response as? HTTPURLResponse {
				if let statusCode = HTTPStatusCode(HTTPResponse: httpResponse) {
					if statusCode.isSuccess {
						callback(
							.success(
								Response(
									response: statusCode,
									data: body
							)
							)
						)
					} else {
						callback(.failure(.serviceError(statusCode)))
					}
				} else {
					callback(.failure(.unknown(nil)))
				}
			}
		}
		task.resume()
		return task
	}
}

extension URLRequest {
	static func with(request: Request) -> URLRequest {
		let urlRequest = NSMutableURLRequest(url: request.url)
		urlRequest.httpMethod = request.method.rawValue
		urlRequest.allHTTPHeaderFields = request.headers
		return urlRequest as URLRequest
	}
}

extension URLSessionTask: Cancellable {}
