<#
.SYNOPSIS
    Syslog üzenet generátor PowerShell-ben

.DESCRIPTION
    Teszt syslog üzenetek küldése UDP-n keresztül.
    Paraméterezhető szerver, port, facility és severity.
    Színes naplózás, dinamikus üzenetek, kulturált leállítás.

.EXAMPLE
    .\event.ps1 -SyslogServer "192.168.1.10" -SyslogPort 514 -MessageCount 20
	
.POWERSHELL DEBUG
	Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#>

param(
    [string]$SyslogServer = "127.0.0.1",
    [int]$SyslogPort = 514,
    [int]$Facility = 1,
    [int]$Severity = 6,
    [int]$MessageCount = 50   # alapértelmezett érték
)

# --- Logging function ---
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("DEBUG","INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    switch ($Level) {
        "DEBUG" { Write-Host "$timestamp - DEBUG - $Message" -ForegroundColor Gray }
        "INFO"  { Write-Host "$timestamp - INFO  - $Message" -ForegroundColor Green }
        "WARN"  { Write-Host "$timestamp - WARN  - $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "$timestamp - ERROR - $Message" -ForegroundColor Red }
    }
}

# --- Syslog sender ---
function Send-SyslogMessage {
    param(
        [string]$Message,
        [string]$Program
    )
    $priority = ($Facility * 8) + $Severity
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"   # RFC 5424 ISO8601
    $hostname = [System.Net.Dns]::GetHostName()
    $syslog_message = "<{0}>{1} {2} {3}: {4}" -f $priority, $timestamp, $hostname, $Program, $Message

    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect($SyslogServer, $SyslogPort)
        $encodedMessage = [System.Text.Encoding]::UTF8.GetBytes($syslog_message)
        $udpClient.Send($encodedMessage, $encodedMessage.Length) | Out-Null
        Write-Log "Sent message: $syslog_message" "DEBUG"
    }
    catch {
        Write-Log "Failed to send message: $_" "ERROR"
    }
    finally {
        $udpClient.Close()
    }
}

# --- Test log generator ---
function Generate-TestLogs {
    $Username = $env:USERNAME
    $Hostname = $env:COMPUTERNAME

    $special_logs = @(
        @{Program="LinuxExam"; Message={ "[$Username][$Hostname] Login successful at $(Get-Date)" }},
        @{Program="LinuxExam"; Message={ "Exam completed at $(Get-Date)" }},
        @{Program="SystemCheck"; Message={ "Disk usage warning on $Hostname at $(Get-Date)" }},
        @{Program="Security"; Message={ "Unauthorized access attempt detected at $(Get-Date)" }}
    )

    try {
        for ($i = 1; $i -le $MessageCount; $i++) {
            $logEntry = $special_logs | Get-Random
            $program = $logEntry.Program
            $message = & $logEntry.Message
            Send-SyslogMessage -Message $message -Program $program

            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
        }
    }
    finally {
        Write-Log "Stopped after sending $MessageCount messages." "INFO"
    }
}

# --- Main ---
Write-Log "Starting to generate $MessageCount test logs..." "INFO"
Generate-TestLogs
