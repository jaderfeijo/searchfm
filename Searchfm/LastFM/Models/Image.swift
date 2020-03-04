//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	struct Image {
		let url: String
		let size: Size
	}
}

extension Lastfm.Image {
	enum Size: String, Decodable {
		case small = "small"
		case medium = "medium"
		case large = "large"
		case extraLarge = "extralarge"
		case mega = "mega"
	}
}


extension Lastfm.Image: Decodable {
	enum CodingKeys: String, CodingKey {
		case url = "#text"
		case size = "size"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			url: try container.decode(String.self, forKey: .url),
			size: try container.decode(Lastfm.Image.Size.self, forKey: .size)
		)
	}
}
