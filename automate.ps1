
Import-Module .\password.ps1

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
		Write-Output "Authenticated successfully with Manage"
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
	
	function Schedule-Automatescript{
	
		#schedule script to run once at time of call for the target computerID
		
		[CmdletBinding()]
		param(
			[string]$computerID,
			[string]$scriptID,
			[string]$token
		)
		
		$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$Header.Add("Authorization", "Bearer "+$token)
		
		$getdate = Get-Date
		$getdate = get-date $getdate -Format "o"
		$getdate = $getdate.substring(0, 17)
		$getdate = $getdate+"00Z"

		$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$PostBody.Add("ClientId", 0) 
		$PostBody.Add("ComputerId", $computerID)
		$PostBody.Add("Disabled", $false)
		$PostBody.Add("DisableTimeZone", $true)
		$PostBody.Add("DistributionWindowAmount", 0)
		$PostBody.Add("DistributionWindowType", 2)
		$PostBody.Add("EffectiveOccurrences", 0)
		$PostBody.Add("EffectiveStartDate", $getdate)
		$PostBody.Add("GroupId", 0)
		$PostBody.Add("IncludeSubgroups", $false)
		$PostBody.Add("Interval", 0)
		$PostBody.Add("LastUpdate", $getdate)
		$PostBody.Add("LocationId", 0) 
		$PostBody.Add("NextRun", $getdate)
		$PostBody.Add("NextSchedule", $getdate)
		$PostBody.Add("OfflineOnly", $false)
		$PostBody.Add("Parameters", "")
		$PostBody.Add("Priority", 6)
		$PostBody.Add("RepeatAmount", 0)
		$PostBody.Add("RepeatStopAfter", 0)
		$PostBody.Add("RepeatType", 0)
		$PostBody.Add("RunScriptOnProbe", $false)
		$PostBody.Add("ScheduleDayOfWeek", 0)
		$PostBody.Add("ScheduleType", 1)
		$PostBody.Add("ScheduleWeekOfMonth", 0)
		$PostBody.Add("ScriptId", $scriptID) 
		$PostBody.Add("SearchID", 0)
		$PostBody.Add("SkipOffline", $false)
		$PostBody.Add("TimeZoneAdd", 0)
		$PostBody.Add("User", "")
		$PostBody.Add("WakeOffline", $false)
		$PostBody.Add("WakeScript", $false)

		$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/"+$computerID+"/ScheduledScripts"
		Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)

	}
	
	function Complete-Ticket(){

		#mark tickets as complete only if current status = "NEW"

		[CmdletBinding()]
		param(
			[PSCustomObject]$target,
			[string]$notes,
			[string]$token
		)
		
		$closeTicket = $true
		
		#create completed status object
		$completed = @{id=""; name="Completed"; _info=""}
		
		$autoMessage = "
			
		This ticket has been processed automatically by Cloudconnect's automation script.
		If this ticket has been processed incorrectly, please contact andy@cloudconnect.tech"

		#for relevant ticket update status to completed
		foreach($ticket in $target){
			
			#if ticket is New
			if(!$ticket.status.name.CompareTo("New") -or !$ticket.status.name.CompareTo("New - Assigned")){
			
				#schedule script reboot 
				if($notes -eq "Schedulled Reboot after 14hrs")
				{
					$computerID = $ticket.summary.split(" ")[9]
					$scriptID = "482"
					Schedule-Automatescript -computerID $computerID -scriptId $scriptID -token $token
				}
				
				#schedule script 439 dism-sfc combo
				if($notes -eq "Schedulled Dism-SFC combo")
				{
					$computerID = $ticket.summary.split(" ")[5]
					$scriptID = "439"
					
					###BUGS here - commenting them out for now###
					##if online schedule script, else put note saying script did not run
					#$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/"+$computerID
					#$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
					#$Header.Add("Authorization", "Bearer "+$token)
					#$targetComputer = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 
					
					#if(!$targetComputer.status.CompareTo("Online"))
					#{
						Schedule-Automatescript -computerID $computerID -scriptId $scriptID -token $token
					#}
					#else{
					#	$notes = "Attempted to schedule Dism-SFC combo, however workstation is currently Offline."
					#	$closeTicket = $false
					#}
				}
			
				
				$finalNote = $notes + $autoMessage
				#mark ticket as completed
				Add-CWMTimeNote -ticketID $ticket.id -notes $finalNote
				if($closeTicket)
				{
					$result = Update-CWMTicket -TicketID $ticket.id -Operation "replace" -Path "status" -Value $completed
				}	
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
			[string]$token,
			[PSCustomObject]$tickets
		)
		
		$target = $tickets |Where-Object {$_.summary -like $summary}
		if($text -ne "")
		{
			$target =$target |Where-Object {(Get-CWMTicketNote -ticketID $_.id).text -like $text}
		}
		
		Complete-Ticket -target $target -notes $notes -token $token
	} 
}

