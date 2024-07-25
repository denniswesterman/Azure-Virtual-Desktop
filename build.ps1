#Requires -RunAsAdministrator

# Set up the base variables
$imageTemplateName = 'AVDImageTemplate' + (Get-Random -Minimum 2 -Maximum 20)
$imageResourceGroup = $imageTemplateName
$location = 'westeurope'
$runOutputName = 'runOutputName' + (Get-Random -Minimum 2 -Maximum 20)

# Image gallery ResourceGroup
$SIGResourceGroup = 'SIG'

# Image gallery name
$sigGalleryName = 'SIG'

# Image definition name
$imageDefName = 'AVD'

# Image version
$date = Get-Date -Format 'yyyy-MM'
$imageversion = $date.Replace('-', '.') + '.' + (Get-Random -Minimum 100 -Maximum 999)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Check of NuGet is installed.
if (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue) {
    Write-Host 'NuGet Already Installed'
} else {
    try {
        Install-PackageProvider -Name NuGet -Confirm:$False -Force  
    } catch [Exception] {
        $_.message 
        exit
    }
}

#Check of Az.Accounts is installed.
if (Get-Module -ListAvailable -Name Az.Accounts) {
    Write-Host 'Az.Accounts Already Installed'
} else {
    try {
        Install-Module -Name Az.Accounts -Repository PSGallery -Confirm:$False -Force  
    } catch [Exception] {
        $_.message 
        exit
    }
}

#Check for update Az.Accounts
Get-Module -Name Az.Accounts -ListAvailable | ForEach-Object {
    $moduleName = $_.Name
    $currentVersion = [Version]$_.Version

    Write-Host "Current version $moduleName [$currentVersion]"

    # Get latest version from gallery
    $latestVersion = [Version](Find-Module -Name $moduleName).Version
    
    # Only proceed if latest version in gallery is greater than your current version
    if ($latestVersion -gt $currentVersion) {
        Write-Host "Found latest version $modulename [$latestVersion] from $($latestVersionModule.Repository)"

        # Check if latest version is already installed before updating
        $latestVersionModule = Get-InstalledModule -Name $moduleName -RequiredVersion $latestVersion -ErrorAction SilentlyContinue
        if ($null -eq $latestVersionModule) {
            Write-Host "Updating $moduleName Module from [$currentVersion] to [$latestVersion]"
            Update-Module -Name $moduleName -RequiredVersion $latestVersion -Force
        } else {
            Write-Host "No update needed, $modulename [$latestVersion] already exists"
        }

        # Uninstall outdated version
        Write-Host "Uninstalling $moduleName [$currentVersion]"
        Uninstall-Module -Name $moduleName -RequiredVersion $currentVersion -Force
    }

    # Otherwise we already have most up to date version
    else {
        Write-Host "$moduleName already up to date"
    }
}

#Check of Az.ManagedServiceIdentity is installed.
if (Get-Module -ListAvailable -Name Az.ManagedServiceIdentity) {
    Write-Host 'Az.ManagedServiceIdentity Already Installed'
} else {
    try {
        Install-Module -Name Az.ManagedServiceIdentity -Repository PSGallery -Confirm:$False -Force  
    } catch [Exception] {
        $_.message 
        exit
    }
}

#Check for update Az.ManagedServiceIdentity
Get-Module -Name Az.ManagedServiceIdentity -ListAvailable | ForEach-Object {
    $moduleName = $_.Name
    $currentVersion = [Version]$_.Version

    Write-Host "Current version $moduleName [$currentVersion]"

    # Get latest version from gallery
    $latestVersion = [Version](Find-Module -Name $moduleName).Version
    
    # Only proceed if latest version in gallery is greater than your current version
    if ($latestVersion -gt $currentVersion) {
        Write-Host "Found latest version $modulename [$latestVersion] from $($latestVersionModule.Repository)"

        # Check if latest version is already installed before updating
        $latestVersionModule = Get-InstalledModule -Name $moduleName -RequiredVersion $latestVersion -ErrorAction SilentlyContinue
        if ($null -eq $latestVersionModule) {
            Write-Host "Updating $moduleName Module from [$currentVersion] to [$latestVersion]"
            Update-Module -Name $moduleName -RequiredVersion $latestVersion -Force
        } else {
            Write-Host "No update needed, $modulename [$latestVersion] already exists"
        }

        # Uninstall outdated version
        Write-Host "Uninstalling $moduleName [$currentVersion]"
        Uninstall-Module -Name $moduleName -RequiredVersion $currentVersion -Force
    }

    # Otherwise we already have most up to date version
    else {
        Write-Host "$moduleName already up to date"
    }
}

#Check of Az.ImageBuilder is installed
if (Get-Module -ListAvailable -Name Az.ImageBuilder) {
    Write-Host 'Az.ImageBuilder Already Installed'
} else {
    try {
        Install-Module -Name Az.ImageBuilder -Repository PSGallery -Confirm:$False -Force  
    } catch [Exception] {
        $_.message 
        exit
    }
}

