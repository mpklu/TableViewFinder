# TableViewFinder

This is a OS X command line tool helps finding cell-based/view-based tableviews from xib files under a given folder and its subfolders.

Result suports HTML and JSON format. Use `--verbose` option to print result right in terminal, or use `--open` to open the result in default application accordingly.

```
Ex: ./TableViewFinder -d PATH/TO/SOURCE/ -o
```


```
Usage: ./TableViewFinder [options]
  -d, --directory:
      Find xib files with tableviews in the given directory and sub-folders
  -o, --open:
      Open result in browser, result is in HTML format by default unless --json option is selected
  -j, --json:
      Generate result in json format. Otherwise it is in HTML format by default
  -v, --verbose:
      Print verbose messages. Use 1 to print out result only. Use 2 to also print out debug information
  --type:
      Type of table view. Ex: --type=cell or --type=view for cell-based and view-based tableviews accordingly
```
