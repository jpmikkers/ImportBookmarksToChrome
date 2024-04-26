# ImportBookmarksToChrome
Powershell script to import bookmarks into Chrome browser (the Default user profile, for now)

## Usage

```posh
Import-BookmarksToChrome -Urls @('https://www.youtube.com')
```

You can also specify import folder name (the default is 'PowershellImported'):

```posh
Import-BookmarksToChrome -Urls @('https://www.youtube.com') -FolderTitle 'MyImports'
```
