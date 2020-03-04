//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import HTTPStatusCodes

extension Lastfm {
	class API {
		
		static let shared: API = API(
			// this probably wouldn't be hard-coded in a real app.
			key: "6253b30ce6788ec243566d13f2be3297",
			dataProvider: HTTPDataProvider()
		)
		
		let key: String
		let dataProvider: DataProvider
		let jsonDecoder: JSONDecoder
		
		init(key: String, dataProvider: DataProvider, jsonDecoder: JSONDecoder = JSONDecoder()) {
			self.key = key
			self.dataProvider = dataProvider
			self.jsonDecoder = jsonDecoder
		}
	}
}

extension Lastfm.API {
	enum Error: Swift.Error {
		case serviceUnreachable
		case serviceError(HTTPStatusCode)
		case decodingError(DecodingError)
		case invalidServerResponse
		case unknown(Swift.Error?)
	}
	
	typealias Response<T> = (Result<T, Error>) -> Void
}

// MARK: - Album Search -

extension Lastfm.API {
	func search<T: Decodable>(type: T.Type, terms: String, page: Int = 1, callback: @escaping Response<Lastfm.SearchResults<T>>) throws -> Cancellable {
		let searchType = try Lastfm.SearchType(from: T.self)
		let baseURL = URL(string: "http://ws.audioscrobbler.com/2.0/")!
		var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
		
		components.queryItems = [
			URLQueryItem(name: "method", value: "\(searchType.rawValue).search"),
			URLQueryItem(name: "\(searchType.rawValue)", value: terms),
			URLQueryItem(name: "api_key", value: key),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "page", value: "\(page)")
		]
		
		let request = Request(
			method: .get,
			url: components.url!,
			headers: nil
		)
		
		let task = dataProvider.performRequest(request) { result in
			switch result {
			case .success(let response):
				guard let body = response.data else {
					callback(.failure(.invalidServerResponse))
					return
				}
				do {
					let searchResults = try self.jsonDecoder.decode(
						Lastfm.SearchResults<T>.self,
						from: body
					)
					callback(.success(searchResults))
				} catch let error as DecodingError {
					callback(.failure(.decodingError(error)))
				} catch let error {
					callback(.failure(.unknown(error)))
				}
			case .failure(.serviceUnreachable):
				callback(.failure(.serviceUnreachable))
			case .failure(.serviceError(let statusCode)):
				callback(.failure(.serviceError(statusCode)))
			case .failure(let error):
				callback(.failure(.unknown(error)))
			}
		}
		
		return task
	}
}
