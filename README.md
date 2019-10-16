# Get-MediaInfo

```
NAME
    Get-MediaInfo

SYNTAX
    Get-MediaInfo
        [-Path] <string>
        [-Kind] {General | Video | Audio | Text | Image | Menu}
        [[-Index] <int>]
        [-Parameter] <string>
        [<CommonParameters>]

ALIASES
    gmi
```

## Description

Get-MediaInfo let's you access specific properties from media files.

## Installation

Go to the release page and download the release. It contains one ps1 file and two DLL files, keep all three files in the same folder and load Get-MediaInfo.ps1 via dot sourcing.

## Examples

**Get the artist from a MP3 file.**

```PowerShell
Get-MediaInfo '.\Meg Myers - Desire (Hucci Remix).mp3' -Kind General -Parameter Performer

Meg Myers
```

**Get the channel count in a MP3 file**  
Return types are always strings und if necessary must be cast to integer.
```PowerShell
'.\Meg Myers - Desire (Hucci Remix).mp3' | Get-MediaInfo -Kind Audio -Parameter 'Channel(s)'

2
```

**Get the language of the second audio stream in a movie**  
The Index parameter is zero based.
```PowerShell
Get-MediaInfo '.\The Warriors.mkv' -Kind Audio -Index 1 -Parameter 'Language/String'

English
```

**Get the count of subtitle streams in a movie**  
```PowerShell
Get-MediaInfo '.\The Warriors.mkv' -Kind General -Parameter 'TextCount'

2
```

## Parameters

**-Path**  
Path to a media file.

**-Kind** General | Video | Audio | Text | Image | Menu  
A kind that is known to MediaInfo.

**-Index**  
Zero based stream number.

**-Parameter**  
Name of the property to get.