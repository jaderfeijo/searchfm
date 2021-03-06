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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		searchBar.becomeFirstResponder()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		switch segue.identifier {
		case "ShowDetail":
			guard let detailViewController = segue.destination as? DetailTableViewController else {
				fatalError("Invalid destination view controller type '\(segue.destination)' for segue '\(String(describing: segue.identifier))'")
			}
			guard let item = sender as? DetailViewModel.Item else {
				fatalError("Invalid item '\(String(describing: sender))'")
			}
			detailViewController.viewModel = DetailViewModel(item: item)
		default:
			fatalError("Unknown segue '\(String(describing: segue.identifier))'")
		}
	}
	
	// MARK: - Table View -
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if viewModel.shouldDisplayLoadingIndicator {
			return 2
		} else {
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return viewModel.searchResults.count
		case 1:
			return 1
		default:
			fatalError("Invalid section index: \(section)")
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemCell") else {
				fatalError("Unable to create cell with identifier: 'SearchItemCell'")
			}
			
			guard let item = viewModel.itemAt(path: indexPath) else {
				fatalError("Failed to retrieve search result item for index path: \(indexPath)")
			}
			
			cell.textLabel!.text = item.title
			cell.detailTextLabel!.text = item.subtitle
			cell.imageView!.image = item.imageLoader?.image ?? UIImage(named: "Placeholder")
			
			return cell
		case 1:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") else {
				fatalError("Unable to create cell with identifier: 'LoadingCell'")
			}
			return cell
		default:
			fatalError("Invalid section index: \(indexPath.section)")
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			let item = viewModel.itemAt(path: indexPath)
			item?.imageLoader?.loadImageAsync { result in
				switch result {
				case .success(let image):
					cell.imageView?.image = image
					cell.setNeedsLayout()
				case .failure(let error):
					print("Error while loading image: \(error)")
				}
			}
		case 1:
			viewModel.loadMoreResults()
		default:
			fatalError("Invalid section index: \(indexPath.section)")
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		searchBar.resignFirstResponder()
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard let item = viewModel.itemAt(path: indexPath) else {
			fatalError("Invalid item index '\(indexPath.row)'")
		}
		
		viewModel.selectItem(item)
	}
}

extension SearchViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.search(for: searchText, type: selectedSearchType)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
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
	
	func navigate(to destination: SearchViewModel.NavigationDestination) {
		switch destination {
		case .detail(let item):
			performSegue(withIdentifier: "ShowDetail", sender: item)
		}
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
