//print("Hello, world!")
import Foundation
import CommandLineKit
import AppKit

let cli = CommandLineKit.CommandLine()
let sourceFolder = StringOption(shortFlag: "d",
								longFlag: "directory",
								required: true,
								helpMessage: "Find xib files with tableviews in the given directory and sub-folders")

let openResult = BoolOption(shortFlag: "o",
								longFlag: "open",
								required: false,
								helpMessage: "Open result in browser, result is in HTML format by default unless --json option is selected")

let usesJSON = BoolOption(shortFlag: "j",
					  longFlag: "json",
					  required: false,
					  helpMessage: "Generate result in json format. Otherwise it is in HTML format by default")


let verbosity = CounterOption(shortFlag: "v",
							  longFlag: "verbose",
							  helpMessage: "Print verbose messages. Use 1 to print out result only. Use 2 to also print out debug information")

let tableType = StringOption(longFlag: "type", helpMessage: "Type of table view. Ex: --type=cell or --type=view for cell-based and view-based tableviews accordingly")

cli.addOptions([sourceFolder, openResult, usesJSON, verbosity, tableType])


do {
	try cli.parse()

	let finder = TableViewFinder()

	if let level = Verbosity(rawValue: verbosity.value) {
		finder.logLevel = level
	}

	if let type = tableType.value,
		let typeFilter = TableFilter(rawValue: type) {
		finder.typeFilter = typeFilter
	}

	finder.parse(sourceFolder.value!)

	var result: String?
	var ext: String = "html"
	if usesJSON.value {
		result = finder.toJsonString()
		ext = "json"
	} else {
		result = finder.toHtml()
	}

	if verbosity.value > 0 {
		print("")
		if let output = result {
			print(output)
		}
	}

	if openResult.value {
		if let output = result {
			let tmp = try TemporaryFile(creatingTempDirectoryForFilename: "xibtables.\(ext)")
			do {
				try output.write(to: tmp.fileURL, atomically: true, encoding: String.Encoding.ascii)
				NSWorkspace.shared.open(tmp.fileURL)
			} catch {
				print(error.localizedDescription)
			}
		}
	}


} catch {
	cli.printUsage(error)
}

