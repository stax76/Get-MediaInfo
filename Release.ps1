
$targetDir = [Environment]::GetFolderPath('Desktop') + '\Get-MediaInfo-3.0'
New-Item -Path $targetDir -ItemType Directory | Out-Null
Copy-Item .\MediaInfo.dll "$targetDir\MediaInfo.dll"
Copy-Item .\MediaInfoNET.dll "$targetDir\MediaInfoNET.dll"
Copy-Item .\Get-MediaInfo.ps1 "$targetDir\Get-MediaInfo.ps1"
& 'C:\Program Files\7-Zip\7z.exe' a -t7z -mx9 "$targetDir.7z" -r "$targetDir\*"
