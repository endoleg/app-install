Start-Transcript -Path "C:\daten\endethor\Desktop\evergreen-softwarevergleich-json-xml.txt" -Force

#https://raw.githubusercontent.com/Deyda/Evergreen-Script/main/Evergreen.ps1
#https://github.com/microsoft/winget-pkgs/tree/master/manifests/
#https://github.com/dangough/Nevergreen
#https://github.com/JonathanPitre/Apps

<#
Find-EvergreenApp -name adoptium
#>

#Install-Module -Name Nevergreen
#Update-Module -Name Nevergreen

#Install-Module -Name Evergreen
#Update-Module -Name Nevergreen

#Install-Module VcRedist -Force

clear

Write-Verbose -Message "Function Get-InstalledSoftware" -Verbose

Function Get-InstalledSoftware{
    Param([String[]]$Computers)
    If (!$Computers) {$Computers = $ENV:ComputerName}
    $Base = New-Object PSObject;
    $Base | Add-Member Noteproperty ComputerName -Value $Null;
    $Base | Add-Member Noteproperty Name -Value $Null;
    $Base | Add-Member Noteproperty Publisher -Value $Null;
    $Base | Add-Member Noteproperty InstallDate -Value $Null;
    $Base | Add-Member Noteproperty EstimatedSize -Value $Null;
    $Base | Add-Member Noteproperty Version -Value $Null;
    $Base | Add-Member Noteproperty Wow6432Node -Value $Null;
    $Results =  New-Object System.Collections.Generic.List[System.Object];
 
    ForEach ($ComputerName in $Computers){
        $Registry = $Null;
        Try{$Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$ComputerName);}
        Catch{Write-Host -ForegroundColor Red "$($_.Exception.Message)";}
 
        If ($Registry){
            $UninstallKeys = $Null;
            $SubKey = $Null;
            $UninstallKeys = $Registry.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Uninstall",$False);
            $UninstallKeys.GetSubKeyNames()|%{
                $SubKey = $UninstallKeys.OpenSubKey($_,$False);
                $DisplayName = $SubKey.GetValue("DisplayName");
                If ($DisplayName.Length -gt 0){
                    $Entry = $Base | Select-Object *
                    $Entry.ComputerName = $ComputerName;
                    $Entry.Name = $DisplayName.Trim();
                    $Entry.Publisher = $SubKey.GetValue("Publisher");
                    [ref]$ParsedInstallDate = Get-Date
                    If ([DateTime]::TryParseExact($SubKey.GetValue("InstallDate"),"yyyyMMdd",$Null,[System.Globalization.DateTimeStyles]::None,$ParsedInstallDate)){
                    $Entry.InstallDate = $ParsedInstallDate.Value
                    }
                    $Entry.EstimatedSize = [Math]::Round($SubKey.GetValue("EstimatedSize")/1KB,1);
                    $Entry.Version = $SubKey.GetValue("DisplayVersion");
                    [Void]$Results.Add($Entry);
                }
            }
 
                If ([IntPtr]::Size -eq 8){
                $UninstallKeysWow6432Node = $Null;
                $SubKeyWow6432Node = $Null;
                $UninstallKeysWow6432Node = $Registry.OpenSubKey("Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",$False);
                    If ($UninstallKeysWow6432Node) {
                        $UninstallKeysWow6432Node.GetSubKeyNames()|%{
                        $SubKeyWow6432Node = $UninstallKeysWow6432Node.OpenSubKey($_,$False);
                        $DisplayName = $SubKeyWow6432Node.GetValue("DisplayName");
                        If ($DisplayName.Length -gt 0){
                            $Entry = $Base | Select-Object *
                            $Entry.ComputerName = $ComputerName;
                            $Entry.Name = $DisplayName.Trim();
                            $Entry.Publisher = $SubKeyWow6432Node.GetValue("Publisher");
                            [ref]$ParsedInstallDate = Get-Date
                            If ([DateTime]::TryParseExact($SubKeyWow6432Node.GetValue("InstallDate"),"yyyyMMdd",$Null,[System.Globalization.DateTimeStyles]::None,$ParsedInstallDate)){
                            $Entry.InstallDate = $ParsedInstallDate.Value
                            }
                            $Entry.EstimatedSize = [Math]::Round($SubKeyWow6432Node.GetValue("EstimatedSize")/1KB,1);
                            $Entry.Version = $SubKeyWow6432Node.GetValue("DisplayVersion");
                            $Entry.Wow6432Node = $True;
                            [Void]$Results.Add($Entry);
                            }
                        }
                    }
                }
        }
    }
    $Results

}

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "######   SVACXXD601-Check (dauert ca. 2 Min.)   ##########" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
#$svacxxd601software=(Get-InstalledSoftware -computers svacxxd601)

