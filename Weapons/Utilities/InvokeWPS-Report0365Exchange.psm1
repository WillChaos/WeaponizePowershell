  <#
.SYNOPSIS
  InvokeWPS-Report0365Exchange.psm1
.DESCRIPTION
  Connects to 0365 exchange admin center and builds an extencisve report for Security, Sales and general auditing. 
.PARAMETER 
  Outpath   - Directory in which to write the report to. If Nothing specified, it will write in the current working directory.
  LogoURL   - The URL directing to a WEB hosting image to be used as a logo for the report. Default will be used if not specified.
  LogoURL2  - Second logo - similar to above. 
  Enable2FA - Set this switch if we require 2fa auth to the tennant  
.INPUTS
  None / Script is interactive
.OUTPUTS
  This Script will write a report to disk using the outpath param.
.NOTES
  Version:        0.7
  Author:         WillChaos
  Creation Date:  27/11/19
  Purpose/Change: 0365 reporting.
.NOISE
  This script isnt meant by any means to be evasive. It is built for reporting.
  This script is not memory dependant. It will Write to the disk, and install powershell modules and dependancies where required.
  This will likely cause events to be written in eventvwr.msc as well as Endpoint/IDS alerting.
  
.EXAMPLE
  PS:/> Import-Module InvokeWPS-Report0365Exchang.psm1
  PS:/> InvokeWPS-Report0365Exchange -OutPath c:\users\me\Desktop\ -LogoURl http://someurel.com/pic.png
