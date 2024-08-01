$path = 'C:\AIB'
mkdir $path

$LogFile = $path + '\' + 'Baseline-Configuration-' + (Get-Date -UFormat '%d-%m-%Y') + '.log'

Function Write-Log {
    param (
        [Parameter(Mandatory = $True)]
        [array]$LogOutput,
        [Parameter(Mandatory = $True)]
        [string]$Path
    )
    $currentDate = (Get-Date -UFormat '%d-%m-%Y')
    $currentTime = (Get-Date -UFormat '%T')
    $logOutput = $logOutput -join (' ')
    "[$currentDate $currentTime] $logOutput" | Out-File $Path -Append
}

# Disable Store auto update
Schtasks /Change /Tn '\Microsoft\Windows\WindowsUpdate\Scheduled Start' /Disable
Write-Log -LogOutput ('Disable Store auto update') -Path $LogFile

# region Time Zone Redirection
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fEnableTimeZoneRedirection' -Value 1 -Force
Write-Log -LogOutput ('Added time zone redirection registry key') -Path $LogFile

# Install Dutch language and set als default
Install-Language nl-NL
Set-SystemPreferredUILanguage nl-NL
Write-Log -LogOutput ('Default language is installed and set') -Path $LogFile

# Remove data but keep logging
$var = 'log'
$array = @(Get-ChildItem $path -Exclude *.$var -Name)
for ($i = 0; $i -lt $array.length; $i++) {
    $removepath = Join-Path -Path $path -ChildPath $array[$i]
    Remove-Item $removepath -Recurse
}