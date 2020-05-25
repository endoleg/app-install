function SetPasswordPolicy{
	$confirm = Read-Host("Would you like to set a password policy? [Y\n]")
	if ( ("y", "yes", "") -contains $confirm){
		$default = Read-Host("Use default values? (maxpwage:30, minpwage:0, minpwlen:10, lockoutthreshold:10, uniquepw:2) [y\N]")
		if ( ("y", "yes") -contains $default){
			net accounts /maxpwage:30 /minpwage:0 /minpwlen:10 /lockoutthreshold:10 /uniquepw:2 
		}
		else {
			$maxage = Read-Host("Maximum password age")
			$minage = Read-Host("Minimum password age")
			$minlen = Read-Host("Minimum password length")
			$lockouthreshold = Read-Host("Lockout threshold")
			$uniquepw = Read-Host("Unique passwords")

			net accounts /maxpwage:$maxage /minpwage:$minage /minpwlen:$minlen /lockoutthreshold:$lockouthreshold /uniquepw:$uniquepw 
		}
	}
	else {
		Write-Host("No password policy set")
	}
}
