param([hashtable]$Params)
$ErrorActionPreference = 'Stop'

<# Example:
    $Params = @{
        Filter  = "Exclude"
        Label   = @("C:\")
        ENCLAVE = $ENCLAVE
    }
#>

if($null -eq $Params.ENCLAVE){
    $ENCLAVE = "Unknown"
}else{   
    $ENCLAVE = $Params.ENCLAVE
}
$envProperties = @{
    Encalve     = $ENCLAVE
    Domain      = $env:USERDNSDOMAIN
    HostName    = hostname
}
[datetime]$dt="1/1/$((get-date).Year)"

$dateTimeCollected  = @{name = "DateTimeCollected"; expression = {(Get-Date).ToString('yyyy-MM-ddHH:mm:sss')}}
$hourOfDay          = @{name = "HourOfDay";         expression = {(Get-Date).Hour}}
$dayOfMonth         = @{name = "dayOfMonth";        expression = {(Get-Date).Day}}
$dayOfYear          = @{name = "DayOfYear";         expression = {((get-date) -$dt).Days}}
$myEnclave          = @{name = "Enclave";           expression = {$envProperties.Encalve}}
$myDomain           = @{name = "Domain";            expression ={$envProperties.Domain}}
$myHostname         = @{name = "HostName";          expression = {$envProperties.HostName}}
$totalgb            = @{name = "CapacityGb";        expression = {[math]::round(($_.capacity/1073741824),2)}}
$freegb             = @{name = "FreeSpaceGb";       expression = {[math]::round(($_.freespace/1073741824),2)}}
$usedspace          = @{name = "UsedSpaceGb";       expression ={[math]::round((($_.capacity-$_.freespace)/1073741824),2)}}
$freeperc           = @{name = "FreeSpacePercent";  expression = {[math]::round(((($_.freespace/1073741824)/($_.capacity/1073741824))*100),0)}}
$volumes            =@()

if($Params.filter -like 'Include'){
    foreach($label in $Params.Labels){
        $volumes += get-wmiobject win32_volume  | select-object $myEnclave,$myDomain,$myHostName,Name, Label,
        $totalgb,$freegb,$usedspace,$freeperc,$dateTimeCollected,$dayOfYear,$dayOfMonth,$hourOfDay | Where-Object{$_.label -like $label}   
    }
    $volumes = $volumes | Select-Object -Property * | Where-Object {$_.label -ne $null}
    $volumes = $volumes | Select-Object -Property * | Where-Object {$_.Name -notlike "\\*"}
}elseif($Params.filter -like 'Exclude'){
    $compare = @()
    $volumes = get-wmiobject win32_volume  |
    select-object $myEnclave,$myDomain,$myHostName,Name, Label, $totalgb,$freegb,$usedspace,$freeperc,$dateTimeCollected,$dayOfYear,$dayOfMonth,$hourOfDay |
    Where-Object{$_.name -notlike "\\*"}
    foreach($Label in $Params.Labels){
    $compare += $volumes | Where-Object {$_.label -like $label}
}
   
$volumes = $volumes | Select-Object -Property * | Where-Object {$_.label -ne $null}
$volumes = $volumes | Select-Object * | Where-Object {$_.label -notin $compare.label}}


$cntr = 1
$volReport = @()
foreach($entry in $volumes){
    $recID = @{name = "RecID"; expression = {$cntr}}
    $volReport += $entry | Select-Object -Property $recID,* $cntr = $cntr + 1
}
return $volReport
