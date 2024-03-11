# path to script folder, name of script
$CURRENT_PSSCRIPTS  = "$env:HOMEPATH\Documents\LocalRepo\AdminTools\PSScripts"
$SCRIPT             = "Get-StorageStats"

# get your credentials
if($null -eq $Creds){$Creds = Get-Credential}
$SESSIONS = Get-PSSession

$HOST_LIST = @()

# create a session for each host
foreach($hostName in $HOST_LIST){
    try{
        Get-PSSession-Name $hostName -ErrorAction "Stop" | Out-Null
    }catch{   
        $sessionParams = @{
            ComputerName    = $hostName
            Name            = $hostName
            Credential      = $Creds
            ErrorAction     = "Stop"
        }   
        New-PSSession @sessionParams
    }
}

$CMD_ARGS_TABLE = @{}
foreach($hostname in $HOST_LIST){   
    $CMD_ARGS_TABLE.Add($hostName,@{
    Filter  = "Exclude"
    Label   = @("")
    ENCLAVE = $ENCLAVE   
    })
}

$results = @()
foreach($session in $SESSIONS){ 
    $results += Invoke-PSCMD @{
        Session                 = @($session)
        PowerShellScriptFolder  = $CURRENT_PSSCRIPTS
        PowerShellScriptFile    = $SCRIPT
        ArgumentList            = @($CMD_ARGS_TABLE.($session.name))
        AsJob                   = $false
    }
}

$cntr       = 1
$volReport  = @()
foreach($entry in $results){
    $recID = @{
        name ="RecID2";expression ={$cntr}
    }
   $volReport += $entry | Select-Object -Property $recID,*
   $cntr = $cntr + 1
}
$volReport | Select-Object -Property * -ExcludeProperty @("RunspaceID","PSComputerName") | Format-Table -AutoSize