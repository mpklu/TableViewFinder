//
//  TableViewFinder.swift
//  TableViewFinder
//
//  Created by Kun Lu on 9/27/18.
//

import Foundation
import ColorizeSwift

enum Verbosity: Int {
	case noResult = 0
	case resultOnly = 1
	case debug = 2
}

enum TableFilter: String {
	case all = "all"
	case cellBased = "cell"
	case viewBased = "view"
}

class TableViewFinder: NSObject, XMLParserDelegate {
	var logLevel: Verbosity = .noResult
	var typeFilter: TableFilter = .all
	var tableInfo = [String: [Table]]()
	var outletMap = [String: String]()
	var sourceURL = URL(fileURLWithPath: NSHomeDirectory())

	var xibURLArray: [URL] = []
	var index = 0
	var currentXib: URL {
		if index < xibURLArray.count {
			return xibURLArray[index]
		}
		return URL(fileURLWithPath: NSHomeDirectory())
	}

	func logConsole(_ msg: String, level: Verbosity = .noResult) {
		if level.rawValue <= logLevel.rawValue {
			print(msg)
			print("")
		}
	}

	func readFile(_ file: URL) {
		if let parser = XMLParser(contentsOf: file) {
			parser.delegate = self
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

	private func shouldAddTable(_ viewBased: Bool) -> Bool {
		switch self.typeFilter {
		case .all:
			return true
		case .cellBased:
			return viewBased == false
		case .viewBased:
			return viewBased
		}
	}

	func addTable(byId tableId: String,
				  viewBased: Bool = false) {
		
		if shouldAddTable(viewBased) == false { return }

		let table = Table()
		table.xib = currentXib
		table.id = tableId
		table.viewBased = viewBased

		if let tables = tableInfo[currentXib.lastPathComponent] {
			var array = [table]
			array.append(contentsOf: tables)
			tableInfo[currentXib.lastPathComponent] = array
		} else {
			tableInfo[currentXib.lastPathComponent] = [table]
		}
//		logConsole("new table added: \(table)")
	}

	func updateTableName() {
		if let tables = tableInfo[currentXib.lastPathComponent] {
			for table in tables {
				if let name = outletMap[table.id] {
					table.outletName = name
					continue;
				} else {
					logConsole("Found no outlet name for \(table)!!".red(), level: .debug)
				}
			}
		} else {
			logConsole("Found no tableview in \(currentXib.lastPathComponent) ".red(), level: .debug)
		}
	}

	func parserDidEndDocument(_ parser: XMLParser) {
		updateTableName()
		parser.delegate = nil
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "tableView" {
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
		logConsole(parseError.localizedDescription, level: .debug)
	}

	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		logConsole(validationError.localizedDescription, level: .debug)
	}

	func parse(_ sourceFolder: String) {
		sourceURL = URL(fileURLWithPath: sourceFolder)
		self.xibURLArray = getXibURLs(in: sourceFolder)
		logConsole("Total xibs: \(xibURLArray.count)".cyan())
		index = -1

		for file in xibURLArray {
			index += 1
			readFile(file)
		}

		logConsole("Found \(tableInfo.count) xibs contains tableviews".lightBlue())
//		logConsole("\(tableInfo.values)")
	}

	/// number of xib files that contain tableview
	func xibCount() -> Int {
		return tableInfo.count
	}

	func allTables() -> [Table] {
		return tableInfo.values.flatMap { $0 }
	}

	func tableCount() -> Int {
		return allTables().count
	}

	func viewBasedTableCount() -> Int {
		return allTables().filter { $0.viewBased }.count
	}

	func cellBasedTableCount() -> Int {
		return allTables().filter { !$0.viewBased }.count
	}

	func title() -> String {
		var ret = ""
		switch self.typeFilter {
		case .all:
			ret = "Tableviews"
		case .cellBased:
			ret = "Cell-based Tableviews"
		case .viewBased:
			ret = "View-based Tableviews"
		}

		ret += " Under .../\(sourceURL.lastPathComponents(3))"
		return ret
	}
}
