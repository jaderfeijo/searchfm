//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

protocol DetailView: class {
	func updateView()
	func openURL(_ url: URL)
}

class DetailViewModel {
	
	let item: Item
	
	// Since having a view is a requirement for the view
	// model to work correctly, we declare it as an implicitly
	// unwrapped value. Failure to hook-up a view to the view
	// model is a programming error which should be caught
	// at development time.
	//
	// Also, we declare the view as a `weak` variable
	// in order to avoid a retain-cycle, since the view
	// owns the view model in this implementation of MVVM.
	weak var view: DetailView! = nil
	
	init(item: Item) {
		self.item = item
	}
}

extension DetailViewModel {
	struct Item {
		let title: String
		let subtitle: String
		let url: URL
	}
}
