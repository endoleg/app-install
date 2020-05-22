<# 
###################################################################################################################################################################################
# Dieses Skript importiert Altdaten nach einer Profilerneuerung
###################################################################################################################################################################################

# Der 1. Teil des Skriptes holt sich Registry-Einstellungen des angemeldeten Users 
  __
 /_ |
  | |
  | |
  | |
  |_|


# Was wird mitgenommen/importiert?
# Registry
# Registryeintrag fuer Word-Dateispeicherort Dokumente (Standardablage), Word-Autostart-Eintrag, Word-Arbeitsgruppenvorlagen-Eintrag, Word-Benutzervorlagen, Outlook-Profil

# Der 2. Teil des Skriptes holt sich einige Dateien des angemeldeten Users 
  ___
 |__ \
    ) |
   / /
  / /_
 |____|


# von $backpfadNEU2016
# und importiert folgende Dateien in das angemeldete Profil XD-Server2016-und-Office2016-Profil:


###################################################################################################################################################################################

# Welche Dateien werden mitgenommen/importiert?
#
# Document Building Blocks --------> Office-Schnellbausteine / Textbausteine
# Mozilla    ------> Mozilla Firefox Profil
# Office     ------> Autokorrektur deutsch acl
# Office-local     ------> Outlook-Dateien2 (WEF appdata local)
# Outlook    ------> Outlook-Dateien
# Proof      ------> Benutzerwoerterbuecher (dic) proof
# PDF24      ------> PDF24-Dateien
# Signatures ------> Outlook-Signaturen
# SAP        ------> SAP-Dateien
# Templates  ------> normal.dot(m) Templates (auch teilweise mit Schnellbausteinen/Autotexten)
# Tracker Software    ------> PDFXchange-Einstellungen und PDFXchange-Stamps
# UProof     ------> Benutzerwoerterbuecher (dic) uproof/proof
###################################################################################################################################################################################

########################################################
# Evtl. in Zukunft sinnvoll (muss noch eingebaut werden)
########################################################
#SystemCertificates
#$source\AppData\Roaming\Microsoft\SystemCertificates
#CredentialManager
#$source\AppData\Roaming\Microsoft\Credentials
#AppData\Local\Microsoft\Credentials
#CryptoKeys
$source\AppData\Roaming\Microsoft\Crypto
#dpapiKeys
#$source\AppData\Roaming\Microsoft\Protect 
$chromeDirectory = "{0:N2} GB" -f ((Get-ChildItem "c:\users\endethor\AppData\Local\Google\Chrome\User Data\Default" | Measure-Object Length -s).sum / 1Gb)
write-verbose -message "`nInitializing Chrome Bookmarks Backup. `nThe Chrome Bookmarks are $chromeDirectory large." -verbose
#AppData\Local\Google\Chrome\User Data\Default\ "Bookmarks.bak" "Custom Dictionary.txt"
#oder
#AppData\Local\Google\Chrome\User Data\Default\
#Cookies
$source\AppData\Local\Microsoft\Windows\INetCookies
AppData\Roaming\Microsoft\Windows\Cookies 
#Adobe Signature 
$source\AppData\Roaming\Adobe\Acrobat\DC\Security
#Quick Launch
"$source\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"
#Anzeigeeinstellungen

############################
# Vielleicht irgendwann in Zukunft mal sinnvoll...
############################
#Office Quick Parts
#"$source\application data\microsoft\templates"
#Sticky Notes
#$source\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState 

#>

Start-Transcript -Path "c:\users\$env:username\Errorlog-Profil-resore.log" -Append
Write-verbose -message "" -verbose

##======================================
## Voraussetzungen / Variablen / etc
##======================================
# VerbosePreference auf Continue setzen so dass write-verbose -messages auch ohne den Zusatz "-verbose" dargestellt werden
$VerbosePreference = 'Continue'

write-verbose -message "----------  Voraussetzungen fuer AD-Abfragen (Gruppen in Gruppen) schaffen ------------" -verbose
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])}

