//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import Dispatch

protocol SearchView: class {
	func updateView()
	func displayError(title: String, message: String)
	func navigate(to destination: SearchViewModel.NavigationDestination)
}

protocol PaginatedEntitySearchProvider {
	func search<T: Decodable>(type: T.Type, terms: String, page: Int, callback: @escaping Lastfm.API.Response<Lastfm.SearchResults<T>>) throws -> Cancellable
}

class SearchViewModel {
	
	let searchProvider: PaginatedEntitySearchProvider
	
	init(searchProvider: PaginatedEntitySearchProvider = Lastfm.API.shared) {
		self.searchProvider = searchProvider
	}
	
	// Since having a view is a requirement for the view
	// model to work correctly, we declare it as an implicitly
	// unwrapped value. Failure to hook-up a view to the view
	// model is a programming error which should be caught
	// at development time.
	//
	// Also, we declare the view as a `weak` variable
	// in order to avoid a retain-cycle, since the view
	// owns the view model in this implementation of MVVM.
	weak var view: SearchView! = nil
	
	private(set)
	var searchResults: [SearchItem] = [] {
		didSet {
			DispatchQueue.main.async { [weak self] in
				self?.view.updateView()
			}
		}
	}
	
	private var cachedResults: [Decodable]? = nil
	private var previousTask: Cancellable? = nil
	
	func search(for terms: String, type: Lastfm.SearchType) {
		guard !terms.isEmpty else {
			searchResults = []
			return
		}
		
		previousTask?.cancel()
		
		do {
			#warning("TODO: Implement pagination")
			switch type {
			case .album:
				previousTask = try searchProvider.search(type: Lastfm.Album.self, terms: terms, page: 1) { [weak self] result in
					self?.previousTask = nil
					switch result {
					case .success(let results):
						self?.cachedResults = results.results
						self?.searchResults = results.results.map { album in
							SearchItem(
								identifier: album.mbid,
								title: album.name,
								subtitle: album.artist
							)
						}
					case .failure(let error):
						self?.handleSearchError(error)
					}
				}
			case .artist:
				previousTask = try searchProvider.search(type: Lastfm.Artist.self, terms: terms, page: 1) { [weak self] result in
					self?.previousTask = nil
					switch result {
					case .success(let results):
						self?.cachedResults = results.results
						self?.searchResults = results.results.map { artist in
							SearchItem(
								identifier: artist.mbid,
								title: artist.name,
								subtitle: "\(artist.listeners) listeners"
							)
						}
					case .failure(let error):
						self?.handleSearchError(error)
					}
				}
			case .track:
				previousTask = try searchProvider.search(type: Lastfm.Track.self, terms: terms, page: 1) { [weak self] result in
					self?.previousTask = nil
					switch result {
					case .success(let results):
						self?.cachedResults = results.results
						self?.searchResults = results.results.map { track in
							SearchItem(
								identifier: track.mbid,
								title: track.name,
								subtitle: track.artist
							)
						}
					case .failure(let error):
						self?.handleSearchError(error)
					}
				}
			} 
		} catch let error {
			DispatchQueue.main.async { [weak self] in
				self?.view.displayError(
					title: "Unknown Error",
					message: "An unknown error has occurred: '\(error)'"
				)
			}
		}
	}
	
	func selectItem(_ item: SearchItem) {
		view.navigate(
			to: .detail(
				detailItem(for: item)
			)
		)
	}
	
	func itemAt(path: IndexPath) -> SearchItem? {
		return searchResults[path.row]
	}
	
	func detailItem(for item: SearchItem) -> DetailViewModel.Item {
		guard let index = searchResults.firstIndex(of: item) else {
			fatalError("Item '\(item)' not found")
		}
		
		let cachedItem = cachedResults![index]
		
		#warning("TODO: Move URL parsing to the model level")
		if let album =  cachedItem as? Lastfm.Album {
			return DetailViewModel.Item(
				title: album.name,
				subtitle: album.artist,
				url: URL(string: album.url)!,
				itemType: .album
			)
		}
		
		if let artist = cachedItem as? Lastfm.Artist {
			return DetailViewModel.Item(
				title: artist.name,
				subtitle: "",
				url: URL(string: artist.url)!,
				itemType: .artist
			)
		}
		
		if let track = cachedItem as? Lastfm.Track {
			return DetailViewModel.Item(
				title: track.name,
				subtitle: track.artist,
				url: URL(string: track.url)!,
				itemType: .track
			)
		}
		
		fatalError("Unknown entity type: '\(cachedItem)'")
	}
	
	// MARK: - Private -
	
	func handleSearchError(_ error: Lastfm.API.Error) {
		DispatchQueue.main.async { [weak self] in
			// In a real app, it would be better to display personalised
			// error messages for different error types, (e.g.: if the server
			// is not available it could be the user's internet connection
			// is not active, so it would be nice to notify the user of that).
			self?.view.displayError(
				title: "Search Error",
				message: "An error occurred while performing the search: '\(error)'"
			)
		}
	}
}

extension SearchViewModel {
	enum NavigationDestination {
		case detail(DetailViewModel.Item)
	}
}

extension SearchViewModel {
	struct SearchItem {
		let identifier: String
		let title: String
		let subtitle: String
	}
}

extension Lastfm.API: PaginatedEntitySearchProvider {}

extension SearchViewModel.SearchItem: Equatable {
	static func == (lhs: SearchViewModel.SearchItem, rhs: SearchViewModel.SearchItem) -> Bool {
		return lhs.identifier == rhs.identifier
	}
}
