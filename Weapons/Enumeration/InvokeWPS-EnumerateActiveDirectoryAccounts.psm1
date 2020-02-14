<#
.TargetOS
  OS:WIN
#>

Function Global:InvokeWPS-EnumerateActiveDirectoryAccounts()
{
    param
    (

    [Switch] $PrivUsersOnly,
    
    [Switch] $ActivityReport
    
    
    )

    # pre req check
    if(Get-Module ActiveDirectory)
    {
        Import-Module ActiveDirectory -Force -ErrorAction Stop | Out-Null
        Write-Host "Imported AD module" -ForegroundColor DarkMagenta
    }
    else
    {
        Write-Host "Error - Unable to import AD module." -ForegroundColor DarkRed
    }

    # handle enum
    if($PrivUsersOnly)
    {
        Write-Host "[+] Begun enumerating privlaged users in AD" -ForegroundColor DarkGreen

        # get every AD User account object
        $PrivGroups = @(
                        "Domain Admins",
                        "Schema Admins",
                        "Administrators",
                        "Hyper-V Administrators",
                        "Account Operators",
                        "Backup Operators",
                        "Server Operators",
                        "Enterprise Admins",
                        "Group Policy Creator Owners"
                        )

        foreach($Group in $PrivGroups)
        {
            $GroupMembers = Get-ADGroupMember -Identity $Group
            if($GroupMembers)
            {
                Write-Host " -- " $Group " -- "
                foreach($ThisUser in $GroupMembers)
                {
                    Write-Host "-> " $ThisUser.Name
                }
                Write-Host " "
            }
        }
    }
    elseif($ActivityReport)
    {
        Write-Host "[+] Begun building Activity report for all AD users" -ForegroundColor DarkGreen

        Get-ADUser -Filter 'enabled -eq $true' -Properties * | Select-Object -Property Name, 
            @{Name="AccountCreated";Expression="WhenCreated"}, 
            @{Name="PasswordLastReset";Expression="PasswordLastSet"}, 
            @{Name="LogonCount";Expression="LogonCount"}, 
            @{Name="TotalFailedLogons";Expression="msDS-FailedInteractiveLogonCount"},
            @{Name="RecentFailedLogons";Expression="msDS-FailedInteractiveLogonCountAtLastSuccessfulLogon"}, 
            @{Name="LastFailedLogon";Expression={[datetime]::FromFileTime($_.'msDS-LastFailedInteractiveLogonTime')}}, 
            @{Name="LastSuccessfulLogon";Expression={[datetime]::FromFileTime($_.'LastLogon')}} 
    }
}
