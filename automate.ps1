$code = {

	Import-Module .\CWManage.psm1
	Import-Module .\password.ps1
	
	$startTicketID = 57000

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
	
	function Add-CWMTimeNote(){
	
		[CmdletBinding()]
		param(
			[string]$ticketID,
			[string]$notes
		)
	
		$getdate = Get-Date
		$getdate = $getdate.AddHours(-8)
		$getdate = get-date $getdate -Format "o"
		$getdate = $getdate.substring(0, 17)
		$getdate = $getdate+"00Z"

		$getLaterDate = Get-Date
		$getlaterdate = $getlaterdate.AddHours(-8)
		$getlaterdate = $getlaterdate.AddMinutes(1)
		$getlaterdate = get-date $getlaterdate -Format "o"
		$getlaterdate = $getlaterdate.substring(0, 17)
		$getlaterdate = $getlaterdate+"00Z"

		New-CWMTimeEntry -chargeToId $ticketID -notes $notes -chargeToType "ServiceTicket" -timeStart $getdate -timeEnd $getLaterDate
			
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
		
		$autoMessage = "
			
		This ticket has been automatically closed by Cloudconnect's automation script.
		If this ticket has been closed by mistake, please contact Andy@Cloudconnect.tech"
			
		$notes = $notes + $autoMessage

		#for relevant ticket update status to completed
		foreach($ticket in $target){
			
			#if ticket is New
			if(!$ticket.status.name.CompareTo("New") -or !$ticket.status.name.CompareTo("New - Assigned")){
				Add-CWMTimeNote -ticketID $ticket.id -notes $notes
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
			[string]$notes,
			[PSCustomObject]$tickets
		)
		
		$target = $tickets |Where-Object {$_.summary -like $summary}
		if($text -ne "")
		{
			$target =$target |Where-Object {(Get-CWMTicketNote -ticketID $_.id).text -like $text}
		}
		
		Complete-Ticket -target $target -notes $notes
	} 
}

function Apply-Filter{

	[CmdletBinding()]
		param(
			[string]$summary,
			[string]$text,
			[string]$notes,
			[PSCustomObject]$tickets
		)

	$scriptBlock = {
		Invoke-Expression $args[0]
		Start-CWMConnection
		Clean-TicketBoard -summary $args[1] -text $args[2] -tickets $args[3] -notes $args[4]
		Disconnect-CWM
	}
	Start-Job -Name $summary -ScriptBlock $scriptBlock -ArgumentList ($code,$summary,$text,$tickets,$notes)
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
	
	Apply-Filter -tickets $tickets -notes "Unnecessary ticket." -summary "Ticket #*/has been submitted to Cloud Connect Helpdesk" -text ""	
	Apply-Filter -tickets $tickets -notes "Notification from LabTech - not a ticket." -summary "Message Center Major Change Update Notification" -text ""	
	Apply-Filter -tickets $tickets -notes "Email - not a ticket." -summary "Weekly digest: Office 365 changes" -text "" 
	
	Apply-Filter -tickets $tickets -notes "Service has stopped - no action required." -summary "*Service * is Stopped for *" -text "*The Service Monitor detected that the service*is Stopped.*" 
	Apply-Filter -tickets $tickets -notes "External drive errors - no action required." -summary "*Drive Errors and Raid Failures*" -text "*\Device\Harddisk*\DR*" 
	Apply-Filter -tickets $tickets -notes "Single Security Audit Failure - no action required." -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-An account failed to log on*" 
	Apply-Filter -tickets $tickets -notes "Cryptographic Operation Failure - no action required." -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-Cryptographic operation.*" 
	
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: herwise, this computer sets up the secure session to any domain controller in the specified domain.*" 
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*" 
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  account created on another domain controller has not replicated to the current domain controller).*" 
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  processed. If you do not see a success message for several hours, then contact your administrator.*" 
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  of new Group Policy objects and settings. An event will be logged when Group Policy is successful.*" 
	Apply-Filter -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: a name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*" 
	
	
	
	Write-Output ""
	Write-Output "To check the state of jobs use Get-Job"
	
} 
