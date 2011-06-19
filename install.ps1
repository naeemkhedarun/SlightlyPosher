$hasProfile = Test-Path $PROFILE
if($hasProfile -eq $false)
{
	$profileDirectory = Split-Path $PROFILE -Parent
	New-Item $profileDirectory -type directory
	
	New-Item $PROFILE -type file
}

$root = gl
Add-Content $PROFILE "$root\posh\profile.ps1"
Add-Content $PROFILE ('$env:Path += ";' + $root + '\bin"')
