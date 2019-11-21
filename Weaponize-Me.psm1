#requires -version 3
<#
.SYNOPSIS
  Weaponize-Me 

.DESCRIPTION
  Weaponize-Me

.PARAMETER 
  None

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  12-11-19
  Purpose/Change: Fuck shit up, my way, on my time, with my preference of shell.
  
.EXAMPLE
  none
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
# Configure TLS support for github
    try
    {
        ([Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12) | Out-Null
        Write-Host "[+] Configured TLS 1.2 Channels for Git communication" -ForegroundColor DarkMagenta

    }
    catch
    {
        Write-Host "[!] Failed to build TLS 1.2 Channel Support" -ForegroundColor DarkRed
    }

#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Location for WPS ZIP Master in gitgub
    $WPS_MasterLocation = "https://codeload.github.com/WillChaos/WeaponizePowershell/zip/master"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function WPSInvoke-WPSBanner
{
    # Simple banner
    Write-Host " 
    
              _      __                        _         ___                     ______       ____  
             | | /| / /__ ___ ____  ___  ___  (_)__ ___ / _ \___ _    _____ ____/ __/ /  ___ / / /  
             | |/ |/ / -_) _ `/ _ \/ _ \/ _ \/ /_ // -_) ___/ _ \ |/|/ / -_) __/\ \/ _ \/ -_) / /   
             |__/|__/\__/\_,_/ .__/\___/_//_/_//__/\__/_/   \___/__,__/\__/_/ /___/_//_/\__/_/_/    
                            /_/                                                                     

    " -ForegroundColor Green

}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

WPSInvoke-WPSBanner
