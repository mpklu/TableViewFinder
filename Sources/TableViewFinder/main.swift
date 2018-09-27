//print("Hello, world!")
let projHome = "/Users/kunlu/Projects/MacPractice/"
let sourceFolder = projHome + "MacPractice/Source/"

let finder = TableViewFinder()

finder.parse(sourceFolder)

let html  = finder.toHtml()

print("")
print(html)
