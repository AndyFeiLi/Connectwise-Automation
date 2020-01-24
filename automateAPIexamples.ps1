#authenticate and get accesstoken


while ($token -eq $null)
{
	$2fa = Read-Host -Prompt "Input your TwoFactorPasscode for Automate"
	$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/apitoken"
	$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$PostBody.Add('username', 'Andy')
	$PostBody.Add('password', '%LgJ!Rk927')
	$PostBody.Add('TwoFactorPasscode', $2fa)
	$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body $($PostBody | ConvertTo-Json -Compress)
	$token = $result.AccessToken
	
}
Write-output "Authenticated successfully with Automate"




$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)


#get all computers & id bwtween 1 and 1000
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=(id >= 1 and id <= 1000)&pagesize=1000"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header

#get scripts list
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Scripts?pagesize=1000"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header

#get particular computer and return the id of the computer
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=ComputerName contains 'A2W-SP-003'"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
$c = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header
$c.id


#retire machine
####################
$Command = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$command.Add("Id", "Id")
$command.Add("Name", "Name")
$command.Add("Command", "sp_DeleteComputer('686','retired by script')")
$command.Add("Level", 0)
#$CompressedCommand = $($command | ConvertTo-Json -Compress)

$CommandExecute = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$CommandExecute.Add("Id", 0)
$CommandExecute.Add("ComputerId", 686)
$CommandExecute.Add("Command", $CompressedCommand)
$CommandExecute.Add("Status", "status")
$CommandExecute.Add("Parameters", "sp_DeleteComputer('686','retired by script')")
$CommandExecute.Add("Output", "output")
$CommandExecute.Add("Fasttalk", $True)
$CommandExecute.Add("DateLastInventoried", "2019-11-27T21:41:10Z")


$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/686/CommandExecute"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($CommandExecute | ConvertTo-Json -Compress)

######command execute test 2####################
$command = [PSCustomObject]@{
    Id     = "64"
    Name = 'WakeOnLan'  
}

$Command = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$command.Add("Id", "64")
$command.Add("Name", "WakeOnLan")
$CompressedCommand = $($command | ConvertTo-Json -Compress)

$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$PostBody.Add("ComputerId", 137)
$PostBody.Add("Command", $CompressedCommand)

$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/137/CommandExecute"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)


####################
#get this computer
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/875"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 

##############
#get drives and counts for each

$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/875/Drives/"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
$d=Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 
$table = $d.letter | ForEach-Object -Begin { $wordCounts=@{} } -Process { $wordCounts.$_++ } -End { $wordCounts }
if($table.e -gt 1){Write-Output "external"}else{Write-Output "internal"}



##try number 2

#check if computer has been retired
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=ComputerName contains 'SSA-DT-009'"
#$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$Header.Add("Authorization", "Bearer "+$token)
$c = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header
$c.id
##############post script###########################################
$getdate = Get-Date
$getdate = get-date $getdate -Format "o"
$getdate = $getdate.substring(0, 17)
$getdate = $getdate+"00Z"

$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$PostBody.Add("ClientId", 0) 
$PostBody.Add("ComputerId", 532)
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
$PostBody.Add("ScriptId", 481) 
$PostBody.Add("SearchID", 0)
$PostBody.Add("SkipOffline", $false)
$PostBody.Add("TimeZoneAdd", 0)
$PostBody.Add("User", "")
$PostBody.Add("WakeOffline", $false)
$PostBody.Add("WakeScript", $false)

$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/532/ScheduledScripts"
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)





######################################################
#482 schedule reboot computer 887 (mine)

$getdate = Get-Date
$getdate = get-date $getdate -Format "o"
$getdate = $getdate.substring(0, 17)
$getdate = $getdate+"00Z"

$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$PostBody.Add("ClientId", 0) 
$PostBody.Add("ComputerId", 887)
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
$PostBody.Add("ScriptId", 482) 
$PostBody.Add("SearchID", 0)
$PostBody.Add("SkipOffline", $false)
$PostBody.Add("TimeZoneAdd", 0)
$PostBody.Add("User", "")
$PostBody.Add("WakeOffline", $false)
$PostBody.Add("WakeScript", $false)

$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/887/ScheduledScripts"
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)


#call script 483 virtual cabinet fix
#computer id 887

		$scriptID = 483
		$computerID = 887

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
		$PostBody.Add("Priority", 15)
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


#####command execute force agent update
#payload
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/863/commandexecute"
$postbod = '{"ComputerId":"863","Command":{"Id":1},"Parameters":["190.333"]}'
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $postbod
