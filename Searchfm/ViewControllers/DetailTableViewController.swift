//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
	
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
	}
}

extension DetailTableViewController: DetailView {
	func updateView() {
		fatalError("Not yet implemented")
	}
	
	func openURL(_ url: URL) {
		fatalError("Not yet implemented")
	}
}
