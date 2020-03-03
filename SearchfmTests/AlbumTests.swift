//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class AlbumTests: XCTestCase {
	
	var albumJson: Data!
	var albumJsonNoImage: Data!
	var jsonDecoder: JSONDecoder!
	
	override func setUp() {
		super.setUp()
		
		albumJson = """
		{
		  "name": "Believe",
		  "artist": "Disturbed",
		  "url": "https://www.last.fm/music/Disturbed/Believe",
		  "image": [],
		  "streamable": "0",
		  "mbid": "c559efc2-f734-41ae-93bd-2d78414e0356"
		}
		""".data(using: .utf8)
		albumJsonNoImage = """
		{
		  "name": "Believe",
		  "artist": "Disturbed",
		  "url": "https://www.last.fm/music/Disturbed/Believe",
		  "streamable": "0",
		  "mbid": "c559efc2-f734-41ae-93bd-2d78414e0356"
		}
		""".data(using: .utf8)
		jsonDecoder = JSONDecoder()
	}
	
	override func tearDown() {
		albumJson = nil
		albumJsonNoImage = nil
		jsonDecoder = nil
		super.tearDown()
	}
	
	func testAlbumParsesCorrectlyFromJSON() {
		let album = try! jsonDecoder.decode(
			Lastfm.Album.self, from: albumJson
		)
		XCTAssertEqual(album.name, "Believe")
		XCTAssertEqual(album.artist, "Disturbed")
		XCTAssertEqual(album.url, "https://www.last.fm/music/Disturbed/Believe")
		XCTAssertEqual(album.image.count, 0)
		XCTAssertEqual(album.streamable, false)
		XCTAssertEqual(album.mbid, "c559efc2-f734-41ae-93bd-2d78414e0356")
	}
	
	func testAlbumParsesCorrectlyFromJSONWithNoImage() {
		let album = try! jsonDecoder.decode(
			Lastfm.Album.self, from: albumJsonNoImage
		)
		XCTAssertEqual(album.name, "Believe")
		XCTAssertEqual(album.artist, "Disturbed")
		XCTAssertEqual(album.url, "https://www.last.fm/music/Disturbed/Believe")
		XCTAssertEqual(album.image.count, 0)
		XCTAssertEqual(album.streamable, false)
		XCTAssertEqual(album.mbid, "c559efc2-f734-41ae-93bd-2d78414e0356")
	}
}
