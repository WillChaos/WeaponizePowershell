<#
.SYNOPSIS
  InvokeWPS-SQLCMD.psm1
.DESCRIPTION
  Simply built to pop code execution with basic SQL cmd access
.PARAMETER 
  $RHost            = sets the target address (this can be localhost or the remote IP depending ont he situation)
  $CreateNewSA      = payload after connecting will be: a new SA account
  $PopBindShell     = payload after connecting will be: A Binded Shell located $RHOST:7777
  $PopReverseShell  = payload after connecting will be: A Bind Shell calling back to $LPORT:7777 (tba)
  $EnableSQLCMD     = enabled SQLCMD (requires local access to the machien to execute)
.OUTPUTS
  WARING: sqlcmd will be staged using the powershell gallery (technically touches disk)
.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  9/1/2020
  Purpose/Change: SQL privesque - Pop an SQLCMD shell an innovate!
  Availbility: currently can only be executed from windows powershell varients (nix/mac not available yet) 
  
.EXAMPLE
  PS:/> Import-Module Invoke-SQLCMD.psm1
  PS:/> InvokeWPS-SQLCMD -RHost 10.1.1.1 -CreateNewSA
#>


Function Global:InvokeWPS-SQLCMD(){
    
    param
    (
        [Parameter(Mandatory)]
        [String] $RHost,

        [Switch] $CreateNewSA,
        [Switch] $PopBindShell,
        [Switch] $PopReverseShell,
        [Switch] $EnableSQLCMD
    )

    # Functions
    Function Stage-SQLCMD()
    {

        if(!(Get-Module -Name SqlServer))
        {
            Write-Host "[WPS] SQLCMD Not present, Downloading & Staging... " -ForegroundColor Magenta
            try
            {
                Install-module -Name SqlServer -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber -ErrorAction Stop
                Import-Module Sqlserver -DisableNameChecking -Force -ErrorAction Stop
                
                # now that the module is staged, lets reloop this action to begin
                Stage-SQLCMD
            }
            catch
            {
                Write-Host "[WPS] Unable to import Powershell SqlServer tools. (try to manuelly import sqlserver module and see what happens)" -ForegroundColor DarkRed
            }
            
        }
        else
        {
            Write-Host "[WPS] SQLCMD present on device." -ForegroundColor Magenta
        }
    }

    # Main
    Stage-SQLCMD

    if($CreateNewSA)
    {
        Invoke-Sqlcmd -ServerInstance $RHost -Query
    }
    if($PopBindShell)
    {

    }
    if($PopReverseShell)
    {
        # TBA
    }
    if($EnableSQLCMD)
    {
        # Requires elevated permissions
        # Requires to  be run on the server locally (RHOST and RPORT not required)

    }
    else
    {
        Write-Host "[WPS] No Payload parametres selected, performing general enumeration." -ForegroundColor Green
        try
        {
            $result = Invoke-Sqlcmd -ServerInstance $RHost -Query "@@version" -ErrorAction stop
            $result
        }
        catch
        {
            Write-Host "[WPS] ERROR response below "
            $result
        }
    }
}
