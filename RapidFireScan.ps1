New-Item -ItemType Directory -Path "C:\NetworkDetective" | Out-Null

$url = "https://s3.amazonaws.com/networkdetective/download/NetworkDetectiveDataCollector.exe" 
Invoke-WebRequest -Uri $url -OutFile "C:\NetworkDetective\NDInstall.exe"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\NetworkDetective\NDInstall.exe" "C:\NetworkDetective"


$dir = "C:\NetworkDetective"

$ArgumentList = "-common"
Start-Process -FilePath "C:\NetworkDetective\nddc.exe" -ArgumentList $ArgumentList -WindowStyle Hidden -Wait

$ArgumentList = "-common", "-nozip"
Start-Process -FilePath "C:\NetworkDetective\sddc.exe" -ArgumentList $ArgumentList -WindowStyle Hidden -Wait

$ArgumentList = "-local"
Start-Process -FilePath "C:\NetworkDetective\nddc.exe" -ArgumentList $ArgumentList -WindowStyle Hidden -Wait

################################################################

#rename ndf file to computer name
$name = get-content env:computername
$name = $name + ".ndf"
$name = $dir + "\" + $name
$ndf = Get-ChildItem -Path "$dir\*" -Include *.ndf
$path = $dir + "\" + $ndf.name
Rename-Item -Path $path -NewName $name

#get all files and upload
$files = Get-ChildItem -Path "$dir\*" -Include *.cdf, *.ndf, *.wdf, *.sdf
Set-Variable -name adFileTypeBinary -value 1 -option Constant 

foreach($entry in $files){

	#Complete path of the file to be uploaded
	$file = $dir + "\" + $entry.name
	 
	#URL without the last "/"
	$url  = "https://XXXXXXXXXX.hostedrmm.com/share/Rapidfire"
	 
	#User and Pwd for Webdav Access
	$user = "XXXXXXXXXXXXXXXX"
	$pass = "XXXXXXXXXXXXXXXX"
	 
	$url += "/" + $file.split('\')[(($file.split("\")).count - 1)]

	# Set binary file type
	 
	$objADOStream = New-Object -ComObject ADODB.Stream
	$objADOStream.Open()
	$objADOStream.Type = $adFileTypeBinary
	$objADOStream.LoadFromFile("$file")
	$buffer = $objADOStream.Read()
	$objXMLHTTP = New-Object -ComObject MSXML2.ServerXMLHTTP
	$objXMLHTTP.Open("PUT", $url, $False, $user, $pass)
	$objXMLHTTP.send($buffer)

}

Remove-Item C:\NetworkDetective -Recurse -Force
Remove-Item C:\windows\temp\rapidfire.ps1
