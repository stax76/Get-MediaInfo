
$videoExtensions = '264', '265', 'asf', 'avc', 'avi', 'divx', 'flv', 'h264', 'h265', 'hevc', 'm2ts', 'm2v', 'm4v', 'mkv', 'mov', 'mp4', 'mpeg', 'mpg', 'mpv', 'mts', 'rar', 'ts', 'vob', 'webm', 'wmv'
$audioExtensions = 'aac', 'ac3', 'dts', 'dtshd', 'dtshr', 'dtsma', 'eac3', 'flac', 'm4a', 'mka', 'mp2', 'mp3', 'mpa', 'ogg', 'opus', 'thd', 'w64', 'wav'
$cacheVersion    = 45
$culture         = [Globalization.CultureInfo]::InvariantCulture

function ConvertStringToInt($value)
{
    try {
        [int]::Parse($value, $culture)
    } catch {
        0
    }
}

function ConvertStringToDouble($value)
{
    try {
        [double]::Parse($value, $culture)
    } catch {
        0.0
    }
}

function ConvertStringToLong($value)
{
    try {
        [long]::Parse($value, $culture)
    } catch {
        [long]0
    }
}

function Get-MediaInfo
{
    [CmdletBinding()]
    [Alias('gmi')]
    Param(
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]] $Path,

        [Switch]$Video,
        [Switch]$Audio
    )

    begin
    {
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }

    Process
    {
        foreach ($file in $Path)
        {
            $file = Convert-Path -LiteralPath $file

            if (-not (Test-Path -LiteralPath $file -PathType Leaf))
            {
                continue
            }

            $extension = [IO.Path]::GetExtension($file).TrimStart([char]'.')
            $chacheFileBase = $file + '-' + (Get-Item -LiteralPath $file).Length + '-' + $cacheVersion

            foreach ($char in [IO.Path]::GetInvalidFileNameChars())
            {
                if ($chacheFileBase.Contains($char))
                {
                    $chacheFileBase = $chacheFileBase.Replace($char.ToString(), '-' + [int]$char + '-')
                }
            }

            $cacheFile = Join-Path ([IO.Path]::GetTempPath()) ($chacheFileBase + '.json')

            if (-not $Video -and -not $Audio)
            {
                if ($videoExtensions -contains $extension)
                {
                    $Video = $true
                }
                elseif ($audioExtensions -contains $extension)
                {
                    $Audio = $true
                }
            }

            if ($Video -and $videoExtensions -contains $extension)
            {
                if (Test-Path -LiteralPath $cacheFile)
                {
                    Get-Content -LiteralPath $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfoSharp -ArgumentList $file

                    $format = $mi.GetInfo('Video', 0, 'Format')

                    if ($format -eq 'MPEG Video')
                    {
                        $format = 'MPEG'
                    }

                    $obj = [PSCustomObject]@{
                        FileName       = [IO.Path]::GetFileName($file)
                        Ext            = $extension
                        Format         = $format
                        DAR            = ConvertStringToDouble $mi.GetInfo('Video', 0, 'DisplayAspectRatio')
                        Width          = ConvertStringToInt $mi.GetInfo('Video', 0, 'Width')
                        Height         = ConvertStringToInt $mi.GetInfo('Video', 0, 'Height')
                        BitRate        = (ConvertStringToInt $mi.GetInfo('Video', 0, 'BitRate')) / 1000
                        Duration       = (ConvertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        FileSize       = (ConvertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        FrameRate      = ConvertStringToDouble $mi.GetInfo('Video', 0, 'FrameRate')
                        AudioCodec     = $mi.GetInfo('General', 0, 'Audio_Codec_List')
                        TextFormat     = $mi.GetInfo('General', 0, 'Text_Format_List')
                        ScanType       = $mi.GetInfo('Video',   0, 'ScanType')
                        Range          = $mi.GetInfo('Video',   0, 'colour_range')
                        Primaries      = $mi.GetInfo('Video',   0, 'colour_primaries')
                        Transfer       = $mi.GetInfo('Video',   0, 'transfer_characteristics')
                        Matrix         = $mi.GetInfo('Video',   0, 'matrix_coefficients')
                        FormatProfile  = $mi.GetInfo('Video',   0, 'Format_Profile')
                        Directory      = [IO.Path]::GetDirectoryName($file)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File -LiteralPath $cacheFile -Encoding UTF8
                    $obj
                }
            }
            elseif ($Audio -and $audioExtensions -contains $extension)
            {
                if (Test-Path -LiteralPath $cacheFile)
                {
                    Get-Content -LiteralPath $cacheFile -Raw | ConvertFrom-Json
                }
                else
                {
                    $mi = New-Object MediaInfoSharp -ArgumentList $file

                    $obj = [PSCustomObject]@{
                        FileName    = [IO.Path]::GetFileName($file)
                        Ext         = $extension
                        Format      = $mi.GetInfo('Audio',   0, 'Format')
                        Performer   = $mi.GetInfo('General', 0, 'Performer')
                        Track       = $mi.GetInfo('General', 0, 'Track')
                        Album       = $mi.GetInfo('General', 0, 'Album')
                        Year        = $mi.GetInfo('General', 0, 'Recorded_Date')
                        Genre       = $mi.GetInfo('General', 0, 'Genre')
                        Duration    = (ConvertStringToDouble $mi.GetInfo('General', 0, 'Duration')) / 60000
                        BitRate     = (ConvertStringToInt $mi.GetInfo('Audio', 0, 'BitRate')) / 1000
                        FileSize    = (ConvertStringToLong $mi.GetInfo('General', 0, 'FileSize')) / 1024 / 1024
                        Directory   = [IO.Path]::GetDirectoryName($file)
                    }

                    $mi.Dispose()
                    $obj | ConvertTo-Json | Out-File -LiteralPath $cacheFile -Encoding UTF8
                    $obj
                }
            }
        }
    }
}

function Get-MediaInfoValue
{
    [CmdletBinding()]
    [Alias('gmiv')]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        [string] $Path,

        [Parameter(Mandatory=$true)]
        [ValidateSet('General', 'Video', 'Audio', 'Text', 'Image', 'Menu')]
        [String] $Kind,

        [int] $Index,

        [Parameter(Mandatory=$true)]
        [string] $Parameter
    )

    begin
    {
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }

    Process
    {
        $mi = New-Object MediaInfoSharp -ArgumentList (Convert-Path -LiteralPath $Path)
        $value = $mi.GetInfo($Kind, $Index, $Parameter)
        $mi.Dispose()
        return $value
    }
}

function Get-MediaInfoSummary
{
    [CmdletBinding()]
    [Alias('gmis')]
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
        Add-Type -Path ($PSScriptRoot + '\MediaInfoSharp.dll')
    }

    Process
    {
        $mi = New-Object MediaInfoSharp -ArgumentList (Convert-Path -LiteralPath $Path)
        $value = $mi.GetSummary($Full, $Raw)
        $mi.Dispose()
        ("`r`n" + $value) -split "`r`n"
    }
}
