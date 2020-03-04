//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class ArtistTests: XCTestCase {
	
	var artistJson: Data!
	var artistJsonNoImage: Data!
	var jsonDecoder: JSONDecoder!
	
	override func setUp() {
		super.setUp()
		
		artistJson = """
		{
			"name": "Miguel",
			"listeners": "858809",
			"mbid": "f5c1f728-4bf0-48d6-aa2b-1d2e36e2cd56",
			"url": "https://www.last.fm/music/Miguel",
			"streamable": "0",
			"image": [
				{
					"#text": "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png",
					"size": "small"
				},
				{
					"#text": "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png",
					"size": "medium"
				},
				{
					"#text": "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png",
					"size": "large"
				},
				{
					"#text": "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
					"size": "extralarge"
				},
				{
					"#text": "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
					"size": "mega"
				}
			]
		}
		""".data(using: .utf8)
		artistJsonNoImage = """
		{
			"name": "Miguel",
			"listeners": "858809",
			"mbid": "f5c1f728-4bf0-48d6-aa2b-1d2e36e2cd56",
			"url": "https://www.last.fm/music/Miguel",
			"streamable": "0"
		}
		""".data(using: .utf8)
		jsonDecoder = JSONDecoder()
	}
	
	override func tearDown() {
		artistJson = nil
		artistJsonNoImage = nil
		jsonDecoder = nil
		
		super.tearDown()
	}
	
	func testArtistParsesCorrectlyFromJSON() {
		let artist = try! jsonDecoder.decode(
			Lastfm.Artist.self,
			from: artistJson
		)
		XCTAssertEqual(artist.name, "Miguel")
		XCTAssertEqual(artist.listeners, 858809)
		XCTAssertEqual(artist.url, "https://www.last.fm/music/Miguel")
		XCTAssertEqual(artist.image.count, 5)
		XCTAssertEqual(artist.streamable, false)
		XCTAssertEqual(artist.mbid, "f5c1f728-4bf0-48d6-aa2b-1d2e36e2cd56")
	}
	
	func testAlbumParsesCorrectlyFromJSONWithNoImage() {
		let artist = try! jsonDecoder.decode(
			Lastfm.Artist.self,
			from: artistJsonNoImage
		)
		XCTAssertEqual(artist.name, "Miguel")
		XCTAssertEqual(artist.listeners, 858809)
		XCTAssertEqual(artist.url, "https://www.last.fm/music/Miguel")
		XCTAssertEqual(artist.image.count, 0)
		XCTAssertEqual(artist.streamable, false)
		XCTAssertEqual(artist.mbid, "f5c1f728-4bf0-48d6-aa2b-1d2e36e2cd56")
	}
}