$svacxxd601software=(Get-Content C:\daten\endethor\desktop\601-software.json | ConvertFrom-Json)
#$svacxxd601softwareIMPORT=(Get-Content C:\daten\endethor\desktop\601-software.json | ConvertFrom-Json)
#$svacxxd601softwareIMPORT
#$svacxxd601software.name

Write-Verbose -Message "" -Verbose

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "########## Verfuegbare Online-Versionen ##################" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "" -Verbose
Write-Verbose -Message "" -Verbose

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "MicrosoftEdge latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp MicrosoftEdge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).Version
(Get-EvergreenApp MicrosoftEdge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Edge" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -eq "Microsoft Edge" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "VideoLanVlcPlayer latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Type -eq "MSI" -and $_.Platform -eq "Windows" }).Version
(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Type -eq "MSI" -and $_.Platform -eq "Windows" }).URI
#(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).Version
#(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer VLC" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*VLC*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "notepadplusplus latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp notepadplusplus | Where-Object { $_.Type -eq "exe" -and $_.Platform -eq "Windows" }).Version
(Get-EvergreenApp notepadplusplus | Where-Object { $_.Type -eq "exe" -and $_.Platform -eq "Windows" }).URI
#(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).Version
#(Get-EvergreenApp VideoLanVlcPlayer | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" -and $_.Platform -eq "Windows" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Notepad" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*notepa*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "7zip latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp 7zip | Where-Object { $_.Type -eq "MSI" }).Version
(Get-EvergreenApp 7zip | Where-Object { $_.Type -eq "MSI" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer 7-zip" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*7-z*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "CitrixWorkspaceApp Current latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp -Name CitrixWorkspaceApp -WarningAction:SilentlyContinue | Where-Object { $_.Title -like "*Workspace*" -and $_.Stream -like "Current" }).Version
(Get-EvergreenApp -Name CitrixWorkspaceApp -WarningAction:SilentlyContinue | Where-Object { $_.Title -like "*Workspace*" -and $_.Stream -like "Current" }).URI
#Write-Verbose -Message "CitrixWorkspaceApp LTSR latest" -Verbose
#(Get-EvergreenApp -Name CitrixWorkspaceApp -WarningAction:SilentlyContinue | Where-Object { $_.Title -like "*Workspace*" -and $_.Stream -like "LTSR" }).Version
#(Get-EvergreenApp -Name CitrixWorkspaceApp -WarningAction:SilentlyContinue | Where-Object { $_.Title -like "*Workspace*" -and $_.Stream -like "LTSR" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Citrix Workspace" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Citrix Workspace(*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "CiscoWebex latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Get-NevergreenApp -Name CiscoWebex #| Where-Object { $_.Architecture -eq "$CiscoWebexTeamsArchitectureClear" -and $_.Type -eq "Msi" }
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Cisco Webex Productivity Tools" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Productivity Tools*" }).Version

