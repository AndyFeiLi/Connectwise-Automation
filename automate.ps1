$code = {
	###########################################
	##################Edit#####################
	###########################################

	$myServer = "au.myconnectwise.net"
	$myCompany = "CloudConnect"
	$mypubkey = ""
	$myprivatekey = ""
	$myclientId = ""

	$startTicketID =  #Start Processing from this ticket ID 
	###########################################
	###########################################
	###########################################

	Import-Module .\CWManage.psm1

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
			[string]$text
		)
	
		$tickets=Get-CWMTicket -condition "id>$startTicketID" -pageSize 1000
		
		$target =$tickets |Where-Object {$_.summary -like $summary}
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
			[string]$text
		)

	$scriptBlock = {
		. Invoke-Expression $args[0]
		Start-CWMConnection
		Clean-TicketBoard -summary $args[1] -text $args[2]
		Disconnect-CWM
	}
	$job = Start-Job -ScriptBlock $scriptBlock -ArgumentList ($code,$summary,$text)


}

function Begin-Automation
{
	$time = Get-Date
	Add-Content C:\Users\Andy\output.txt $time

	Apply-Filter -summary "Ticket #*/has been submitted to Cloud Connect Helpdesk" -text ""	
	Apply-Filter -summary "Weekly digest: Office 365 changes" -text ""	
	
	Apply-Filter -summary "*Drive Errors and Raid Failures*" -text "*\Device\Harddisk*\DR*"
	Apply-Filter -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: herwise, this computer sets up the secure session to any domain controller in the specified domain.*"
	Apply-Filter -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*"
} 
