#### Functions Used to Load VS Command Prompt #####
function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function Set-VsVars32($vsYear)
{
   switch ($vsYear)
   {
        2008 {$vstools = $env:VS90COMNTOOLS}
        2010 {$vstools = $env:VS100COMNTOOLS }
   }

   $batchFile = [System.IO.Path]::Combine($vstools, "vsvars32.bat") 
   
   Get-Batchfile -file $batchFile
   
   Write-Host -ForegroundColor 'Yellow' "VsVars has been loaded from: $batchFile"
}

function Clear-Assemblies($directory)
{
	Get-ChildItem $directory -include bin,obj -Recurse | foreach ($_) { 
		"Cleaning: " + $_.fullname
		remove-item $_.fullname -Force -Recurse 
	}
}

function Set-CopyLocalFalse($projectFile, $doProjectReferences, $tfsCheckout)
{
	[xml]$s = get-content $projectFile

	$references = $s.Project.ItemGroup | Where-Object { $_.Reference -ne $null }
	$projectReferences = $s.Project.ItemGroup | Where-Object { $_.ProjectReference -ne $null }
		
	foreach($reference in $references.ChildNodes)
	{ 
		if($reference.Private -eq $null)
		{
			[System.Xml.XmlElement]$copyLocal = $s.CreateElement("Private", "http://schemas.microsoft.com/developer/msbuild/2003")
			$copyLocal.InnerText = "False"
			[Void]$reference.AppendChild($copyLocal) 
		}
	}

	if($doProjectReferences -eq $true)
	{
		foreach($reference in $projectReferences.ChildNodes)
		{ 
			if($reference.Private -eq $null)
			{
				[System.Xml.XmlElement]$copyLocal = $s.CreateElement("Private", "http://schemas.microsoft.com/developer/msbuild/2003")
				$copyLocal.InnerText = "False"
				[Void]$reference.AppendChild($copyLocal) 
			}
		}
	}
	
	if($tfsCheckout -eq $true) 
	{
		Set-TFSCheckout $projectFile
	}
		
	$s.save($projectFile)
}

function Set-TFSCheckout($file)
{
		Write-Host -ForegroundColor 'Yellow' "Checking out " + $file
		tf checkout $file
}

function Set-SolutionWideCopyLocalFalse($directory, $doProjectReferences, $tfsCheckout)
{
	Get-ChildItem $directory -include *.csproj,*.vbproj -Recurse | foreach ($_) { 
		Set-CopyLocalFalse $_.fullname $doProjectReferences $tfsCheckout
	}
}

function Set-SolutionWideSkipPostSharp($directory, $tfsCheckout, $skip)
{
	Get-ChildItem $directory -include *.csproj,*.vbproj -Recurse | foreach ($_) { 
		Set-SkipPostSharpFalse $_.fullname $tfsCheckout $skip
	}
}

function Set-SkipPostSharp($file, $tfsCheckout, $skip)
{
	[xml]$s = get-content $file

	$references = $s.Project.PropertyGroup[0] 
	
	if($references.SkipPostSharp -eq $null)
	{
		[System.Xml.XmlElement]$copyLocal = $s.CreateElement("SkipPostSharp", "http://schemas.microsoft.com/developer/msbuild/2003")
		$copyLocal.InnerText = $skip
		[Void]$references.AppendChild($copyLocal) 
	}
	
	if($tfsCheckout -eq $true) 
	{
		Set-TFSCheckout $file
	}
	
	$s.save($file)
}



function Get-ProjectsContainingReferenceTo($directory, $referenceName)
{
	Get-ChildItem $directory -include *.csproj,*.vbproj -Recurse | foreach ($_) { 
		if(Get-ContainsReferenceTo $_.fullname $referenceName -eq $true){ $_.fullname }
	}
}

function Get-ProjectsContainingAProjectReferenceTo($directory, $referenceName)
{
	Get-ChildItem $directory -include *.csproj,*.vbproj -Recurse | foreach ($_) { 
		if(Get-ContainsProjectReferenceTo $_.fullname $referenceName -eq $true){ $_.fullname }
	}
}

function Get-ContainsReferenceTo($projectFile, $referenceName)
{
	[xml]$s = get-content $projectFile

	$references = $s.Project.ItemGroup | Where-Object { $_.ProjectReference -ne $null }
	
	foreach($reference in $references.ChildNodes)
	{ 
		if($reference.Include -ne $null -and $reference.Include.StartsWith($referenceName))
		{
			return $true
		}
	}

	return $false
}

Write-Host -ForegroundColor 'Yellow' "VS Module loaded"