//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import HTTPStatusCodes

enum Method: String {
	case get = "GET"
	case head = "HEAD"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
	case trace = "TRACE"
	case options = "OPTIONS"
}

struct Request {
	let method: Method
	let url: URL
	let headers: [String:String]?
}

struct Response {
	let response: HTTPStatusCode
	let data: Data?
}

enum DataProviderError: Swift.Error {
	case serviceUnreachable
	case serviceError(HTTPStatusCode)
	case unknown(Swift.Error?)
}

protocol Cancellable {
	func cancel()
}

protocol DataProvider {
	
	typealias AsyncResponse = (Result<Response, DataProviderError>) -> Void
	
	func performRequest(_ request: Request, callback: @escaping AsyncResponse) -> Cancellable
}
