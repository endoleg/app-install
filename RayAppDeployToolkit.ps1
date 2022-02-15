## Variables declaration
#System Directory
If ($envOSArchitecture -eq '32-Bit') {
	$is64Bit = $false
	[string]$envSystem32 = $env:WinDir + '\System32' }
Else {
	$is64Bit = $true
	[string]$envSystem32 = $env:WinDir + '\SysWow64' 
}

[string]$envSystem64 = $env:WinDir + '\System32' 

#region Ray-Functions
Function Ray-Execute-MSI {
<#
.SYNOPSIS
	Executes msiexec.exe to perform the following actions for MSI & MSP files and MSI product codes: install, uninstall, patch, repair, active setup.
.DESCRIPTION
	Executes msiexec.exe to perform the following actions for MSI & MSP files and MSI product codes: install, uninstall, patch, repair, active setup.
	If the -Action parameter is set to "Install" and the MSI is already installed, the function will exit.
	Sets default switches to be passed to msiexec based on the preferences in the XML configuration file.
	Automatically generates a log file name and creates a verbose log file for all msiexec operations.
	Expects the MSI or MSP file to be located in the "Files" sub directory of the App Deploy Toolkit. Expects transform files to be in the same directory as the MSI file.
.PARAMETER Action
	The action to perform. Options: Install, Uninstall, Patch, Repair, ActiveSetup.
.PARAMETER Path
	The path to the MSI/MSP file or the product code of the installed MSI.
.PARAMETER Transform
	The name of the transform file(s) to be applied to the MSI. The transform file is expected to be in the same directory as the MSI file.
.PARAMETER Patch
	The name of the patch (msp) file(s) to be applied to the MSI for use with the "Install" action. The patch file is expected to be in the same directory as the MSI file.
.PARAMETER Parameters
	Overrides the default parameters specified in the XML configuration file. Install default is: "REBOOT=ReallySuppress /QB!". Uninstall default is: "REBOOT=ReallySuppress /QN".
.PARAMETER AddParameters
	Adds to the default parameters specified in the XML configuration file. Install default is: "REBOOT=ReallySuppress /QB!". Uninstall default is: "REBOOT=ReallySuppress /QN".
.PARAMETER SecureParameters
	Hides all parameters passed to the MSI or MSP file from the toolkit Log file.
.PARAMETER LoggingOptions
	Overrides the default logging options specified in the XML configuration file. Default options are: "/L*v".
.PARAMETER LogName
	Overrides the default log file name. The default log file name is generated from the MSI file name. If LogName does not end in .log, it will be automatically appended.
	For uninstallations, by default the product code is resolved to the DisplayName and version of the application.
.PARAMETER WorkingDirectory
	Overrides the working directory. The working directory is set to the location of the MSI file.
.PARAMETER SkipMSIAlreadyInstalledCheck
	Skips the check to determine if the MSI is already installed on the system. Default is: $false.
.PARAMETER IncludeUpdatesAndHotfixes
	Include matches against updates and hotfixes in results.
.PARAMETER NoWait
	Immediately continue after executing the process.
.PARAMETER PassThru
	Returns ExitCode, STDOut, and STDErr output from the process.
.PARAMETER IgnoreExitCodes
	List the exit codes to ignore or * to ignore all exit codes.
.PARAMETER PriorityClass	
	Specifies priority class for the process. Options: Idle, Normal, High, AboveNormal, BelowNormal, RealTime. Default: Normal
.PARAMETER ExitOnProcessFailure
	Specifies whether the function should call Exit-Script when the process returns an exit code that is considered an error/failure. Default: $true
.PARAMETER RepairFromSource
	Specifies whether we should repair from source. Also rewrites local cache. Default: $false
.PARAMETER ContinueOnError
	Continue if an error occured while trying to start the process. Default: $false.
.EXAMPLE
	Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi'
	Installs an MSI
.EXAMPLE
	Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi' -Transform 'Adobe_FlashPlayer_11.2.202.233_x64_EN_01.mst' -Parameters '/QN'
	Installs an MSI, applying a transform and overriding the default MSI toolkit parameters
.EXAMPLE
	[psobject]$ExecuteMSIResult = Execute-MSI -Action 'Install' -Path 'Adobe_FlashPlayer_11.2.202.233_x64_EN.msi' -PassThru
	Installs an MSI and stores the result of the execution into a variable by using the -PassThru option
.EXAMPLE
	Execute-MSI -Action 'Uninstall' -Path '{26923b43-4d38-484f-9b9e-de460746276c}'
	Uninstalls an MSI using a product code
.EXAMPLE
	Execute-MSI -Action 'Patch' -Path 'Adobe_Reader_11.0.3_EN.msp'
	Installs an MSP
.NOTES
.LINK
	http://psappdeploytoolkit.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$false)]
		[ValidateSet('Install','Uninstall','Patch','Repair','ActiveSetup')]
		[string]$Action = 'Install',
		[Parameter(Mandatory=$true,HelpMessage='Please enter either the path to the MSI/MSP file or the ProductCode')]
		[ValidateScript({($_ -match $MSIProductCodeRegExPattern) -or ('.msi','.msp' -contains [IO.Path]::GetExtension($_))})]
		[Alias('FilePath')]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$Transform,
		[Parameter(Mandatory=$false)]
		[Alias('Arguments')]
		[ValidateNotNullorEmpty()]
		[string]$Parameters,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$AddParameters,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$SecureParameters = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$Patch,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$LoggingOptions,
		[Parameter(Mandatory=$false)]
		[Alias('LogName')]
		[string]$private:LogName,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$WorkingDirectory,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$SkipMSIAlreadyInstalledCheck = $false,
		[Parameter(Mandatory=$false)]
		[switch]$IncludeUpdatesAndHotfixes = $false,
		[Parameter(Mandatory=$false)]
		[switch]$NoWait = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$PassThru = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$IgnoreExitCodes,
		[Parameter(Mandatory=$false)]
		[ValidateSet('Idle', 'Normal', 'High', 'AboveNormal', 'BelowNormal', 'RealTime')]
		[Diagnostics.ProcessPriorityClass]$PriorityClass = 'Normal',
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ExitOnProcessFailure = $true,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$RepairFromSource = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $false
	)

    ## Prepare parameters
    $param = @{ 'Action' = $Action; 'Path' = $Path }

    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Transform' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Parameters' -ParameterHashtable $param
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'AddParameters' -ParameterHashtable $param
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'SecureParameters' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Patch' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'LoggingOptions' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'private:LogName' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'WorkingDirectory' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'SkipMSIAlreadyInstalledCheck' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'IncludeUpdatesAndHotfixes' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'NoWait' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'PassThru' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'IgnoreExitCodes' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'PriorityClass' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ExitOnProcessFailure' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'RepairFromSource' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ContinueOnError' -ParameterHashtable $param -DoNotReplaceString

    ## Execute command
    Execute-Msi @param 
}