#Neueste Version der Cisco Webex Meetings-Desktop-App mit Powershell herunterladen
# Beispiel-URL: https://akamaicdn.webex.com/client/WBXclient-41.4.5-14/webexapp.msi
# oder https://akamaicdn.webex.com/client/webexapp.msi
write-verbose -Message "webexapp.msi - Cisco Webex Meetings-Desktop-App latest" -Verbose
$appURL = "https://akamaicdn.webex.com/client/webexapp.msi"
$appURL
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Cisco Webex Meeting" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Cisco Webex Meeting*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "AdobeAcrobatReaderDC latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
#Get-EvergreenApp -Name AdobeAcrobatReaderDC #| Where-Object {$_.Architecture -eq "$AdobeArchitectureClear" -and $_.Language -eq "$AdobeLanguageClear"}
(Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object {$_.Language -eq "German"}).Version
(Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object {$_.Language -eq "German"}).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Adobe Acrobat Reader" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Adobe Acrobat Reader*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "VMwareTools latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
#Get-EvergreenApp -Name VMwareTools #| Where-Object { $_.Architecture -eq "$VMWareToolsArchitectureClear" }
#(Get-EvergreenApp -Name VMwareTools).Version
(Get-EvergreenApp -Name VMwareTools).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer VMware Tools" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*VMware T*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "AdoptiumTemurin8 JAVA JRE latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(Get-EvergreenApp AdoptiumTemurin8 | Where-Object { $_.Architecture -eq "x86" -and $_.Type -eq "jre" }).Version
(Get-EvergreenApp AdoptiumTemurin8 | Where-Object { $_.Architecture -eq "x86" -and $_.Type -eq "jre" }).URI
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Java 8" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Java 8*" }).Version
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Adoptium" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Adoptium*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
write-Verbose -Message "VcList C++ latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Get-VcList | Where-Object { $_.Architecture -eq "$MSVisualCPlusPlusRuntimeArchitectureClear" -and $_.Release -eq "$MSVisualCPlusPlusRuntimeReleaseClear"}
Write-Verbose -Message "--------------svacxxd601 Versionsnummer VcList C++ " -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*c++*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "PDF24Creator latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Get-evergreenApp -name GeekSoftwarePDF24Creator | Where-Object { $_.Type -eq "Msi"}
Write-Verbose -Message "--------------svacxxd601 Versionsnummer PDF24Creator " -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*PDF24*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "Controlup Agent latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
get-EvergreenApp -name ControlupAgent
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Controlup Agent" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Controlup*" }).Version


#Write-Verbose -Message "CiscoWebexVDI" -Verbose
#Get-CiscoWebexVDI | Where-Object { $_.Architecture -eq "$CiscoWebexTeamsArchitectureClear" }

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "PDF-XChange latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "latest: https://pdf-xchange.de/DL/pdf-xchange.htm" -Verbose
Write-Verbose -Message "latest: https://pdf-xchange.de/DL/tracker9/pro-msi64-tracker.php" -Verbose
Write-Verbose -Message "latest: https://pdf-xchange.de/DL/tracker9/pro-msi32-tracker.php" -Verbose
Write-Verbose -Message "--------------svacxxd601 Versionsnummer PDF-XChange" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*PDF-XC*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "Webex latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
#https://github.com/endoleg/app-install/blob/master/Cisco-Apps.ps1
#Neueste Version des Webex Teams VDI HVD Installers (x64) mit Powershell herunterladen
# Beispiel-URL: https://binaries.webex.com/vdi-hvd-aws-gold/20210122084730/Webex.msi
# oder https://binaries.webex.com/WebexTeamsDesktop-Windows-Gold/Webex.msi
write-verbose -Message "Webex.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/teams-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/vdi-hvd-aws-gold\/\d*\/Webex.msi"
write-verbose -Message "Verfuegbare Versionen" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "Download der neuesten Webex.msi nach $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$appURL
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Webex" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -eq "Webex" }).Version


Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "Jabber latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/jabber/jabber-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/jabberclientwindows\d*.*.*.*\/CiscoJabberSetup.msi"
#https://binaries.webex.com/jabberclientwindows/20210603051133/CiscoJabberSetup.msi
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$appURL 
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Cisco Jabber" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -eq "Cisco Jabber" }).Version

