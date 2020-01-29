Function Global:InvokeWPS-EnumerateDomain()
{
    param
    (
        [Parameter(Position=0,mandatory=$true)]
        [string] $DomainName
    )

    # MX 
    Write-Host "[+] Resolving Mail Exchange for target: $DomainName " -ForegroundColor Magenta
    foreach($MXRecord in (Resolve-DnsName -Name $DomainName -Type MX -ErrorAction SilentlyContinue))
    {
        if($MXRecord.section -like "Answer")
        {
            $MXPriority = $MXRecord.Preference
            $MXName     = $MXRecord.Name
            $MXNE       = $MXRecord.NameExchange
            $MXIP       = (Resolve-DnsName -Name $MXNE -Type A -ErrorAction SilentlyContinue).IP4Address
            $ASN        = (wget https://api.hackertarget.com/aslookup/?q=$MXIP -ErrorAction SilentlyContinue)
            Write-Host "-[$MXPriority] $MXName | $MXNE > $MXIP ($ASN)" -ForegroundColor DarkGray
        }
    }


    # WWW / @ 
    Write-Host "[+] Resolving webhost information: $DomainName " -ForegroundColor Magenta
    foreach($ARecord in (Resolve-DnsName -Name $DomainName -Type A -ErrorAction SilentlyContinue))
    {
        if($ARecord.section -like "Answer")
        {
            $AName     = $ARecord.Name
            $AIP       = $ARecord.IP4Address
            $ASN       = (wget https://api.hackertarget.com/aslookup/?q=$AIP -ErrorAction SilentlyContinue)

            Write-Host "-[A] $AName > $AIP ($ASN)" -ForegroundColor DarkGray
        }

    }
    foreach($ARecord in (Resolve-DnsName -Name "www.$DomainName" -Type A -ErrorAction SilentlyContinue))
    {
        if($ARecord.section -like "Answer")
        {
            $AName     = $ARecord.Name
            $AIP       = $ARecord.IP4Address
            $ASN       = (wget https://api.hackertarget.com/aslookup/?q=$AIP -ErrorAction SilentlyContinue)
            Write-Host "-[A] $AName > $AIP ($ASN)" -ForegroundColor DarkGray
        }

    }

    # .TXT / _DMARC / _DKIM

    # Whois
}
