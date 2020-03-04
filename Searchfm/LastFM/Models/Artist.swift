//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	struct Artist {
		let name: String
		let listeners: Int
		let url: String
		let image: [Image]
		let streamable: Bool
		let mbid: String
	}
}

extension Lastfm.Artist: Decodable {
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case listeners = "listeners"
		case url = "url"
		case image = "image"
		case streamable = "streamable"
		case mbid = "mbid"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let name = try container.decode(String.self, forKey: .name)
		let listeners = try container.decodeStringAsInt(forKey: .listeners) ?? 0
		let url = try container.decode(String.self, forKey: .url)
		let image = try container.decodeIfPresent([Lastfm.Image].self, forKey: .image) ?? []
		let streamable = try container.decodeStringAsBool(forKey: .streamable) ?? false
		let mbid = try container.decode(String.self, forKey: .mbid)
		
		self.init(
			name: name,
			listeners: listeners,
			url: url,
			image: image,
			streamable: streamable,
			mbid: mbid
		)
	}
}
