$hasProfile = Test-Path $PROFILE
if($hasProfile -eq $false)
{
	$profileDirectory = Split-Path $PROFILE -Parent
	New-Item $profileDirectory -type directory
	
	New-Item $PROFILE -type file
	"Creating profile."
}

$root = gl

$isInstalled = Get-Content $PROFILE | ForEach-Object { if($_.Contains("$root\posh\profile.ps1") -eq $true){$true;}}

if($isInstalled -ne $true){

	Add-Content $PROFILE "$root\posh\profile.ps1"
	Add-Content $PROFILE ('$env:Path += ";' + $root + '\bin"')
	
	"Your environment has been configured at: " + $PROFILE
}
else
{
	Write-Host "Your environment is already configured at: " + $PROFILE
}
