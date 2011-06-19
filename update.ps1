
function downloadFile($url, $targetFile)
{ 
    "Downloading $url" 
    $uri = New-Object "System.Uri" "$url" 
    $request = [System.Net.HttpWebRequest]::Create($uri) 
    $request.set_Timeout(15000) #15 second timeout 
    $response = $request.GetResponse() 
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024) 
    $responseStream = $response.GetResponseStream() 
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create 
    $buffer = new-object byte[] 10KB 
    $count = $responseStream.Read($buffer,0,$buffer.length) 
    $downloadedBytes = $count 
    while ($count -gt 0) 
    { 
        [System.Console]::CursorLeft = 0 
        [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength) 
        $targetStream.Write($buffer, 0, $count) 
        $count = $responseStream.Read($buffer,0,$buffer.length) 
        $downloadedBytes = $downloadedBytes + $count 
    } 
    "`nFinished Download" 
    $targetStream.Flush()
    $targetStream.Close() 
    $targetStream.Dispose() 
    $responseStream.Dispose() 
}

$location = "https://github.com/naeemkhedarun/SlightlyPosher/zipball/master"
$file = "package.zip"
$dl = New-Object System.Net.WebClient

"Downloading latest update..."
$pkg = downloadFile $location $file

$shell_app=new-object -com shell.application 
$filename = $file
$zip_file = $shell_app.namespace((Get-Location).Path + "\$filename") 
$destination = $shell_app.namespace((Get-Location).Path) 
$destination.Copyhere($zip_file.items())

"`nCopying files..."
Get-ChildItem -Filter "naeemkhedarun-SlightlyPosher*" | Get-ChildItem | Copy-Item -Force -Recurse

"Cleaning up..."
Get-ChildItem -Filter "naeemkhedarun-SlightlyPosher*" | Remove-Item -Recurse
Get-ChildItem -Filter ".git*" | Remove-Item

Remove-Item $file

"Update complete!"