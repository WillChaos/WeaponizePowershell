<#
.SYNOPSIS
  InvokeWPS-Connect0365Exchange.psm1
.DESCRIPTION
  Simply built to connect to office365 exchange admin - nothing fancy here.
.PARAMETER 
  None / Script is interactive
.INPUTS
  None / Script is interactive
.OUTPUTS
  None
.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  25/11/19
  Purpose/Change: Simple Automation.
  
.EXAMPLE
  PS:/> Import-Module InvokeWPS-Connect0365Exchange.psm1
  PS:/> InvokeWPS-Connect0365Exchange
#>

Function Global:InvokeWPS-Connect0365Exchange()
{
    $Credential = Get-Credential

        try
        {
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                                     -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
                                     -Credential $Credential `
                                     -Authentication Basic `
                                     -AllowRedirection `
                                     -ErrorAction Stop `
                                     -WarningAction SilentlyContinue `
                                     -InformationAction SilentlyContinue
            Import-PSSession $Session -DisableNameChecking

            Write-Host "[WPS]> Connected to 0365 Exchange!" -ForegroundColor DarkGreen                          
                                     
        }
        catch
        {
            Write-Host "[WPS]> Failed to connect to 0365 Exchange - Auth failure?" -ForegroundColor DarkRed
        }
}


