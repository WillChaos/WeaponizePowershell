<#
.TargetOS
  OS:ALL
#>

Function Global:InvokeWPS-InteractiveFuzzer()
{
    param
    (
        # specifies the host to connect to
        [Parameter(Position=0,Mandatory=$true)]
        [String] $IPAddress,

        # specifies the port number to communicate on
        [Parameter(Position=1,Mandatory=$true)]
        [Int] $PortNumber,

        # will attempt TLS negotiation (not fully featured yet)
        [Parameter(Position=2,Mandatory=$false)]
        [switch] $UseTLS
    )

    # functions
    Function Invoke-MenuBanner()
    {
        
        Write-Host "[+]-----------------------------------------------------------------------------------------------[+]" -ForegroundColor Black
        Write-Host "                                         WPS Interactiuve Fuzzer                                     " -ForegroundColor Green
        Write-Host "[+]-----------------------------------------------------------------------------------------------[+]" -ForegroundColor Black
        Write-Host "[+]_______________________________________________________________________________________________[+]" -ForegroundColor Black
        
    }

    Function Invoke-Fuzzer()
    {


        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
                    Write-host " " 

                    Write-Host "[WPS]> data to send"                 -ForegroundColor Green
                    [string]$command = Read-Host 

                    Write-Host "[WPS]> How many times to send data"  -ForegroundColor Green
                    [int]$frequency  = Read-Host 

                    Write-Host "[WPS]> Incremental offset"           -ForegroundColor Green
                    [int]$byteOffset = Read-Host 

                    Write-Host "[WPS]> Custom pre-payload"           -ForegroundColor Green
                    [string]$PrePL   = Read-Host

                    Write-Host "[WPS]> Delay between payloads"       -ForegroundColor Green
                    [int]$delay  = Read-Host


        foreach($count in 0..$frequency)
        {
            Write-Host "[+]> Binding socket: {$IPAddress | $PortNumber}" -ForegroundColor Green
            try
            {
                $tcp       = New-Object System.Net.Sockets.TcpClient($IPAddress,$PortNumber)
                $tcpstream = $tcp.GetStream()
                $reader    = New-Object System.IO.StreamReader($tcpStream)
                $writer    = New-Object System.IO.StreamWriter($tcpStream)
                $writer.AutoFlush = $true
                Write-Host "-[+]> Connected!" -ForegroundColor Green


                # while tcp stream is connected, do the below
                while ($tcp.Connected)
                {   
                    Write-Host " "
                    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
                    Write-Host "Response from: $IPAddress"       
                    write-host ([char]$reader.Read()) -NoNewline
                    Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
            

                    while(($reader.Peek() -ne -1) -or ($tcp.Available))
                    {
                        write-host ([char]$reader.Read()) -NoNewline
                
                    }
                        if ($tcp.Connected)
                        {
                            if($PrePL)
                            {
                                Write-Host "--[+]> Sending pre payload: $PrePL " -ForegroundColor DarkGreen
                                $writer.WriteLine($PrePL) | Out-Null
                            }

                            $command = $command * $byteOffset 

                            Write-Host "--[+]> sending " ($command -split "").count "Bytes" -ForegroundColor DarkGreen
                            $writer.WriteLine($command) | Out-Null

                            sleep $delay
                        }     
                }

                $reader.Close()
                $writer.Close()
                $tcp.Close()


            }
            catch
            {
                Write-Host "[WPS]-> Failed to Bind to Socket" -ForegroundColor DarkRed
                break
            }
        }
    }


    # exec
    Invoke-MenuBanner
    Invoke-Fuzzer
}
