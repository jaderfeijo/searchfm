//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class SearchTypeTests: XCTestCase {
	
	var album: Lastfm.Album!
	
	override func setUp() {
		super.setUp()
		
		album = Lastfm.Album(
			name: "Test Album",
			artist: "Test Artist",
			url: "test://none",
			image: [],
			streamable: false,
			mbid: "test-mbid"
		)
	}
	
	override func tearDown() {
		album = nil
		
		super.tearDown()
	}
	
	func testInitFromModelTypeSucceeds() {
		XCTFail("Not yet implemented")
	}
	
	func testInitFromModelTypeFailsWhenModelIsNotSupported() {
		XCTFail("Not yet implemented")
	}
}

extension SearchTypeTests {
	struct UnsupportedModel: Decodable {}
}