Write-Verbose -Message "##########################################################" -Verbose
write-verbose -Message "CiscoJVDIAgentSetup.msi" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/jabber/jabber-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/jabbervdiwindows\/\d*\/CiscoJVDIAgentSetup.msi"
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$appURL
Write-Verbose -Message "--------------svacxxd601 Versionsnummer Cisco JVDI Agent" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -eq "Cisco JVDI Agent" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "edocprintpro latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "latest: https://www.pdfprinter.at" -Verbose
Write-Verbose -Message "--------------svacxxd601 Versionsnummer edocprint" -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*edoc*" }).Version

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "MicrosoftVisualStudioCode latest" -Verbose
Write-Verbose -Message "##########################################################" -Verbose
(winget show Microsoft.VisualStudioCode | where {$_ -match '\s+Download URL:'}) -replace '\s+Download URL: ',''
#(get-EvergreenApp MicrosoftVisualStudioCode | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Platform -eq "win32-x64" }).Version
#(get-EvergreenApp MicrosoftVisualStudioCode | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Platform -eq "win32-x64" }).URI
#Get-EvergreenApp -Name MicrosoftVisualStudioCode | Where-Object { $_.Architecture -eq "$MSVisualStudioCodeArchitectureClear" -and $_.Channel -eq "$MSVisualStudioCodeChannelClear" -and $_.Platform -eq 
Write-Verbose -Message "--------------svacxxd601 Versionsnummer MicrosoftVisualStudioCode " -Verbose
($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Visual Studio Code*" }).Version

#$svacxxd601software | ConvertTo-Json -Depth 5 | out-file C:\daten\endethor\desktop\601-software.json -Force

Write-Verbose -Message "##########################################################" -Verbose
Write-Verbose -Message "##########################################################" -Verbose

notepad.exe "C:\daten\endethor\Desktop\evergreen-softwarevergleich-json-xml.txt"


stop-Transcript





#Write-Verbose "##############################################################################################################################" -Verbose    
#Write-Verbose "##############################################################################################################################" -Verbose    
#Write-Verbose "##############################################################################################################################" -Verbose    

#Write-Verbose -Message "Putty" -Verbose
#Get-Putty | Where-Object { $_.Architecture -eq "$PuTTYArchitectureClear" -and $_.Channel -eq "$PuttyChannelClear"}

#Write-Verbose -Message "##########################################################" -Verbose
#Write-Verbose -Message "RDAnalyzer" -Verbose
#Get-EvergreenApp -Name RDAnalyzer | Where-Object {$_.Type -eq "exe"}


#Write-Verbose -Message "TreeSizeFree" -Verbose
#(get-EvergreenApp JamTreeSizeFree).Version
#(get-EvergreenApp JamTreeSizeFree).URI

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer Cryptshare" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Cryptshare*" }).Version

#Write-Verbose -Message "Microsoft.NET" -Verbose
#(get-EvergreenApp Microsoft.NET).Version
#(get-EvergreenApp Microsoft.NET).URI

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer MS Silverlight" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Silverlight*" }).Version
#Write-Verbose -Message "--------------MS Silverlight auf ninite.com" -Verbose

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer SAP GUI" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*SAP GUI*" }).Version

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer *SAP Busi*" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*SAP Business Cl*" }).Version

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer SAP SSO" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*SAP Sec*" }).Version

#Write-Verbose -Message "--------------svacxxd601 Versionsnummer Citrix Workspace Environment Management Agent" -Verbose
#($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Citrix Workspace Environment Management Agent*" -and $_.InstallDate -notlike $null }).Version
#(Get-EvergreenApp -Name CitrixVirtualAppsDesktopsFeed | Where-Object {$_.Title -like "Workspace Environment Management 21*"} | Sort-Object Version -Descending | Select-Object -First 1)

#$VersionsnummerCryptshare = ($svacxxd601software | Where-Object -FilterScript {$_.Name -like "*Cryptshare*" }).Version
#Write-Verbose -Message "--------------VersionsnummerCryptsharer $VersionsnummerCryptshare" -Verbose

<#
Write-Verbose "##############################################################################################################################" -Verbose    
Write-Verbose "##############################################################################################################################" -Verbose    
Write-Verbose "##############################################################################################################################" -Verbose    

Write-Verbose "--------------LOKAL: Get-InstalledSoftware und einige Versionsnummern ... ----------------"-Verbose    
$Softwareuebersicht = Get-InstalledSoftware 
$VersionsnummerJabber = ($Softwareuebersicht | Where-Object -FilterScript {$_.Name -eq "Cisco Jabber" }).Version
Write-Verbose -Message "--------------LOKAL: VersionsnummerJabber $VersionsnummerJabber" -Verbose
$VersionsnummerJVDI = ($Softwareuebersicht | Where-Object -FilterScript {$_.Name -like "*JVDI*" }).Version
Write-Verbose -Message "--------------LOKAL: VersionsnummerJVDI $VersionsnummerJVDI" -Verbose
$VersionsnummerWebexVDI = ($Softwareuebersicht | Where-Object -FilterScript {$_.Name -like "*Webex Meetings Virtual*" }).Version
Write-Verbose -Message "--------------LOKAL: VersionsnummerWebexVDI $VersionsnummerWebexVDI" -Verbose


Write-Verbose "##############################################################################################################################" -Verbose    
Write-Verbose "##############################################################################################################################" -Verbose    
Write-Verbose "##############################################################################################################################" -Verbose    

#>



#Write-Verbose "--------------$env:COMPUTERNAME: svacxxd601software und einige Versionsnummern ... ----------------"-Verbose    
#$svacxxd601software=(Get-InstalledSoftware -computers svacxxd601)
