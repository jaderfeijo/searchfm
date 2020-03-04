//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	
	/// An enum defining the searchable entity types.
	enum SearchType: String {
		case album = "album"
		case artist = "artist"
		case track = "track"
	}
}

extension Lastfm.SearchType {
	
	enum Error: Swift.Error {
		case unknownModel(Any.Type)
	}
	
	/// Maps a model type to a `SearchType`.
	/// 
	/// This method throws am `Error.unknownModel` if
	/// the specified `modelType` is not known or
	/// supported.
	/// 
	/// - Parameter modelType: The model type to be mapped.
	init<T: Decodable>(from modelType: T.Type) throws {
		if modelType == Lastfm.Album.self {
			self = .album
		} else if modelType == Lastfm.Artist.self {
			self = .artist
		} else if modelType == Lastfm.Track.self {
			self = .track
		} else {
			throw Error.unknownModel(modelType)
		}
	}
}
