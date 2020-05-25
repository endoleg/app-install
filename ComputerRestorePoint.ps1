if (-not (Get-ComputerRestorePoint))
		{
			Enable-ComputerRestore -Drive $env:SystemDrive
		}
		# Set system restore point creation frequency to 5 minutes
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -PropertyType DWord -Value 5 -Force
		# Descriptive name format for the restore point: <Month>.<date>.<year> <time>
		$CheckpointDescription = Get-Date -Format "dd.MM.yyyy HH:mm"
		Checkpoint-Computer -Description $CheckpointDescription -RestorePointType MODIFY_SETTINGS
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -PropertyType DWord -Value 1440 -Force
