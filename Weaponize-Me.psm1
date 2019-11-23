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

  [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression') | Out-Null

  # download zip - store content as bytes in mem
  $ZipBytes   = (Invoke-WebRequest -Uri $WPS_MasterLocation).content

  # build a Zip object, and write the bytes into the zip object - also in mem
  $ZipStream  = New-Object System.IO.Memorystream
  $ZipStream.Write($ZipBytes,0,$ZipBytes.Length)

  # define Archive type from newly built zip/byte stream object
  $ZipArchive = New-Object System.IO.Compression.ZipArchive($ZipStream)

  # store references of the contents of zip 9so we can opperate on it)
  $ZippedContent = $ZipArchive.Entries

  # opperate on each item in the zip
  foreach($Zippeditem in $ZippedContent)
  {
    # if the zip items contain a powershell file or module, do the below (that isnt the main module
    if(($Zippeditem.FullName -like "*Ps1") -or ($Zippeditem.FullName -like "*psm1") -and ($Zippeditem.FullName -notlike "*Weaponize-Me.psm1"))
    {
        Write-Host "[+] Importing module: "$Zippeditem.FullName -ForegroundColor DarkMagenta
        # open zip item type in memory - store string based contents into a file
        $EntryReader = New-Object System.IO.StreamReader($Zippeditem.Open())
        $ItemContent  = $EntryReader.ReadToEnd()

        #import ps module contents into this shell
        if($IsMacOS)
        {
            Invoke-Command -ScriptBlock {pwsh -command $ItemContent} | Out-Null
        }
        if($IsLinux)
        {
            Invoke-Command -ScriptBlock {pwsh -command $ItemContent} | Out-Null
        }
        if($IsWindows)
        {
            Invoke-Command -ScriptBlock {powershell.exe -command $ItemContent} | Out-Null
        }
    }
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

WPSInvoke-WPSBanner
WPSConfigure-preReqs