write-verbose -message "----------  message box by calling the .Net Windows.Forms (MessageBox class) - Load the assembly -----------" -verbose
Add-Type -AssemblyName System.Windows.Forms | Out-Null

write-verbose -message "---------- Benutzername in SID umwandeln ----------" -verbose
$DOMAIN = "BG10"
$USERNAME = $env:UserName
$objUser = New-Object System.Security.Principal.NTAccount($DOMAIN, $USERNAME)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
write-verbose -message "---------- Benutzername bg10\$env:UserName ----------" -verbose
$usersid = $strSID.Value
$name = "$env:USERNAME"

$backpfadOSunabhangig="\\bg10\citrix\Config\BackupXD\office\$usersid"
$backpfadNEU2016="\\bg10\citrix\ProfileVSSBackupSID\$usersid\Win2016x64\UPM_Profile"
write-verbose -message "---------- Backup kommt von $backpfadNEU2016 ----------" -verbose
#VSS-Linktypen-Freischaltung mit #&C:\Windows\system32\fsutil behavior set SymLinkEvaluation R2R:1 R2L:1

##############################################################
# nur zur Kontrolle
<#
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Document Building Blocks\1031\16"
start "$backpfadNEU2016\AppData\Roaming\Mozilla\Firefox"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Office"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Outlook"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Proof"
start "$backpfadNEU2016\AppData\Roaming\SAP"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Signatures"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\Templates"
start "$backpfadNEU2016\AppData\Roaming\Tracker Software"
start "$backpfadNEU2016\AppData\Roaming\Microsoft\UProof"

start "$backpfadNEU2016\AppData\Local\Microsoft\Office\16.0\WEF" #Office-local
start "$backpfadNEU2016\AppData\Roaming\PDF24"
#Regbackup2016-NEU.reg

start $backpfadOSunabhangig
#>
##############################################################
##############################################################



