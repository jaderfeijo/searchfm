//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UITableViewController {
	
	@IBOutlet var searchBar: UISearchBar!
	
	let viewModel: SearchViewModel
	
	init(viewModel: SearchViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		viewModel = SearchViewModel()
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.view = self
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.searchResults.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemCell") else {
			fatalError("Unable to create cell with identifier: 'SearchItemCell'")
		}
		
		guard let item = viewModel.itemAt(path: indexPath) else {
			fatalError("Failed to retrieve search result item for index path: \(indexPath)")
		}
		
		cell.textLabel!.text = item.title
		cell.detailTextLabel!.text = item.subtitle
		cell.imageView!.image = UIImage(named: "AppIcon")!
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		fatalError("Not yet implemented")
	}
}

extension SearchViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.search(for: searchText, type: selectedSearchType)
	}
	
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchText = searchBar.searchTextField.text else {
			return
		}
		viewModel.search(for: searchText, type: selectedSearchType)
	}
}

extension SearchViewController: SearchView {
	func updateView() {
		tableView.reloadData()
	}
	
	func displayError(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	func navigate(to: SearchViewModel.NavigationDestination) {
		fatalError("Not yet implemented")
	}
}

extension SearchViewController {
	var selectedSearchType: Lastfm.SearchType {
		switch searchBar.selectedScopeButtonIndex {
		case 0:
			return .album
		case 1:
			return .artist
		case 2:
			return .track
		default:
			fatalError("Unknown search type index selected: '\(searchBar.selectedScopeButtonIndex)'")
		}
	}
}
