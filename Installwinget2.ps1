Write-Verbose "[$((Get-Date).TimeOfDay)] Starting $($myinvocation.mycommand)"

if ($PSVersionTable.PSVersion.Major -eq 7) {
    Write-Warning 'This command does not work in PowerShell 7. You must install in Windows PowerShell.'
    return
}

# Test for requirement
$Requirement = Get-AppPackage 'Microsoft.DesktopAppInstaller'
if (-Not $Requirement) {
    Write-Verbose 'Installing Desktop App Installer requirement'
    Try {
        Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -ErrorAction Stop
    } Catch {
        Throw $_
    }
}

$uri = 'https://api.github.com/repos/microsoft/winget-cli/releases'

Try {
    Write-Verbose "[$((Get-Date).TimeOfDay)] Getting information from $uri"
    $get = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop

    Write-Verbose "[$((Get-Date).TimeOfDay)] Getting latest release"
    $data = $get[0].assets | Where-Object { $_.name -match 'msixbundle' }

    if ($data) {
        $appx = $data.browser_download_url
        Write-Verbose "[$((Get-Date).TimeOfDay)] $appx"

        $file = Join-Path -Path $env:TEMP -ChildPath $data.name

        Write-Verbose "[$((Get-Date).TimeOfDay)] Saving to $file"
        
        # Use HttpClient for faster download
        $client = New-Object System.Net.Http.HttpClient
        $response = $client.GetAsync($appx, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        $response.EnsureSuccessStatusCode()
        
        $stream = $response.Content.ReadAsStreamAsync().Result
        $fileStream = [System.IO.File]::Create($file)
        $stream.CopyTo($fileStream)
        $fileStream.Close()
        $stream.Close()

        Write-Verbose "[$((Get-Date).TimeOfDay)] Adding Appx Package"
        Add-AppxPackage -Path $file -ErrorAction Stop

        Get-AppxPackage Microsoft.DesktopAppInstaller
    } else {
        Write-Verbose "[$((Get-Date).TimeOfDay)] No suitable asset found."
    }
} Catch {
    Write-Verbose "[$((Get-Date).TimeOfDay)] There was an error."
    Throw $_
}

Write-Verbose "[$((Get-Date).TimeOfDay)] Ending $($myinvocation.mycommand)"
