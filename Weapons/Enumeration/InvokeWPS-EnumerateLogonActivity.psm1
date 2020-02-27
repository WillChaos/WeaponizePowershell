<#
    .SYNOPSIS
      Script was built simply to enumerate recent account logon/logoff/authentication history
      
    .TargetOS
      OS:WIN
      
    .NOTES
      Version:        0.7
      Author:         WillChaos
      Creation Date:  27-2-2020
      Purpose/Change: Increase in demand for authentication activity
      Production availability: Still in testing. not considered reliable yet. 

    .EVENTINFO
      Logon Type | Description
      __________________________________________________________________________________________________________________________
      2	         Interactive (logon at keyboard and screen of system)
      3	         Network (i.e. connection to shared folder on this computer from elsewhere on network)
      4	         Batch (i.e. scheduled task)
      5	         Service (Service startup)
      7	         Unlock (i.e. unnattended workstation with password protected screen saver)
      8	         NetworkCleartext (Logon with credentials sent in the clear text. Most often indicates a logon to IIS with "basic authentication") See this article for more information.
      9	         NewCredentials such as with RunAs or mapping a network drive with alternate credentials.  This logon type does not seem to show up in any events.  If you want to track users attempting to logon with alternate credentials see 4648.  MS says "A caller cloned its current token and specified new credentials for outbound connections. The new logon session has the same local identity, but uses different credentials for other network connections."
      10	 RemoteInteractive (Terminal Services, Remote Desktop or Remote Assistance)
      11	 CachedInteractive (logon with cached domain credentials such as when logging on to a laptop when away from the network)
      __________________________________________________________________________________________________________________________
      
#>

$ID = "4624"

Function Global:InvokeWPS-EnumerateLogonActivity()
{
	param
	(
    
		[Parameter(Mandatory=$true)]
		[String] $UserName,
        
        [Parameter(Mandatory=$true)]
		[Int] $DaysToAudit,

        # login to console
        [Switch] $InteractiveLogins,

        # Schuedled takss and scripts
        [Switch] $BatchLogins,

        # RDP sessions and non console based interactive logins
        [Switch] $RemoteLogins,

        # Network drives / shares etc
        [Switch] $NetworkLogins,

        # Login using cached credentials (SAM DB rather then DC auth)
        [Switch] $LocalLogins,

        # All logs assosiated with the event ID
        [Switch] $AllLogins

	)
    
    # ----------------------------------------------------------------Functions----------------------------------------------------------------------------

    Function Invoke-Banner()
    {
        Write-Host " __________________________________________________________________________________________________ " -ForegroundColor DarkGray
        Write-Host "|                               WillChaos Logon Enumerator                                         |" -ForegroundColor DarkGray
        Write-Host "+--------------------------------------------------------------------------------------------------+" -ForegroundColor DarkGray
        Write-Host "   There is "  $Audit.count  " logon events related to $UserName in the past: $DaysToAudit Days    "  -ForegroundColor DarkGray
        Write-Host "+--------------------------------------------------------------------------------------------------+" -ForegroundColor DarkGray
        Write-Host " "
        sleep 2
    }

    Function Get-LogonType()
    {
        param
        (
            [Parameter(Mandatory=$true)]
            [psobject] $EventLogObj
        )

        if(($EventLogObj.ReplacementStrings)[8] -like '2')
        {
            return "Interactive logon"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '3')
        {
            return "Network logon"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '4')
        {
            return "Batch / script logon"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '5')
        {
            return "Service start/logon"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '7')
        {
            return "Unlock - screensaver/lockscreen logon"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '8')
        {
            return "Cleartext Logon (usually IIS/basic Auth)"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '9')
        {
            return "New Credentials / Runas logon (map drive as different user etc)"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '10')
        {
            return "Remote interactive Logon (RDP etc)"
        }
        if(($EventLogObj.ReplacementStrings)[8] -like '11')
        {
            return "Cached Credetnial (logon without domain connectivity etc)"
        }
        else
        {
            return "Unkown logon Type"
        }


    }

    # --------------------------------------------------------------main Execution--------------------------------------------------------------------------

    # Inital log Enum
    Write-Host "[WPS] Enumerating logs on the system... (this may take a while)" -ForegroundColor DarkGreen
    $Audit = Get-EventLog -LogName Security -After (get-date).addDays("-"+$DaysToAudit) -InstanceId $ID | Where-Object {$_.Message -like "*$UserName*"}

    # Create header banner
    Invoke-Banner

    if($Audit -eq $Null)
    {
        Write-Host "-[!] No Logs found at all with event ID of: $ID" -ForegroundColor DarkRed
    }
    else
    {
        if($AllLogins)
        {
            Write-Host "-[+] Filtering for: ALL LOGINS"
            foreach($Event in $Audit)
            {
                Write-Host " - " -ForegroundColor Gray
                Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                Write-Host "Time: "      $Event.TimeGenerated
                Write-Host "Logon Type:" (Get-LogonType -EventLogObj $Event)
                
            }
        }
        elseif($LocalLogins -and (!$AllLogins))
        {
            Write-Host "-[+] Filtering for: LOCAL LOGINS"
            foreach($Event in $Audit)
            {
                if((($Event.ReplacementStrings)[8]) -like '11')
                {
                    Write-Host " - " -ForegroundColor Gray
                    Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                    Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                    Write-Host "Time: "      $Event.TimeGenerated
                }
                
            }
        }
        elseif($NetworkLogins -and (!$AllLogins))
        {
            Write-Host "-[+] Filtering for: NETWORK LOGINS"
            foreach($Event in $Audit)
            {
                if((($Event.ReplacementStrings)[8]) -like '3')
                {
                    Write-Host " - " -ForegroundColor Gray
                    Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                    Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                    Write-Host "Time: "      $Event.TimeGenerated
                }
                
            }

        }
        elseif($RemoteLogins -and (!$AllLogins))
        {
            Write-Host "-[+] Filtering for: REMOTE INTERACTIVE LOGINS"
            foreach($Event in $Audit)
            {
                if((($Event.ReplacementStrings)[8]) -like '10')
                {
                    Write-Host " - " -ForegroundColor Gray
                    Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                    Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                    Write-Host "Time: "      $Event.TimeGenerated
                }
                
            }
        }
        elseif($BatchLogins -and (!$AllLogins))
        {
            Write-Host "-[+] Filtering for: BATCH LOGINS"
            foreach($Event in $Audit)
            {
                if((($Event.ReplacementStrings)[8]) -like '4')
                {
                    Write-Host " - " -ForegroundColor Gray
                    Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                    Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                    Write-Host "Time: "      $Event.TimeGenerated
                }
                
            }
        }
        elseif($InteractiveLogins -and (!$AllLogins))
        {
            Write-Host "-[+] Filtering for: INTERACTIVE CONSOLE LOGINS"
            foreach($Event in $Audit)
            {
                if((($Event.ReplacementStrings)[8]) -like '2')
                {
                    Write-Host " - " -ForegroundColor Gray
                    Write-Host "Username: " ($Event.ReplacementStrings)[6] "\" ($Event.ReplacementStrings)[5]
                    Write-Host "Device: "   ($Event.ReplacementStrings)[18]
                    Write-Host "Time: "      $Event.TimeGenerated
                }
                
            }
        }
        else
        {
            Write-Host "[!] Didn't select an argument login type." -ForegroundColor DarkRed

        }
        
    }
   
}
