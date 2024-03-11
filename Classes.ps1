Class CreateScript {
    [psobject]GetSpecifications([hashtable]$fromSender){
        $content = Get-Content -path $fromSender.Source
    return ($content | convertfrom-csv)
    }
}
$CreateScript = [CreateScript]::new()

$SpecificationList = $CreateScript.GetSpecifications(@{Source = "./SpecificationList.csv"})


$cmdList = @()
foreach($entry in $SpecificationList){
   $cmdList += "Add ({0})" -f $entry.Specification
}

$cmdList -join ",`n" 