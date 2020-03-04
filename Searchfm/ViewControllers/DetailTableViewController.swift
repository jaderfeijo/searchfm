//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import UIKit
import SafariServices

class DetailTableViewController: UITableViewController {
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleTitleLabel: UILabel!
	@IBOutlet var subtitleValueLabel: UILabel!
	
	/// The view model instance for this view controller.
	///
	/// This value must be set before the view for
	/// this view controller is loaded.
	var viewModel: DetailViewModel! = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.view = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.willDisplay()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 && indexPath.row == 0 {
			viewModel.selectOpenInLastFM()
		}
	}
}

extension DetailTableViewController: DetailView {
	func updateView() {
		#warning("TODO: Change to actual image")
		imageView.image = UIImage(named: "AppIcon")
		titleLabel.text = viewModel.item.title
		subtitleTitleLabel.text = viewModel.item.itemType.displayName
		subtitleValueLabel.text = viewModel.item.subtitle
	}
	
	func openURL(_ url: URL) {
		let browserViewController = SFSafariViewController(url: url)
		self.present(browserViewController, animated: true, completion: nil)
	}
}

extension Lastfm.SearchType {
	var displayName: String {
		switch self {
		case .album:
			return "Album"
		case .artist:
			return "Artist"
		case .track:
			return "Track"
		}
	}
}
