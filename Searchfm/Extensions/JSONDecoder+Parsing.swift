//
// Copyright © 2020 Jader Feijo. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
	
	/// Decodes an `Int` that is represented as a `String` inside
	/// the keyed container (e.g.: `"0"`, `"123"`).
	/// 
	/// If an `Int` cannot be parsed from the `String` this method
	/// throws a `DecodingError.typeMismatch`.
	///
	/// - Parameter key: The key for which to decode the `Int`.
	func decodeStringAsInt(forKey key: K) throws -> Int {
		let stringValue = try decode(String.self, forKey: key)
		
		guard let intValue = Int(stringValue) else {
			throw DecodingError.typeMismatch(
				Int.self,
				DecodingError.Context(
					codingPath: [key],
					debugDescription: "Value '\(stringValue)' is not a valid integer"
				)
			)
		}
		
		return intValue
	}
	
	/// Decodes a `Bool` that is represented as a `String` inside
	/// the keyed container (e.g.: `"0"`, `"1"`)
	/// 
	/// This method first attempts to extract an `Int` from the
	/// `String`, if an `Int` cannot be parsed, this method throws
	/// a `DecodingError.typeMismatch`.
	/// 
	/// - Parameter key: The key for which to decode the `Bool`.
	func decodeStringAsBool(forKey key: K) throws -> Bool {
		let intValue = try decodeStringAsInt(forKey: key)
		return Bool(truncating: intValue as NSNumber)
	}
}
