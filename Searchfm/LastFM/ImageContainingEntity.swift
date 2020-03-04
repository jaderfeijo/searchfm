//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

protocol ImageContainingEntity {
	var image: [Lastfm.Image] { get }
}

extension ImageContainingEntity {
	func imageOfSize(_ size: Lastfm.Image.Size) -> Lastfm.Image? {
		return image.first { $0.size == size }
	}
	
	func imageLoader(forImageSize size: Lastfm.Image.Size) -> AsyncImageLoader? {
		guard let image = imageOfSize(size) else {
			return nil
		}
		guard let imageURL = URL(string: image.url) else {
			return nil
		}
		return AsyncImageLoader(url: imageURL)
	}
}
