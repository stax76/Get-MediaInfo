
$targetDir = [Environment]::GetFolderPath('Desktop') + '\Get-MediaInfo'
New-Item -Path $targetDir -ItemType Directory
Copy-Item 'D:\Projekte\CS\mpv.net\mpv.net\bin\x64\MediaInfo.dll' "$targetDir\MediaInfo.dll"
Copy-Item .\MediaInfoNET.dll "$targetDir\MediaInfoNET.dll"
Copy-Item .\MediaInfoNET.dll "$targetDir\MediaInfoNET.dll"
Copy-Item .\Get-MediaInfo.ps1 "$targetDir\Get-MediaInfo.ps1"
