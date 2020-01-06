###########################################
##################Edit#####################
###########################################

$myServer = "au.myconnectwise.net"
$myCompany = "CloudConnect"
$mypubkey = ""
$myprivatekey = ""
$myclientId = ""

$startTicketID = 100 #Start Processing from this ticket ID 
###########################################
###########################################
###########################################

Import-Module .\CWManage.psm1

$global:totalCompleted = 0


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

	[CmdletBinding()]
    param(
        [PSCustomObject]$target
    )
	
	#create completed status object
	$completed = @{id=""; name="Completed"; _info=""}

	#for relevant ticket update status to completed
	foreach($ticket in $target){
	
		#if ticket is New
		if(!$ticket.status.name.CompareTo("New")){
		
			$result = Update-CWMTicket -TicketID $ticket.id -Operation "replace" -Path "status" -Value $completed
			
			$output = [pscustomobject]@{
					Result = "Completed"
					TicketID = $ticket.id 
					Ticket = $ticket.summary
				}
			
			Write-Output $output
			$global:totalCompleted = $global:totalCompleted + 1
		}
	}
}

function Clean-UselessTickets
{
	Write-Output "Loading Recent Tickets"
	$tickets=Get-CWMTicket -condition "id>$startTicketID" -pageSize 1000
	
	Write-Output "Processing Tickets"
	
	#clear tickets "Ticket #*/has been submitted to Cloud Connect Helpdesk"
	$target =$tickets |Where-Object {$_.summary -like "Ticket #*/has been submitted to Cloud Connect Helpdesk"}
	Complete-Ticket -target $target
	
	#clear tickets "The driver detected a controller error on \Device\Harddisk1\DR#"
	$target =$tickets |Where-Object {$_.summary -like "*Drive Errors and Raid Failures*"}
	Complete-Ticket -target $target
	
} 


function Begin-Automation
{
	
	#start connectwise manage session
	Start-CWMConnection
	
	#clean up monitoring board of useless tickets
	Clean-UselessTickets
	
	#end connectwise manage session
	#Disconnect-CWM
	Write-Output "Session Closed"
	
	Write-Output ($totalCompleted.tostring() + " ticket(s) completed")
	
	
} 
