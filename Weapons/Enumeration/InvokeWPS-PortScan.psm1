<#
.SYNOPSIS
  Simple and reliable port scanner built with powerrshell at the fingertips, 
  Built with Masscan as the backbone for speed and NMAP for the reliable inspection.

.DESCRIPTION
  Port Scanner and service detector. this will also use some of Nmaps NSE engine to find default vulns.
  This shouldnt be reliaed on for deep port inspection - just as a reliable indicator of weather a port is open or not.

.PARAMETER 
  $RHost         : Remote Host to target 
  $SurfaceScan   : Extensive scan. As quick as an in depth initial scan can be. masscan + indepth Nmap     
  $QuickEnumScan : Scans top known ports using masscan - then enums those ports using nmap
  $VeryQuickScan : No Enum/discovery scripts - blast with masscan (less reliable)
  
.INPUTS
  N/A - None Required.

.OUTPUTS
  N/A - Unless piped and specified otherwise. 

.TargetOS
  OS:NIX

.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  14-2-2020
  Purpose/Change: Box Port Enumeration. Efficventrly and conistently. 
  
.EXAMPLE
  InvokeWPS-PortScan -RHost 10.10.10.171 -VeryQuickScan
#>

Function Global:InvokeWPS-PortScan()
{
	param
	(
		[Parameter(Mandatory=$true)]
		[String] $RHost,

		[switch] $SurfaceScan,
		[switch] $QuickEnumScan,
		[switch] $VeryQuickScan
        
	)

	# Functions
	Function isPreReqsMet()
	{
		if( ((Invoke-Expression -Command "masscan -h") -like "*list those options that are compatible with nmap*") )
		{
			# nested if's just to prevent super long if statements
			if( (Invoke-Expression -Command "nmap -h") -like "*https://nmap.org/book/man.html*")
			{
				Write-Host "[WPS] PreReqs Met"
				return $true
			}
			else
			{
				Write-Host "[WPS] ERROR: Nmap not installed. apt-get install nmap?"
				return $false
			}
		}
		else
		{
			Write-Host "[WPS] ERROR: MASSCAN not installed. apt-get install masscan?"
			return $false
		}
	}


	# Exec
	if(isPreReqsMet)
	{
		if($VeryQuickScan -and $RHost)
		{
			Write-Host "[+]> Performing Very quick scan" -ForeGroundColor DarkGray
            		$ScanArgs = "sudo masscan --ports 0-65535 $RHost --rate 1000"
            		Invoke-Expression -Command $ScanArgs
		}
		if($QuickEnumScan -and $RHost)
		{
			Write-Host "[+]> Perfroming A Quick Scan + Quick Enum" -ForeGroundColor DarkGray
		}
		if($SurfaceScan -and $RHost)
		{
			Write-Host "[+]> Perfroming A Surface scan. This may take a bit.. Grab a coffee.." -ForeGroundColor DarkGray
		}
		else
		{
			Write-Host "[WPS]> Select the RHOST and a scan argument: SurfaceScan, QuickEnumScan or VeryQuickScan" -ForeGroundColor DarkRed
		}
	}
}
