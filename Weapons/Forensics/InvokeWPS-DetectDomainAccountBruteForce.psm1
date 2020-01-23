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
   
    Write-Host "[WPS]> Checking for potential brute forceing..." -ForegroundColor Green

    try
    {
        if($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_FL)
        {
            Write-Host "------------------------ Failed Logons in the past $Hours hours ------------------------------" -ForegroundColor DarkGray
            $result
        }
        elseif($result = Get-EventLog -LogName Security -After (Get-Date).AddHours(-$Hours) -InstanceId $ID_AU){
            Write-Host "---------------------- Accounts locked out in the past $Hours hours ---------------------------" -ForegroundColor DarkGray
            $result
        }
        else
        {
            Write-Host "[!] Either No relevant loggs on the system or AD logging not enabled." -ForegroundColor DarkRed
            Return $false
        }
    }
    catch [System.Security.SecurityException]
    {
        Write-Host "[!] No Access to events - are we running elevated?" -ForegroundColor DarkRed
    }
    
}
