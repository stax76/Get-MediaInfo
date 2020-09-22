
$targetDir = [Environment]::GetFolderPath('Desktop') + '\Get-MediaInfo'
New-Item -Path $targetDir -ItemType Directory | Out-Null
Copy-Item .\MediaInfo.dll      "$targetDir\MediaInfo.dll"
Copy-Item .\MediaInfoSharp.dll "$targetDir\MediaInfoSharp.dll"
Copy-Item .\MediaInfoSharp.pdb "$targetDir\MediaInfoSharp.pdb"
Copy-Item .\Get-MediaInfo.psd1 "$targetDir\Get-MediaInfo.psd1"
Copy-Item .\Get-MediaInfo.psm1 "$targetDir\Get-MediaInfo.psm1"
