
$targetDir = 'D:\Work'
New-Item -Path $targetDir -ItemType Directory | Out-Null
Copy-Item .\MediaInfo.dll      "$targetDir\MediaInfo.dll"
Copy-Item .\MediaInfoSharp.dll "$targetDir\MediaInfoSharp.dll"
Copy-Item .\MediaInfoSharp.pdb "$targetDir\MediaInfoSharp.pdb"
Copy-Item .\Get-MediaInfo.psd1 "$targetDir\Get-MediaInfo.psd1"
Copy-Item .\Get-MediaInfo.psm1 "$targetDir\Get-MediaInfo.psm1"

$key = Read-Host 'Enter Api Key'

Publish-Module -Path $targetDir -NuGetApiKey $key
