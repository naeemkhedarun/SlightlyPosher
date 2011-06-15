$originalLocation = Get-Location

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Import-Module .\modules\PowerTab -ArgumentList ".\modules\PowerTab\profile\PowerTabConfig.xml"

Import-Module .\modules\Pscx -arg ".\modules\pscx\Pscx.UserPreferences.ps1"

Import-Module .\modules\VS

Import-Module .\modules\LINQ
Write-Host -ForegroundColor 'Yellow' "Loaded LINQ Module"

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