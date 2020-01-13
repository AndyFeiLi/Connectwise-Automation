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
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/computers?condition=ComputerName contains 'NBCN-LT-002'"
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
$CompressedCommand = $($command | ConvertTo-Json -Compress)

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

####################
#get this computer
$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/686"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $Header 

##############post script###########################################
$PostBody = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$PostBody.Add("ScriptId", 439)
$PostBody.Add("ComputerId", 686)
$PostBody.Add("ScheduleType", 0)
$PostBody.Add("EffectiveStartDate", "2019-11-27T21:41:13Z")


$uri = "https://cloudconnect.hostedrmm.com/cwa/api/v1/Computers/686/ScheduledScripts"
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add("Authorization", "Bearer "+$token)
Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $Header -Body $($PostBody | ConvertTo-Json -Compress)