#Check for update Az.ImageBuilder
Get-Module -Name Az.ImageBuilder -ListAvailable | ForEach-Object {
    $moduleName = $_.Name
    $currentVersion = [Version]$_.Version

    Write-Host "Current version $moduleName [$currentVersion]"

    # Get latest version from gallery
    $latestVersion = [Version](Find-Module -Name $moduleName).Version
    
    # Only proceed if latest version in gallery is greater than your current version
    if ($latestVersion -gt $currentVersion) {
        Write-Host "Found latest version $modulename [$latestVersion] from $($latestVersionModule.Repository)"

        # Check if latest version is already installed before updating
        $latestVersionModule = Get-InstalledModule -Name $moduleName -RequiredVersion $latestVersion -ErrorAction SilentlyContinue
        if ($null -eq $latestVersionModule) {
            Write-Host "Updating $moduleName Module from [$currentVersion] to [$latestVersion]"
            Update-Module -Name $moduleName -RequiredVersion $latestVersion -Force
        } else {
            Write-Host "No update needed, $modulename [$latestVersion] already exists"
        }

        # Uninstall outdated version
        Write-Host "Uninstalling $moduleName [$currentVersion]"
        Uninstall-Module -Name $moduleName -RequiredVersion $currentVersion -Force
    }

    # Otherwise we already have most up to date version
    else {
        Write-Host "$moduleName already up to date"
    }
}

Install-Module Az.Compute -Force -AllowClobber -Repository PSGallery -ErrorAction SilentlyContinue
Install-Module Az.Resources -Force -AllowClobber -Repository PSGallery -ErrorAction SilentlyContinue

#To suppress these warning messages
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

#Import-Module
Import-Module Az.Accounts
Import-Module Az.ManagedServiceIdentity
Import-Module Az.ImageBuilder

# Disconnect all existing Azure connections
do {
    Disconnect-AzAccount
    $azureContext = Get-AzContext
} until (!$azureContext)

#Connect to Az
Connect-AzAccount
#Connect-AzAccount -UseDeviceAuthentication

# VM Selection
$Publisher = Get-AzVMImagePublisher -Location westeurope | Select-Object PublisherName | Where-Object { $_.PublisherName -like 'MicrosoftWindowsDesktop' }
$Publisher.PublisherName
$Offer = Get-AzVMImageOffer -Location westeurope -PublisherName $Publisher.PublisherName | Select-Object Offer | Where-Object { ($_.Offer -eq 'Windows-11' ) }
$Offer.offer
$Skus = Get-AzVMImageSku -Location westeurope -PublisherName $Publisher.PublisherName -Offer $Offer.offer | Select-Object Skus | Where-Object { ($_.Skus -like 'win11-23h2-ent') } 
$Skus.Skus
$Version = Get-AzVMImage -Location westeurope -PublisherName $Publisher.PublisherName -Offer $Offer.offer -Sku $Skus.Skus
$LatestVersion = $Version | Sort-Object -Property Version -Descending | Select-Object -First 1
$LatestVersion.Version


#can use -latest when actually using

# Office Selection
$officeselection = @(
    'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Office/NL-NL_OfficeClientEdition_64.ps1', `
        'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Office/NL-NL_OfficeClientEdition_32.ps1', `
        'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Office/NL-NL_OfficeClientEdition_Visio_32.ps1', `
        'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Office/en-US_OfficeClientEdition_32.ps1'
)
$Office = $officeselection | Out-GridView -Title 'Office Selection' -PassThru

# Languagepack Selection
$languagepackselection = @(
    'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Languagepack/Default.ps1', `
        'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Languagepack/NL_Win10.ps1'
)
$Languagepack = $languagepackselection | Out-GridView -Title 'Languagepack Selection' -PassThru

