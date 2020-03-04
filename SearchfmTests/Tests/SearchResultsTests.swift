//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class SearchResultsTests: XCTestCase {
	
	var albumSearchResultsJson: Data!
	var jsonDecoder: JSONDecoder!
	
	override func setUp() {
		super.setUp()
		
		albumSearchResultsJson = try! Data(
			contentsOf: Bundle.test.url(
				forResource: "AlbumSearchResults",
				withExtension: "json"
			)!
		)
		jsonDecoder = JSONDecoder()
	}
	
	override func tearDown() {
		albumSearchResultsJson = nil
		jsonDecoder = nil
		
		super.tearDown()
	}
	
	func testAlbumSearchResultsParsesCorrectly() {
		let albumSearchResults = try! jsonDecoder.decode(
			Lastfm.SearchResults<Lastfm.Album>.self,
			from: albumSearchResultsJson
		)
		
		XCTAssertEqual(albumSearchResults.totalResults, 122380)
		XCTAssertEqual(albumSearchResults.page, 2)
		XCTAssertEqual(albumSearchResults.results.count, 50)
		
		XCTAssertEqual(albumSearchResults.results.first!.name, "Make Me Believe In Hope")
		XCTAssertEqual(albumSearchResults.results.first!.artist, "Bright Light Bright Light")
		XCTAssertEqual(albumSearchResults.results.first!.url, "https://www.last.fm/music/Bright+Light+Bright+Light/Make+Me+Believe+In+Hope")
		XCTAssertEqual(albumSearchResults.results.first!.image.count, 4)
		XCTAssertEqual(albumSearchResults.results.first!.streamable, false)
		XCTAssertEqual(albumSearchResults.results.first!.mbid, "a40e791d-14b2-480f-b5d4-053e27b57134")
	}
}
