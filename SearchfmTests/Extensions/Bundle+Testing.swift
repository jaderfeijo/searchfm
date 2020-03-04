//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension Bundle {
	/// Returns the current test bundle instance.
	static var test: Bundle {
		return Bundle(for: TestClass.self)
	}
}

/// This class is used as a locator to find the test `Bundle`.
private class TestClass {}
