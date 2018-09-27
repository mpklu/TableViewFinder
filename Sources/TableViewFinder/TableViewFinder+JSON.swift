//
//  TableViewFinder+JSON.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/27/18.
//

import Foundation
extension TableViewFinder {
	func toJsonString() -> String? {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		if let data = try? encoder.encode(tableInfo),
			let json = String(data: data, encoding: .ascii) {
			return json
		}
		return nil
	}
}
