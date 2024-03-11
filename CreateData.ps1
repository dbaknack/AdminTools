. ./AdminTools/Data/Source.ps1
class SimpleDataGenerator{
    $address        = (Get-RandomAddress)
    $intList        = 0..9
    $engCharList    = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")

    $customTypes = @{
        ZipCode = @{
            name = "ZipCode"
            int  = @{
                length = 5
                mask = "{0}{1}{2}{3}{4}"
            }
        }
        PhoneNumber = @{
            Name = "PhoneNumber"
            char = @{
                length = 14
                mask = "({0}{1}{2}) {3}{4}{5}-{6}{7}{8}{9}"
            }
        }
    }
    [psobject]Record([int]$count){
        $records = @()
        foreach($cntr in 1..$count){
            $randomeAddress = $this.address.addresses | Get-Random
            $randomeNumber = @()
            foreach ($i in 0..9){
                $randomeNumber += $this.intList | Get-Random
            }
            $scriptBlock = [scriptblock]::Create("'$($this.customTypes.PhoneNumber.char.mask)' -f $($randomeNumber -join (','))")
            $randomeNumber = Invoke-Command -ScriptBlock $scriptBlock
            $records += [pscustomobject]@{
                FirstName = Get-RandomFirstName
                LastName = Get-RandomLastname
                PhoneNumber =  $randomeNumber
                MiddleInital = (($this.engCharList) | Get-Random)
                State = $randomeAddress.State
                City = $randomeAddress.city
                HomeAddress = $randomeAddress.Address1
                PostalCode = $randomeAddress.postalCode
                
            }
        }

        return $records
    }
}
($Data.Record(30) | ConvertTo-Csv ) | Select-Object -Skip 1 





















$myRecods = @()
$total= 0
$Data = [SimpleDataGenerator]::new()
foreach($i in 1..100){
    $randomeWaitTime = 0..1000 | Get-Random
    do {
        $myRecods +=($Data.Record($randomeWaitTime) | ConvertTo-Csv ) | Select-Object -Skip 1
        #Start-Sleep -Seconds .1
        $total = $total +$randomeWaitTime
    }until ($i = 99)
} 
$total

$myRecods