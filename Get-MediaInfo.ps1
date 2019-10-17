
function Get-MediaInfo
{
    [CmdletBinding()]
    [Alias("gmi")]
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
        $scriptFolder = Split-Path $PSCommandPath
        Add-Type -Path ($scriptFolder + '\MediaInfoNET.dll')

        if ($Env:Path.IndexOf($scriptFolder + ';') -eq -1)
        {
            $Env:Path = $scriptFolder + ';' + $Env:Path
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
