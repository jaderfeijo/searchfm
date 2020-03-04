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
		let streamable = try container.decodeStringAsBool(forKey: .streamable)
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
