//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import XCTest
@testable import Searchfm

class ImageTests: XCTestCase {
	
	var smallImageJson: Data!
	var mediumImageJson: Data!
	var largeImageJson: Data!
	var extraLargeImageJson: Data!
	var jsonDecoder: JSONDecoder!
	
	override func setUp() {
		super.setUp()
		
		smallImageJson = """
		{
			"#text": "https://lastfm.freetls.fastly.net/i/u/34s/bca3b80481394e25b03f4fc77c338897.png",
			"size": "small"
		}
		""".data(using: .utf8)!
		mediumImageJson = """
		{
			"#text": "https://lastfm.freetls.fastly.net/i/u/64s/bca3b80481394e25b03f4fc77c338897.png",
			"size": "medium"
		}
		""".data(using: .utf8)!
		largeImageJson = """
		{
			"#text": "https://lastfm.freetls.fastly.net/i/u/174s/bca3b80481394e25b03f4fc77c338897.png",
			"size": "large"
		}
		""".data(using: .utf8)
		extraLargeImageJson = """
		{
			"#text": "https://lastfm.freetls.fastly.net/i/u/300x300/bca3b80481394e25b03f4fc77c338897.png",
			"size": "extralarge"
		}
		""".data(using: .utf8)
		jsonDecoder = JSONDecoder()
	}
	
	override func tearDown() {
		smallImageJson = nil
		mediumImageJson = nil
		largeImageJson = nil
		extraLargeImageJson = nil
		jsonDecoder = nil
		
		super.tearDown()
	}
	
	func testImageParsesCorrectlyFromJSON() {
		let smallImage = try! jsonDecoder.decode(
			Lastfm.Album.Image.self,
			from: smallImageJson
		)
		XCTAssertEqual(
			smallImage.url,
			"https://lastfm.freetls.fastly.net/i/u/34s/bca3b80481394e25b03f4fc77c338897.png"
		)
		XCTAssertEqual(
			smallImage.size,
			.small
		)
		
		let mediumImage = try! jsonDecoder.decode(
			Lastfm.Album.Image.self,
			from: mediumImageJson
		)
		XCTAssertEqual(
			mediumImage.url,
			"https://lastfm.freetls.fastly.net/i/u/64s/bca3b80481394e25b03f4fc77c338897.png"
		)
		XCTAssertEqual(
			mediumImage.size,
			.medium
		)
		
		let largeImage = try! jsonDecoder.decode(
			Lastfm.Album.Image.self,
			from: largeImageJson
		)
		XCTAssertEqual(
			largeImage.url,
			"https://lastfm.freetls.fastly.net/i/u/174s/bca3b80481394e25b03f4fc77c338897.png"
		)
		XCTAssertEqual(
			largeImage.size,
			.large
		)
		
		let extraLargeImage = try! jsonDecoder.decode(
			Lastfm.Album.Image.self,
			from: extraLargeImageJson
		)
		XCTAssertEqual(
			extraLargeImage.url,
			"https://lastfm.freetls.fastly.net/i/u/300x300/bca3b80481394e25b03f4fc77c338897.png"
		)
		XCTAssertEqual(
			extraLargeImage.size,
			.extraLarge
		)
	}
}
