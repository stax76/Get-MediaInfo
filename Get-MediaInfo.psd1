
@{
    RootModule = 'Get-MediaInfo.psm1'
    ModuleVersion = '3.5'
    GUID = '86639e26-2698-42ec-b7f1-c66daca2eb78'
    Author = 'stax76 (Frank Skare)'
    CompanyName = 'stax76 (Frank Skare)'
    Copyright = '(C) 2020 stax76 (Frank Skare). All rights reserved.'
    Description = 'Complete PowerShell MediaInfo solution'
    PowerShellVersion = '5.1'
    ProcessorArchitecture = 'Amd64'
    FunctionsToExport = @('Get-MediaInfo', 'Get-MediaInfoValue', 'Get-MediaInfoSummary')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @('gmi', 'gmiv', 'gmis')

    PrivateData = @{
        PSData = @{
            Tags = @('mp3', 'media', 'video', 'audio')
            ProjectUri = 'https://github.com/stax76/Get-MediaInfo'
        }
    }
}
