Function Global:InvokeWPS-EnumerateFilesContainingString()
{
    param
    (
    [String[]] $StringsToSearch,
    [String[]] $FileTypes,
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
                       "*.backup",
                       "*.default",
                       "*.cs"
         Write-Host "[WPS]> Filetpe param not specifed - using defaults" -ForegroundColor Black
    }
    Write-Host "[WPS]> Recursive String enumeration started..." -ForegroundColor DarkMagenta

    Foreach ($String in $StringsToSearch)
    {
        
        Get-Childitem -Path $RootSearchDirectory -Recurse -include $FileTypes | 
        Select-String -Pattern "$String" | 
        Select Path,LineNumber,@{n='SearchWord';e={$String}}
    }
}
