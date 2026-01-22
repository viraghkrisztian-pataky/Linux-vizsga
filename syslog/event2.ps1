<#
.SYNOPSIS
    Syslog üzenet generátor PowerShell-ben

.DESCRIPTION
    Teszt syslog üzenetek küldése UDP-n keresztül.
    Paraméterezhető szerver, port, facility és severity.
    Színes naplózás, dinamikus üzenetek, kulturált leállítás.

.EXAMPLE
    .\event2.ps1 -SyslogServer "192.168.1.10" -SyslogPort 514 -MessageCount 20
	
.POWERSHELL DEBUG
	Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#>
param(
    [string]$SyslogServer = "127.0.0.1",
    [int]$SyslogPort = 1514,
    [int]$Facility = 1,
    [int]$MessageCount = 10
)

function Send-SyslogMessage {
    param(
        [string]$Message,
        [string]$Program,
        [int]$Severity
    )

    $priority  = ($Facility * 8) + $Severity
    $timestamp = Get-Date -Format "MMM dd HH:mm:ss"
    $hostname  = $env:COMPUTERNAME

    # FONTOS: ${Program} !!!
    $syslog = "<$priority>$timestamp $hostname ${Program}: $Message"

    Write-Host "SEND -> $syslog" -ForegroundColor Cyan

    $udp = New-Object System.Net.Sockets.UdpClient
    $bytes = [Text.Encoding]::ASCII.GetBytes($syslog)
    $udp.Send($bytes, $bytes.Length, $SyslogServer, $SyslogPort) | Out-Null
    $udp.Close()
}

$logs = @(
    @{Program="kernel";  Severity=0; Message="System unusable"},
    @{Program="alert";   Severity=1; Message="Immediate action required"},
    @{Program="crit";    Severity=2; Message="Critical condition"},
    @{Program="app";     Severity=3; Message="Application error"},
    @{Program="disk";    Severity=4; Message="Disk space warning"},
    @{Program="service"; Severity=5; Message="Service notice"},
    @{Program="login";   Severity=6; Message="User login successful"},
    @{Program="debug";   Severity=7; Message="Debug trace message"}
)

Write-Host "=== SYSLOG TESZT INDUL ===" -ForegroundColor Green

for ($i = 1; $i -le $MessageCount; $i++) {
    $e = $logs | Get-Random
    Send-SyslogMessage `
        -Program $e.Program `
        -Message $e.Message `
        -Severity $e.Severity

    Start-Sleep -Seconds 1
}

Write-Host "=== KÉSZ ===" -ForegroundColor Green
