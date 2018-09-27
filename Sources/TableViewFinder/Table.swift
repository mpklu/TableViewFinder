//
//  Table.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/27/18.
//

import Foundation

class Table: Codable, CustomStringConvertible {
	var id: String = ""
	var xib: URL = URL(fileURLWithPath: "/")
	var outletName: String = ""
	var viewBased: Bool = false
	var description: String {
		return "\(xib.lastPathComponent):(\(outletName) \(viewBased ? "view-based":  "cell-based"))"
	}
}

