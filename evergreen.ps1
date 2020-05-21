#Requires -RunAsAdministrator

# Adam Yarborough @littletoyrobots 2019

# Liberal stealing ideas and content from Trond Eirik Haavarstein (@xenappblog), Aaron Parker (@stealthpuppy),

# Bronson Magnan (@CIT_Bronson), Ryan C Butler (@RyanCButler), and probably many others. I'll try and list

# them as I can.  You should probably use chocolatey instead of this, I just thought it was fun.

 

# This assumes Win10 1803+, it probably won't work.

 

# Here are the mandatory settings enforced by this script

# 1 - Sets Timezone to EST

# 2 - Installs .NET 3.5, 4.7.2

# 3 - Installs Visual C++ Runtimes

# 4 - Installs LAPS

# 5 - Confirms Security Baseline (lots to do here)

# ...

# n - To be determined

 

# Very Common

$AdobeReader = $true            # Installs Adobe Acrobat Reader DC

$AlternateBrowsers = $true      # Installs Google Chrome, Mozilla Firefox

$Citrix = $true                 # Installs Citrix Workspace App

 

# Common

$MediaPlayers = $true           # Installs VLC

$WebexSuite = $true             # Installs Webex Teams, Webex Meetings

 

# Less Common

# ... Custom Applications here.

 

# Special Cases

$Java8 = $false                  # Installs Java8

 

# Installs VSCode, Powershell Plugin, Notepad++, Git, GitHub Desktop, SSMS, 7zip, RDCMan, SysInternals, RSAT, etc

$AdminDesktop = $true          

 

# Questionable Practices

$EnableSMB1 = $false            # Enables SMB1 *Please don't do this*

 

# Coming soon! Placeholder only

$MicrosoftOffice = $false        # Microsoft Office 2019

 

# Add in some powershell modules we all know and love. Make sure to leave in Requirements and Evergreen

$PowerShellModules = "Requirements", "Evergreen"

<#

$PowerShellModules = @(

    "Requirements"

    "Evergreen"

    "Invoke-CommandAs"

    "PSKoans"

    "OSDBuilder"

    "PSFramework"

)

#>

# End of Configuration

 

 

 

 

# Do not edit below this line.  Or whatever, I'm a comment not a cop.

 

$LogFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "Desktop-Settings-$(Get-Date -format filedate).txt"

Start-Transcript $LogFile -Append

 

# Update-Module -Force -WarningAction 'SilentlyContinue'

foreach ($Module in $PowerShellModules) {

    if (-not (Get-Module -Name $Module)) { Install-Module -Name $Module -Scope AllUsers }

}

 

Import-Module Requirements

Import-Module Evergreen

 

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

 

 

# Returns array of software, matches wildcard provided with -like comparisons.  Probably garbage, but it works.

function Get-InstalledSoftware {

    Param (

        $Name

    )

    # Search in this order

    # Check Registry in Wow6432Node

    # Check Registry

    # Check Win32_Product

 

    $Software = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object DisplayName -like $Name | Select-Object DisplayName, DisplayVersion

    if ($null -ne $Software) {

        $Software | ForEach-Object {

            [PSCustomObject]@{

                Name    = $_.DisplayName

                Version = $_.DisplayVersion

            }

        }

    }

    else {

        $Software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object DisplayName -like $Name | Select-Object DisplayName, DisplayVersion

        if ($null -ne $Software) {

            $Software | ForEach-Object {

                [PSCustomObject]@{

                    Name    = $_.DisplayName

                    Version = $_.DisplayVersion

                }

            }

        }

   

        else {

            # I really don't like to do this because its slow.

            $Software = Get-CimInstance Win32_Product | Where-Object Name -like $Name | Select-Object Name, Version -Unique

            $Software | ForEach-Object {

                [PSCustomObject]@{

                    Name    = $_.Name

                    Version = $_.Version

                }

            }

        }

    }

}

 

#

#   Here I just define things I like to see on my workstation.  They almost always get installed or set.

#