function Apply-Filter{

	[CmdletBinding()]
		param(
			[string]$summary,
			[string]$text,
			[string]$notes,
			[string]$token,
			[PSCustomObject]$tickets
		)

	$scriptBlock = {
		Invoke-Expression $args[0]
		Start-CWMConnection
		Clean-TicketBoard -summary $args[1] -text $args[2] -tickets $args[3] -notes $args[4] -token $args[5]
		Disconnect-CWM
	}
	Start-Job -Name $summary -ScriptBlock $scriptBlock -ArgumentList ($code,$summary,$text,$tickets,$notes,$token)
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
	
	Apply-Filter -token $token -tickets $tickets -notes "Unnecessary ticket." -summary "Ticket #*/has been submitted to Cloud Connect Helpdesk" -text ""	
	Apply-Filter -token $token -tickets $tickets -notes "Notification from LabTech - not a ticket." -summary "Message Center Major Change Update Notification" -text ""	
	Apply-Filter -token $token -tickets $tickets -notes "Email - not a ticket." -summary "Weekly digest: Office 365 changes" -text "" 
	
	Apply-Filter -token $token -tickets $tickets -notes "Service has stopped - no action required." -summary "*Service * is Stopped for *" -text "*The Service Monitor detected that the service*is Stopped.*" 
	Apply-Filter -token $token -tickets $tickets -notes "External drive errors - no action required." -summary "*Drive Errors and Raid Failures*" -text "*\Device\Harddisk*\DR*" 
	Apply-Filter -token $token -tickets $tickets -notes "Single Log on Failure - no action required." -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-An account failed to log on*" 
	Apply-Filter -token $token -tickets $tickets -notes "Cryptographic Operation Failure - no action required." -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-Cryptographic operation.*" 
	
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: herwise, this computer sets up the secure session to any domain controller in the specified domain.*" 
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*" 
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  account created on another domain controller has not replicated to the current domain controller).*" 
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  processed. If you do not see a success message for several hours, then contact your administrator.*" 
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found:  of new Group Policy objects and settings. An event will be logged when Group Policy is successful.*" 
	Apply-Filter -token $token -tickets $tickets -notes "Temporary disconnection from DNS server - no action required." -summary "*Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: a name resolution failure. Verify your Domain Name System (DNS) is configured and working correctly.*" 
	
	Apply-Filter -token $token -tickets $tickets -notes "Process Monitor - no action required." -summary "Bad Process for * at *" -text "*The Bad Process Monitor detected a Process that is marked bad: * This process should be terminated.*" 
	Apply-Filter -token $token -tickets $tickets -notes "System shutdown - no action required." -summary "Critical Blacklist Events - Warnings and Errors for*" -text "*The first Critical Blacklist Event found: System log - EventLog:  The previous system shutdown at * on * was unexpected.*" 
	
	Apply-Filter -token $token -tickets $tickets -notes "Schedulled Reboot after 14hrs" -summary "*UPTIME - Over 1 Month Without Reboot:49*" -text "*UPTIME - Over 1 Month Without Reboot* Detected on*at*" 
	Apply-Filter -token $token -tickets $tickets -notes "Schedulled Dism-SFC combo" -summary "Security Audit Failure:*" -text "*Microsoft-Windows-Security-Auditing-Code Integrity determined that the * hash* of *file * not valid.*" 
	
	Write-Output ""
	Write-Output "To check the state of jobs use Get-Job"
} 

#mainloop
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
Begin-Automation

