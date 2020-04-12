
$ErrorActionPreference = 'Stop'

$VideoExtensions = "264", "265", "asf", "avc", "avi", "divx", "flv", "h264", "h265", "hevc", "m2ts", "m2v", "m4v", "mkv", "mov", "mp4", "mpeg", "mpg", "mpv", "mts", "rar", "ts", "vob", "webm", "wmv"
$AudioExtensions = "aac", "ac3", "dts", "dtshd", "dtshr", "dtsma", "eac3", "flac", "m4a", "mka", "mp2", "mp3", "mpa", "ogg", "opus", "thd", "thd+ac3", "w64", "wav"
$CacheVersion    = 43

$culture = [Globalization.CultureInfo]::InvariantCulture

function ConvertStringToInt($value)
{
    try {
        [int]::Parse($value, $culture)
    }
    catch {
        0
    }
}

function ConvertStringToDouble($value)
{
    try {
        [double]::Parse($value, $culture)
    }
    catch {
        0.0
    }
}

function ConvertStringToLong($value)
{
    try {
        [long]::Parse($value, $culture)
    }
    catch {
        [long]0
    }
}

function Get-MediaInfo
{
    [CmdletBinding()]
    [Alias("gmi")]
    Param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]] $Path,

        [Switch]$Video,
        [Switch]$Audio
    )

    begin
    {
        $ScriptDir = Split-Path $PSCommandPath
        Add-Type -Path ($ScriptDir + '\MediaInfoNET.dll')

        if (-not $Env:Path.Contains($ScriptDir + ';'))
        {
            $Env:Path = $ScriptDir + ';' + $Env:Path
        }
    }

    Process
    {
        foreach ($File in $Path)
        {
            if (-not (Test-Path $File -PathType Leaf))
            {
                continue
            }

            $Extension = [IO.Path]::GetExtension($File).TrimStart([char]'.')

            $ChacheFileBase = $File + '-' + (Get-Item $File).Length + '-' + $CacheVersion

            foreach ($char in [IO.Path]::GetInvalidFileNameChars())
            {
                if ($ChacheFileBase.Contains($char))
                {
                    $ChacheFileBase = $ChacheFileBase.Replace($char.ToString(), '-' + [int]$char + '-')
                }
            }

            $cacheFile = Join-Path ([IO.Path]::GetTempPath()) ($ChacheFileBase + '.json')

            if (-not $Video -and -not $Audio)
            {
                if ($VideoExtensions -contains $Extension)
                {
                    $Video = $true
                }
                elseif ($AudioExtensions -contains $Extension)
                {
                    $Audio = $true
                }
            }

            if ($Video -and $VideoExtensions -contains $Extension)
            {
                if (Test-Path $cacheFile)
                {
                    Get-Content $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfo -ArgumentList $File

                    $Format = $mi.GetInfo('Video', 0, 'Format')

                    if ($Format -eq 'MPEG Video')
                    {
                        $Format = 'MPEG'
                    }

                    $obj = [PSCustomObject]@{
                        FileName       = [IO.Path]::GetFileName($File)
                        Ext            = $Extension
                        Format         = $Format
                        DAR            = ConvertStringToDouble $mi.GetInfo('Video', 0, 'DisplayAspectRatio')
                        Width          = ConvertStringToInt $mi.GetInfo('Video',   0, 'Width')
                        Height         = ConvertStringToInt $mi.GetInfo('Video',   0, 'Height')
                        BitRate        = (ConvertStringToInt $mi.GetInfo('Video', 0, 'BitRate')) / 1000
                        Duration       = (ConvertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        FileSize       = (ConvertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        FrameRate      = ConvertStringToDouble $mi.GetInfo('Video',   0, 'FrameRate')
                        ScanType       = $mi.GetInfo('Video',   0, 'ScanType')
                        ColorPrimaries = $mi.GetInfo('Video',   0, 'colour_primaries')
                        Transfer       = $mi.GetInfo('Video',   0, 'transfer_characteristics')
                        FormatProfile  = $mi.GetInfo('Video',   0, 'Format_Profile')
                        AudioCodec     = $mi.GetInfo('General', 0, 'Audio_Codec_List')
                        TextFormat     = $mi.GetInfo('General', 0, 'Text_Format_List')
                        Directory      = [IO.Path]::GetDirectoryName($File)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File $cacheFile
                    $obj
                }
            }
            elseif ($Audio -and $AudioExtensions -contains $Extension)
            {
                if (Test-Path $cacheFile)
                {
                    Get-Content $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfo -ArgumentList $File

                    $obj = [PSCustomObject]@{
                        FileName    = [IO.Path]::GetFileName($File)
                        Ext         = $Extension
                        Format      = $mi.GetInfo('Audio',   0, 'Format')
                        Performer   = $mi.GetInfo('General', 0, 'Performer')
                        Track       = $mi.GetInfo('General', 0, 'Track')
                        Album       = $mi.GetInfo('General', 0, 'Album')
                        Year        = $mi.GetInfo('General', 0, 'Recorded_Date')
                        Genre       = $mi.GetInfo('General', 0, 'Genre')
                        Duration    = (ConvertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        BitRate     = (ConvertStringToInt $mi.GetInfo('Audio',   0, 'BitRate')) / 1000
                        FileSize    = (ConvertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        Directory   = [IO.Path]::GetDirectoryName($File)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File $cacheFile
                    $obj
                }
            }
        }
    }
}

function Get-MediaInfoValue
{
    [CmdletBinding()]
    [Alias("gmiv")]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        [string] $Path,

        [Parameter(Mandatory=$true)]
        [ValidateSet("General", "Video", "Audio", "Text", "Image", "Menu")]
        [String] $Kind,

        [int] $Index,

        [Parameter(Mandatory=$true)]
        [string] $Parameter
    )

    begin
    {
        $ScriptDir = Split-Path $PSCommandPath
        Add-Type -Path ($ScriptDir + '\MediaInfoNET.dll')

        if (-not $Env:Path.Contains($ScriptDir + ';'))
        {
            $Env:Path = $ScriptDir + ';' + $Env:Path
        }
    }

    Process
    {
        $mi = New-Object MediaInfo -ArgumentList $Path
        $value = $mi.GetInfo($Kind, $Index, $Parameter)
        $mi.Dispose()
        return $value
    }
}

function Get-MediaInfoSummary
{
    [CmdletBinding()]
    [Alias("gmis")]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Full,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Raw
    )

    begin
    {
        $ScriptDir = Split-Path $PSCommandPath
        Add-Type -Path ($ScriptDir + '\MediaInfoNET.dll')

        if (-not $Env:Path.Contains($ScriptDir + ';'))
        {
            $Env:Path = $ScriptDir + ';' + $Env:Path
        }
    }

    Process
    {
        $mi = New-Object MediaInfo -ArgumentList $Path
        $value = $mi.GetSummary($Full, $Raw)
        $mi.Dispose()
        ("`r`n" + $value) -split "`r`n"
    }
}

# gci 'D:\Samples' | gmi | ogv
