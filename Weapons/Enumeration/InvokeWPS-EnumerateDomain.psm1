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
            Write-Host "-[MX: $MXPriority] $MXName | $MXNE > $MXIP ($ASN)" -ForegroundColor DarkGray
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

    # NS
    Write-Host "[+] Resolving nameserver information: $DomainName " -ForegroundColor Magenta
    foreach($NSRecord in (Resolve-DnsName -Name $DomainName -Type NS -ErrorAction SilentlyContinue))
    {
        if($NSRecord.section -like "Answer")
        {
            $NSName     = $NSRecord.Name
            $NSIP       = $NSRecord.NameHost 

            Write-Host "-[NS] $NSName > $NSIP" -ForegroundColor DarkGray
        }

    }

    # .TXT 
    Write-Host "[+] Resolving TXT information: $DomainName " -ForegroundColor Magenta
    foreach($TXTRecord in (Resolve-DnsName -Name $DomainName -Type txt -ErrorAction SilentlyContinue))
    {
        if($TXTRecord.section -like "Answer")
        {
            $TXTName     = $TXTRecord.Name
            $TXTEntry    = $TXTRecord.Strings 

            Write-Host "-[TXT] $TXTName > $TXTEntry" -ForegroundColor DarkGray
        }

    }
    # ._DMARC 
    Write-Host "[+] Resolving _DMARC information: $DomainName " -ForegroundColor Magenta
    foreach($DMARCRecord in (Resolve-DnsName -Name "_Dmarc.$DomainName" -Type txt -ErrorAction SilentlyContinue))
    {
        if($DMARCRecord.section -like "Answer")
        {
            $DMARCName     = $DMARCRecord.Name
            $DMARCEntry    = $DMARCRecord.Strings 

            Write-Host "-[TXT] $DMARCName > $DMARCEntry" -ForegroundColor DarkGray
        }

    }
    # DKIM (this isnt reliable - brute forcey)
    Write-Host "[+] Attempting to resolve DKIM information: $DomainName (not 100% reliable" -ForegroundColor Magenta
    # 365
    if(Resolve-DnsName -Name selector1._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] Office365 DKIM signing detected: selector1._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    if(Resolve-DnsName -Name selector2._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] Office365 DKIM signing detected: selector2._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    if(Resolve-DnsName -Name k1._domainkey._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] Mailchimp DKIM signing detected: k1._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    if(Resolve-DnsName -Name cm._domainkey._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] e-Campaign DKIM signing detected: cm._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    if(Resolve-DnsName -Name s1._domainkey._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] SendGrid DKIM signing detected: s1._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    if(Resolve-DnsName -Name s2._domainkey._domainkey.$DomainName -ErrorAction SilentlyContinue)
    {
        Write-Host "-[DKIM] SendGrid DKIM signing detected: s2._domainkey.$DomainName" -ForegroundColor DarkGray

    }
    
    


    # Whois
}
