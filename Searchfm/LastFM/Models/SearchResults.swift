//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Lastfm {
	struct SearchResults<T: Decodable> {
		let totalResults: Int
		let page: Int
		let results: [T]
	}
}

// MARK: - JSON Decoding -

/// Due to the search results JSON having some keys being quite nested
/// and some even having keys that are dynamic based on the entity type
/// that is being searched we have to jump through a few hoops to parse
/// the `SearchResults` model, especially if we want to continue to use
/// it as a generic type in order to reduce repetition.
///
/// From what I could see, the JSON is structured in this way due to
/// conformance to the OpenSearch API standard. An alternative would've
/// been to use a library which already conforms to this standard and
/// provides the client functionality in Swift, however in the limited
/// time available for this assignment I could not find a library that
/// seemed reliable enough to base this implementation on, hence the
/// custom approach below.

extension Lastfm.SearchResults: Decodable {
	enum CodingKeys<T> {
		case page
		case totalResults
		case results
		case openSearchQuery
		case matches
		case item
	}
	
	init(from decoder: Decoder) throws {
		// root
		let rootContainer = try decoder.container(
			keyedBy: CodingKeys<T>.self
		)
		
		// root.results
		let resultsContainer = try rootContainer.nestedContainer(
			keyedBy: CodingKeys<T>.self,
			forKey: .results
		)
		
		// root.results.openSearch:Query
		let openSearchQueryContainer = try resultsContainer.nestedContainer(
			keyedBy: CodingKeys<T>.self,
			forKey: .openSearchQuery
		)
		
		// root.results.<item>match
		let matchesContainer = try resultsContainer.nestedContainer(
			keyedBy: CodingKeys<T>.self,
			forKey: .matches
		)
		
		self.init(
			totalResults: try resultsContainer.decodeStringAsInt(forKey: .totalResults),
			page: try openSearchQueryContainer.decodeStringAsInt(forKey: .page),
			results: try matchesContainer.decode([T].self, forKey: .item)
		)
	}
}

/// In the code below we define an enum, `SearchType`, which
/// describes the different searchable entities that are
/// supported. The actual type of the search is then inferred
/// from the generic type of `SearchResults.CodingKeys` and
/// mapped to the correct enum inside the `searchType` property.
/// Finally, the `rawValue` of `SearchType` is interpolated into
/// the key name for the keys that require it.
///
/// This means that whenever new search types need to be
/// supported, the `SearchType` enum needs to
/// be updated to include the new type, and the `searchType`
/// variable must be updated in order to map the generic type
/// to the appropriate `SearchType` so that key names can be
/// parsed correctly.
///
/// The code responsible for mapping the generic type to
/// a `SearchType` below triggeres a `fatalError` if the
/// mapping fails. This is due to the fact that such a
/// failure would be considered a programming error that
/// needs to be caught at debug time, hence the need to
/// bring this to the attention of the developer.

extension Lastfm {
	enum SearchType: String {
		case album = "album"
	}
}

extension Lastfm.SearchResults.CodingKeys: CodingKey {
	var searchType: Lastfm.SearchType {
		if T.self == Lastfm.Album.self {
			return .album
		} else {
			fatalError("Unknown model type '\(T.self)'")
		}
	}
	
	var stringValue: String {
		switch self {
		case .page:
			return "startPage"
		case .totalResults:
			return "opensearch:totalResults"
		case .results:
			return "results"
		case .openSearchQuery:
			return "opensearch:Query"
		case .matches:
			return "\(searchType.rawValue)matches"
		case .item:
			return searchType.rawValue
		}
	}
}
