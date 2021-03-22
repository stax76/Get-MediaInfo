
$targetDir = [Environment]::GetFolderPath('Desktop') + '\Get-MediaInfo-3.3'
New-Item -Path $targetDir -ItemType Directory | Out-Null
Copy-Item .\MediaInfo.dll "$targetDir\MediaInfo.dll"
Copy-Item .\MediaInfoSharp.dll "$targetDir\MediaInfoSharp.dll"
Copy-Item .\Get-MediaInfo.ps1 "$targetDir\Get-MediaInfo.ps1"
& 'C:\Program Files\7-Zip\7z.exe' a -t7z -mx9 "$targetDir.7z" -r "$targetDir\*"
