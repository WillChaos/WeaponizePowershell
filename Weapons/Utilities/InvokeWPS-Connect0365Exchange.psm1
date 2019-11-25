Function InvokeWPS-Connect0365Exchange()
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


