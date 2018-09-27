//
//  TableViewFinder+HTML.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/27/18.
//

import Foundation

import Foundation
extension String {
	func enclosedInTag(_ tag: String,
					   attributes: [String: String]? = nil) -> String {
		if let attr = attributes {
			var ret = "<\(tag)"
			for (name, value) in attr {
				ret += " \(name)= \"\(value)\""
			}
			ret += ">\(self)</\(tag)>"
			return ret
		} else {
			return "<\(tag)>\(self)</\(tag)>"
		}
	}

	static func emptyTag(_ tag: String,
					   attributes: [String: String]? = nil) -> String {
		if let attr = attributes {
			var ret = "<\(tag)"
			for (name, value) in attr {
				ret += " \(name)= \"\(value)\""
			}
			ret += ">"
			return ret
		} else {
			return "<\(tag)>"
		}
	}

	/// Remove starting and ending tag. No attributes in tag
	func removedTag(_ tag: String) -> String {
		let startingTag = "<\(tag)>"
		let endingTag = "</\(tag)>"
		if self.hasPrefix(startingTag)
			&&  self.hasSuffix(endingTag) {
			var ret = self
			//remove s. tag
			var idx = ret.index(ret.startIndex, offsetBy: startingTag.count)
			ret.removeSubrange(ret.startIndex..<idx)
			//remove e. tag
			idx = ret.index(ret.endIndex, offsetBy: -endingTag.count)
			ret.removeSubrange(idx..<ret.endIndex)
			return ret
		} else {
			return self
		}
	}

	func htmlTableRow() -> String {
		return enclosedInTag("tr")
	}

	func htmlTableCell() -> String {
		return enclosedInTag("td")
	}

	func rightAlignedNoWrapCell() -> String {
		return enclosedInTag("td", attributes: ["align": "right",
												"nowrap": "nowrap"])
	}

	static func emptyTableCell() -> String {
		return "&nbsp;".enclosedInTag("td")
	}

	static func script(with url: URL) -> String {
		return url.absoluteString.enclosedInTag("script")
	}

	static func css(with url: URL) -> String {
		return String.emptyTag("link", attributes: ["rel": "stylesheet",
													"href": url.absoluteString])
	}

	func inlineColored(_ color: String) -> String {
		return enclosedInTag("span", attributes: ["style": "color: \(color)"])
	}

	func redColored() -> String { return inlineColored("red") }
	func blueColored() -> String { return inlineColored("blue") }

}

extension Table {
	func toHtml() -> String {
		return outletName.htmlTableCell() + (viewBased ? "view".blueColored() : "cell".redColored()).htmlTableCell()
	}
}

extension TableViewFinder {
	typealias XibTables = (name: String, tables: [Table])
	func toHtml() -> String
	{
		var ret = "<!DOCTYPE html>"

		let head = htmlHead()

		let body = bodyContent().enclosedInTag("body")

		ret += (head + body).enclosedInTag("html")

		return ret
	}

	func htmlHead() -> String {
		var ret = "Tables In Xibs".enclosedInTag("title")

		ret += String.emptyTag("meta", attributes: ["name": "viewport",
													   "content": "width=device-width, initial-scale=1"])

		ret += String.css(with: URL(string: "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css")!)

		ret += String.script(with: URL(string: "https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js")!)

		ret += String.script(with: URL(string: "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js")!)

		return ret.enclosedInTag("head")
	}

	private func tableHeader() -> String {
		var ret = "File ( "
			+ "cell-based".redColored()
			+ " | "
			+ "view-based".blueColored()
			+ " )"

		ret = ret.enclosedInTag("th")
		ret += "IBOutlet Name".enclosedInTag("th")
		ret += "Type".enclosedInTag("th")

		return ret.htmlTableRow().enclosedInTag("thead")
	}

	private func bodyContent() -> String {
		var tableElement = tableHeader()

		for (file, tables) in tableInfo {
			let xib = (name: file, tables: tables)
			tableElement += html(for: xib)
		}

		let div = header() + tableElement.enclosedInTag("table", attributes: ["class": "table table-condensed"])
		return div.enclosedInTag("div", attributes: ["class": "container"])
	}

	private func header() -> String {
		var ret = "Number of Xibs: \(xibCount())".enclosedInTag("h3")
		let cellCountHtml = "\(cellBasedTableCount())".redColored()
		let viewCountHtml = "\(viewBasedTableCount())".blueColored()
		ret += "Number of Tables: \(tableCount()) ( \(cellCountHtml) | \(viewCountHtml) )"
			.enclosedInTag("h3")
		return ret
	}

	private func html(for xib: XibTables) -> String {
		var ret = ""
		let viewBasedCount = xib.tables.filter { $0.viewBased }.count
		let cellBasedCount = xib.tables.count - viewBasedCount

		let cellCountHtml = "\(cellBasedCount)".redColored()
		let viewCountHtml = "\(viewBasedCount)".blueColored()

		let title = xib.name + " ( \(cellCountHtml) | \(viewCountHtml) )"

		if xib.tables.count > 1 {
			var index = 0
			for table in xib.tables {
				var tableRow =  index == 0 ? title.enclosedInTag("td", attributes: ["rowspan": "\(xib.tables.count)"]) : ""
				tableRow += table.toHtml()
				ret += tableRow.htmlTableRow()
				index += 1
			}
		} else {
			if let table = xib.tables.first {
				var tableRow =  title.enclosedInTag("td")
				tableRow += table.toHtml()
				ret += tableRow.htmlTableRow()
			}
		}
		return ret
	}
}
