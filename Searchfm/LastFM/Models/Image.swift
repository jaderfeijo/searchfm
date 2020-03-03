//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm.Album {
	struct Image {
		let url: String
		let size: Size
	}
}

extension Lastfm.Album.Image: Decodable {
	enum CodingKeys: String, CodingKey {
		case url = "#text"
		case size = "size"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			url: try container.decode(String.self, forKey: .url),
			size: try container.decode(Lastfm.Album.Image.Size.self, forKey: .size)
		)
	}
}
