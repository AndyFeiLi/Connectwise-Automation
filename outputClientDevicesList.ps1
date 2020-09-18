Import-Module .\password.ps1

while ($token -eq $null)
{
	$2fa = Read-Host -Prompt "Input your TwoFactorPasscode for Automate"
	$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/apitoken"
	$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$PostBody.Add("username", $username)
	$PostBody.Add("password", $password)
	$PostBody.Add("TwoFactorPasscode", $2fa)
	$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body $($PostBody | ConvertTo-Json -Compress)
	$token = $result.AccessToken
}
Write-output "Authenticated successfully with Automate"

#the client name in automate
$domain = "Youth Lab"

$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=client.name contains '"+$domain+"'"

$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
$d=Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 

$d | Export-Csv -Path .\YouthLab.csv
