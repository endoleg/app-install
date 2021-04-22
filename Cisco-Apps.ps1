#Neueste Version des Cisco Jabber VDI Agent mit Powershell herunterladen
write-verbose -Message "Download CiscoJVDIAgentSetup.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/jabber/jabber-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/jabbervdiwindows\/\d*\/CiscoJVDIAgentSetup.msi"
write-verbose -Message "------------------------------" -Verbose
write-verbose -Message "Available versions" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "------------------------------" -Verbose
$appMSI = "c:\Windows\Temp\CiscoJVDIAgentSetup.msi"
write-verbose -Message "Download latest CiscoJVDIAgentSetup.msi to $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appMSI

#########################################################################

#Neueste Version der Cisco Jabber Application mit Powershell herunterladen
write-verbose -Message "Download CiscoJabberSetup.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/jabber/jabber-vdi.html") -SessionVariable websession
#$regexURL = "https\:\/\/binaries\.webex\.com\/jabbervdiwindows\/\d*\/CiscoJVDIAgentSetup.msi"
$regexURL = "https\:\/\/binaries\.webex\.com\/static-content-pipeline\/jabber-upgrade\/production\/jabberdesktop\/apps\/windows\/public\/\d*.*.*.*\/CiscoJabberSetup.msi"
write-verbose -Message "------------------------------" -Verbose
write-verbose -Message "Verfuegbare Versionen" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "------------------------------" -Verbose
$appMSI = "c:\Windows\Temp\CiscoJabberSetup.msi"
write-verbose -Message "Download der neuesten CiscoJabberSetup.msi nach $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appMSI

#########################################################################

#Neueste Version des Cisco Jabber VDI Clients (x64) mit Powershell herunterladen
write-verbose -Message "Download CiscoJVDIClientSetup-x86_64.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/jabber/jabber-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/jabbervdiwindows\/\d*\/CiscoJVDIClientSetup-x86_64.msi"
write-verbose -Message "------------------------------" -Verbose
write-verbose -Message "Verfuegbare Versionen" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "------------------------------" -Verbose
$appMSI = "c:\Windows\Temp\CiscoJVDIClientSetup-x86_64.msi"
write-verbose -Message "Download der neuesten CiscoJVDIClientSetup-x86_64.msi nach $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appMSI

#########################################################################

#Neueste Version des Webex Teams VDI HVD Installers (x64) mit Powershell herunterladen
# Beispiel-URL: https://binaries.webex.com/vdi-hvd-aws-gold/20210122084730/Webex.msi
# oder https://binaries.webex.com/WebexTeamsDesktop-Windows-Gold/Webex.msi
write-verbose -Message "Download Webex.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/teams-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/vdi-hvd-aws-gold\/\d*\/Webex.msi"
write-verbose -Message "------------------------------" -Verbose
write-verbose -Message "Verfuegbare Versionen" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "------------------------------" -Verbose
$appMSI = "c:\Windows\Temp\Webex.msi"
write-verbose -Message "Download der neuesten Webex.msi nach $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appMSI

#########################################################################

#Neueste Version des Webex Teams VDI Desktop Plugin (x64) mit Powershell herunterladen
# Beispiel-URL: https://binaries.webex.com/WebexTeamsDesktop-Windows-VDI-gold-Production/20210409083713/WebexVDIPlugin.msi
write-verbose -Message "Download WebexVDIPlugin.msi" -Verbose
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ("https://www.webex.com/downloads/teams-vdi.html") -SessionVariable websession
$regexURL = "https\:\/\/binaries\.webex\.com\/WebexTeamsDesktop-Windows-VDI-gold-Production\/\d*\/WebexVDIPlugin.msi"
write-verbose -Message "------------------------------" -Verbose
write-verbose -Message "Verfuegbare Versionen" -Verbose
$webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value }
write-verbose -Message "------------------------------" -Verbose
$appMSI = "c:\Windows\Temp\WebexVDIPlugin.msi"
write-verbose -Message "Download der neuesten WebexVDIPlugin.msi nach $appMSI" -Verbose
$appURL = $webRequest.RawContent | Select-String -Pattern $regexURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
Invoke-WebRequest -UseBasicParsing -Uri $appURL -OutFile $appMSI