Function Ray-Execute-Process {
<#
.SYNOPSIS
	Execute a process with optional arguments, working directory, window style.
.DESCRIPTION
	Executes a process, e.g. a file included in the Files directory of the App Deploy Toolkit, or a file on the local machine.
	Provides various options for handling the return codes (see Parameters).
.PARAMETER Path
	Path to the file to be executed. If the file is located directly in the "Files" directory of the App Deploy Toolkit, only the file name needs to be specified.
	Otherwise, the full path of the file must be specified. If the files is in a subdirectory of "Files", use the "$dirFiles" variable as shown in the example.
.PARAMETER Parameters
	Arguments to be passed to the executable
.PARAMETER SecureParameters
	Hides all parameters passed to the executable from the Toolkit log file
.PARAMETER WindowStyle
	Style of the window of the process executed. Options: Normal, Hidden, Maximized, Minimized. Default: Normal.
	Note: Not all processes honor the "Hidden" flag. If it it not working, then check the command line options for the process being executed to see it has a silent option.
.PARAMETER CreateNoWindow
	Specifies whether the process should be started with a new window to contain it. Default is false.
.PARAMETER WorkingDirectory
	The working directory used for executing the process. Defaults to the directory of the file being executed.
.PARAMETER NoWait
	Immediately continue after executing the process.
.PARAMETER PassThru
	Returns ExitCode, STDOut, and STDErr output from the process.
.PARAMETER WaitForMsiExec
	Sometimes an EXE bootstrapper will launch an MSI install. In such cases, this variable will ensure that
	that this function waits for the msiexec engine to become available before starting the install.
.PARAMETER MsiExecWaitTime
	Specify the length of time in seconds to wait for the msiexec engine to become available. Default: 600 seconds (10 minutes).
.PARAMETER IgnoreExitCodes
	List the exit codes to ignore.
.PARAMETER PriorityClass	
	Specifies priority class for the process. Options: Idle, Normal, High, AboveNormal, BelowNormal, RealTime. Default: Normal
.PARAMETER ExitOnProcessFailure
	Specifies whether the function should call Exit-Script when the process returns an exit code that is considered an error/failure. Default: $true
.PARAMETER ContinueOnError
	Continue if an exit code is returned by the process that is not recognized by the App Deploy Toolkit. Default: $false (fail on error).
.EXAMPLE
	Execute-Process -Path 'uninstall_flash_player_64bit.exe' -Parameters '/uninstall' -WindowStyle Hidden
	If the file is in the "Files" directory of the App Deploy Toolkit, only the file name needs to be specified.
.EXAMPLE
	Execute-Process -Path "$dirFiles\Bin\setup.exe" -Parameters '/S' -WindowStyle Hidden
.EXAMPLE
	Execute-Process -Path 'setup.exe' -Parameters '/S' -IgnoreExitCodes '1,2'
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[Alias('FilePath')]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[Alias('Arguments')]
		[ValidateNotNullorEmpty()]
		[string[]]$Parameters,
		[Parameter(Mandatory=$false)]
		[switch]$SecureParameters = $false,
		[Parameter(Mandatory=$false)]
		[ValidateSet('Normal','Hidden','Maximized','Minimized')]
		[Diagnostics.ProcessWindowStyle]$WindowStyle = 'Normal',
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$CreateNoWindow = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$WorkingDirectory,
		[Parameter(Mandatory=$false)]
		[switch]$NoWait = $false,
		[Parameter(Mandatory=$false)]
		[switch]$PassThru = $false,
		[Parameter(Mandatory=$false)]
		[switch]$WaitForMsiExec = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[int]$MsiExecWaitTime = $configMSIMutexWaitTime,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$IgnoreExitCodes,
		[Parameter(Mandatory=$false)]
		[ValidateSet('Idle', 'Normal', 'High', 'AboveNormal', 'BelowNormal', 'RealTime')]
		[Diagnostics.ProcessPriorityClass]$PriorityClass = 'Normal',
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ExitOnProcessFailure = $true,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$UseShellExecute = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $false
	)

    ## Prepare parameters
    $param = @{ 'Path' = $Path }

	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Parameters' -ParameterHashtable $param
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'SecureParameters' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'WindowStyle' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'CreateNoWindow' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'WorkingDirectory' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'NoWait' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'PassThru' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'WaitForMsiExec' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'MsiExecWaitTime' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'IgnoreExitCodes' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'PriorityClass' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ExitOnProcessFailure' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'UseShellExecute' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ContinueOnError' -ParameterHashtable $param -DoNotReplaceString

    ## Execute command
    Execute-ProcessEx @param 
	Start-Sleep -Seconds 1
}

