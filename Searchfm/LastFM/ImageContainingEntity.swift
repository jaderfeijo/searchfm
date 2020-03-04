//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

protocol ImageContainingEntity {
	var image: [Lastfm.Image] { get }
}

extension ImageContainingEntity {
	func imageOfSize(_ size: Lastfm.Image.Size) -> Lastfm.Image? {
		var nextSize: Lastfm.Image.Size? = size
		var largestImage: Lastfm.Image? = nil
		
		repeat {
			if let size = nextSize {
				largestImage = image.first(where: { $0.size == size})
				nextSize = size.oneSmaller
			}
		} while largestImage == nil
		
		return largestImage
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
