#authenticate and get accesstoken
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/apitoken"
$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$PostBody.Add("username", "")
$PostBody.Add("password", "")
$PostBody.Add("TwoFactorPasscode", )
$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Body $($PostBody | ConvertTo-Json -Compress)
$result.AccessToken
$token = $result.AccessToken


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
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=ComputerName contains 'CC-LT-00'"
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
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/686"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 





##try number 2

#check if computer has been retired
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=ComputerName contains 'CC-LT-00'"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
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
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)

