# ImportBookmarksToChrome
Powershell script to import bookmarks into Chrome browser (the Default user profile, for now)
\
\
If you're looking for a way to import bookmarks into Microsoft Edge browser, visit the [ImportBookmarksToEdge](https://github.com/jpmikkers/ImportBookmarksToEdge) repository.


## Usage

```posh
Import-BookmarksToChrome -Urls @('https://www.youtube.com')
```

You can also specify import folder name (the default is 'PowershellImported'):

```posh
Import-BookmarksToChrome -Urls @('https://www.youtube.com') -FolderTitle 'MyImports'
```
