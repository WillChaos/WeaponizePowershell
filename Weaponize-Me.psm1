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

Function WPSConfigure-preReqs
{
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
}

Function WPSInvoke-SelfInmemory
{
  Write-Host "[+] Staging self in memory" -ForegroundColor DarkMagenta
  [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

  # download zip - store content as bytes (in mem)
  $ZipBytes   = (Invoke-WebRequest -Uri $WPS_MasterLocation).content
  
  # build a Zip object, and write the bytes into the zip object (in mem)
  $ZipStream  = New-Object System.IO.Memorystream
  $ZipStream.Write($ZipBytes,0,$ZipBytes.Length)
  $ZipArchive = New-Object System.IO.Compression.ZipArchive($ZipStream)
  $ZippedContent = $ZipArchive.Entries

  # opperate on each item in the zip
  foreach($Zippeditem in $ZippedContent)
  {
    # if the zip items contain a powershell file or module, do the below (that isnt the main module
    if(($Zippeditem.FullName -like "*Ps1") -or ($Zippeditem.FullName -like "*psm1") -and ($Zippeditem.FullName -notlike "*Weaponize-Me.psm1"))
    {
        # open zip item type in memory - store string based contents into a file
        $EntryReader = New-Object System.IO.StreamReader($Zippeditem.Open())
        $ItemContent  = $EntryReader.ReadToEnd()

        # handle Os dependant scripts - import only as NIX script if specified
        if($ItemContent -like "*OS:NIX*")
        {
            #import ps module contents into this shell - targetting linux
            Write-Host "-[>] Importing module: "$Zippeditem.FullName  -ForegroundColor DarkGray
            Invoke-Expression $ItemContent
        }
        if($ItemContent -like "*OS:WIN*")
        {
            #import ps module contents into this shell - targetting windows
            Write-Host "-[>] Importing module: "$Zippeditem.FullName -ForegroundColor DarkGray
            Invoke-Expression $ItemContent
        }
        else
        {
            #import ps module contents into this shell - always import modules - including undefined ones - assume the module works on all OS's
            Write-Host "-[>] Importing module: "$Zippeditem.FullName  -ForegroundColor DarkGray
            Invoke-Expression $ItemContent
        }
        
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

WPSInvoke-WPSBanner
WPSConfigure-preReqs
WPSInvoke-SelfInmemory
