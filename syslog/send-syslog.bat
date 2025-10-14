@echo off
setlocal ENABLEDELAYEDEXPANSION
title SYSLOG Üzenetküldő

echo ====================================
echo   SYSLOG Üzenetküldő PowerShell-ben
echo ====================================
echo.

:: Cél Syslog szerver IP-címe bekérése
set /p TargetIP=Add meg a cél SYSLOG szerver IP-címét: 

echo.
echo Üzenet küldése folyamatban...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ComputerName = $env:COMPUTERNAME; ^
 $LocalIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1 -ExpandProperty IPAddress); ^
 $MessageText = 'SIKER:' + $ComputerName + '-' + $LocalIP; ^
 $Encoding = [System.Text.Encoding]::ASCII; ^
 $Facility = 16;  # local0
 $Severity = 6;   # informational
 $Priority = ($Facility * 8) + $Severity; ^
 $Timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss.ffffffzzz'); ^
 $Hostname = $env:COMPUTERNAME; ^
 $AppName = 'SyslogBatch'; ^
 $FullMsg = '<{0}>1 {1} {2} {3} {4} - - {5}' -f $Priority, $Timestamp, $Hostname, $AppName, $PID, $MessageText; ^
 $Bytes = $Encoding.GetBytes($FullMsg); ^
 $Udp = New-Object System.Net.Sockets.UdpClient; ^
 $Udp.Connect('%TargetIP%',514); ^
 $Udp.Send($Bytes,$Bytes.Length) | Out-Null; ^
 $Udp.Close(); ^
 Write-Host 'Üzenet elküldve a SYSLOG szerverre: %TargetIP%' -ForegroundColor Green"

echo.
pause
endlocal
