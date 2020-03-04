//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import HTTPStatusCodes

extension Lastfm {
	class API {
		
		let dataProvider: DataProvider
		
		init(dataProvider: DataProvider) {
			self.dataProvider = dataProvider
		}
	}
}

extension Lastfm.API {
	enum Error: Swift.Error {
		case serviceUnreachable
		case serviceError(HTTPStatusCode)
		case unknown
	}
	
	typealias Response<T> = (Result<T, Error>) -> Void
}

// MARK: - Album Search -

extension Lastfm.API {
	func search<T: Decodable>(_ terms: String, page: Int = 1, callback: Response<[Lastfm.SearchResults<T>]>) {
		fatalError("Not yet implemented")
	}
}
