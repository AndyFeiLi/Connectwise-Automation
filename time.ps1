$time = Get-CWMTimeEntry -Condition 'member/identifier="gavin" and dateEntered > [2020-2-27T05:53:27Z]' -all
$hours = 0
$companyHours = @()

foreach($entry in $time){
	$hours = $hours + $entry.actualhours
	
	$companyname = $entry.company.name
	$hour = $entry.actualhours
	$name = $entry.member.identifier
	
	$item = "" | Select name,company,hours
	$item.name = $name + "|"
	$item.company = $companyname + "|"
	$item.hours = $hour
	
	$companyHours += $item
	
}

$out = $companyHours.GetEnumerator()|sort -property value -Descending

$out = $out|Format-Table -Autosize -HideTableHeaders| out-string
Add-Content -Path .\hours.txt -Value $out

(gc .\hours.txt) | ? {$_.trim() -ne "" } | set-content .\hours.txt
