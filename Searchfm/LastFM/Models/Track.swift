//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	struct Track {
		let name: String
		let artist: String
		let url: String
		let streamable: Bool
		let listeners: Int
		let image: [Image]
		let mbid: String
	}
}

extension Lastfm.Track: Decodable {
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case artist = "artist"
		case url = "url"
		case streamable = "streamable"
		case listeners = "listeners"
		case image = "image"
		case mbid = "mbid"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let name = try container.decode(String.self, forKey: .name)
		let artist = try container.decode(String.self, forKey: .artist)
		let url = try container.decode(String.self, forKey: .url)
		let streamable = try container.decodeStringAsBool(forKey: .streamable) ?? false
		let listeners = try container.decodeStringAsInt(forKey: .listeners) ?? 0
		let image = try container.decodeIfPresent([Lastfm.Image].self, forKey: .image) ?? []
		let mbid = try container.decode(String.self, forKey: .mbid)
		
		self.init(
			name: name,
			artist: artist,
			url: url,
			streamable: streamable,
			listeners: listeners,
			image: image,
			mbid: mbid
		)
	}
}
