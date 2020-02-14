  <#
.SYNOPSIS
  InvokeWPS-EnumeratePersistentApps
  (Still under construction) 
.DESCRIPTION
  Simply enumerates OS for installed software / apps - as well as searching common startup locations for peristent apps/malware
.OUTPUTS
  N/A
.TargetOS
  OS:WIN
.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  16/12/19
  Purpose/Change: Finding installed or persistent apps/software/malware at a glance
 
.EXAMPLE
  PS:/> Import-Module InvokeWPS-EnumeratePersistentApps.psm1
  PS:/> InvokeWPS-EnumeratePersistentApps
#>

Function Global:InvokeWPS-EnumeratePersistentApps()
{
    
    Function Enumerate-WINStartupKeys()
    {

    }

    Function Enumerate-WINStartupDirs()
    {
        $UserStartupDirs    = @(
                                   "C:\Users\$env:username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
                               )

        $AlluserStartupDirs = @(
                                   "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
                               )
        
        Write-Host "[WPS]> Enumerating files in startup folders" -ForegroundColor DarkMagenta

        foreach($FileObject in $UserStartupDirs)
        {
            if(Test-Path $FileObject)
            {
                Get-ChildItem "$FileObject" | Select Name, CreationTime
            }
        }

        foreach($FileObject in $AlluserStartupDirs)
        {
            if(test-path $FileObject)
            {
                Get-ChildItem "$FileObject" | Select Name, CreationTime
            }
        }

    }

    # Execution 
    if($env:OS -like "*nt*")
    {
        Enumerate-WinStartupKeys
        Enumerate-WinStartupDirs
    }
    else
    {
        Write-Host "[WPS]> Module not yet supported on non WIN OS" -ForegroundColor DarkRed
        
    }
}
