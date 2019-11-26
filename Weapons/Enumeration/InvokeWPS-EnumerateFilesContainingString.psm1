Function Global:InvokeWPS-EnumerateFilesContainingString()
{
    param
    (
    [Parameter(Mandatory=$true)]
    [String[]] $StringsToSearch,
    
    [String[]] $FileTypes,
    
    [Parameter(Mandatory=$true)]
    [String]   $RootSearchDirectory
    

    )

    if(!($FileTypes))
    {
        # Sets default file types if not specified 
        $FileTypes   = "*.txt",
                       "*.csv",
                       "*.sql",
                       "*.mdb",
                       "*.config",
                       "*.aspx",
                       "*.asp",
                       "*.php",
                       "*.bak",
                       "*.back",
                       "*.backup",
                       "*.default",
                       "*.cs",
                       "*.php",
                       "*.php5",
                       "*.doc",
                       "*.docx",
                       "*.html",
                       "*.htm",
                       "*.py",
                       "*.cfm",
                       "*.xml",
                       "*.cgi",
                       "*.shtml",
                       "*.rb",
                       "*.js",
                       "*.jsp",
                       "*.action",
                       "*.hta",
                       "*.htaccess",
                       "*.c",
                       "*.lua",
                       "*.r",
                       "*.rss",
                       "*.sh",
                       "*.vb",
                       "*.xaml",
                       "*.yaml"




         Write-Host "[WPS]> Filetpe param not specifed - using defaults" -ForegroundColor Black
    }
    Write-Host "[WPS]> Recursive String enumeration started..." -ForegroundColor DarkMagenta

    Foreach ($sw in $StringsToSearch)
    {
        
        Get-Childitem -Path $RootSearchDirectory -Recurse -include $FileTypes | 
        Select-String -Pattern "$sw" | 
        Select Path,LineNumber,@{n='SearchWord';e={$sw}}
    }
}
