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
	
	var shouldDisplayLoadingIndicator: Bool {
		return searchResults.count > 0
	}
	
	private(set)
	var searchResults: [SearchItem] = [] {
		didSet {
			DispatchQueue.main.async { [weak self] in
				self?.view.updateView()
			}
		}
	}
	
	private var cachedResults: [Decodable] = []
	private var currentTask: Cancellable? = nil
	private var searchTerms: String? = nil
	private var searchType: Lastfm.SearchType? = nil
	private var currentPage: Int = 1
	
	func search(for terms: String, type: Lastfm.SearchType) {
		cachedResults = []
		searchResults = []
		
		currentTask?.cancel()
		
		guard !terms.isEmpty else {
			searchTerms = nil
			searchType = nil
			currentPage = 1
			return
		}
		
		searchTerms = terms
		searchType = type
		currentPage = 1
		
		do {
			switch type {
			case .album:
				try searchAlbum()
			case .artist:
				try searchArtist()
			case .track:
				try searchTrack()
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
	
	func loadMoreResults() {
		guard searchTerms != nil, let type = searchType else {
			return
		}
		
		currentTask?.cancel()
		
		currentPage += 1
		
		do {
			switch type {
			case .album:
				try searchAlbum()
			case .artist:
				try searchArtist()
			case .track:
				try searchTrack()
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
		
		let cachedItem = cachedResults[index]
		
		if let album =  cachedItem as? Lastfm.Album {
			return DetailViewModel.Item(
				title: album.name,
				subtitle: album.artist,
				url: URL(string: album.url)!,
				itemType: .album,
				imageLoader: album.imageLoader(forImageSize: .mega)
			)
		}
		
		if let artist = cachedItem as? Lastfm.Artist {
			return DetailViewModel.Item(
				title: artist.name,
				subtitle: artist.name,
				url: URL(string: artist.url)!,
				itemType: .artist,
				imageLoader: artist.imageLoader(forImageSize: .mega)
			)
		}
		
		if let track = cachedItem as? Lastfm.Track {
			return DetailViewModel.Item(
				title: track.name,
				subtitle: track.artist,
				url: URL(string: track.url)!,
				itemType: .track,
				imageLoader: track.imageLoader(forImageSize: .mega)
			)
		}
		
		fatalError("Unknown entity type: '\(cachedItem)'")
	}
	
	// MARK: - Private -
	
	private func handleSearchError(_ error: Lastfm.API.Error) {
		DispatchQueue.main.async { [weak self] in
			// In a real app, it would be better to display personalised
			// error messages for different error types, (e.g.: if the server
			// is not available it could be that the user's internet connection
			// is not active, so it would be nice to notify the user of that).
			self?.view.displayError(
				title: "Search Error",
				message: "An error occurred while performing the search: '\(error)'"
			)
		}
	}
	
	private func searchAlbum() throws {
		guard let terms = searchTerms else {
			return
		}
		currentTask = try searchProvider.search(type: Lastfm.Album.self, terms: terms, page: currentPage) { [weak self] result in
			self?.currentTask = nil
			switch result {
			case .success(let results):
				self?.cachedResults += results.results
				self?.searchResults += results.results.map { album in
					SearchItem(
						identifier: album.mbid,
						title: album.name,
						subtitle: album.artist,
						imageLoader: album.imageLoader(forImageSize: .small)
					)
				}
			case .failure(let error):
				self?.handleSearchError(error)
			}
		}
	}
	
	private func searchArtist() throws {
		guard let terms = searchTerms else {
			return
		}
		currentTask = try searchProvider.search(type: Lastfm.Artist.self, terms: terms, page: currentPage) { [weak self] result in
			self?.currentTask = nil
			switch result {
			case .success(let results):
				self?.cachedResults += results.results
				self?.searchResults += results.results.map { artist in
					SearchItem(
						identifier: artist.mbid,
						title: artist.name,
						subtitle: "\(artist.listeners) listeners",
						imageLoader: artist.imageLoader(forImageSize: .small)
					)
				}
			case .failure(let error):
				self?.handleSearchError(error)
			}
		}
	}
	
	private func searchTrack() throws {
		guard let terms = searchTerms else {
			return
		}
		currentTask = try searchProvider.search(type: Lastfm.Track.self, terms: terms, page: currentPage) { [weak self] result in
			self?.currentTask = nil
			switch result {
			case .success(let results):
				self?.cachedResults += results.results
				self?.searchResults += results.results.map { track in
					SearchItem(
						identifier: track.mbid,
						title: track.name,
						subtitle: track.artist,
						imageLoader: track.imageLoader(forImageSize: .small)
					)
				}
			case .failure(let error):
				self?.handleSearchError(error)
			}
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
		let imageLoader: AsyncImageLoader?
	}
}

extension Lastfm.API: PaginatedEntitySearchProvider {}

extension SearchViewModel.SearchItem: Equatable {
	static func == (lhs: SearchViewModel.SearchItem, rhs: SearchViewModel.SearchItem) -> Bool {
		return (
			lhs.identifier == rhs.identifier &&
			lhs.title == rhs.title &&
			lhs.subtitle == rhs.subtitle
		)
	}
}
