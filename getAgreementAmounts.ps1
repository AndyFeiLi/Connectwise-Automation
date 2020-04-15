$agree = Get-CWMAgreement -all

#$alladditions = Get-CWMAgreementAddition  683

foreach($entry in $agree){

	$additions = Get-CWMAgreementAddition  $entry.id
	$alladditions = $alladditions + $additions
}
