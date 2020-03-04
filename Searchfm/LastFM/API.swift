//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

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
		case serviceError
		case unknown
	}
	
	typealias Response<T> = (Result<T, Error>) -> Void
}

// MARK: - Album Search -

extension Lastfm.API {
	
	//func searchAlbum(named albumName: String, callback: Response<[Album]>)
}
