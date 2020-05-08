	Import-Module .\CWManage.psm1
	Import-Module .\password.ps1
	
	function Start-CWMConnection
	{
		# This is the URL to your manage server.
		$Server = $myServer

		# This is the company entered at login
		$Company = $myCompany

		#Public and private key created in connectwise manage
		$pubkey = $mypubkey
		$privatekey = $myprivatekey

		#ClientID created from https://developer.connectwise.com/ClientID
		$clientId = $myclientId


		# Connect to Manage server
		$Connection = @{
					Server = $Server
					Company = $Company 
					pubkey = $pubkey
					privatekey = $privatekey
					clientId = $clientId
				}
		Connect-CWM @Connection
		Write-Output "Authenticated successfully with Manage"
	} 
	Start-CWMConnection


$projects = Get-CWMProject -all

$projectList = @()

foreach($entry in $projects){
	
	$id = $entry.id
	$actualhours = $entry.actualhours
	$billingamount = $entry.billingamount
	$billingmethod = $entry.billingmethod
	$budgethours = $entry.budgethours
	$name = $entry.name
	$company = $entry.company.name
	$description = $entry.description
	$actualStart = $entry.actualStart
	
	$item = "" | Select id,actualstart,actualhours,billingamount,billingmethod,budgethours,name,company,description
	$item.id = $id
	$item.actualStart = $actualStart
	$item.actualhours = $actualhours
	$item.billingamount = $billingamount
	$item.billingmethod = $billingmethod
	$item.budgethours = $budgethours
	$item.name = $name
	$item.company = $company
	$item.description = $description
	
	$projectList += $item
	
}

$projectList | Export-Csv -Path .\projects.csv


