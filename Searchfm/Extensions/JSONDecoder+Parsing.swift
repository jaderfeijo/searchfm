//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
	
	/// Decodes an `Int` that is represented as a `String` inside
	/// the keyed container (e.g.: `"0"`, `"123"`).
	/// 
	/// If an `Int` cannot be parsed from the `String` this method
	/// returns `nil`.
	///
	/// - Parameter key: The key for which to decode the `Int`.
	func decodeStringAsInt(forKey key: K) throws -> Int? {
		let stringValue = try decode(String.self, forKey: key)
		return Int(stringValue)
	}
	
	/// Decodes a `Bool` that is represented as a `String` inside
	/// the keyed container (e.g.: `"0"`, `"1"`)
	/// 
	/// This method first attempts to extract an `Int` from the
	/// `String`, if an `Int` cannot be parsed, this method
	/// returns `nil`.
	/// 
	/// - Parameter key: The key for which to decode the `Bool`.
	func decodeStringAsBool(forKey key: K) throws -> Bool? {
		guard let intValue = try decodeStringAsInt(forKey: key) else {
			return nil
		}
		return Bool(truncating: intValue as NSNumber)
	}
}