##############################################################
write-verbose -message "----------  Gruppenmitglieder von CTX-Migration-Profilbackup-auslassen sollen das Skript direkt verlassen ----------" -verbose
##############################################################
if ($groups -contains "BG10\CTX-Migration-Profilbackup-auslassen"){
    write-verbose -message "----------Gruppenmitglied von CTX-Migration-Profilbackup-auslassen - Skript wird verlassen" -verbose
	Write-verbose -message "----------Obwohl keine Migration stattgefunden hat, wird Eintrag gesetzt mit Wert 1 - damit Autostart trotz Gruppe CTX-Migration-Profilbackup-auslassen laeuft----------------------------------" -verbose
    if(! (Test-Path -Path 'HKCU:\Software\_BGETEM_PS')) {New-Item  -Path 'HKCU:\Software\_BGETEM_PS' | Out-Null } 
    New-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' -Name 'MigServer2008-2016' -Value 1 -PropertyType DWORD -Force  | Out-Null
    start-sleep 3
    exit
}else{
    write-host "----------Kein Gruppenmitglied CTX-Migration-Profilbackup-auslassen - Skript wird weiter durchlaufen" -ForegroundColor Yellow
    write-verbose -message "----------Kein Gruppenmitglied CTX-Migration-Profilbackup-auslassen - Skript wird weiter durchlaufen" -verbose

    ##############################################################
    Write-verbose -message "----------Registryeintragpruefung HKCU:\Software\_BGETEM_PS\MigServer2008-2016 mit Wert 1 - wenn NICHT vorhanden, dann weiter in der Klammer----------------------------------" -verbose
    ##############################################################
    if( (!(Test-Path 'HKCU:\Software\_BGETEM_PS')) -or  (Get-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' | Select-Object -ExpandProperty 'MigServer2008-2016') -ne 1) 
    {
    Write-verbose -message "----------Registryeintrag noch nicht vorhanden - es geht weiter IN der Klammer - Es muss etwas getan werden!" -verbose
    Write-verbose -message "---------- RadioButton1 gedrueckt - deshalb ausfuehren einer Aktion ---------" -verbose
    Write-verbose -message "----------Ok-Klick Aufforderung fuer Anwender" -Verbose
    [System.Windows.Forms.MessageBox]::Show("Import von Profileinstellungen wird durchgefuehrt. Sie werden abgemeldet, wenn die Profil-Einrichtung fertig ist. Dauer: Maximal 1 Minute. Bitte OK klicken.")
    Write-verbose -message "----------Ok-Klick erfolgt - Import erfolgt jetzt" -Verbose

	
    #    __
    #   /_ |
    #    | |
    #    | |
    #    | |
    #    |_|
    #  

    ###########################################################################################
    ###########################################################################################
    Write-verbose -message "----------REGISTRY-Import Anfang----------------------------------" -verbose
    ###########################################################################################
    ###########################################################################################
    Write-verbose -message "----------Import der von 2016 bei Abmeldung exportierten Datei Regbackup2016-NEU.reg----------------------------------" -verbose
    ###########################################################################################

    <#
    if(Test-Path "$backpfadOSunabhangig\Regbackup2016-NEU.reg"){
    Write-verbose -message "Regbackup2016-NEU.reg ist da und wird importiert" -verbose
    regedit /s "$backpfadOSunabhangig\Regbackup2016-NEU.reg"
    }else {
    Write-verbose -message "Regbackup2016-NEU.reg ist NICHT da und wird NICHT importiert" -verbose
    Write-HOST "Regbackup2016-NEU.reg ist NICHT da und wird NICHt importiert" -ForegroundColor Red
    }
    #>

    #if(Test-Path "c:\users\$env:username\Regbackup2016-NEU.reg"){
    if(Test-Path "$backpfadNEU2016\Regbackup2016-NEU.reg"){
        Write-verbose -message "$backpfadNEU2016\Regbackup2016-NEU.reg ist da und wird importiert" -verbose
    Write-HOST "Regbackup2016-NEU.reg ist da und wird importiert" -ForegroundColor Green
    regedit /s "c:\users\$env:username\Regbackup2016-NEU.reg"
    }else {
    Write-verbose -message "$backpfadNEU2016\Regbackup2016-NEU.reg ist NICHT da und wird NICHT importiert" -verbose
    Write-HOST "$backpfadNEU2016\Regbackup2016-NEU.reg ist NICHT da und wird NICHT importiert" -ForegroundColor Red
    Write-verbose -message "Es wird versucht alternativ $backpfadOSunabhangig\Regbackup2016-NEU.reg zu importieren" -verbose
    regedit /s "$backpfadOSunabhangig\Regbackup2016-NEU.reg"
    }

    Write-verbose -message "----------REGISTRY-Import Ende----------------------------------" -verbose
    ###########################################################################################
    ###########################################################################################


    #########################################################################################################################################

    #    ___
    #   |__ \
    #      ) |
    #     / /
    #    / /_
    #   |____|
    #  
    
    ###########################################################################################
    ###########################################################################################
    Write-verbose -message "----------DATEI-IMPORT Anfang----------------------------------" -verbose
    ###########################################################################################
    ###########################################################################################

 
        ########################################################################################
        Write-verbose -message "----------Document Building Blocks - Office-Schnellbausteine / Textbausteine nach Office-Pfad transferieren----------------------------------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Document Building Blocks\1031\16"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Document Building Blocks\1031\16"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		        {
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "" -verbose
            Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.do*" | Copy-Item -Destination $DestPath -Force
			Write-verbose -message "----------Import Office-Schnellbausteine do*-Dateien von $SourcePath nach $DestPath----------------------------------" -verbose
		} 
  
		########################################################################################
		Write-verbose -message "----------Mozilla Firefox Import----------------------------------" -verbose
		########################################################################################
		if(test-path "$backpfadNEU2016\AppData\Roaming\Mozilla\Firefox"){
        $sourceordner= "$backpfadNEU2016\AppData\Roaming\Mozilla\Firefox"
        $Zielordner =  "$env:USERPROFILE\AppData\Roaming\Mozilla\Firefox"
        $Getprofil= Get-ChildItem $sourceordner
        Foreach($item in $Getprofil){
            Copy-Item "$sourceordner\$($item.name)" -Destination "$Zielordner\$($item.name)" -Force -Recurse
        }
		}

        ########################################################################################
  	    Write-verbose -message "----------Office-Autokorrektur acl deutsch ins neue Profil transferieren-----------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Office"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Office"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
            Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.acl" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Autokorrektur deutsch acl-Dateien von $SourcePath nach $DestPath" -verbose
		} 

        ########################################################################################
        Write-verbose -message "----------Office-Outlook-WEF-Dateien ins neue Profil transferieren--------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Local\Microsoft\Office\16.0\WEF"
		$DestPath = "C:\Users\$env:UserName\AppData\Local\Microsoft\Office\16.0\WEF"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
            Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "" -verbose
            Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Office-Outlook-Dateien2 von $SourcePath nach $DestPath" -Verbose
		} 

  
        ########################################################################################
        Write-verbose -message "----------Outlook - Office-Outlook-Dateien ins neue Profil transferieren---------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Outlook"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Outlook"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "" -verbose
             taskkill.exe /F /IM outlook.exe
            Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Office-Outlook-Dateien von $SourcePath nach $DestPath" -Verbose
		} 

        ########################################################################################
  	    Write-verbose -message "----------PDF24-Einstellungsdateien ins neue Profil transferieren------------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\PDF24"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\PDF24"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import PDF24-Einstellungsdateien werden transferiert von $SourcePath nach $DestPath" -Verbose
		} 


        ########################################################################################
        Write-verbose -message "----------Proof - Office-Benutzerwoerterbuecher (dic) proof ins neue Profil transferieren---------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Proof"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Proof"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Office-Benutzerwoerterbuecher (dic) proof von $SourcePath nach $DestPath" -verbose
		} 

        ########################################################################################
  	    Write-verbose -message "----------SAP - SAP-Einstellungsdateien ins neue Profil transferieren----------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\SAP"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\SAP"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
				Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import SAP-GUI-Einstellungsdateien werden transferiert von $SourcePath nach $DestPath" -Verbose
		} 


        ########################################################################################
		Write-verbose -message "----------Office-Outlook-Signaturen ins neue Profil transferieren----------------------------------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Signatures"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Signatures"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
            Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "" -verbose
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Office-Outlook-Signaturen von $SourcePath nach $DestPath" -Verbose
		} 
  

        ########################################################################################
  	    Write-verbose -message "----------Templates - Office-normal.dot(m) Templates (auch teilweise mit Schnellbausteinen/Autotexten) ins neue Profil transferieren" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\Templates"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Templates"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.do*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import normal.dot(m) Templates (auch teilweise mit Schnellbausteinen/Autotexten) von $SourcePath nach $DestPath" -Verbose
		} 


        ########################################################################################
  	    Write-verbose -message "----------PDFXChange-Einstellungsdateien ins neue Profil transferieren----------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Tracker Software"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Tracker Software"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import PDFXChange-Einstellungsdateien werden transferiert von $SourcePath nach $DestPath" -Verbose
		} 

        ########################################################################################
  	    Write-verbose -message "----------UProof Office-Benutzerwoerterbuecher (dic) uproof ins neue Profil transferieren---------" -verbose
        ########################################################################################
		$SourcePath = "$backpfadNEU2016\AppData\Roaming\Microsoft\UProof"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\UProof"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-Host "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -ForegroundColor Red
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
			Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "" -verbose
            Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Office-Benutzerwoerterbuecher (dic) uproof von $SourcePath nach $DestPath" -verbose
		} 


        ########################################################################################
        ########################################################################################
        # unklar ob noch notwendig
        Write-verbose -message "----------Registryeintrag fuer Outlook-DefaulProfile-Wert transferieren nach Import der Reg----------------------------------" -verbose
        Write-verbose -message "Outlook-DefaulProfile-Wert-Import - new-item-Fehlermeldungen sind normal - copy-item Fehler kommen wenn Quelle leer ist" -verbose
        ########################################################################################
        ########################################################################################
		Function testDOCPATH{
        if(test-path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\"){    
            Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\' | Select-Object -ExpandProperty 'DefaultProfile'
            return $true
        }
        else{
            return $false
        }
		}
        if(testDOCPATH){
        Copy-Itemproperty "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\" -Name "DefaultProfile" -Destination "HKCU:\Software\Microsoft\Office\16.0\Outlook\"
        }else{Write-Host "----------Quelleintrag nicht vorhanden! Deshalb wird nicht kopiert" -ForegroundColor Red}

    #################
    # MARKER SETZEN #
    #################
        
        ########################################################################################
		Write-verbose -message "----------Eintrag setzen mit Wert 1 - damit er beim naechsten Mal, wenn er prueft, den Eintrag findet und dann die komplette Klammer ueberspringt----------------------------------" -verbose
        ########################################################################################
        if(! (Test-Path -Path 'HKCU:\Software\_BGETEM_PS')) {New-Item  -Path 'HKCU:\Software\_BGETEM_PS' | Out-Null } 
        New-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' -Name 'MigServer2008-2016' -Value 1 -PropertyType DWORD -Force  | Out-Null
        New-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' -Name 'Importskript-2016' -Value 1 -PropertyType DWORD -Force  | Out-Null


    ##########################################################################################################
    Write-verbose -message "----------Funktionen einlesen - Loeschen eines Outlook-Backups BGETEM (das Backup ist nicht notwendig - kommt evtl. von Migrationen)----------------------------------" -verbose
    ##  http://terenceluk.blogspot.de/2012/02/how-to-roam-outlook-2010-signature.html
    ##########################################################################################################
        function BACKUPOFBGETEM{
        if(Test-Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\"){
        Set-Location "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\"
        $Path =Test-Path "BACKUP OF BGETEM"
         if($Path){
            Remove-Item "BACKUP OF BGETEM"
         }
        }
        }
        function OUTLOOKPROFILE{
        if(Test-Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\" ){
        Set-Location "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\"
        $Path =Test-Path "BACKUP OF Default Outlook Profile"
         if($Path){
            Remove-Item "BACKUP OF Default Outlook Profile"
        }
        }
        }
        Write-verbose -message "----------Funktion BACKUPOFBGETEM aufrufen----------------------------------" -verbose
        BACKUPOFBGETEM
        Write-verbose -message "----------Funktion OUTLOOKPROFILE aufrufen----------------------------------" -verbose
        OUTLOOKPROFILE
        
        ##########################################################################################################

    Write-verbose -message "" -verbose
    Write-verbose -message "" -verbose
    
    ########################################################################################
    Write-verbose -message "----------Messagebox, dass Import erledigt und Abmeldung erfolgt----------------------------------" -verbose
    ########################################################################################
        $msg = "Import von Profileinstellungen wurde durchgefuehrt. Sie werden gleich abgemeldet und koennen sich danach direkt wieder anmelden, um die Einrichtung fertig zu stellen."
        $result= [System.Windows.Forms.MessageBox]::Show("$msg, Import Fertig - Abmeldung"," ",1)

        if($result -eq "OK"){
        #$synth.Speak("Sie werden abgemeldet!")
	    Write-verbose -message "--------------------------------------------" -verbose
        Write-verbose -message "----------Abmeldung durch killen von explorer.exe----------------------------------" -verbose
        Write-verbose -message "" -verbose
        Write-verbose -message "" -verbose
        taskkill.exe /F /IM explorer.exe
        logoff
        }else{
        exit
        }

    }
    else
    {
	Write-verbose -message "----------Es muss nichts getan werden! Registrykey ist schon gesetzt----------------------------------" -verbose
    $MigrationswertBGETEM_PS = Get-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' | Select-Object -ExpandProperty 'MigServer2008-2016'
    Write-verbose -message "----------Registryeintrag ist $MigrationswertBGETEM_PS -------------" -verbose
    }

}

