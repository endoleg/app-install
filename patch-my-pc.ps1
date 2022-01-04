#thanks to haavarstein for the idea
Clear-Host

Write-Verbose "Setting Arguments" -Verbose
$ProgressPreference = 'SilentlyContinue'
#$Icons = "C:\Icons"
$Path = "C:\Windows\Temp"
$Template = "$Path\AppV_Template.appvt"
$TemplateURL = "https://raw.githubusercontent.com/haavarstein/Applications/master/AppV_Template.appvt"
$XML = "$Path\Applications.xml"
$XMLURL = "https://raw.githubusercontent.com/haavarstein/Applications/master/Applications.xml"
$PatchMyPC = "$Path\Definitions.xml"
$PatchMyPCURL = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
$TeamsWebHook = "XXXXXXXXXXXXX"

# Set Timeout
[System.Net.ServicePointManager]::MaxServicePointIdleTime = 5000000

Write-Verbose "Installing Required PowerShell Modules" -Verbose
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
if (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget")) { Install-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies }
if (!(Get-Module -ListAvailable -Name Evergreen)) { Install-Module Evergreen -Force | Import-Module Evergreen }
#if (!(Get-Module -ListAvailable -Name IntuneWin32App)) {Install-Module IntuneWin32App -Force | Import-Module IntuneWin32App}
#Install-Module powershell-yaml
If (!(Test-Path -Path $Path)) {New-Item -ItemType directory -Path $Path | Out-Null}
Invoke-WebRequest -UseBasicParsing -Uri $TemplateURL -OutFile $Template
Invoke-WebRequest -UseBasicParsing -Uri $XMLURL -OutFile $XML
Invoke-WebRequest -UseBasicParsing -Uri $PatchMyPCURL -OutFile $PatchMyPC

$MyConfigFileloc = ("$XML")
[xml]$MyConfigFile = (Get-Content $MyConfigFileLoc)

$MyDefinitionFileloc = ("$PathMyPC")
[xml]$MyDefinitionFile = (Get-Content $Path\Definitions.xml)

foreach ($App in $MyConfigFile.Applications.ChildNodes)
{

#Connect-MSIntuneGraph -TenantID $TentantID | Out-Null

$Product = $App.Product
write-verbose "Product $Product " -verbose
$Vendor = $App.Vendor
write-verbose "Vendor $Vendor" -verbose
$Architecture = $App.Architecture
write-verbose "Architecture $Architecture" -verbose
$DisplayName = $App.DisplayName
write-verbose "DisplayName $DisplayName" -verbose
$PackageName = "$Product"
write-verbose "PackageName $PackageName " -verbose
$Evergreen = $App.Evergreen
write-verbose "Evergreen $Evergreen" -verbose
$Version = $MyDefinitionFile.Data.ARPData.$("$Product" + "Ver")
write-verbose "Version $Version" -verbose
$URL = $MyDefinitionFile.Data.ARPData.$("$Product" + "Download")
write-verbose "URL $URL " -verbose
$InstallerType = $App.Installer
write-verbose "InstallerType $InstallerType " -verbose
$UnattendedArgs = $App.Install
write-verbose "UnattendedArgs $UnattendedArgs" -verbose
$UnattendedArgs = $UnattendedArgs.Replace("/i ","")
write-verbose "UnattendedArgs $UnattendedArgs " -verbose
$LogApp = "${env:SystemRoot}" + "\Temp\$Product $Version.log"
write-verbose "LogApp $LogApp" -verbose
write-output "-----------------------------------------------------------------"
}
