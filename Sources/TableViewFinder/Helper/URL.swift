//
//  URL.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/28/18.
//

import Foundation

extension URL {
	func lastPathComponents(_ num: Int) -> String {
		var components = self.pathComponents
		var path = ""
		var counter = num
		while counter > 0,
			let name = components.popLast() {
				path = name + "/" + path
				counter -= 1
		}
		return path
	}
}