# Teams Selection
$teamsselection = @(
    'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Teams/installTeams_EN.ps1', `
        'https://raw.githubusercontent.com/knowledgebaseit/Azure-Image-Builder/main/Customize/Teams/installTeams_NL.ps1'
)
$Teams = $teamsselection | Out-GridView -Title 'Teams Selection' -PassThru


#Registering the Resource Provider for AIB
$resourceproviderfeature = Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview
If ($resourceproviderfeature.RegistrationState -ne 'Registered') {
    Write-Host 'Resource Provider not yet Registered! Registering now...'
    Register-AzResourceProvider -ProviderNamespace Microsoft.VirtualMachineImages
    Write-Host 'Waiting loop until Resource Provider is Registered...'
    Do {
        Start-Sleep -Seconds 5
    }
    While ((Get-AzResourceProvider -ProviderNamespace Microsoft.VirtualMachineImages).RegistrationState -ne 'Registered')

    Write-Host 'Registering Feature now...'
    Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview
    Do {
        Start-Sleep -Seconds 5
    }
    While ((Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview).RegistrationState -ne 'Registered')
}
Write-Host 'Resource Provider OK.'

Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage | Where-Object RegistrationState -NE Registered | Register-AzResourceProvider

# Get existing context
$currentAzContext = Get-AzContext
# Get subscription Id
$subscriptionID = $currentAzContext.Subscription.Id

# Create resource group
if ($null -eq (Get-AzResourceGroup -Name $imageResourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $imageResourceGroup -Location $location
} else {
    Write-Host "ResourceGroup $imageResourceGroup already exists"
}

# Setup role def names, these need to be unique
$dateVariable = Get-Date -Format 'yyyyMMddHHmm'
$imageRoleDefName = 'Azure Image Builder Image Def' + $dateVariable
$idenityName = 'aibIdentity' + $dateVariable

# Create identity
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName -Location $location

$idenityNameResourceId = $(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName).Id
$idenityNamePrincipalId = $(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName).PrincipalId

$aibRoleImageCreationUrl = 'https://raw.githubusercontent.com/denniswesterman/Azure-Virtual-Desktop/main/aibRoleImageCreation.json'
$aibRoleImageCreationPath = 'aibRoleImageCreation.json'

# Download config
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing

((Get-Content -Path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>', $subscriptionID) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -Path $aibRoleImageCreationPath -Raw) -replace '<imagergName>', $imageResourceGroup) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -Path $aibRoleImageCreationPath -Raw) -replace '<sigrgName>', $SIGResourceGroup) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -Path $aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath

# Create role definition
New-AzRoleDefinition -InputFile ./aibRoleImageCreation.json

# Grant role definition to image builder service principal
New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

# Create gallery SIG ResourceGroup
if ($null -eq (Get-AzResourceGroup -Name $SIGResourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $SIGResourceGroup -Location $location
} else {
    Write-Host "ResourceGroup $SIGResourceGroup already exists"
}

New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$SIGResourceGroup"


# Create gallery
if ($null -eq (Get-AzGallery -GalleryName $sigGalleryName -ResourceGroupName $SIGResourceGroup -ErrorAction SilentlyContinue)) {
    New-AzGallery -ResourceGroupName $SIGResourceGroup -GalleryName $sigGalleryName -Location $location
} else {
    Write-Host "Gallery $sigGalleryName already exists"
}

# Create gallery definition
if ($null -eq (Get-AzGalleryImageDefinition -GalleryName $sigGalleryName -ResourceGroupName $SIGResourceGroup -Name $imageDefName -ErrorAction SilentlyContinue)) {
    New-AzGalleryImageDefinition -ResourceGroupName $SIGResourceGroup -GalleryName $sigGalleryName -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher 'Knowledgebase' -Offer 'Windows' -Sku '10avd'
} else {
    Write-Host "Gallery $imageDefName already exists"
}

#Download template and configure
$templateUrl = 'https://raw.githubusercontent.com/denniswesterman/Azure-Virtual-Desktop/main/JSON.json'
$templateFilePath = 'armTemplateAVD.json'

Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

((Get-Content -Path $templateFilePath -Raw) -replace '<subscriptionID>', $subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<region>', $location) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<runOutputName>', $runOutputName) | Set-Content -Path $templateFilePath

((Get-Content -Path $templateFilePath -Raw) -replace '<publisher>', $Publisher.PublisherName) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<offer>', $Offer.offer) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<sku>', $Skus.Skus) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<version>', $LatestVersion.Version) | Set-Content -Path $templateFilePath

((Get-Content -Path $templateFilePath -Raw) -replace '<office>', $Office) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<languagepack>', $Languagepack) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<teams>', $Teams) | Set-Content -Path $templateFilePath

((Get-Content -Path $templateFilePath -Raw) -replace '<sigrgName>', $SIGResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<imageDefName>', $imageDefName) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<imageversion>', $imageversion) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<sharedImageGalName>', $sigGalleryName) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<region1>', $location) | Set-Content -Path $templateFilePath
((Get-Content -Path $templateFilePath -Raw) -replace '<imgBuilderId>', $idenityNameResourceId) | Set-Content -Path $templateFilePath

New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -api-version '2019-05-01-preview' -imageTemplateName $imageTemplateName -svclocation $location

# Build the image
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait

#Get starting time
$StartTime = $(Get-Date)
Clear-Host
# Get Status of the Image Build and Query
do {
    $status = (Get-AzResource -ResourceGroupName $imageResourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -Name $imageTemplateName).Properties.lastRunStatus
    $elapsedTime = $(Get-Date) - $StartTime
    $totalTime = '{0:HH:mm:ss}' -f ([datetime]$elapsedTime.Ticks)
    $totalTime
    $status.runSubState
    Start-Sleep -Seconds 15
} while ($status.runState -eq 'Running')

# Delete the role assignment from SIG
Write-Host "Remove RoleAssignment from $sigGalleryName"
Remove-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$sigGalleryName"

# Remove the Image Template
Remove-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName

# Remove the Image Template ResourceGroup
Write-Host "Remove ResourceGroup $imageResourceGroup"
Remove-AzResourceGroup -Name $imageResourceGroup -Force