$error.clear()

# Für Tests das exit ca. Zeile 152 auskommentieren
# write-host "Exit in Zeile 152 (ca) wieder einklammern, wenn Skript produktiv wird!" -ForegroundColor Yellow

Stop-Transcript




######################################################################################################################################################################
######################################################################################################################################################################
###########################################################          SKRIPT-ENDE          ############################################################################
######################################################################################################################################################################
######################################################################################################################################################################
######################################################################################################################################################################










#$synth.Speak("Ende des Skriptes!")

#start-sleep -seconds 20

<#
if($Error.count -gt 0){
    $Error |out-file "c:\users\$env:username\Errorlog-Skript-Import-Citrix-XD-Profil.txt"
}

else{
    out-file "c:\users\$env:username\Erfolgreich-Skript-Import-Citrix-XD-Profil.txt"
} 
#>


<#
exit
clear

#Outlook-Prozess beenden, wenn vorhanden - ist sinnvoll fuer die Migration der Daten
get-process outloo* | Stop-Process

Write-Host "Pruefen, ob Registryeintrag vorhanden ist mit Wert 1 - wenn nicht vorhanden, dann weiter in der Klammer" -ForegroundColor Yellow

#Pruefen, ob Registryeintrag vorhanden ist mit Wert 1 - wenn nicht vorhanden, dann weiter in der Klammer
if( (!(Test-Path 'HKCU:\Software\_BGETEM_PS')) -or  (Get-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' | Select-Object -ExpandProperty 'MigServer2008-2016') -ne 1) 
{
Write-Host "Registryeintrag noch nicht vorhanden - es geht weiter in der Klammer" -ForegroundColor yellow


} 

#>


#Eintrag setzen mit Wert 1 - damit er beim naechsten Mal, wenn er prueft, den Eintrag findet und dann die komplette Klammer ueberspringt
     #if(! (Test-Path -Path 'HKCU:\Software\_BGETEM_PS')) {New-Item  -Path 'HKCU:\Software\_BGETEM_PS' | Out-Null } 
     #New-ItemProperty -Path 'HKCU:\Software\_BGETEM_PS' -Name 'MigServer2008-2016' -Value 1 -PropertyType DWORD -Force  | Out-Null

##Outlook-Prozess beenden, wenn vorhanden - ist sinnvoll fuer die Migration von Outlook-Daten
 #get-process outloo* | Stop-Process

#exit


<#
#######################################################################################################################################################################################
#######################################################################################################################################################################################

      #Platzhalter fuer Export von wichtigen Registryeintraegen
      #reg.exe export "HKEY_CURRENT_USER\Software\SAP" C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-SAP.reg /y
	  #copy "C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-SAP.reg" \\bg10\citrix\Config\BackupXD\office\
	  #reg.exe export "HKEY_CURRENT_USER\Software\PDFPrint" C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFPrint.reg /y
	  #copy "C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFPrint.reg" \\bg10\citrix\Config\BackupXD\office\
      #reg.exe export "HKEY_CURRENT_USER\Software\Tracker Software" C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFXChange.reg /y
	  #copy "C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFXChange.reg" \\bg10\citrix\Config\BackupXD\office\

      #test
      #reg.exe export "HKEY_CURRENT_USER\Software\Landesk\Show Agent Configuration Message" C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFXChange.reg /y
	  
      #Platzhalter fï¿½r Import von gespeicherten Registryeintraegen
      #regedit /s C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-SAP.reg
	  #regedit /s C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFPrint.reg
	  #regedit /s C:\Users\$env:UserName\AppData\Local\Temp\$env:UserName-PDFXChange.reg

#>

#############################################################################
#Toolbar "Programme" hinzufuegen nach Anleitung :
#https://jkindon.com/2019/01/29/modern-start-menu-management-and-windows-toolbars/
#############################################################################
#Start-Process -filepath "reg.exe" -argumentlist "\\bg10\NETLOGON\Citrix\WEM\Toolbar.reg"
#Import der der dazugehoerigen Datei
#regedit /s "\\bg10\NETLOGON\Citrix\WEM\Toolbar.reg"

#taskkill.exe /F /IM explorer.exe
#Start-Process Explorer.exe

#speech
#Add-Type -AssemblyName System.speech
#$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
##$synth.selectVoice("Microsoft Anna")
#$synth.Speak("Ersteinrichtung. Bitte Okay klicken")

<#
 #Der auskommentierte Teil wird neuerdings in Ersteinrichtung-Citrix.ps1 aufgerufen
  ##################################################################################
  Write-verbose -message "----------Ersteinrichtung Taskbar----------------------------------" -verbose
  ##################################################################################
if(!(test-path "C:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE")){
    powershell.exe -WindowStyle Hidden -executionpolicy bypass -file \\bg10\netlogon\Citrix\WEM\PinTo10.ps1 "C:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE" PIN TASKBAR
    start-sleep -seconds 2
}
if(!(test-path "c:\Users\Public\Desktop\Internet Explorer.lnk" )){
    powershell.exe -WindowStyle Hidden -executionpolicy bypass -file \\bg10\netlogon\Citrix\WEM\PinTo10.ps1 "c:\Users\Public\Desktop\Internet Explorer.lnk" PIN TASKBAR
    start-sleep -seconds 2
}

if(!(test-path "c:\Users\Public\Desktop\Windows Explorer.lnk")){
    powershell.exe -WindowStyle Hidden -executionpolicy bypass -file \\bg10\netlogon\Citrix\WEM\PinTo10.ps1 "c:\Users\Public\Desktop\Windows Explorer.lnk" PIN TASKBAR
    start-sleep -seconds 2
}
  ##################################################################################
  #Write-verbose -message "----------PDFs erst Mal von Adobe Reader oeffnen lassen - Festlegung per SetUserFTA ----------------------------------" -verbose
  #\\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .pdf AcroExch.Document.11
  Write-verbose -message "----------PDFs erst Mal von PDFExchange oeffnen lassen - Festlegung per SetUserFTA ----------------------------------" -verbose
  \\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .pdf PDFXEdit.PDF
  #Write-verbose -message "----------WAVs erst Mal von VLC oeffnen lassen - Festlegung per SetUserFTA ----------------------------------" -verbose
  #\\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .wav VLC.wav
  Write-verbose -message "----------jpeg, jpg, jpe, png von Windows Fotoanzeige oeffnen lassen - Festlegung per SetUserFTA ----------------------------------" -verbose
  \\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .jpeg jpegfile
  \\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .jpg jpegfile
  \\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .jpe jpegfile
  \\bg10\netlogon\Citrix\SetUserFTA\SetUserFTA.exe .png pngfile
#>

<#
        ########################################################################################
  	    Write-verbose -message "----------Mozilla-Einstellungsdateien vom 2008erProfil ins neue Profil transferieren ------" -verbose
        ########################################################################################
		$SourcePath = "\\bg10\citrix\Profile\$env:UserName\Win2008x64\UPM_Profile\AppData\Roaming\Mozilla"
		$DestPath = "C:\Users\$env:UserName\AppData\Roaming\Mozilla"
		if (!(Test-Path $SourcePath))
		{		#Nichts kopiert - Kein gueltiger Quellpfad: 
			Write-verbose -message "----------Nichts kopiert - Kein gueltiger Quellpfad: $SourcePath----------------------------------" -verbose
		}		else 		{
		if (!(Test-Path $DestPath))
			{
				Write-verbose -message "----------Zielordner nicht existent  -  Erstellt den Zielordner----------------------------------" -verbose
			New-Item -ItemType Directory -Path $DestPath
			}
			Write-verbose -message "----------Inhalt Quellordner rekursiv auslesen in Zielordner kopieren (ueberschreibt Berechtigungen)----------------------------------" -verbose
			Get-ChildItem -Path $SourcePath -Recurse -Filter "*.*" | Copy-Item -Destination $DestPath -Force
		    Write-verbose -message "----------Import Mozilla-Einstellungsdateien werden transferiert von $SourcePath nach $DestPath" -Verbose
		} 

#>

#####################


