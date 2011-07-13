$originalLocation = Get-Location

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

$global:SlightlyPosherBin = Join-Path (Split-Path -Path (Get-Location).ToString() -Parent) -ChildPath "bin"
$global:SlightlyPosherDir = Get-Location

Import-Module .\modules\PowerTab -ArgumentList ".\modules\PowerTab\profile\PowerTabConfig.xml"

Import-Module .\modules\Pscx -arg ".\modules\pscx\Pscx.UserPreferences.ps1"

Import-Module .\modules\VS

Import-Module .\modules\LINQ
Write-Host -ForegroundColor 'Yellow' "LINQ Module loaded"

Import-Module .\modules\WGet
Write-Host -ForegroundColor 'Yellow' "WGet Module loaded"

Import-Module .\modules\SlightlyPosher
Write-Host -ForegroundColor 'Yellow' "SlightPosher Module loaded"

Set-VsVars32 2010
 
#Credit: http://www.nivot.org/post/2009/08/15/PowerShell20PersistingCommandHistory.aspx
# save last 100 history items on exit
$historyPath = Join-Path (split-path $profile) history.clixml
 
# hook powershell's exiting event & hide the registration with -supportevent.
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count 1000 | Export-Clixml (Join-Path (split-path $profile) history.clixml) }
 
# load previous history, if it exists
if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
    Write-Host -Fore Green "`nLoaded $count history item(s).`n"
}

Push-Location $originalLocation