$BaseDesktopRequirements = @(

    @{

        Name     = 'Timezone-EST'

        Describe = 'Timezone set to Eastern Standard Time'

        Test     = { (Get-TimeZone).StandardName -eq 'Eastern Standard Time' }

        Set      = { Set-TimeZone -Name 'Eastern Standard Time'; Start-Sleep -Seconds 1 }

    }

    , @{

        Name     = 'NET35'

        Describe = '.NET Framework 3.5 feature installed'

        Test     = { (Get-WindowsCapability -Online -Name 'NetFx3~~~~').State -eq 'Installed' }

        Set      = { Add-WindowsCapability -Online -Name 'NetFx3~~~~'; Start-Sleep -Seconds 1 }

    }

    , @{

        Name     = 'NET47'

        Describe = '.NET Framework 4.7.2 (or higher) installed'

        Test     = { (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 461808 }

        Set      = {

            $URI = "https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "dotnet472.exe"

            $UnattendedArgs = "/q /norestart /log ${env:SystemRoot}\Temp\dotnet472.log"

 

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'VS2008x64'

        Describe = 'Microsoft Visual C++ 2008 x64 Runtime is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Microsoft Visual C++ 2008*') }

        Set      = {

            $URI = "http://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vcredist-2008-x64.exe"

            $UnattendedArgs = "/qb!"

          

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'VS2010x64'

        Describe = 'Microsoft Visual C++ 2010 x64 Runtime is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Microsoft Visual C++ 2010*') }

        Set      = {

            $URI = "http://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vcredist-2010-x64.exe"

            $UnattendedArgs = "/qb!"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'VS2012x64'

        Describe = 'Microsoft Visual C++ 2012 x64 Runtime is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Microsoft Visual C++ 2012*') }

        Set      = {

            $URI = "http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vcredist-2012-x64.exe"

            $UnattendedArgs = "/quiet /norestart"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'VS2013x64'

        Describe = 'Microsoft Visual C++ 2013 x64 Runtime is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Microsoft Visual C++ 2013*') }

        Set      = {

            $URI = "http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vcredist-2013-x64.exe"

            $UnattendedArgs = "/quiet /norestart"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'VS2019x64'

        Describe = 'Microsoft Visual C++ 2019 x64 Runtime is installed - same distributable as 2015 and 2017'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Microsoft Visual C++ 2019 X64*') }

        Set      = {

            $URI = "https://aka.ms/vs/16/release/vc_redist.x64.exe"

            $Outfile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vcredist-2019-x64.exe"

            $UnattendedArgs = "/quiet /norestart"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile -ArgumentList $UnattendedArgs -Wait -PassThru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    #

    #   Power Settings. 

    #

    # TODO: Turn off network interface power settings, etc.

    , @{

        Name     = 'HighPerfPower'

        Describe = 'High Performance Power Plan selected'

        Test     = {

            (Get-CimInstance -ClassName Win32_PowerPlan -Namespace 'root\cimv2\power' | Where-Object ElementName -eq 'High performance').IsActive

        }

        Set      = {

            PowerCfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

            Start-Sleep -Seconds 1

        }

    }

    #

    #   Security Settings

    #

    # TODO: Implement more baseline security

    , @{

        Name     = 'Laps'

        Describe = 'Local Administrator Password Solution client is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name 'Local Administrator Password Solution') }

        Set      = {

            $URI = "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi"

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "LAPS.x64.msi"

            $UnattendedArgs = "/i $Outfile ALLUSERS=1 /qn /liewa ${env:SystemRoot}\Temp\laps.log"

   

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'NoDomainUserAdmin'

        Describe = 'Confirm "Domain Users" not present in Local Administrators'

        Test     = {

            $null -eq (Get-LocalGroupMember -Name 'Administrators' | Where-Object Name -eq "$env:USERDOMAIN\Domain Users")

        }

        Set      = {

            Remove-LocalGroupMember -Group "Administrators" -Member "$env:USERDOMAIN\Domain Users" -ErrorAction 'SilentlyContinue'

        }

    }

)

 

#

#   These are the things I do with Adobe Reader. 

#

$AdobeReaderRequirements = @(

    @{

        Name     = 'AdobeAcrobatReaderDC'

        Describe = 'Adobe Acrobat Reader DC installed and current (evergreen)'

        Test     = {

            $AllWindowsVersions = Get-AdobeAcrobatReaderDC | Where-Object Platform -eq 'Windows'

            $CurrentVersion = $AllWindowsVersions | Where-Object Type -eq 'Updater' | Select-Object -ExpandProperty Version -Unique

            if ($null -eq $CurrentVersion) {

                $CurrentVersion = $AllWindowsVersions | Where-Object Language -eq 'English' | Select-Object -ExpandProperty Version -Unique

            }

            (Get-InstalledSoftware -Name 'Adobe Acrobat Reader DC').Version -eq $CurrentVersion

        }

        Set      = {

            # Install Base version

            $AllWindowsVersions = Get-AdobeAcrobatReaderDC | Where-Object Platform -eq 'Windows'

            $URI = $AllWindowsVersions | Where-Object Language -eq 'English' | Select-Object -ExpandProperty URI

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "adobeacrobat.exe"

            $UnattendedArgs = "/sAll /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES /liewa ${env:SystemRoot}\Temp\adobeacrobatexe.log"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $OutFile -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

 

            # Install Updates

            $AllWindowsVersions = Get-AdobeAcrobatReaderDC | Where-Object Platform -eq 'Windows' | Where-Object Type -eq 'Updater'

            $Updater = $AllWindowsVersions | Where-Object Language -eq 'Neutral'

            if ($null -ne $Updater) {

                $UpdateFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "adobeacrobat.msp"

                $UnattendedArgs = "/p $UpdateFile /norestart /qn /liewa ${env:SystemRoot}\Temp\adobeacrobatmsp.log"

           

                Invoke-WebRequest -Uri $Updater.URI -OutFile $UpdateFile -UseBasicParsing

                Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

                Start-Sleep -Seconds 1

            }           

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name      = 'DisableAdobeAcrobatScheduledTask'

        Describe  = 'Disable Adobe Acrobat Update Task'

        Test      = { (Get-ScheduledTask -TaskName 'Adobe Acrobat Update Task').State -eq 'Disabled' }

        Set       = {

            Disable-ScheduledTask -TaskName 'Adobe Acrobat Update Task'

            Start-Sleep -Seconds 1

        }

        DependsOn = 'AdobeAcrobatReaderDC'

    }

    , @{

        Name      = 'DisableAdobeAcrobatARMService'

        Describe  = 'Disable Adobe Acrobat ARM Service'

        Test      = { (Get-Service -Name 'AdobeARMService').StartType -eq 'Disabled' }

        Set       = {

            Stop-Service -Name 'AdobeARMService' -ErrorAction 'SilentlyContinue' | Out-Null

            Set-Service -Name 'AdobeARMService' -StartupType 'Disabled' | Out-Null

            Start-Sleep -Seconds 1

        }

        DependsOn = 'AdobeAcrobatReaderDC'

    }

    , @{

        Name      = 'DisableAdobeWelcomeScreen'

        Describe  = 'Disable Adobe Acrobat Welcome Screen'

        Test      = {

            try {

                if ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown\cWelcomeScreen' -Name 'bShowWelcomeScreen' -ea SilentlyContinue) -eq 0) { }

                else { return $false }

            }

            catch { return $false }

            return $true

        }

        Set       = {

            cmd.exe /c 'reg add "HKLM\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown\cWelcomeScreen" /f /v bShowWelcomeScreen /t REG_DWORD /d 0' | Out-Null

            cmd.exe /c 'reg add "HKLM\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" /f /v bUsageMeasurement /t REG_DWORD /d 0' | Out-Null

            Start-Sleep -Seconds 1

        }

        DependsOn = 'AdobeAcrobatReaderDC'

    }

)

 

#

# Installs Chrome and Mozilla

#

# TODO: Install the browser plugins I use, set Mozilla to trust internal certificate store, etc.

$AlternateBrowserRequirements = @(

    @{

        Name     = 'GoogleChrome'

        Describe = 'Google Chrome installed and current (evergreen)'

        Test     = {

            $CurrentVersion = Get-GoogleChrome -Platform win64 | Select-Object -ExpandProperty Version

            (Get-InstalledSoftware -Name 'Google Chrome').Version -eq $CurrentVersion

        }

        Set      = {

            $URI = Get-GoogleChrome -Platform win64 | Select-Object -ExpandProperty URI

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "googlechrome.msi"

            $UnattendedArgs = "/i $Outfile ALLUSERS=1 NOGOOGLEUPDATEPING=1 /qn /liewa ${env:SystemRoot}\Temp\googlechrome.log"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'MozillaFirefox'

        Describe = 'Mozilla Firefox installed and current (evergreen)'

        Test     = {

            # I could really use a better version than this...

            $CurrentVersion = (Get-MozillaFirefox -Platform win64).Version

            (Get-InstalledSoftware -Name 'Mozilla Firefox*').Version -eq $CurrentVersion

        }

        Set      = {

            $URI = Get-MozillaFirefox -Platform win64 | Select-Object -ExpandProperty Uri

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "firefox.exe"

            $UnattendedArgs = "/S /PreventRebootRequired=true"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $Outfile -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

            Start-Sleep -Seconds 1

        }

    }

    #    , @{

    #        Name     = 'MozillaAcceptCerts'

    #        Describe = 'Set firefox to trust the local windows certificate store'

    #    }

)

 

#

#   Install Citrix Workspace App the way I usually do.

#

$CitrixRequirements = @(

    #

    #   Citrix

    #

    @{

        Name      = 'CitrixWorkspaceApp'

        Describe  = 'Citrix Workspace App is installed and current (evergreen)'

        Test      = {

            $AllWindowsVersions = Get-CitrixWorkspaceApp | Where-Object Platform -eq 'Windows'

            $CurrentVersion = $AllWindowsVersions | Where-Object Title -eq 'Citrix Workspace - Current Release' | Select-Object -ExpandProperty Version

            (Get-ChildItem "C:\Program Files (x86)\Citrix\ICA Client\CDViewer.exe" -ErrorAction SilentlyContinue).VersionInfo.ProductVersion -eq $CurrentVersion

        }

        Set       = {

            $AllWindowsVersions = Get-CitrixWorkspaceApp | Where-Object Platform -eq 'Windows'

            $URI = $AllWindowsVersions | Where-Object Title -eq 'Citrix Workspace - Current Release' | Select-Object -ExpandProperty Uri

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "citrixworkspaceapp.exe"

            $UnattendedArgs = "/silent /noreboot /includeSSON /AutoUpdateCheck=auto /EnableCEIP=False /EnableTracing=true"

 

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            $P = Start-Process $OutFile -ArgumentList $UnattendedArgs -Passthru -ErrorAction Stop

            if ($null -ne $P) { Wait-Process -InputObject $P }

            Start-Sleep -Seconds 1

        }

        DependsOn = 'VS2008x64', 'VS2010x64', 'VS2012x64', 'VS2013x64', 'VS2019x64'

    }

    , @{

        Name      = 'ProviderOrder'

        Describe  = 'Network Provider Order is set higher (500) for PnSson'

        Test      = {

            $false -or ((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider\ProviderOrder' 'PnSson').PnSson -eq 500)

        }

        Set       = {

            Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider\ProviderOrder' 'LanmanWorkstation' -Value 2000

            Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\NetworkProvider\ProviderOrder' 'PnSson' -Value 500

            Start-Sleep -Seconds 1

        }

        DependsOn = 'CitrixWorkspaceApp'

    }

   

)

 

#

#   Install VLC

#

# TODO: File association

$MediaPlayerRequirements = @(

    @{

        Name     = 'VLC'

        Describe = 'VLC Media Player is installed and current (evergreen)'

        Test     = {

            $CurrentVersion = (Get-VideoLanVlcPlayer | Where-Object Platform -eq 'Win64').Version

            (Get-InstalledSoftware -Name 'VLC media player').Version -eq $CurrentVersion

        }

        Set      = {

            $Uri = (Get-VideoLanVlcPlayer | Where-Object Platform -eq 'Win64').Uri

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "vlc-win64.exe" # Don't name it just vlc.exe

           $UnattendedArgs = "/S" # /L=1033 sets to English, NCRC skips CRC

 

            if (Test-Path "$env:ProgramFiles\VideoLan\VLC\Uninstall.exe") {

                Start-Process "$env:ProgramFiles\VideoLan\VLC\Uninstall.exe" -ArgumentList '/S' -Wait -Passthru | Out-Null

                Start-Sleep -Seconds 1

            }

            if (Test-Path "${env:ProgramFiles(x86)}\VideoLan\VLC\Uninstall.exe") {

                Start-Process "${env:ProgramFiles(x86)}\VideoLan\VLC\Uninstall.exe" -ArgumentList '/S' -Passthru | Out-Null

                Start-Sleep -Seconds 1

            }

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process $OutFile -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

)

 

#

#   Install Webex Teams and Webex Meetings.

#

$WebexRequirements = @(

    @{

        Name     = 'WebexTeams'

        Describe = 'Webex Teams is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name "Webex Teams") }

        Set      = {

            $URI = "https://binaries.webex.com/WebexTeamsDesktop-Windows-Gold/WebexTeams.msi"

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "webexteams.msi"

            $UnattendedArgs = "/i $Outfile ALLUSERS=1 /qn /liewa ${env:SystemRoot}\Temp\webexteams.log"

           

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

    , @{

        Name     = 'WebexMeetings'

        Describe = 'Webex Meetings is installed'

        Test     = { $false -or (Get-InstalledSoftware -Name "*Webex Meetings*") }

        Set      = {

            $URI = "https://akamaicdn.webex.com/client/webexapp.msi"

            $OutFile = Join-Path "$env:SystemRoot\Temp" -ChildPath "webexapp.msi"

            $UnattendedArgs = "/i $Outfile ALLUSERS=1 /qn /liewa ${env:SystemRoot}\Temp\webexapp.log"

 

            Invoke-WebRequest -Uri $URI -OutFile $OutFile -UseBasicParsing

            Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru | Out-Null

            Start-Sleep -Seconds 1

        }

    }

)
