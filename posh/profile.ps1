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

#### Functions Used to Load VS Command Prompt #####
  
function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}
  
function VsVars32()
{
    $vs90comntools = get-childitem Env: | where {$_.Name -eq "VS90COMNTOOLS"}    
    $batchFile = [System.IO.Path]::Combine($vs90comntools.Value, "vsvars32.bat")
    Get-Batchfile -file $batchFile
}
 
###### Run Functions on Startup ######
VsVars32
 
Push-Location $originalLocation