#region Function Execute-ProcessEx
Function Execute-ProcessEx {
<#
.SYNOPSIS
	Execute a process with optional arguments, working directory, window style.
.DESCRIPTION
	Executes a process, e.g. a file included in the Files directory of the App Deploy Toolkit, or a file on the local machine.
	Provides various options for handling the return codes (see Parameters).
.PARAMETER Path
	Path to the file to be executed. If the file is located directly in the "Files" directory of the App Deploy Toolkit, only the file name needs to be specified.
	Otherwise, the full path of the file must be specified. If the files is in a subdirectory of "Files", use the "$dirFiles" variable as shown in the example.
.PARAMETER Parameters
	Arguments to be passed to the executable
.PARAMETER SecureParameters
	Hides all parameters passed to the executable from the Toolkit log file
.PARAMETER WindowStyle
	Style of the window of the process executed. Options: Normal, Hidden, Maximized, Minimized. Default: Normal.
	Note: Not all processes honor the "Hidden" flag. If it it not working, then check the command line options for the process being executed to see it has a silent option.
.PARAMETER CreateNoWindow
	Specifies whether the process should be started with a new window to contain it. Default is false.
.PARAMETER WorkingDirectory
	The working directory used for executing the process. Defaults to the directory of the file being executed.
.PARAMETER NoWait
	Immediately continue after executing the process.
.PARAMETER PassThru
	Returns ExitCode, STDOut, and STDErr output from the process.
.PARAMETER WaitForMsiExec
	Sometimes an EXE bootstrapper will launch an MSI install. In such cases, this variable will ensure that
	this function waits for the msiexec engine to become available before starting the install.
.PARAMETER MsiExecWaitTime
	Specify the length of time in seconds to wait for the msiexec engine to become available. Default: 600 seconds (10 minutes).
.PARAMETER IgnoreExitCodes
	List the exit codes to ignore.
.PARAMETER ContinueOnError
	Continue if an exit code is returned by the process that is not recognized by the App Deploy Toolkit. Default: $false.
.EXAMPLE
	Execute-ProcessEx -Path 'uninstall_flash_player_64bit.exe' -Parameters '/uninstall' -WindowStyle 'Hidden'
	If the file is in the "Files" directory of the App Deploy Toolkit, only the file name needs to be specified.
.EXAMPLE
	Execute-ProcessEx -Path "$dirFiles\Bin\setup.exe" -Parameters '/S' -WindowStyle 'Hidden'
.EXAMPLE
	Execute-ProcessEx -Path 'setup.exe' -Parameters '/S' -IgnoreExitCodes '1,2'
.EXAMPLE
	Execute-ProcessEx -Path 'setup.exe' -Parameters "-s -f2`"$configToolkitLogDir\$installName.log`""
	Launch InstallShield "setup.exe" from the ".\Files" sub-directory and force log files to the logging folder.
.EXAMPLE
	Execute-ProcessEx -Path 'setup.exe' -Parameters "/s /v`"ALLUSERS=1 /qn /L* \`"$configToolkitLogDir\$installName.log`"`""
	Launch InstallShield "setup.exe" with embedded MSI and force log files to the logging folder.
.NOTES
.LINK
	http://psappdeploytoolkit.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[Alias('FilePath')]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[Alias('Arguments')]
		[ValidateNotNullorEmpty()]
		[string[]]$Parameters,
		[Parameter(Mandatory=$false)]
		[switch]$SecureParameters = $false,
		[Parameter(Mandatory=$false)]
		[ValidateSet('Normal','Hidden','Maximized','Minimized')]
		[Diagnostics.ProcessWindowStyle]$WindowStyle = 'Normal',
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$CreateNoWindow = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$WorkingDirectory,
		[Parameter(Mandatory=$false)]
		[switch]$NoWait = $false,
		[Parameter(Mandatory=$false)]
		[switch]$PassThru = $false,
		[Parameter(Mandatory=$false)]
		[switch]$WaitForMsiExec = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[timespan]$MsiExecWaitTime = $(New-TimeSpan -Seconds $configMSIMutexWaitTime),
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$IgnoreExitCodes,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $false
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			$private:returnCode = $null
			
			## Validate and find the fully qualified path for the $Path variable.
			If (([IO.Path]::IsPathRooted($Path)) -and ([IO.Path]::HasExtension($Path))) {
				Write-Log -Message "[$Path] is a valid fully qualified path, continue." -Source ${CmdletName}
				If (-not (Test-Path -LiteralPath $Path -PathType 'Leaf' -ErrorAction 'Stop')) {
					Throw "File [$Path] not found."
				}
			}
			Else {
				#  The first directory to search will be the 'Files' subdirectory of the script directory
				[string]$PathFolders = $dirFiles
				#  Add the current location of the console (Windows always searches this location first)
				[string]$PathFolders = $PathFolders + ';' + (Get-Location -PSProvider 'FileSystem').Path
				#  Add the new path locations to the PATH environment variable
				$env:PATH = $PathFolders + ';' + $env:PATH
				
				#  Get the fully qualified path for the file. Get-Command searches PATH environment variable to find this value.
				[string]$FullyQualifiedPath = Get-Command -Name $Path -CommandType 'Application' -TotalCount 1 -Syntax -ErrorAction 'Stop'
				
				#  Revert the PATH environment variable to it's original value
				$env:PATH = $env:PATH -replace [regex]::Escape($PathFolders + ';'), ''
				
				If ($FullyQualifiedPath) {
					Write-Log -Message "[$Path] successfully resolved to fully qualified path [$FullyQualifiedPath]." -Source ${CmdletName}
					$Path = $FullyQualifiedPath
				}
				Else {
					Throw "[$Path] contains an invalid path or file name."
				}
			}
			
			## Set the Working directory (if not specified)
			If (-not $WorkingDirectory) { $WorkingDirectory = Split-Path -Path $Path -Parent -ErrorAction 'Stop' }
			
			## If MSI install, check to see if the MSI installer service is available or if another MSI install is already underway.
			## Please note that a race condition is possible after this check where another process waiting for the MSI installer
			##  to become available grabs the MSI Installer mutex before we do. Not too concerned about this possible race condition.
			If (($Path -match 'msiexec') -or ($WaitForMsiExec)) {
				[boolean]$MsiExecAvailable = Test-IsMutexAvailable -MutexName 'Global\_MSIExecute' -MutexWaitTimeInMilliseconds $MsiExecWaitTime.TotalMilliseconds
				Start-Sleep -Seconds 1
				If (-not $MsiExecAvailable) {
					#  Default MSI exit code for install already in progress
					[int32]$returnCode = 1618
					Throw 'Please complete in progress MSI installation before proceeding with this install.'
				}
			}
			
			Try {
				## Disable Zone checking to prevent warnings when running executables
				$env:SEE_MASK_NOZONECHECKS = 1
				
				## Using this variable allows capture of exceptions from .NET methods. Private scope only changes value for current function.
				$private:previousErrorActionPreference = $ErrorActionPreference
				$ErrorActionPreference = 'Stop'
				
				## Define process
				$processStartInfo = New-Object -TypeName 'System.Diagnostics.ProcessStartInfo' -ErrorAction 'Stop'
				$processStartInfo.FileName = $Path
				$processStartInfo.WorkingDirectory = $WorkingDirectory
				$processStartInfo.UseShellExecute = $false
				$processStartInfo.ErrorDialog = $false
				$processStartInfo.RedirectStandardOutput = $true
				$processStartInfo.RedirectStandardError = $true
				$processStartInfo.CreateNoWindow = $CreateNoWindow
				If ($Parameters) { $processStartInfo.Arguments = $Parameters }
				If ($windowStyle) { $processStartInfo.WindowStyle = $WindowStyle }
				$process = New-Object -TypeName 'System.Diagnostics.Process' -ErrorAction 'Stop'
				$process.StartInfo = $processStartInfo
				
				## Add event handler to capture process's standard output redirection
				[scriptblock]$processEventHandler = { If (-not [string]::IsNullOrEmpty($EventArgs.Data)) { $Event.MessageData.AppendLine($EventArgs.Data) } }
				$stdOutBuilder = New-Object -TypeName 'System.Text.StringBuilder' -ArgumentList ''
				$stdOutEvent = Register-ObjectEvent -InputObject $process -Action $processEventHandler -EventName 'OutputDataReceived' -MessageData $stdOutBuilder -ErrorAction 'Stop'
				
				## Start Process
				Write-Log -Message "Working Directory is [$WorkingDirectory]." -Source ${CmdletName}
				If ($Parameters) {
					If ($Parameters -match '-Command \&') {
						Write-Log -Message "Executing [$Path [PowerShell ScriptBlock]]..." -Source ${CmdletName}
					}
					Else {
						If ($SecureParameters) {
							Write-Log -Message "Executing [$Path (Parameters Hidden)]..." -Source ${CmdletName}
						}
						Else {							
							Write-Log -Message "Executing [$Path $Parameters]..." -Source ${CmdletName}
						}
					}
				}
				Else {
					Write-Log -Message "Executing [$Path]..." -Source ${CmdletName}
				}
				[boolean]$processStarted = $process.Start()
				
				If ($NoWait) {
					Write-Log -Message 'NoWait parameter specified. Continuing without waiting for exit code...' -Source ${CmdletName}
				}
				Else {
					$process.BeginOutputReadLine()
					$stdErr = $($process.StandardError.ReadToEnd()).ToString() -replace $null,''
					
					## Instructs the Process component to wait indefinitely for the associated process to exit.
					$process.WaitForExit()

					## Wait for child processes
					WaitForChildProcesses -ProcessId $process.Id
					
					## HasExited indicates that the associated process has terminated, either normally or abnormally. Wait until HasExited returns $true.
					While (-not ($process.HasExited)) { $process.Refresh(); Start-Sleep -Seconds 1 }
					
					## Get the exit code for the process
					Try {
						[int32]$returnCode = $process.ExitCode
					}
					Catch [System.Management.Automation.PSInvalidCastException] {
						#  Catch exit codes that are out of int32 range
						[int32]$returnCode = 60013
					}
					
					## Unregister standard output event to retrieve process output
					If ($stdOutEvent) { Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'Stop'; $stdOutEvent = $null }
					$stdOut = $stdOutBuilder.ToString() -replace $null,''
					
					If ($stdErr.Length -gt 0) {
						Write-Log -Message "Standard error output from the process: $stdErr" -Severity 3 -Source ${CmdletName}
					}
				}
			}
			Finally {
				## Make sure the standard output event is unregistered
				If ($stdOutEvent) { Unregister-Event -SourceIdentifier $stdOutEvent.Name -ErrorAction 'Stop'}
				
				## Free resources associated with the process, this does not cause process to exit
				If ($process) { $process.Close() }
				
				## Re-enable Zone checking
				Remove-Item -LiteralPath 'env:SEE_MASK_NOZONECHECKS' -ErrorAction 'SilentlyContinue'
				
				If ($private:previousErrorActionPreference) { $ErrorActionPreference = $private:previousErrorActionPreference }
			}
			
			If (-not $NoWait) {
				## Check to see whether we should ignore exit codes
				$ignoreExitCodeMatch = $false
				If ($ignoreExitCodes) {
					#  Split the processes on a comma
					[int32[]]$ignoreExitCodesArray = $ignoreExitCodes -split ','
					ForEach ($ignoreCode in $ignoreExitCodesArray) {
						If ($returnCode -eq $ignoreCode) { $ignoreExitCodeMatch = $true }
					}
				}
				#  Or always ignore exit codes
				If ($ContinueOnError) { $ignoreExitCodeMatch = $true }
				
				## If the passthru switch is specified, return the exit code and any output from process
				If ($PassThru) {
					Write-Log -Message "Execution completed with exit code [$returnCode]." -Source ${CmdletName}
					[psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{ ExitCode = $returnCode; StdOut = $stdOut; StdErr = $stdErr }
					Write-Output -InputObject $ExecutionResults
				}
				ElseIf ($ignoreExitCodeMatch) {
					Write-Log -Message "Execution complete and the exit code [$returncode] is being ignored." -Source ${CmdletName}
				}
				ElseIf (($returnCode -eq 3010) -or ($returnCode -eq 1641)) {
					Write-Log -Message "Execution completed successfully with exit code [$returnCode]. A reboot is required." -Severity 2 -Source ${CmdletName}
					Set-Variable -Name 'msiRebootDetected' -Value $true -Scope 'Script'
				}
				ElseIf (($returnCode -eq 1605) -and ($Path -match 'msiexec')) {
					Write-Log -Message "Execution failed with exit code [$returnCode] because the product is not currently installed." -Severity 3 -Source ${CmdletName}
				}
				ElseIf (($returnCode -eq -2145124329) -and ($Path -match 'wusa')) {
					Write-Log -Message "Execution failed with exit code [$returnCode] because the Windows Update is not applicable to this system." -Severity 3 -Source ${CmdletName}
				}
				ElseIf (($returnCode -eq 17025) -and ($Path -match 'fullfile')) {
					Write-Log -Message "Execution failed with exit code [$returnCode] because the Office Update is not applicable to this system." -Severity 3 -Source ${CmdletName}
				}
				ElseIf ($returnCode -eq 0) {
					Write-Log -Message "Execution completed successfully with exit code [$returnCode]." -Source ${CmdletName}
				}
				Else {
					[string]$MsiExitCodeMessage = ''
					If ($Path -match 'msiexec') {
						[string]$MsiExitCodeMessage = Get-MsiExitCodeMessage -MsiExitCode $returnCode
					}
					
					If ($MsiExitCodeMessage) {
						Write-Log -Message "Execution failed with exit code [$returnCode]: $MsiExitCodeMessage" -Severity 3 -Source ${CmdletName}
					}
					Else {
						Write-Log -Message "Execution failed with exit code [$returnCode]." -Severity 3 -Source ${CmdletName}
					}
					Exit-Script -ExitCode $returnCode
				}
			}
		}
		Catch {
			If ([string]::IsNullOrEmpty([string]$returnCode)) {
				[int32]$returnCode = 60002
				Write-Log -Message "Function failed, setting exit code to [$returnCode]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			}
			Else {
				Write-Log -Message "Execution completed with exit code [$returnCode]. Function failed. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			}
			If ($PassThru) {
				[psobject]$ExecutionResults = New-Object -TypeName 'PSObject' -Property @{ ExitCode = $returnCode; StdOut = If ($stdOut) { $stdOut } Else { '' }; StdErr = If ($stdErr) { $stdErr } Else { '' } }
				Write-Output -InputObject $ExecutionResults
			}
			Else {
				Exit-Script -ExitCode $returnCode
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}
#endregion

Function WaitForChildProcesses{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[int]$ProcessId
	)
	Try {
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
	
		$mos = New-Object -TypeName 'System.Management.ManagementObjectSearcher' -ErrorAction 'Stop'
		$mos.Query = "SELECT * FROM Win32_Process WHERE ParentProcessId=$ProcessId";

		$collection = $mos.Get()
		If ($collection.Count -igt 0)
		{
			foreach ($item in $collection)
			{
				$childProcId = $item["ProcessId"]
				$childProcName = $item["Name"]
				Write-Log -Message "Waiting for the child process to finish: ID=$childProcId, Name=$childProcName" -Source ${CmdletName}
				$process = [System.Diagnostics.Process]
				$childProcess = $process::GetProcessById($childProcId)
				$childProcess.WaitForExit()

				# Wait for child processes of the current child process
				WaitForChildProcesses -ProcessId $childProcId
			}
		}
	}
	Catch {
		Write-Log -Message "Failed to get the child processes of the process ID=[$ProcessId]." -Severity 3 -Source ${CmdletName}
	}
}


Function Ray-Add-Content {
<#
.SYNOPSIS
	Appending Data to a Text File.
.DESCRIPTION
	Appending Data to a Text File.
.PARAMETER Path
	Path of the file.
.PARAMETER Content
	Content to be added to the file.
.PARAMETER EndWithNewLine
	Add NewLine character to Content.
.PARAMETER ContinueOnError
	Continue if an error is encountered
.EXAMPLE
	Ray-Add-Content -Path "addcontent.txt" -Content "I koniec pliku!" -Bit64 -EndWithNewLine
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Content,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$EndWithNewLine = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			If($EndWithNewLine){
				$Content = $Content + "`r`n"
			}
						
			
			Add-Content $Path $Content -NoNewline
		}
		Catch {
			Write-Log -Message "Failed to add content to  file in path [$path] (Bit64 [$Bit64]). `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to add content to  file in path [$path] (Bit64 [$Bit64]): $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Copy-File {
<#
.SYNOPSIS
	Copy a file or group of files to a destination path.
.DESCRIPTION
	Copy a file or group of files to a destination path.
.PARAMETER Path
	Path of the file to copy.
.PARAMETER Destination
	Destination Path of the file to copy.
.PARAMETER Recurse
	Copy files in subdirectories.
.PARAMETER Flatten
	Flattens the files into the root destination directory.
.PARAMETER ContinueOnError
	Continue if an error is encountered. This will continue the deployment script, but will not continue copying files if an error is encountered. Default is: $true.
.PARAMETER ContinueFileCopyOnError
	Continue copying files if an error is encountered. This will continue the deployment script and will warn about files that failed to be copied. Default is: $false.
.EXAMPLE
	Ray-Copy-File -Path "$dirSupportFiles\MyApp.ini" -Destination "$envWinDir\MyApp.ini"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Destination,
		[Parameter(Mandatory=$false)]
		[switch]$Recurse = $false,
		[Parameter(Mandatory=$false)]
		[switch]$Flatten,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true,
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueFileCopyOnError = $false	
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			# Create destination folder structure if it does not exist
			$destFolder = Split-Path -Path $Destination -Parent
			If (-Not (Test-Path $destFolder))
			{
				New-Item -ItemType directory -Path $destFolder
			}
		
			# Prepare parameters
			$param = @{ 'Path' = $Path; 'Destination' = $Destination}
			$param = ParseParam $PSBoundParameters 'Recurse' $param -DoNotReplaceString 
			$param = ParseParam $PSBoundParameters 'Flatten' $param -DoNotReplaceString 
			$param = ParseParam $PSBoundParameters 'ContinueOnError' $param -DoNotReplaceString 
			$param = ParseParam $PSBoundParameters 'ContinueFileCopyOnError' $param -DoNotReplaceString 
			
			# Call toolkit function
			Copy-File @param
		}
		Catch {
			Write-Log -Message "Failed to copy file(s) in path [$path] to destination [$destination]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to copy file(s) in path [$path] to destination [$destination]: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Copy-Folder {
<#
.SYNOPSIS
	Copy a folder to a destination path.
.DESCRIPTION
	Copy a folder to a destination path.
.PARAMETER Path
	Path of the folder to copy.
.PARAMETER Destination
	Destination Path of the folder to copy.
.PARAMETER Recurse
	Copy subdirectories.
.PARAMETER ContinueOnError
	Continue if an error is encountered	
.EXAMPLE
	Ray-Copy-Folder -Path "$dirSupportFiles\MyFolder" -Destination "$envWindir\MyFolder"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Destination,
		[Parameter(Mandatory=$false)]
		[switch]$Recurse = $false,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true		
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			# RSC-376 - Create destination folder structure if it does not exist
			$destFolder = Split-Path -Path $Destination -Parent
			If (-Not (Test-Path $destFolder))
			{
				New-Item -ItemType directory -Path $destFolder
			}

			# Prepare parameters
			$param = @{ 'Path' = $Path; 'Destination' = $Destination}
			$param = ParseParam $PSBoundParameters 'Recurse' $param -DoNotReplaceString 
			
			# Call PsAppDeployToolkit function
			Copy-File @param
		}
		Catch {
			Write-Log -Message "Failed to copy folder in path [$path] to destination [$destination]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to copy folder in path [$path] to destination [$destination]: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Set-IniValue {
<#
.SYNOPSIS
	Opens an INI file and sets the value of the specified section and key.
.DESCRIPTION
	Opens an INI file and sets the value of the specified section and key.
.PARAMETER FilePath
	FULL Path to the INI file.
.PARAMETER Section
	Section within the INI file.
.PARAMETER Key
	Key within the section of the INI file.
.PARAMETER Value
	Value for the key within the section of the INI file. To remove a value, set this variable to $null.
.PARAMETER ContinueOnError
	Continue if an error is encountered.
.EXAMPLE
	Set-IniValue -FilePath "$envProgramFilesX86\IBM\Notes\notes.ini" -Section 'Notes' -Key 'KeyFileName' -Value 'MyFile.ID'
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Section,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Key,
		# Don't strongly type this variable as [string] b/c PowerShell replaces [string]$Value = $null with an empty string
		[Parameter(Mandatory=$true)]
		[AllowNull()]
		$Value,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $true
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			
			Set-IniValue -FilePath $FilePath -Section $Section -Key $Key -Value $Value
		}
		Catch {
			Write-Log -Message "Failed to write INI file key value. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to write INI file key value: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-RegistryKey {
<#
.SYNOPSIS
	Deletes the specified registry key or value.
.DESCRIPTION
	Deletes the specified registry key or value.
.PARAMETER Key
	Path of the registry key to delete.
.PARAMETER Name
	Name of the registry value to delete.
.PARAMETER Recurse
	Delete registry key recursively.
.PARAMETER SID
	The security identifier (SID) for a user. Specifying this parameter will convert a HKEY_CURRENT_USER registry key to the HKEY_USERS\$SID format.
	Specify this parameter from the Invoke-HKCURegistrySettingsForAllUsers function to read/edit HKCU registry settings for all users on the system.
.PARAMETER Bit64
	Targets platform x64.
.PARAMETER ContinueOnError
	Continue if an error is encountered. Default is: $true.
.EXAMPLE
	Remove-RegistryKey -Key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
.EXAMPLE
	Remove-RegistryKey -Key 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'RunAppInstall'
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Key,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory=$false)]
		[switch]$Recurse,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$SID,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$Bit64 = $false,		
		[Parameter(Mandatory=$false)]
		[switch]$OnlyIfEmpty
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			$Key = FixRegistryPath -StringToReplace $Key -Bit64 $Bit64	
			
			$param = @{ 'Key' = $Key}
			
			$param = ParseParam $PSBoundParameters 'Name' $param -Bit64 $Bit64
			
			$param = ParseParam $PSBoundParameters 'SID' $param -Bit64 $Bit64
			
			$param = ParseParam $PSBoundParameters 'Recurse' $param -DoNotReplaceString
			
			If ($OnlyIfEmpty)
			{
				$regKey = Get-Item Registry::$Key
				If (($regKey -eq $null) -or (($regKey.ValueCount -le 0) -and ($regKey.SubKeyCount -le 0)))
				{
					Remove-RegistryKey @param
				}
				Else
				{
					Write-Log -Message "The registry key [$Key] is not empty so it will not be removed." -Source ${CmdletName}
				}
			}
			Else 
			{
				Remove-RegistryKey @param
			}
		}
		Catch {
			If (-not ($Name)) {
				Write-Log -Message "Failed to delete registry key [$Key]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
				If (-not $ContinueOnError) {
					Throw "Failed to delete registry key [$Key]: $($_.Exception.Message)"
				}
			}
			Else {
				Write-Log -Message "Failed to delete registry value [$Key] [$Name]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
				If (-not $ContinueOnError) {
					Throw "Failed to delete registry value [$Key] [$Name]: $($_.Exception.Message)"
				}
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-File {
<#
.SYNOPSIS
	Remove a file or all files recursively in a given path.
.DESCRIPTION
	Remove a file or all files recursively in a given path.
.PARAMETER Path
	Path of the file to remove.
.PARAMETER Recurse
	Optionally, remove all files recursively in a directory.
.PARAMETER ContinueOnError
	Continue if an error is encountered.	
.EXAMPLE
	Remove-File -Path 'C:\Windows\Downloaded Program Files\Temp.inf'
.EXAMPLE
	Remove-File -Path 'C:\Windows\Downloaded Program Files' -Recurse
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[switch]$Recurse,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}

	Process {
		Try {
			$param = @{ 'Path' = $Path}
			$param = ParseParam $PSBoundParameters 'Recurse' $param -DoNotReplaceString
			
			Remove-File @param

			Write-Log -Message "Successfully deleted: [File] $Path" -Source ${CmdletName}
		}
		Catch {
			Write-Log -Message "Failed to delete file(s) in path [$path]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to delete file(s) in path [$path]: $($_.Exception.Message)"
			}
		}
	}

	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-Folder {
<#
.SYNOPSIS
	Remove folder and files if they exist.
.DESCRIPTION
	Remove folder and all files recursively in a given path.
.PARAMETER Path
	Path to the folder to remove.
.PARAMETER ContinueOnError
	Continue if an error is encountered	
.PARAMETER OnlyIfEmpty
	Remove only if the folder is empty (there is no file in the top directory and sub-directories).	
.EXAMPLE
	Remove-Folder -Path "$envWinDir\Downloaded Program Files"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[switch]$DisableRecursion,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true,
		[Parameter(Mandatory=$false)]
		[switch]$OnlyIfEmpty
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}

	Process {
		Try {
			$param = @{ 'Path' = $Path }	
			$param = ParseParam $PSBoundParameters 'DisableRecursion' $param -DoNotReplaceString	
			$param = ParseParam $PSBoundParameters 'ContinueOnError' $param -DoNotReplaceString		
			
			If ($OnlyIfEmpty)
			{
				$files = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.PSIsContainer -eq $False }
				If (($files -eq $null) -or ($files.Length -le 0))
				{
					Remove-Folder @param
				}
				Else
				{
					Write-Log -Message "The folder [$path] is not empty so it will not be removed." -Source ${CmdletName}
				}
			}
			Else 
			{
				Remove-Folder @param
			}

			Write-Log -Message "Successfully deleted: [Folder] $Path" -Source ${CmdletName}
		}
		Catch {
			Write-Log -Message "Failed to delete folder(s) and file(s) recursively from path [$path]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to delete folder(s) and file(s) recursively from path [$path]: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-Item {
<#
.SYNOPSIS
	Remove a file or all files recursively in a given path.
.DESCRIPTION
	Remove a file or all files recursively in a given path.
.PARAMETER Path
	Path of the file or directory to remove.
.PARAMETER Recurse
	Optionally, remove all files recursively in a directory.
.PARAMETER ContinueOnError
	Continue if an error is encountered.	
.EXAMPLE
	Ray-Remove-Item -Path 'C:\Windows\Downloaded Program Files\Temp.inf'
.EXAMPLE
	Ray-Remove-Item -Path 'C:\Windows\Downloaded Program Files'
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Path,
		[Parameter(Mandatory=$false)]
		[switch]$Recurse,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true
	)

	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	
	Process {
		$isFolder= (Get-Item $Path) -is [System.IO.DirectoryInfo]
		$param = @{ 'Path' = $Path; 'ContinueOnError' = $ContinueOnError }

		if ($isFolder)
		{
			Write-Log -Message "Removing folder: $Path" -Source ${CmdletName}
			Ray-Remove-Folder @param;
		}
		else
		{
			Write-Log -Message "Removing file: $Path" -Source ${CmdletName}
			Ray-Remove-File @param;
		}
	}
	
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Set-RegistryKey {
<#
.SYNOPSIS
	Creates a registry key name, value, and value data; it sets the same if it already exists.
.DESCRIPTION
	Creates a registry key name, value, and value data; it sets the same if it already exists.
.PARAMETER Key
	The registry key path.
.PARAMETER Name
	The value name.
.PARAMETER Value
	The value data.
.PARAMETER Type
	The type of registry value to create or set. Options: 'Binary','DWord','ExpandString','MultiString','None','QWord','String','Unknown'. Default: String.
.PARAMETER SID
	The security identifier (SID) for a user. Specifying this parameter will convert a HKEY_CURRENT_USER registry key to the HKEY_USERS\$SID format.
	Specify this parameter from the Invoke-HKCURegistrySettingsForAllUsers function to read/edit HKCU registry settings for all users on the system.
.PARAMETER ContinueOnError
	Continue if an error is encountered. Default is: $true.
.PARAMETER Bit64
	Targets platform x64.		
.EXAMPLE
	Ray-Set-RegistryKey -Key $blockedAppPath -Name 'Debugger' -Value $blockedAppDebuggerValue
.EXAMPLE
	Ray-Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'Debugger' -Value $blockedAppDebuggerValue -Type String
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Key,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		[Parameter(Mandatory=$false)]
		$Value,
		[Parameter(Mandatory=$false)]
		[ValidateSet('Binary','DWord','ExpandString','MultiString','None','QWord','String','Unknown')]
		[Microsoft.Win32.RegistryValueKind]$Type = 'String',
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$SID,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[boolean]$ContinueOnError = $true,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[switch]$Bit64 = $false
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
		
			$Key = FixRegistryPath -StringToReplace $Key -Bit64 $Bit64
	
			## RSC-403 - If it is a multi-string registry value (REG_MULTI_SZ), then append the value instead of ovwrwriting it
			If ($Type -ieq 'MultiString')
			{
				$multiValue = Get-RegistryKey -Key $Key -Value $Name -ContinueOnError $True
				If ($multiValue)
				{
					$multiValue += "`r`n$Value"
					$Value = $multiValue
				}
			}

			$param = @{ 'Key' = $Key; 'Value' = $Value }
			$param = ParseParam $PSBoundParameters 'Name' $param 
			$param = ParseParam $PSBoundParameters 'Type' $param 
			$param = ParseParam $PSBoundParameters 'SID' $param 
			$param = ParseParam $PSBoundParameters 'Recurse' $param -DoNotReplaceString

			Set-RegistryKey @param
			
		}
		Catch {
			If ($Name) {
				Write-Log -Message "Failed to $RegistryValueWriteAction value [$value] for registry key [$key] [$name]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
				If (-not $ContinueOnError) {
					Throw "Failed to $RegistryValueWriteAction value [$value] for registry key [$key] [$name]: $($_.Exception.Message)"
				}
			}
			Else {
				Write-Log -Message "Failed to set registry key [$key]. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
				If (-not $ContinueOnError) {
					Throw "Failed to set registry key [$key]: $($_.Exception.Message)"
				}
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-IniKey {
<#
.SYNOPSIS
	Opens an INI file and removes specified value and key.
.DESCRIPTION
	Opens an INI file and removes specified value and key.
.PARAMETER FilePath
	FULL Path to the INI file.
.PARAMETER Section
	Section within the INI file.
.PARAMETER Key
	Key within the section of the INI file.
.PARAMETER ContinueOnError
	Continue if an error is encountered.
.EXAMPLE
	Ray-Remove-IniKey -FilePath "$envProgramFilesX86\IBM\Notes\notes.ini" -Section 'Notes' -Key 'KeyFileName' 
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Section,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Key,		
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $true
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
				
			[IniFileHelper]::RemoveIniKey($FilePath, $Section, $Key)			
		}
		Catch {
			Write-Log -Message "Failed to write INI file key value. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to write INI file key value: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Remove-IniSection {
<#
.SYNOPSIS
	Opens an INI file and removes specified section.
.DESCRIPTION
	Opens an INI file and removes specified section.
.PARAMETER FilePath
	FULL Path to the INI file.
.PARAMETER Section
	Section within the INI file.
.PARAMETER Key
	Key within the section of the INI file.
.PARAMETER ContinueOnError
	Continue if an error is encountered.
.EXAMPLE
	Ray-Remove-IniSection -FilePath "$envProgramFilesX86\IBM\Notes\notes.ini" -Section 'Notes' 
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$Section,		
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $true
	)
	
	Begin {
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
		Try {
			[IniFileHelper]::RemoveIniSection($FilePath, $Section)			
		}
		Catch {
			Write-Log -Message "Failed to write INI file key value. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to write INI file key value: $($_.Exception.Message)"
			}
		}
	}
	End {
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}
#endregion

Function Ray-Set-ActiveSetup {
<#
.SYNOPSIS
	Creates an Active Setup entry in the registry to execute a file for each user upon login.
.DESCRIPTION
	Active Setup allows handling of per-user changes registry/file changes upon login.
	A registry key is created in the HKLM registry hive which gets replicated to the HKCU hive when a user logs in.
	If the "Version" value of the Active Setup entry in HKLM is higher than the version value in HKCU, the file referenced in "StubPath" is executed.
	This Function:
	- Creates the registry entries in HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\$installName.
	- Creates StubPath value depending on the file extension of the $StubExePath parameter.
	- Handles Version value with YYYYMMDDHHMMSS granularity to permit re-installs on the same day and still trigger Active Setup after Version increase.
	- Copies/overwrites the StubPath file to $StubExePath destination path if file exists in 'Files' subdirectory of script directory.
	- Executes the StubPath file for the current user as long as not in Session 0 (no need to logout/login to trigger Active Setup).
.PARAMETER StubExePath
	Full destination path to the file that will be executed for each user that logs in.
	If this file exists in the 'Files' subdirectory of the script directory, it will be copied to the destination path.
.PARAMETER Arguments
	Arguments to pass to the file being executed.
.PARAMETER Description
	Description for the Active Setup. Users will see "Setting up personalized settings for: $Description" at logon. Default is: $installName.
.PARAMETER Key
	Name of the registry key for the Active Setup entry. Default is: $installName.
.PARAMETER Version
	Optional. Specify version for Active setup entry. Active Setup is not triggered if Version value has more than 8 consecutive digits. Use commas to get around this limitation.
.PARAMETER Locale
	Optional. Arbitrary string used to specify the installation language of the file being executed. Not replicated to HKCU.
.PARAMETER PurgeActiveSetupKey
	Remove Active Setup entry from HKLM registry hive. Will also load each logon user's HKCU registry hive to remove Active Setup entry.
.PARAMETER DisableActiveSetup
	Disables the Active Setup entry so that the StubPath file will not be executed.
.PARAMETER ExecuteForCurrentUser
	Specifies whether the StubExePath should be executed for the current user. Since this user is already logged in, the user won't have the application started without logging out and logging back in. Default: $True
.PARAMETER ContinueOnError
	Continue if an error is encountered. Default is: $true.
.EXAMPLE
	Ray-Set-ActiveSetup -StubExePath 'C:\Users\Public\Company\ProgramUserConfig.vbs' -Arguments '/Silent' -Description 'Program User Config' -Key 'ProgramUserConfig' -Locale 'en'
.EXAMPLE
	Ray-Set-ActiveSetup -StubExePath "$envWinDir\regedit.exe" -Arguments "/S `"%SystemDrive%\Program Files (x86)\PS App Deploy\PSAppDeployHKCUSettings.reg`"" -Description 'PS App Deploy Config' -Key 'PS_App_Deploy_Config' -ContinueOnError $true
.EXAMPLE
	Ray-Set-ActiveSetup -Key 'ProgramUserConfig' -PurgeActiveSetupKey
	Deletes "ProgramUserConfig" active setup entry from all registry hives.
.NOTES
	Original code borrowed from: Denis St-Pierre (Ottawa, Canada), Todd MacNaught (Ottawa, Canada)
.LINK
	http://psappdeploytoolkit.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[string]$StubExePath,
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[string]$Arguments,
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[string]$Description = $installName,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$Key = $installName,
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[string]$Version = ((Get-Date -Format 'yyMM,ddHH,mmss').ToString()), # Ex: 1405,1515,0522
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[string]$Locale,
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[switch]$DisableActiveSetup = $false,
		[Parameter(Mandatory=$true,ParameterSetName='Purge')]
		[switch]$PurgeActiveSetupKey,
		[Parameter(Mandatory=$false,ParameterSetName='Create')]
		[ValidateNotNullorEmpty()]
		[boolean]$ExecuteForCurrentUser = $true,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[boolean]$ContinueOnError = $true
	)

    ## Prepare parameters
    $param = @{ 'StubExePath' = $StubExePath }

    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Arguments' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Description' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Key' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Version' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'Locale' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'DisableActiveSetup' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'PurgeActiveSetupKey' -ParameterHashtable $param -DoNotReplaceString
	$param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ExecuteForCurrentUser' -ParameterHashtable $param -DoNotReplaceString
    $param = ParseParam -BoundParameters $PSBoundParameters -ParameterName 'ContinueOnError' -ParameterHashtable $param -DoNotReplaceString

    ## Execute command
    Set-ActiveSetup @param 
}

#region Supporting Functions
Function FixRegistryPath {
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true,HelpMessage='Please enter a string')]
        [AllowEmptyString()]
		$StringToReplace,
        [Parameter(Mandatory=$false)]
		[boolean]$Bit64 = $false)

    Begin
    {
        $output = $StringToReplace
        $dict = @{"^HKCU\\Software" = "HKCU\Software\Wow6432Node"; "^HKLM\\SOFTWARE" = "HKLM\SOFTWARE\Wow6432Node"; "^HKEY_CURRENT_USER\\Software" = "HKEY_CURRENT_USER\Software\Wow6432Node"; "^HKEY_LOCAL_MACHINE\\SOFTWARE" = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node"}
    }
    
    Process
    {
        If (-Not [string]::IsNullOrEmpty($StringToReplace))
        {
            If ($Is64Bit)
            {
                If (-Not $Bit64)
                {
                    If ($output -notmatch "Wow6432Node")
                    {
                        ForEach ($key in $dict.Keys)
                        {
                            If ($output -match $key)
                            {
                                $output = $output -replace $key, $dict[$key]
                            }
                        }
                    }
                }
            }
        }   
    }

    End
    {
        return $output   
    }
}

Function ParseParam {
    [CmdletBinding()]
    Param (
        [hashtable]$BoundParameters,
        [string]$ParameterName,
        [hashtable]$ParameterHashtable,
        [switch]$DoNotReplaceString,
        [boolean]$Bit64 = $false)
 
    Begin
    {
        $output = $ParameterHashtable
    }
    
    Process
    {
        if( $BoundParameters.ContainsKey($ParameterName) ) 
        { 
            $parameterValue = $BoundParameters[$ParameterName]
            if(-not $DoNotReplaceString)
            {
                $parameterValue = FixRegistryPath -StringToReplace $parameterValue -Bit64 $Bit64 
            }

            $output.Add($ParameterName, $parameterValue)
        }
    }

    End
    {
        return $output   
    }
}
Function Ray-Call-Script {
<#
.SYNOPSIS
	Execute script or function in it.
.DESCRIPTION
	Execute script or function in it.
.PARAMETER FilePath
	Path to the script file.
.PARAMETER FunctionName
	Name of the function in script file.
.PARAMETER FunctionParameters
	Paramteres for function.		
.EXAMPLE
	Ray-Call-Script -FilePath "script.ps1" -ScriptParameters "param1 param2 param3"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$ScriptParameters
	)
	
	Begin {	
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
	
		Try {
				#run entire script
				if($PSBoundParameters.ContainsKey('ScriptParameters'))
				{								
					Invoke-Expression "$FilePath $ScriptParameters"
				}
				else
				{					
					Invoke-Expression "$FilePath"
				}
		}
		Catch {			
			Write-Log -Message "Failed to call script. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to call script: $($_.Exception.Message)"
			}
		}
	}
	End {	
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Call-PowerShellScript {
<#
.SYNOPSIS
	Execute powershell script or function in it.
.DESCRIPTION
	Execute powershell script or function in it.
.PARAMETER FilePath
	Path to the script file.
.PARAMETER FunctionName
	Name of the function in script file.
.PARAMETER FunctionParameters
	Paramteres for function.		
.EXAMPLE
	Ray-Call-PowerShellScript -FilePath "script.ps1" -FunctionName "function1" -FunctionParameters "param1 param2 param3"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$FunctionName,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$FunctionParameters
	)
	
	Begin {	
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
	
		Try {
						
			if( $PSBoundParameters.ContainsKey('FunctionName')) 
			{ 
				#run Function
				#register script file
				Try {				
					If (-not (Test-Path -LiteralPath $FilePath -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$FilePath]." }
					import-module $FilePath -Force
				}
				Catch {
					[int32]$mainExitCode = 60008
					Write-Error -Message "Module [$Raynet] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
					Exit $mainExitCode
				}
				
				if($PSBoundParameters.ContainsKey('FunctionParameters'))
				{										
					invoke-expression "$FunctionName $FunctionParameters"
				}
				else
				{				
					&$FunctionName
				}								
			}
			else
			{
				#run entire script
				if($PSBoundParameters.ContainsKey('FunctionParameters'))
				{								
					Invoke-Expression "$FilePath $FunctionParameters"
				}
				else
				{					
					Invoke-Expression "$FilePath"
				}
			}
			
			
		}
		Catch {			
			Write-Log -Message "Failed to call script. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to call script: $($_.Exception.Message)"
			}
		}
	}
	End {	
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}

Function Ray-Call-VbScript {
<#
.SYNOPSIS
	Execute powershell script or function in it.
.DESCRIPTION
	Execute powershell script or function in it.
.PARAMETER FilePath
	Path to the script file.
.PARAMETER ScriptParameters
	Paramteres for function.		
.EXAMPLE
	Ray-Call-VbScript -FilePath "script.vbs" -ScriptParameters "param1 param2"
.NOTES
.LINK
	http://psappdeploytoolkit.codeplex.com
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullorEmpty()]
		[string]$FilePath,
		[Parameter(Mandatory=$false)]
		[ValidateNotNullorEmpty()]
		[string]$ScriptParameters
	)
	
	Begin {	
		## Get the name of this function and write header
		[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
	}
	Process {
	
		Try {
				#run entire script
				if($PSBoundParameters.ContainsKey('ScriptParameters'))
				{								
					 Invoke-Expression "cscript.exe $FilePath $ScriptParameters"
				}
				else
				{					
					 cscript.exe "$FilePath"
				}
		}
		Catch {			
			Write-Log -Message "Failed to call script. `n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
			If (-not $ContinueOnError) {
				Throw "Failed to call script: $($_.Exception.Message)"
			}
		}
	}
	End {	
		Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
	}
}
#endregion

#region CSharpCode INIFile
    $CSharpCode = @"

    using System.Text;
    using System.Runtime.InteropServices;

    public static class IniFileHelper
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool WritePrivateProfileString(string lpAppName, string lpKeyName, StringBuilder lpString, string lpFileName);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = false)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool WritePrivateProfileSection(string lpAppName, StringBuilder lpString, string lpFileName);

        public static void RemoveIniSection(string filePath, string sectionName)
        {
            WritePrivateProfileSection(sectionName, null, filePath);
        }

        public static void RemoveIniKey(string filePath, string sectionName, string keyName)
        {
            WritePrivateProfileString(sectionName, keyName, null, filePath);
        }
    }
"@

$AssembliesToLoad = @("mscorlib.dll")
Add-Type -ReferencedAssemblies $AssembliesToLoad -TypeDefinition $CSharpCode -Language CSharp

#endregion

