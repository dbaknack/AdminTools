param([psobject]$fromSender)
begin{
    Write-Host $fromSender.count -ForegroundColor Cyan
    $cntr = 1
    $ConversionTable = @()
}
process{
    Write-Host $fromSender.count -ForegroundColor RED
    foreach($entry in $fromSender){
        $valResult = switch($entry.From) {  
            "bytes" {$entry.Value; break}
            "kb"    {($entry.Value * 1024); break}      
            "Mb"    {($entry.Value * 1024 * 1024); break}     
            "Gb"    {($entry.Value * 1024 * 1024 * 1024); break}
            "Tb"    {($entry.Value * 1024 * 1024 * 1024) * 1024; break}
        }            
        
        $ConversionTable += [pscustomobject]@{
            RecID           =   $cntr++
            Tag             =   $entry.Tag
            OriginalValue   =   $entry.Value
            From            =   $entry.From
            Bytes           =   [math]::round($valResult,3)
            Kb              =   [math]::round(($valResult/1KB),3)
            Mb              =   [math]::round(($valResult/1MB),3)
            Gb              =   [math]::round(($valResult/1GB),3)
            Tb              =   [math]::round(($valResult/1TB),3)
        }
    }
}
end{
    $ConversionTable 
}