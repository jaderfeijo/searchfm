//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class TrackTests: XCTestCase {
	
	var trackJson: Data!
	var trackJsonNoImage: Data!
	var jsonDecoder: JSONDecoder!
	
	override func setUp() {
		super.setUp()
		
		// The two bits of JSON below were actually extracted from a real
		// response from the Lastfm API, including the 'FIXME' value for
		// the 'streamable' field.
		
		trackJson = """
		{
			"name": "Billie Jean",
			"artist": "Michael Jackson",
			"url": "https://www.last.fm/music/Michael+Jackson/_/Billie+Jean",
			"streamable": "FIXME",
			"listeners": "1275445",
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
				}
			],
			"mbid": "f980fc14-e29b-481d-ad3a-5ed9b4ab6340"
		}
		""".data(using: .utf8)
		trackJsonNoImage = """
		{
			"name": "Billie Jean",
			"artist": "Michael Jackson",
			"url": "https://www.last.fm/music/Michael+Jackson/_/Billie+Jean",
			"streamable": "FIXME",
			"listeners": "1275445",
			"mbid": "f980fc14-e29b-481d-ad3a-5ed9b4ab6340"
		}
		""".data(using: .utf8)
		jsonDecoder = JSONDecoder()
	}
	
	override func tearDown() {
		trackJson = nil
		trackJsonNoImage = nil
		jsonDecoder = nil
		
		super.tearDown()
	}
	
	func testTrackParsesCorrectlyFromJSON() {
		let track = try! jsonDecoder.decode(
			Lastfm.Track.self,
			from: trackJson
		)
		XCTAssertEqual(track.name, "Billie Jean")
		XCTAssertEqual(track.artist, "Michael Jackson")
		XCTAssertEqual(track.url, "https://www.last.fm/music/Michael+Jackson/_/Billie+Jean")
		XCTAssertEqual(track.streamable, false)
		XCTAssertEqual(track.listeners, 1275445)
		XCTAssertEqual(track.image.count, 4)
		XCTAssertEqual(track.mbid, "f980fc14-e29b-481d-ad3a-5ed9b4ab6340")
	}
	
	func testTrackParsesCorrectlyFromJSONWithNoImage() {
		let track = try! jsonDecoder.decode(
			Lastfm.Track.self,
			from: trackJsonNoImage
		)
		XCTAssertEqual(track.name, "Billie Jean")
		XCTAssertEqual(track.artist, "Michael Jackson")
		XCTAssertEqual(track.url, "https://www.last.fm/music/Michael+Jackson/_/Billie+Jean")
		XCTAssertEqual(track.streamable, false)
		XCTAssertEqual(track.listeners, 1275445)
		XCTAssertEqual(track.image.count, 0)
		XCTAssertEqual(track.mbid, "f980fc14-e29b-481d-ad3a-5ed9b4ab6340")
	}
}
