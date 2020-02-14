<#
.TargetOS
  OS:NIX
#>

Function Global:InvokeWPS-PortScan()
{
	param
	(
		# extensive scan. As quick as an in depth initial scan can be. masscan + indepth Nmap
		[switch] $SurfaceScan,
		# Scans top known ports using masscan - then enums those ports using nmap
		[switch] $QuickEnumScan,
		# No Enum/discovery scripts - blast with masscan (less reliable)
		[switch] $VeryQuickScan,
		# Target
		[String] $RHost
	)

	# Functions
	Function isPreReqsMet()
	{
		if( ((Invoke-Expression -Command "masscan -h") -like "*list those options that are compatible with nmap*") )
		{
			# nested ifs just to prevent super long if statements
			if( (Invoke-Expression -Command "nmap -h") -like "*Usage: nmap [Scan Type(s)]*")
			{
				Write-Host "[WPS] PreReqs Met"
				return $true
			}
			else
			{
				Write-Host "[WPS} ERROR: Nmap not installed. apt-get install nmap?"
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
		}
		if($QuickEnumScan -and $RHost)
		{
			Write-Host "[+]> Perfroming A Quick Scan + Quick Enum" -ForeGroundColor DarkGray
		}
		if(SurfaceScan -and $RHost)
		{
			Write-Host "[+]> Perfroming A Surface scan. This may take a bit.. Grab a coffee.." -ForeGroundColor DarkGray
		}
		else
		{
			Write-Host "[WPS]> Select the RHOST and a scan argument: SurfaceScan, QuickEnumScan or VeryQuickScan" -ForeGroundColor DarkRed
		}
	}
}
