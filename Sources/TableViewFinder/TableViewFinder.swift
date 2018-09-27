//
//  TableViewFinder.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/27/18.
//

import Foundation

class Table: CustomStringConvertible {
	var id: String = ""
	var xib: URL = URL(fileURLWithPath: "/")
	var outletName: String = ""
	var viewBased: Bool = false
	var description: String {
		return "\(xib.lastPathComponent):(\(outletName) \(viewBased ? "view-based":  "cell-based"))"
	}
}

class TableViewFinder: NSObject, XMLParserDelegate {
	var tableInfo = [URL: [Table]]()
	var outletMap = [String: String]()

	var xibURLArray: [URL] = []
	var index = 0
	var currentXib: URL {
		if index < xibURLArray.count {
			return xibURLArray[index]
		}
		return URL(fileURLWithPath: NSHomeDirectory())
	}

	func logConsole(_ msg: String) {
		print(msg)
		print("")
	}

	func readFile(_ file: URL) {
//		logConsole("Loading \(file)")
		if let parser = XMLParser(contentsOf: file) {
			parser.delegate = self
			logConsole("will parse \(currentXib)")
			if parser.parse() {
//				logConsole("parsed!")
			} else {
//				logConsole("failed!")
			}
		}
	}

	func getXibURLs(in sourceFolder: String) -> [URL] {
		var ret = [URL]()
		if let enumerator = FileManager.default.enumerator(atPath: sourceFolder) {
			for file in enumerator {
				if let path = file as? String,
					path.hasSuffix("xib") {
					ret.append(URL(fileURLWithPath: sourceFolder + path))
				}
			}
		}
		return ret
	}

	func addTable(byId tableId: String,
				  viewBased: Bool = false) {

		let table = Table()
		table.xib = currentXib
		table.id = tableId
		table.viewBased = viewBased

		if let tables = tableInfo[currentXib] {
			var array = [table]
			array.append(contentsOf: tables)
			tableInfo[currentXib] = array
		} else {
			tableInfo[currentXib] = [table]
		}
//		logConsole("new table added: \(table)")
	}

	func updateTableName() {
		if let tables = tableInfo[currentXib] {
			for table in tables {
				if let name = outletMap[table.id] {
					table.outletName = name
					continue;
				} else {
					logConsole("Found no outlet name for \(table)!!")
				}
			}
		} else {
			logConsole("Found no tableview in \(currentXib.lastPathComponent) ")
		}
	}

	func parserDidEndDocument(_ parser: XMLParser) {
		updateTableName()
		parser.delegate = nil
//		parseNext()
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		//		logConsole("hit elelment: \(elementName)")
		if elementName == "tableView" {
			//			logConsole("tableView element found: \(attributeDict)")
			var viewBased = false
			if let tableId = attributeDict["id"] {
				if let viewBasedAttr = attributeDict["viewBased"],
					viewBasedAttr == "YES" {
					viewBased =  true
				}
				addTable(byId: tableId, viewBased: viewBased)
			}
		} else if elementName == "outlet" {
			if let tableId = attributeDict["destination"],
				let tableName = attributeDict["property"] {
				outletMap[tableId] = tableName
			}
		}
	}
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		logConsole(parseError.localizedDescription)
	}

	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		logConsole(validationError.localizedDescription)
	}

//	func parseNext() {
//		index += 1
//		if index < xibURLArray.count {
//			readFile(xibURLArray[index])
//		}
//	}

	func parse(_ sourceFolder: String) {
		self.xibURLArray = getXibURLs(in: sourceFolder)
		logConsole("Total xibs: \(xibURLArray.count)")
		index = -1

		for file in xibURLArray {
			index += 1
			readFile(file)
		}

		logConsole("Found \(tableInfo.count) xibs contains tableviews")
		logConsole("\(tableInfo.values)")
//		parseNext()
	}
}
