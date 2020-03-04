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
		XCTAssertEqual(try! Lastfm.SearchType(from: Lastfm.Album.self), .album)
		XCTAssertEqual(try! Lastfm.SearchType(from: Lastfm.Artist.self), .artist)
		XCTAssertEqual(try! Lastfm.SearchType(from: Lastfm.Track.self), .track)
	}
	
	func testInitFromModelTypeFailsWhenModelIsNotSupported() {
		do {
			let _ = try Lastfm.SearchType(from: UnsupportedModel.self)
			XCTFail("Expected an exception to be thrown")
		} catch let error {
			switch error {
			case Lastfm.SearchType.Error.unknownModel(let type):
				XCTAssert(type == UnsupportedModel.self)
			default:
				XCTFail("Unexpected error: '\(error)'")
			}
		}
	}
}

extension SearchTypeTests {
	struct UnsupportedModel: Decodable {}
}
