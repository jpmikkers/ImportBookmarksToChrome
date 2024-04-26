function Import-BookmarksToChrome {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Urls,

        [Parameter(Mandatory=$false)]
        [string]$FolderTitle = 'PowershellImported',

        [Parameter(Mandatory=$false)]
        [string]$KillChromeAfterImport = $true
    )
    
    $activeProfile = "Default"
    Write-Verbose "Active profile is '$activeProfile'"

    # c:\Users\<username>\AppData\Local\Microsoft\Edge\User Data\<profilename>"
    $chromeProfileLocation = Join-Path $env:LOCALAPPDATA -ChildPath 'Google\Chrome\User Data' -AdditionalChildPath $activeProfile
    Write-Verbose "profile location '$chromeProfileLocation'"

    if(!(Test-Path -PathType Container -Path $chromeProfileLocation))
    {
        throw "Can't find profile folder '$chromeProfileLocation'"
    }

    $bookmarksfile = Join-Path $chromeProfileLocation -ChildPath 'Bookmarks'

    if(!(Test-Path -PathType Leaf -Path $bookmarksfile))
    {
        throw "Can't find bookmarks file '$bookmarksfile'"
    }

    # Read the JSON file
    $bookmarks = Get-Content $bookmarksfile -Raw | ConvertFrom-Json

    if($null -eq $bookmarks.roots.bookmark_bar.children)
    {
        throw "bookmarks file format is wrong"
    }

    if($bookmarks.roots.bookmark_bar.children.name -contains $FolderTitle)
    {
        Write-Verbose "I found the import folder '$FolderTitle'"
    }
    else 
    {
        Write-Verbose "folder node '$FolderTitle' not found, adding.."
        $chromeNow = DateTimeToChrome([DateTime]::UtcNow)
        $bookmarks.roots.bookmark_bar.children += [ordered]@{
            "children"       = @()
            "date_added"     = "$chromeNow"
            "date_last_used" = "$chromeNow"
            "date_modified"  = "$chromeNow"
            "guid"           = [guid]::NewGuid()
            # "id"           = "9"                  # Id seems to be filled in automatically by Edge
            "name"           = $FolderTitle
            "source"         = 'unknown'
            "type"           = 'folder'
        }
    }

    $foldernode = $bookmarks.roots.bookmark_bar.children | Where-Object { $_.Name -eq $foldertitle } | Select-Object -First 1

    if($null -ne $foldernode)
    {
        $existingUrls = @($foldernode.children.url)

        foreach($url in $Urls)
        {
            Write-Verbose "Importing '$url'"

            if($existingUrls -contains $url -or $existingUrls -contains ($url+'/'))
            {
                Write-Verbose "Url '$url' already imported, skipping"
            }
            else 
            {
                $chromeNow = DateTimeToChrome([DateTime]::UtcNow)
                $foldernode.children += [ordered]@{
                    "date_added"     = "$chromeNow"
                    "date_last_used" = "$chromeNow"
                    "guid"           = [guid]::NewGuid()
                    "name"           = $url
                    "show_icon"      = $false
                    "source"         = "user_copy"
                    "type"           = "url"
                    "url"            = $url
                }
            }
        }
    }

    # Export the modified object back to JSON
    $bookmarks | ConvertTo-Json -Depth 50 | Out-File $bookmarksfile

    if($KillChromeAfterImport)
    {
        Write-Verbose "Killing running chrome browsers"
        Get-Process -Name 'chrome' -ErrorAction Ignore | Foreach-Object { $_.Kill($true) }
    }        
}

function DateTimeFromChrome {
    param ( [Int64]$v )
    return [DateTime]::new(1601,1,1,0,0,0,[System.DateTimeKind]::Utc).AddMicroseconds($v)
}

function DateTimeToChrome {
    param ( [datetime]$v )
    return [Int64]($v.Subtract([DateTime]::new(1601,1,1,0,0,0,[System.DateTimeKind]::Utc))).TotalMicroseconds
}