#>
Function Global:InvokeWPS-Report0365Exchange()
{
    param
    (
        [String] $OutPath,
        [String] $LogoURL,
        [String] $Logo2URL,
        [Switch] $Enable2FA
    )

    # -----------------------------------Declarations-----------------------------------------------

    # if we havent set the OutPath, then lets set it to our current directory
    if(!($OutPath))
    {
        [String] $OutPath = (Get-Location).Path
        Write-Host "[WPS]> Outpath not specified, Report will be dumped to working directory: $OutPath" -ForegroundColor Black
    }

    # set Logo 
    if(!($LogoURL))
    {
        $URL_LOGO = "https://newtrend.com.au/wp-content/uploads/2017/11/Newtrend-Logo-with-award-01.png"

        [String] $LogoURL = $URL_LOGO
        Write-Host "[WPS]> LogoURL not specified, using default: $LogoURL" -ForegroundColor Black
    }

    # set second Logo  
    if(!($Logo2URL))
    {
        $URL_LOGO2 = "https://newtrend.com.au/wp-content/uploads/2016/01/Newtrend-Cloud-b-and-w-1635x1635.jpg"

        [String] $Logo2URL = $URL_LOGO2
        Write-Host "[WPS]> Logo2URL not specified, using default: $Logo2URL" -ForegroundColor Black
    }

    
    # -------------------------------------Functions------------------------------------------------
    Function StagepreReqs()
    {
    # Check if test gallery is registered 
    $PackageSource = Get-PackageSource -Name 'Posh Test Gallery' -ErrorAction SilentlyContinue

    if (!($PackageSource))
    {
	    $PackageSource = Register-PackageSource -Trusted -ProviderName 'PowerShellGet' -Name 'Posh Test Gallery' -Location 'https://www.poshtestgallery.com/api/v2/'
    }

    # Check if module is installed
    $AzureADmodule = Get-Module 'AzureAD.Standard.Preview' -ListAvailable -ErrorAction SilentlyContinue
    $ReportModule  = Get-Module 'ReportHTML'               -ListAvailable -ErrorAction SilentlyContinue

    if (!($AzureADmodule)) 
    {
        try
        {
            $ThisModule = Install-Module -Name 'AzureAD.Standard.Preview' -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber -ErrorAction Stop
            Import-Module $ThisModule.RootModule
            Write-Host "[WPS]> AzureAD Module Installed & Staged" -ForegroundColor Black
        }
        catch
        {
            Write-Host "[WPS]> Error installing AzureAD module. Exiting" -ForegroundColor DarkRed
            exit
        } 

    }
    else
    {
        Import-Module -Name 'AzureAD.Standard.Preview' -Force `
                                                       -ErrorAction Stop `
                                                       -WarningAction SilentlyContinue `
                                                       -InformationAction SilentlyContinue

        Write-Host "[WPS]> AzureAD Module Staged" -ForegroundColor Black
    }

    

    if(!($ReportModule))
    {
        try
        {
            $ThisModule = Install-Module -Name 'ReportHTML' -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber -ErrorAction Stop
            Import-Module $ThisModule.RootModule
            Write-Host "[WPS]> ReportHTML Module Installed & Staged" -ForegroundColor Black
        }
        catch
        {
            Write-Host "[WPS]> Error installing ReportHTML module. Exiting" -ForegroundColor DarkRed
            exit
        } 
    }
    else
    {
        Import-Module -Name 'ReportHTML'             -Force `
                                                     -ErrorAction Stop `
                                                     -WarningAction SilentlyContinue `
                                                     -InformationAction SilentlyContinue

        Write-Host "[WPS]> ReportHTML Module Staged" -ForegroundColor Black
    }

    Write-Host "[WPS]> Staged PreReqs for report succesfully!" -ForegroundColor Green 
    }
    
    Function Connect-0365()
    {
        # return boolean state to check if we shoudl continue with reporting. (if connected or not)
        $Credential = Get-Credential
        if(!($Enable2FA))
        {
            try
                                                                {
            $Session = New-PSSession  -ConfigurationName Microsoft.Exchange `
                                      -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
                                      -Credential $Credential `
                                      -Authentication Basic `
                                      -AllowRedirection `
                                      -ErrorAction Stop `
                                      -WarningAction SilentlyContinue `
                                      -InformationAction SilentlyContinue
            Import-PSSession $Session -DisableNameChecking

            Write-Host "[WPS]> Connected to 0365 Exchange!" -ForegroundColor DarkGreen
            return $true                          
                                     
        }
            catch
                        {
            Write-Host "[WPS]> Failed to connect to 0365 Exchange - Auth failure?" -ForegroundColor DarkRed
            return $false
        }
        }
        else
        {
            Write-Host "[WPS]> 2FA Authentication not yet supported :*( " -ForegroundColor DarkRed
            Exit
        }


    }

    Function Poll-Datasets()
    {


        $Table                = New-Object 'System.Collections.Generic.List[System.Object]'
        $LicenseTable         = New-Object 'System.Collections.Generic.List[System.Object]'
        $UserTable            = New-Object 'System.Collections.Generic.List[System.Object]'
        $SharedMailboxTable   = New-Object 'System.Collections.Generic.List[System.Object]'
        $GroupTypetable       = New-Object 'System.Collections.Generic.List[System.Object]'
        $IsLicensedUsersTable = New-Object 'System.Collections.Generic.List[System.Object]'
        $ContactTable         = New-Object 'System.Collections.Generic.List[System.Object]'
        $MailUser             = New-Object 'System.Collections.Generic.List[System.Object]'
        $ContactMailUserTable = New-Object 'System.Collections.Generic.List[System.Object]'
        $RoomTable            = New-Object 'System.Collections.Generic.List[System.Object]'
        $EquipTable           = New-Object 'System.Collections.Generic.List[System.Object]'
        $GlobalAdminTable     = New-Object 'System.Collections.Generic.List[System.Object]'
        $StrongPasswordTable  = New-Object 'System.Collections.Generic.List[System.Object]'
        $CompanyInfoTable     = New-Object 'System.Collections.Generic.List[System.Object]'
        $MessageTraceTable    = New-Object 'System.Collections.Generic.List[System.Object]'
        $DomainTable          = New-Object 'System.Collections.Generic.List[System.Object]'

        $Sku = @{
             "O365_BUSINESS_ESSENTIALS"           = "Office 365 Business Essentials"
             "O365_BUSINESS_PREMIUM"              = "Office 365 Business Premium"
             "DESKLESSPACK"                       = "Office 365 (Plan K1)"
             "DESKLESSWOFFPACK"                   = "Office 365 (Plan K2)"
             "LITEPACK"                           = "Office 365 (Plan P1)"
             "EXCHANGESTANDARD"                   = "Office 365 Exchange Online Only"
             "STANDARDPACK"                       = "Enterprise Plan E1"
             "STANDARDWOFFPACK"                   = "Office 365 (Plan E2)"
             "ENTERPRISEPACK"                     = "Enterprise Plan E3"
             "ENTERPRISEPACKLRG"                  = "Enterprise Plan E3"
             "ENTERPRISEWITHSCAL"                 = "Enterprise Plan E4"
             "STANDARDPACK_STUDENT"               = "Office 365 (Plan A1) for Students"
             "STANDARDWOFFPACKPACK_STUDENT"       = "Office 365 (Plan A2) for Students"
             "ENTERPRISEPACK_STUDENT"             = "Office 365 (Plan A3) for Students"
             "ENTERPRISEWITHSCAL_STUDENT"         = "Office 365 (Plan A4) for Students"
             "STANDARDPACK_FACULTY"               = "Office 365 (Plan A1) for Faculty"
             "STANDARDWOFFPACKPACK_FACULTY"       = "Office 365 (Plan A2) for Faculty"
             "ENTERPRISEPACK_FACULTY"             = "Office 365 (Plan A3) for Faculty"
             "ENTERPRISEWITHSCAL_FACULTY"         = "Office 365 (Plan A4) for Faculty"
             "ENTERPRISEPACK_B_PILOT"             = "Office 365 (Enterprise Preview)"
             "STANDARD_B_PILOT"                   = "Office 365 (Small Business Preview)"
             "VISIOCLIENT"                        = "Visio Pro Online"
             "POWER_BI_ADDON"                     = "Office 365 Power BI Addon"
             "POWER_BI_INDIVIDUAL_USE"            = "Power BI Individual User"
             "POWER_BI_STANDALONE"                = "Power BI Stand Alone"
             "POWER_BI_STANDARD"                  = "Power-BI Standard"
             "PROJECTESSENTIALS"                  = "Project Lite"
             "PROJECTCLIENT"                      = "Project Professional"
             "PROJECTONLINE_PLAN_1"               = "Project Online"
             "PROJECTONLINE_PLAN_2"               = "Project Online and PRO"
             "ProjectPremium"                     = "Project Online Premium"
             "ECAL_SERVICES"                      = "ECAL"
             "EMS"                                = "Enterprise Mobility Suite"
             "RIGHTSMANAGEMENT_ADHOC"             = "Windows Azure Rights Management"
             "MCOMEETADV"                         = "PSTN conferencing"
             "SHAREPOINTSTORAGE"                  = "SharePoint storage"
             "PLANNERSTANDALONE"                  = "Planner Standalone"
             "CRMIUR"                             = "CMRIUR"
             "BI_AZURE_P1"                        = "Power BI Reporting and Analytics"
             "INTUNE_A"                           = "Windows Intune Plan A"
             "PROJECTWORKMANAGEMENT"              = "Office 365 Planner Preview"
             "ATP_ENTERPRISE"                     = "Exchange Online Advanced Threat Protection"
             "EQUIVIO_ANALYTICS"                  = "Office 365 Advanced eDiscovery"
             "AAD_BASIC"                          = "Azure Active Directory Basic"
             "RMS_S_ENTERPRISE"                   = "Azure Active Directory Rights Management"
             "AAD_PREMIUM"                        = "Azure Active Directory Premium"
             "MFA_PREMIUM"                        = "Azure Multi-Factor Authentication"
             "STANDARDPACK_GOV"                   = "Microsoft Office 365 (Plan G1) for Government"
             "STANDARDWOFFPACK_GOV"               = "Microsoft Office 365 (Plan G2) for Government"
             "ENTERPRISEPACK_GOV"                 = "Microsoft Office 365 (Plan G3) for Government"
             "ENTERPRISEWITHSCAL_GOV"             = "Microsoft Office 365 (Plan G4) for Government"
             "DESKLESSPACK_GOV"                   = "Microsoft Office 365 (Plan K1) for Government"
             "ESKLESSWOFFPACK_GOV"                = "Microsoft Office 365 (Plan K2) for Government"
             "EXCHANGESTANDARD_GOV"               = "Microsoft Office 365 Exchange Online (Plan 1) only for Government"
             "EXCHANGEENTERPRISE_GOV"             = "Microsoft Office 365 Exchange Online (Plan 2) only for Government"
             "SHAREPOINTDESKLESS_GOV"             = "SharePoint Online Kiosk"
             "EXCHANGE_S_DESKLESS_GOV"            = "Exchange Kiosk"
             "RMS_S_ENTERPRISE_GOV"               = "Windows Azure Active Directory Rights Management"
             "OFFICESUBSCRIPTION_GOV"             = "Office ProPlus"
             "MCOSTANDARD_GOV"                    = "Lync Plan 2G"
             "SHAREPOINTWAC_GOV"                  = "Office Online for Government"
             "SHAREPOINTENTERPRISE_GOV"           = "SharePoint Plan 2G"
             "EXCHANGE_S_ENTERPRISE_GOV"          = "Exchange Plan 2G"
             "EXCHANGE_S_ARCHIVE_ADDON_GOV"       = "Exchange Online Archiving"
             "EXCHANGE_S_DESKLESS"                = "Exchange Online Kiosk"
             "SHAREPOINTDESKLESS"                 = "SharePoint Online Kiosk"
             "SHAREPOINTWAC"                      = "Office Online"
             "YAMMER_ENTERPRISE"                  = "Yammer for the Starship Enterprise"
             "EXCHANGE_L_STANDARD"                = "Exchange Online (Plan 1)"
             "MCOLITE"                            = "Lync Online (Plan 1)"
             "SHAREPOINTLITE"                     = "SharePoint Online (Plan 1)"
             "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ" = "Office ProPlus"
             "EXCHANGE_S_STANDARD_MIDMARKET"      = "Exchange Online (Plan 1)"
             "MCOSTANDARD_MIDMARKET"              = "Lync Online (Plan 1)"
             "SHAREPOINTENTERPRISE_MIDMARKET"     = "SharePoint Online (Plan 1)"
             "OFFICESUBSCRIPTION"                 = "Office ProPlus"
             "YAMMER_MIDSIZE"                     = "Yammer"
             "DYN365_ENTERPRISE_PLAN1"            = "Dynamics 365 Customer Engagement Plan Enterprise Edition"
             "ENTERPRISEPREMIUM_NOPSTNCONF"       = "Enterprise E5 (without Audio Conferencing)"
             "ENTERPRISEPREMIUM"                  = "Enterprise E5 (with Audio Conferencing)"
             "MCOSTANDARD"                        = "Skype for Business Online Standalone Plan 2"
             "PROJECT_MADEIRA_PREVIEW_IW_SKU"     = "Dynamics 365 for Financials for IWs"
             "STANDARDWOFFPACK_IW_STUDENT"        = "Office 365 Education for Students"
             "STANDARDWOFFPACK_IW_FACULTY"        = "Office 365 Education for Faculty"
             "EOP_ENTERPRISE_FACULTY"             = "Exchange Online Protection for Faculty"
             "EXCHANGESTANDARD_STUDENT"           = "Exchange Online (Plan 1) for Students"
             "OFFICESUBSCRIPTION_STUDENT"         = "Office ProPlus Student Benefit"
             "STANDARDWOFFPACK_FACULTY"           = "Office 365 Education E1 for Faculty"
             "STANDARDWOFFPACK_STUDENT"           = "Microsoft Office 365 (Plan A2) for Students"
             "DYN365_FINANCIALS_BUSINESS_SKU"     = "Dynamics 365 for Financials Business Edition"
             "DYN365_FINANCIALS_TEAM_MEMBERS_SKU" = "Dynamics 365 for Team Members Business Edition"
             "FLOW_FREE"                          = "Microsoft Flow Free"
             "POWER_BI_PRO"                       = "Power BI Pro"
             "O365_BUSINESS"                      = "Office 365 Business"
             "DYN365_ENTERPRISE_SALES"            = "Dynamics Office 365 Enterprise Sales"
             "RIGHTSMANAGEMENT"                   = "Rights Management"
             "PROJECTPROFESSIONAL"                = "Project Professional"
             "VISIOONLINE_PLAN1"                  = "Visio Online Plan 1"
             "EXCHANGEENTERPRISE"                 = "Exchange Online Plan 2"
             "DYN365_ENTERPRISE_P1_IW"            = "Dynamics 365 P1 Trial for Information Workers"
             "DYN365_ENTERPRISE_TEAM_MEMBERS"     = "Dynamics 365 For Team Members Enterprise Edition"
             "CRMSTANDARD"                        = "Microsoft Dynamics CRM Online Professional"
             "EXCHANGEARCHIVE_ADDON"              = "Exchange Online Archiving For Exchange Online"
             "EXCHANGEDESKLESS"                   = "Exchange Online Kiosk"
             "SPZA_IW"                            = "App Connect"
             "WINDOWS_STORE"                      = "Windows Store for Business"
             "MCOEV"                              = "Microsoft Phone System"
             "VIDEO_INTEROP"                      = "Polycom Skype Meeting Video Interop for Skype for Business"
             "SPE_E5"                             = "Microsoft 365 E5"
             "SPE_E3"                             = "Microsoft 365 E3"
             "ATA"                                = "Advanced Threat Analytics"
             "MCOPSTN2"                           = "Domestic and International Calling Plan"
             "FLOW_P1"                            = "Microsoft Flow Plan 1"
             "FLOW_P2"                            = "Microsoft Flow Plan 2"
            }

        # Poll for intial tennant data
        $AllUsers    = Get-AzureADUser         -All:$true
        $CompanyInfo = Get-AzureADTenantDetail -All

        # Set company info
        $CompanyName = $CompanyInfo.DisplayName
        $TechEmail   = $CompanyInfo.TechnicalNotificationMails | Out-String
        $DirSync     = $CompanyInfo.DirSyncEnabled
        $LastDirSync = $CompanyInfo.CompanyLastDirSyncTime
        
        # we are up to here..


    }

    Function Build-Report()
    {

    }
    # -------------------------------------Execution------------------------------------------------
    StagepreReqs
    If(Connect-0365)
    {
        Poll-Datasets
        Build-Report
    }


}
