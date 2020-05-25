<#   
.DESCRIPTION
    Adds the Microsoft Web Activities Google Chrome extension to the forced install list.
    Can be used for forcing installaiton of any Google Chrome extension.
    Takes existing extensions into account which might be added by other means, such as GPO and MDM.
    Assuming a maximum of possible installed extensions never exceeds a count of 20 - this can be changed as well. (who has more than 20 forced extensions added to Chrome? :-D)
 
.NOTES
    Filename: Install-GoogleChromeExtensions
    Version: 1.0
    Author: Martin Bengtsson
    Blog: www.imab.dk
    Twitter: @mwbengtsson
    
#>
 
# Function to enumerate registry values
Function Get-RegistryValues {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
 
    Push-Location
    Set-Location -Path $Path
    Get-Item . | Select-Object -ExpandProperty property | ForEach-Object {
        New-Object psobject -Property @{“Property”=$_;“Value” = (Get-ItemProperty -Path . -Name $_).$_}
    }
    Pop-Location
} 
 
# Registry path for the ExtensionInstallForcelist
$RegistryPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
$KeyType = "String"
 
# the-great-suspender
$ExtensionID = "klbibkeccnjlkjkiokjodocebajanakg;https://clients2.google.com/service/update2/crx"

# simple-vimeo-downloader
# $ExtensionID = "mffmjlddchdccijipncbjhoabgmphjfb;https://clients2.google.com/service/update2/crx"
# https-everywhere
# $ExtensionID = "gcbommkclmclpchllfjekcdonpmejbdp;https://clients2.google.com/service/update2/crx"
# uBlock Origin 
# $ExtensionID = "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
# +Roam
# $ExtensionID = "ekdmipoabmcjmlonhcdoijilfdoomjbm;https://clients2.google.com/service/update2/crx"
# Just Read
# $ExtensionID = "dgmanlpmmkibanfdgjocnabmcaclkmod;https://clients2.google.com/service/update2/crx"
# Momentum
# $ExtensionID = "laookkfknpbbblfpciffpaejjkokdgca;https://clients2.google.com/service/update2/crx"

 
# Registry path does not exist. Creating the path
if (-not(Test-Path -Path $RegistryPath)) {
    Write-Host -ForegroundColor Red "Registry patch on $RegistryPath does not exist - trying to create it"
    try {
        New-Item -Path $RegistryPath -Force
    }
    catch {
        Write-Host -ForegroundColor Red "Failed to create registry path"
    }
}
 
# Loop through the existing values and properties in the registry
$InstalledExtensionsProperties = Get-RegistryValues -Path $RegistryPath | Select-Object Property
$InstalledExtensions = Get-RegistryValues -Path $RegistryPath | Select-Object Value
 
# Assuming that the list of forced extensions will never exceed a count of 20
$Values = 1..20
 
# If no registry key properties found, continue do something. No need to do something complicated, if no extensions exists already.
if ($InstalledExtensionsProperties -ne $null) { 
    
    # Finding next available number for use in KeyName
    $NextNumber = Compare-Object $InstalledExtensionsProperties.Property $Values | Select-Object -First 1
    $KeyName = $NextNumber.InputObject
    
    # If the extension is not installed already, install it
    if ($InstalledExtensions -match $ExtensionID) {
        Write-Host -ForegroundColor Green "$ExtensionID is already added. Doing nothing :-)"
        
    }
    # else try to add the extension please
    else {
        Write-Host -ForegroundColor Red "The extenion $ExtensionID is not found. Adding it."
        try {
            New-ItemProperty -Path $RegistryPath -Name $KeyName -PropertyType $KeyType -Value $ExtensionID
        }
        catch {
            Write-Host -ForegroundColor Red "Failed to create registry key"   
        }    
    }
}
# Else just add the extension as the first extension
else {
    
    Write-Host -ForegroundColor Red "No extensions already added. Adding the extensions as the first one"
    try {
        New-ItemProperty -Path $RegistryPath -Name 1 -PropertyType $KeyType -Value $ExtensionID
    }
    catch {
        Write-Host -ForegroundColor Red "Failed to create registry key"   
    }
}




<#
#### ========================
#### Install uBlock Plugin
#### ------------------------
function Remove-ChromeuBlock
{
	Remove-ItemProperty -Force -Path "HKCU:\Software\Google\Chrome\PreferenceMACs\Default\extensions.settings\" -Name "cjpalhdlnbpafiamejdnhcphjbkeiagm"
	#### Remove-ItemProperty -Force -Path "HKLM:\Software\Policies\Google\Chrome\" -Name "ExtensionInstallForcelist"
	Remove-Item -Force -Path "HKLM:\SOFTWARE\Wow6432node\Google\Chrome\Extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm*" -Recurse
}
function Install-ChromeuBlock
{
	New-Item -Force -Path "HKLM:\SOFTWARE\Wow6432node\Google\Chrome\Extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm"
	New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Wow6432node\Google\Chrome\Extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\" -Name "update_url" -Value "https://clients2.google.com/service/update2/crx"
	New-ItemProperty -Force -Path "HKLM:\SOFTWARE\Wow6432node\Google\Chrome\Extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm\" -Name "uBlock-Forced" -Value "oblockorigin-chrome"
}
Install-ChromeuBlock
#### ========================
#>
