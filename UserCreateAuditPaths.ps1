$CURRENT_PSSCRIPTS  = "$env:HOMEPATH\Documents\LocalRepo\AdminTools\PSScripts"
$SCRIPT             = "Create-AuditPaths"
$DESCRIPTION =@(
    "Description: $SCRIPT"
    "------------------------------"
    "   Folders provide a hierarchical structure for organizing and managing audit-related components."
    "   This script will validate that the provided root drive as defined by the drive letter provided, exists on the server."
    "   If no drive letter matches the one provided, the action on the host will stop."
    "   On the root drive, this script will check to make sure the provided folder name exists."
    "   Finally, this script will check to make sure that there is a folder within the folder name provided for the instance."
    "   Besides the root drive, if any of the checks sees a folder that doesn't exists, it will be created."
)

# get your credentials
if($null -eq $Creds){$Creds = Get-Credential}
    $SESSIONS = Get-PSSession
    
    # host to connect to
    $HOST_LIST = @()

    # create a session for each host
    foreach($hostName in $HOST_LIST){
        try{
            Get-PSSession -Name $hostName -ErrorAction "Stop" | Out-Null
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

# host with sql instances installed
$HostedInstances = (
    [pscustomobject]@{HostName ='';InstanceName =''}
)

$CMD_ARGS_TABLE = @{};($HostedInstances | Sort-Object -Property @("HostName") -Unique)| ForEach-Object{
    $CMD_ARGS_TABLE.Add(($_.HostName),@{})
}

foreach($hostName in $CMD_ARGS_TABLE.keys){
    $hostInstances = $HostedInstances | Select-Object -Property * | Where-Object {$_.HostName -eq $hostName}
    foreach($instance in $hostInstances){
        $CMD_ARGS_TABLE.($instance.HostName).Add($instance.InstanceName,@{RootDrive = 'P:\';FolderName = 'Audit'})
    }
}

Clear-host
$DESCRIPTION += "`nThis action will be applied on the following $($CMD_ARGS_TABLE.Keys.count) hosts:"
$CMD_ARGS_TABLE.Keys| ForEach-Object{
   $DESCRIPTION += "   "+$_
}
$DESCRIPTION += ""
$FEEDBACK   ="Press 'y' if you wish to continue, 'n' to abort, or 'y -withConfirm' to be prompted again on each host provided"

$DESCRIPTION = "{0}" -f ($DESCRIPTION -join "`n");
Write-Host -Object $DESCRIPTION -ForegroundColor "DarkCyan"
do{   
    $userResponse = Read-Host -Prompt $FEEDBACK
}until(($userResponse -eq 'y') -or ($userResponse -eq 'n') -or ($userResponse -eq 'y -withConfirm'))


if($userResponse -eq 'y -withConfirm'){
    $FEEDBACK = "Press 'y' if you wish to continue, 'n' to abort"

    foreach($session in $SESSIONS){
        Invoke-PSCMD@{
            Session = @($session)
            PowerShellScriptFolder  = $CURRENT_PSSCRIPTS
            PowerShellScriptFile    = $SCRIPT
            ArgumentList            = @($CMD_ARGS_TABLE.($session.ComputerName))
            AsJob                   = $false
        }   
        do{      
            $userResponse = Read-Host -Prompt $FEEDBACK
        }until(($userResponse -eq 'y') -or ($userResponse -eq 'n'))

        if($userResponse -eq 'n'){
            $abort = $true
        }else{
            $abort = $false
        }
        if($abort){
            Clear-host;write-host "Script halted by user" -ForegroundColor "Yellow"
            return   
        }
    }
}elseif($userResponse -eq 'y'){
    foreach($session in $SESSIONS){
        Invoke-PSCMD @{
            Session                 = @($session)
            PowerShellScriptFolder  = $CURRENT_PSSCRIPTS
            PowerShellScriptFile    = $SCRIPT
            ArgumentList            = @($CMD_ARGS_TABLE.($session.ComputerName))
            AsJob                  = $false
        }
    }
}else{
    Clear-host;Write-Host "Script halted by user, no action performed" -ForegroundColor "Yellow"
}

$FEEDBACK = "`nDo you want to close all your open sessions?`nEnter 'y' to close all, or 'n' to keep them open"
do{   
    $userResponse = Read-Host -Prompt $FEEDBACK
}until(($userResponse -eq 'y') -or ($userResponse -eq 'n') -or($userResponse -eq 'y -withConfirm'))

if($userResponse -eq 'y'){   
    Get-PSSession | Remove-PSSession
    Clear-host;Write-host "Sessions closed" -ForegroundColor "Yellow"
}
if($userResponse -eq 'n'){
    Clear-host;Write-host "Your sessions are stil open" -ForegroundColor "Yellow"
}