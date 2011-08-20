
function Get-SystemInternalsSuite()
{
	$currentLocation = Get-Location
	Push-Location $env:TEMP
	Get-WebFile "http://download.sysinternals.com/Files/SysinternalsSuite.zip"
	new-item "bin" -type directory -ErrorAction SilentlyContinue
	Expand-Archive "SysinternalsSuite.zip" -OutputPath "bin"
	Copy-Item "bin/*" -Destination $global:SlightyPosherBin -Force
	Remove-Item "bin" -recurse
	Push-Location $currentLocation 
}

#Credit: http://robertrobelo.wordpress.com/2010/03/19/balloon-tip-notifications/
function Show-BalloonTip {
 # Requires -Version 2.0
 [CmdletBinding()]
 param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidateNotNull()]
  [String]
  $BalloonTipText,
  [Parameter(Position = 1)]
  [String]
  $BalloonTipTitle = 'PowerShell Event Notificaton',
  [Parameter(Position = 2)]
  [ValidateSet('Error', 'Info', 'None', 'Warning')]
  [String]
  $BalloonTipIcon = 'Info'
 )
 end {
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  [Windows.Forms.ToolTipIcon]$BalloonTipIcon = $BalloonTipIcon
  $NotifyIcon = New-Object Windows.Forms.NotifyIcon -Property @{
   BalloonTipIcon = $BalloonTipIcon
   BalloonTipText = $BalloonTipText
   BalloonTipTitle = $BalloonTipTitle
   Icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)
   Text = -join $BalloonTipText[0..62]
   Visible = $true
  }
  switch ($BalloonTipIcon) {
   Error {[Media.SystemSounds]::Hand.Play()}
   Info {[Media.SystemSounds]::Asterisk.Play()}
   None {[Media.SystemSounds]::Beep.Play()}
   Warning {[Media.SystemSounds]::Exclamation.Play()}
  }
  $NotifyIcon.ShowBalloonTip(0)
  switch ($Host.Runspace.ApartmentState) {
   STA {
    $null = Register-ObjectEvent -InputObject $NotifyIcon -EventName BalloonTipClosed -Action {
	 $Sender.Dispose()
     Unregister-Event $EventSubscriber.SourceIdentifier
     Remove-Job $EventSubscriber.Action
    }
   }
   default {
    continue
   }
  }
 }
}

#Credit: http://www.techmumbojumblog.com/?p=304
function Get-Checksum($file, $crypto_provider) {
	if ($crypto_provider -eq $null) {
		$crypto_provider = new-object 'System.Security.Cryptography.MD5CryptoServiceProvider';
	}		

	$file_info	= get-item $file;
	trap { ;
	continue } $stream = $file_info.OpenRead();
	if ($? -eq $false) {
		return $null;
	}

	$bytes		= $crypto_provider.ComputeHash($stream);
	$checksum	= '';
	foreach ($byte in $bytes) {
		$checksum	+= $byte.ToString('x2');
	}

	$stream.close() | out-null;

	return $checksum;
}