$code = {

	Import-Module .\CWManage.psm1
	Import-Module .\password.ps1
	
	$startTicketID = 56952

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
		Write-Output "Authenticated Successfully"
	} 
	
	function Complete-Ticket(){

		#mark tickets as complete only if current status = "NEW"

		[CmdletBinding()]
		param(
			[PSCustomObject]$target,
			[string]$notes
		)
		
		#create completed status object
		$completed = @{id=""; name="Completed"; _info=""}

		#for relevant ticket update status to completed
		foreach($ticket in $target){
		
			#if ticket is New
			if(!$ticket.status.name.CompareTo("New") -or !$ticket.status.name.CompareTo("New - Assigned")){
			
				$result = Update-CWMTicket -TicketID $ticket.id -Operation "replace" -Path "status" -Value $completed
				
				$output = [pscustomobject]@{
						TicketID = $ticket.id
						Result = "Completed"
						Ticket = $ticket.summary
					}
				
				Add-Content C:\Users\Andy\output.txt $output
				
			}
		}
	}

	function Clean-TicketBoard
	{
	
		[CmdletBinding()]
		param(
			[string]$summary,
			[string]$text,
			[PSCustomObject]$tickets
		)
		
		$target = $tickets |Where-Object {$_.summary -like $summary}
		if($text -ne "")
		{
			$target =$target |Where-Object {(Get-CWMTicketNote -ticketID $_.id).text -like $text}
		}
		
		Complete-Ticket -target $target 
	} 
}

function Apply-Filter{

	[CmdletBinding()]
		param(
			[string]$summary,
			[string]$text,
			[PSCustomObject]$tickets
		)

	$scriptBlock = {
		Invoke-Expression $args[0]
		Start-CWMConnection
		Clean-TicketBoard -summary $args[1] -text $args[2] -tickets $args[3]
		Disconnect-CWM
	}
	Start-Job -Name $summary -ScriptBlock $scriptBlock -ArgumentList ($code,$summary,$text,$tickets)
}

function Begin-Automation
{
	
	$time = Get-Date
	Add-Content C:\Users\Andy\output.txt $time

	#get current tickets
	Invoke-Expression $code.ToString()
	Start-CWMConnection
	$tickets=Get-CWMTicket -condition "id>$startTicketID" -pageSize 1000
	
	#write-output $tickets.count
	
	Apply-Filter -summary "Ticket #*/has been submitted to Cloud Connect Helpdesk" -text ""	-tickets $tickets
	Apply-Filter -summary "Weekly digest: Office 365 changes" -text "" -tickets $tickets
	Apply-Filter -summary "*Service * is Stopped for *" -text "" -tickets $tickets
	
	Apply-Filter -summary "*Drive Errors and Raid Failures*" -text "*\Device\Harddisk*\DR*" -tickets $tickets
	Apply-Filter -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: herwise, this computer sets up the secure session to any domain controller in the specified domain.*" -tickets $tickets
	Apply-Filter -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*" -tickets $tickets
	Apply-Filter -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-An account failed to log on*" -tickets $tickets
	
	Write-Output "To check the state of Jobs use Get-Job"
	
} 
