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


$time = Get-CWMTimeEntry -Condition 'dateEntered > [2020-3-1T01:00:00Z]' -all
$hours = 0
$companyHours = @()

foreach($entry in $time){
	$hours = $hours + $entry.actualhours
	
	$companyname = $entry.company.name
	$ticketID = $entry.chargetoid
	$hour = $entry.actualhours
	$name = $entry.member.identifier
	$chargetotype = $entry.chargetotype
	$worktype = $entry.worktype.name
	$workrole = $entry.workrole.name
	$agreement = $entry.agreement.name
	$billableoption = $entry.billableoption
	$notes = $entry.notes
	$hoursbilled = $entry.hoursbilled
	$hourlyrate = $entry.hourlyrate
	
	if($notes)
	{
		$notes = $notes.replace("`n",", ").replace("`r",", ")
	}
	
	$item = "" | Select ticketID,chargetotype,worktype,workrole,agreement,billableoption,name,company,hours,hoursbilled,hourlyrate,notes
	$item.ticketID = $ticketID.ToString() 
	$item.chargetotype = $chargetotype 
	$item.worktype = $worktype 
	$item.workrole = $workrole 
	$item.agreement = $agreement 
	$item.billableoption = $billableoption 
	$item.name = $name 
	$item.company = $companyname 
	$item.hours = $hour.ToString() 
	$item.hoursbilled = $hoursbilled.ToString() 
	$item.hourlyrate = $hourlyrate.ToString() 
	$item.notes = $notes
	
	
	$companyHours += $item
	
}

$companyhours | Export-Csv -Path .\hours.csv

#$xlfile = "$.\hours.xlsx"
#$companyhours | Export-Excel $xlfile -AutoSize -StartRow 11 -TableName ReportService

#$out = "ticketID|chargetotype|worktype|workrole|agreement|billableoption|name|company|hours|hoursbilled|hourlyrate|notes"
#Add-Content -Path .\hours.txt -Value $out

#$out = $companyhours|Format-Table -Property * -autosize |out-string -width 10000
#Add-Content -Path .\hours.txt -Value $out

#(gc .\hours.txt) | ? {$_.trim() -ne "" } | set-content .\hours.txt
