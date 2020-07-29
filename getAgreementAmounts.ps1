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
$agree = Get-CWMAgreement -Condition 'type/name != "Break Fix" and type/name != "TBS Install" and type/name != "3cx AMC + Base" and type/name != "zz-TBS installs" and company/identifier != "XYZTestCompany" and noEndingDateFlag = TRUE and name != "Monthly - Veeam O365" and name != "Monthly - Rack Space Rental" and name != "Custom Quote" and company/identifier != "CloudConnectPtyLtd"' -all 
#$agree = Get-CWMAgreement -all

#$alladditions = Get-CWMAgreementAddition 532

$d = @{}

#gettrakka has 35 additions in total, 32+2

foreach($entry in $agree){
	
	if($d[$entry.company.identifier] -eq $null)
	{	
		$addition = Get-CWMAgreementAddition $entry.id -all -Condition 'product/identifier = "CC-SSD" or product/identifier = "CC-RAM" or product/identifier = "CC-CPU"' 
	
		if($addition.count -ne 0)
		{
			$d.Add($entry.company.identifier, $addition)
		}
	}
	else {
	
		$addition = Get-CWMAgreementAddition $entry.id -all -Condition 'product/identifier = "CC-SSD" or product/identifier = "CC-RAM" or product/identifier = "CC-CPU"' 
		
		if($addition.count -ne 0)
		{
		
			$prevAddition = $d[$entry.company.identifier]
			
			$allAddition = $addition + $prevAddition
			
			
			$d[$entry.company.identifier] = $allAddition
		}
	
	}

}
	
#}
$agree | Export-Csv -Path .\agree.csv


