<#
     .INFO: 
     A Simple Script that perfroms a eventvwr lookup for account logon failuers and lockouts.
     This script works best on a central logging server or DC. 
     Script generally requires elevation to see the events.  nothing to fancy in this scrpt
     
     .Params: 
     $hours - simply pass in how many hours to search back. so if you pass in 3, we will look over the past 3 hours
              for any lockouts/failed logins. Accepts floats ie 0.5 or 2.3
     .TargetOS
       OS:WIN      
     
#>

Function Global:InvokeWPS-DetectDomainAccountBruteForce()
{

    param
    (  
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Hours
    )
    
    # Event IDS
    $ID_LO = @(4740,644,6279)                  # Account locked out.
    $ID_AU = @(4767)                           # Account unlocked.
    $ID_FL = @(529,4776,4769,4625,4768,4771)   # Failed Logon because of bad password	
   
    # Error codes (WIP)
    $0xc000006a = ("0xc000006a: username is correct, but the password is wrong")

    # Build custom Audit object
    $OBJ_FL = New-Object -TypeName psobject
   
    Write-Host "[WPS]> Checking for potential brute forceing..." -ForegroundColor Green

    try
    {
        if($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_FL -ErrorAction SilentlyContinue -EntryType FailureAudit)
        {
            Write-Host "------------------------ Failed Logons in the past $Hours hours ------------------------------" -ForegroundColor DarkGray
            foreach($log in $result)
            {
               #handling formating of different logs
               if($log.InstanceId -like "*4776*")
               {
                    # get info
                    $name     = (($log).ReplacementStrings)[1]
                    $target   = (($log).ReplacementStrings)[2]
                    $errcode  = (($log).ReplacementStrings)[3]
                    $timegen  =   $log.TimeGenerated
                    $timewrit =   $log.TimeWritten
                    $eventid  =   $log.InstanceId

                    # present info
                    Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                    Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                    Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                    Write-Host "-[*] target devcie locking out against: $target" -ForegroundColor Gray
                    Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                    Write-Host "-[*] Logon Error code: : $errcode"               -ForegroundColor Gray
                    Write-Host "-"
               }
               if($log.InstanceId -like "*4769*")
               {
                    # get info
                    $name     = (($log).ReplacementStrings)[0]
                    $target   = (($log).ReplacementStrings)[6] + ":" + (($log).ReplacementStrings)[7]
                    $errcode  = (($log).ReplacementStrings)[8]
                    $timegen  =   $log.TimeGenerated
                    $timewrit =   $log.TimeWritten
                    $eventid  =   $log.InstanceId

                    # present info
                    Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                    Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                    Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                    Write-Host "-[*] lockout destination: $target"               -ForegroundColor Gray
                    Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                    Write-Host "-[*] Logon Error code: : $errcode"               -ForegroundColor Gray
                    Write-Host "-"
               }
               if($log.InstanceId -like "*4625*")
               {
                    # get info
                    $name       = (($log).ReplacementStrings)[5]
                    $target     = (($log).ReplacementStrings)[13] 
                    $locproc    = (($log).ReplacementStrings)[11]
                    $errreason  = (($log).ReplacementStrings)[7]
                    $timegen    =   $log.TimeGenerated
                    $timewrit   =   $log.TimeWritten
                    $eventid    =   $log.InstanceId
                    

                    # present info
                    Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                    Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                    Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                    Write-Host "-[*] lockout destination: $target"               -ForegroundColor Gray
                    Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                    Write-Host "-[*] Failure Reason: : $errreason"               -ForegroundColor Gray
                    Write-Host "-[*] Process assosiated with lockout: $locproc"  -ForegroundColor Gray
                    Write-Host "-"
               }
               if($log.InstanceId -like "*4768*")
               {
                    # get info
                    $name       = (($log).ReplacementStrings)[0]
                    $target     = (($log).ReplacementStrings)[9] 
                    $failcode   = (($log).ReplacementStrings)[6] + ":" + (($log).ReplacementStrings)[7]
                    $timegen    =   $log.TimeGenerated
                    $timewrit   =   $log.TimeWritten
                    $eventid    =   $log.InstanceId
                    

                    # present info
                    Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                    Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                    Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                    Write-Host "-[*] lockout destination: $target"               -ForegroundColor Gray
                    Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                    Write-Host "-[*] Failure Code: : $failcode"                  -ForegroundColor Gray
                    Write-Host "-"
               }
               if($log.InstanceId -like "*4771*")
               {
                    # get info
                    $name       = (($log).ReplacementStrings)[0]
                    $target     = (($log).ReplacementStrings)[6] 
                    $failcode   = (($log).ReplacementStrings)[4]
                    $timegen    =   $log.TimeGenerated
                    $timewrit   =   $log.TimeWritten
                    $eventid    =   $log.InstanceId
                    

                    # present info
                    Write-Host "[+] $name failed logon"                          -ForegroundColor Green
                    Write-Host "-[*] Time Generated: $timegen"                   -ForegroundColor Gray
                    Write-Host "-[*] Time Written: $timewrit"                    -ForegroundColor Gray
                    Write-Host "-[*] lockout destination: $target"               -ForegroundColor Gray
                    Write-Host "-[*] Log Event ID : $eventid"                    -ForegroundColor Gray
                    Write-Host "-[*] Failure Code: : $failcode"                  -ForegroundColor Gray
                    Write-Host "-"
               }
               if($log.InstanceId -like "*529*")
               {
                Write-Host "[?] Found log 529 (related to local sam file - we havent added loggin abilty for this yet, add it now with the samples in eventvwr.msc)" -ForegroundColor DarkGray
                Write-Host " - "
               }
               
               
            }
            
        }
        elseif($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_LO -ErrorAction SilentlyContinue -EntryType FailureAudit)
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
