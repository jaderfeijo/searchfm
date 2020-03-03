//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	struct Album {
		let name: String
		let artist: String
		let url: String
		let image: [Image]
		let streamable: Bool
		let mbid: String
	}
}

extension Lastfm.Album: Decodable {
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case artist = "artist"
		case url = "url"
		case image = "image"
		case streamable = "streamable"
		case mbid = "mbid"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let name = try container.decode(String.self, forKey: .name)
		let artist = try container.decode(String.self, forKey: .artist)
		let url = try container.decode(String.self, forKey: .url)
		let image = try container.decodeIfPresent([Image].self, forKey: .image) ?? []
		
		// the code below is necessary because Lastfm provides us with a boolean as an
		// integer inside a string (e.g.: `"0"`). Unfortunately Swift's built in
		// JSONDecoder does not consider this automatically as a `Bool` if we try to
		// parse it directly, so we need to convert it, and throw an appropriate error
		// if the parsing fails.
		let streamableString = try container.decode(String.self, forKey: .streamable)
		guard let streamableInt = Int(streamableString) else {
			throw DecodingError.valueNotFound(
				Bool.self,
				DecodingError.Context(
					codingPath: [CodingKeys.streamable],
					debugDescription: "Failed to parse a Bool from 'streamable' value: '\(streamableString)'."
				)
			)
		}
		let streamable = Bool(truncating: streamableInt as NSNumber)
		
		let mbid = try container.decode(String.self, forKey: .mbid)
		
		self.init(
			name: name,
			artist: artist,
			url: url,
			image: image,
			streamable: streamable,
			mbid: mbid
		)
	}
}
