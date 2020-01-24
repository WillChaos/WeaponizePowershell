Function Global:InvokeWPS-DetectDomainAccountBruteForce()
{
<#
     info: 
     A Simple Script that perfroms a eventvwr lookup for account logon failuers and lockouts.
     This script works best on a central logging server or DC. 
     Script generally requires elevation to see the events.  nothing to fancy in this scrpt
    Params: 
    $hours - simply pass in how many hours to search back. so if you pass in 3, we will look over the past 3 hours
             for any lockouts/failed logins.
#>
    param
    (  
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Hours
    )
    
    $ID_LO = @(4740,644,6279)     # Account locked out.
    $ID_AU = @(4767)              # Account unlocked.
    $ID_FL = @(4625,529)          # Failed Logon because of bad password	
   
    # build custom Audit object
    $OBJ_FL = New-Object -TypeName psobject
   

    Write-Host "[WPS]> Checking for potential brute forceing..." -ForegroundColor Green

    try
    {
        if($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_FL -ErrorAction SilentlyContinue)
        {
            Write-Host "------------------------ Failed Logons in the past $Hours hours ------------------------------" -ForegroundColor DarkGray
            foreach($log in $result)
            {
                # get info
                $name     = (($log).ReplacementStrings)[0]
                $target   = (($log).ReplacementStrings)[1]
                $timegen  =   $log.TimeGenerated
                $timewrit =   $log.TimeWritten
                $eventid  =   $log.InstanceId

                # present info
                Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                Write-Host "-[*] target devcie locking out against: $target" -ForegroundColor Gray
                Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                Write-Host "-"
            }
            
        }
        elseif($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_LO -ErrorAction SilentlyContinue)
        {
            Write-Host "---------------------- Accounts locked out in the past $Hours hours ---------------------------" -ForegroundColor DarkGray
            foreach($log in $result)
            {
                # get info
                $name     = (($log).ReplacementStrings)[0]
                $target   = (($log).ReplacementStrings)[1]
                $timegen  =   $log.TimeGenerated
                $timewrit =   $log.TimeWritten
                $eventid  =   $log.InstanceId

                # present info
                Write-Host "[+] $name was locked out"                        -ForegroundColor Green
                Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                Write-Host "-[*] target devcie locking out against: $target" -ForegroundColor Gray
                Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                Write-Host "-"
            }
        }
        else
        {
            Write-Host "[!] Either No relevant loggs on the system or AD logging not enabled." -ForegroundColor DarkRed
        }
    }
    catch [System.Security.SecurityException]
    {
        Write-Host "[!] No Access to events - are we running elevated?" -ForegroundColor DarkRed
    }
    
}
