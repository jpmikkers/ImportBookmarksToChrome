. .\ImportBookmarksToChrome.ps1

$VerbosePreference = 'Continue'
Import-BookmarksToChrome -Urls @("https://www.youtube.com")
