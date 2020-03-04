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
/// it as a generic type in order to reduce code repetition.
///
/// From what I could see, the JSON is structured in this way due to
/// conformance to the OpenSearch API standard. An alternative would've
/// been to use a library which already conforms to this standard and
/// provides the client functionality in Swift, however in the limited
/// time available for this assignment I could not find a library that
/// seemed reliable enough to base this implementation on, hence the
/// custom approach below.

extension Lastfm.SearchResults: Decodable {
	enum CodingKeys<T: Decodable> {
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
			totalResults: try resultsContainer.decodeStringAsInt(forKey: .totalResults) ?? 0,
			page: try openSearchQueryContainer.decodeStringAsInt(forKey: .page) ?? 0,
			results: try matchesContainer.decode([T].self, forKey: .item)
		)
	}
}

extension Lastfm.SearchResults.CodingKeys: CodingKey {
	var searchType: Lastfm.SearchType {
		// Failure to map a model type (`T`) to a `SearchType`
		// would be considered a programming error and should
		// halt the execution of the program immediately,
		// hence the force unwrap.
		return try! Lastfm.SearchType(from: T.self)
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
