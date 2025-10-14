# Set up logging
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "DEBUG"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Debug "$timestamp - $Level - $Message"
}

function Send-SyslogMessage {
    param(
        [string]$Message,
        [string]$Program,
        [int]$Facility = 1,
        [int]$Severity = 6
    )
    $SYSLOG_SERVER = '127.0.0.1'
    $SYSLOG_PORT = 514

    $priority = ($Facility * 8) + $Severity
    $timestamp = Get-Date -Format "MMM dd HH:mm:ss"
    $hostname = [System.Net.Dns]::GetHostName()
    $syslog_message = "<{0}>{1} {2} {3}: {4}" -f $priority, $timestamp, $hostname, $Program, $Message

    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect($SYSLOG_SERVER, $SYSLOG_PORT)
        $encodedMessage = [System.Text.Encoding]::UTF8.GetBytes($syslog_message)
        $udpClient.Send($encodedMessage, $encodedMessage.Length) | Out-Null
        Write-Log "Sent message: $syslog_message"
        
        # Debug: Print the full message
        Write-Host "Full message sent: $syslog_message"
    }
    catch {
        Write-Log "Failed to send message: $_" -Level "ERROR"
    }
    finally {
        $udpClient.Close()
    }
}

function Generate-TestLogs {
$Username = $env:USERNAME
$Hostname = $env:COMPUTERNAME
$CurrentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$special_logs = @(
		@{Program="Linux vizsga"; Message="[$Username][$Hostname][$CurrentTime] Message success"},
		@{Program="Linux vizsga"; Message="Exam is successfully:[$CurrentTime]"}		
	)

    while ($true) {
        try {
            # Generate a special log message
            $logEntry = $special_logs | Get-Random
            $program = $logEntry.Program
            $message = $logEntry.Message
            Send-SyslogMessage -Message $message -Program $program

            # Wait for a random interval between 1 and 5 seconds
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
        }
        catch {
            Write-Log "Error in Generate-TestLogs: $_" -Level "ERROR"
        }
    }
}

Write-Host "Starting to generate test logs. Press Ctrl+C to stop."
try {
    Generate-TestLogs
}
catch [System.Management.Automation.PipelineStoppedException] {
    Write-Host "`nStopped generating test logs."
}
catch {
    Write-Log "Unexpected error: $_" -Level "ERROR"
}
