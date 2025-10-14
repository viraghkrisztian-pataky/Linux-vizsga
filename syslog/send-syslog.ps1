#requires -Version 2 -Modules NetTCPIP

Add-Type -TypeDefinition @"
    public enum Syslog_Facility
    {
        kern, user, mail, daemon, auth, syslog, lpr, news, uucp,
        clock, authpriv, ftp, ntp, logaudit, logalert, cron,
        local0, local1, local2, local3, local4, local5, local6, local7
    }
"@

Add-Type -TypeDefinition @"
    public enum Syslog_Severity
    {
        Emergency, Alert, Critical, Error, Warning, Notice, Informational, Debug
    }
"@

function Send-SyslogMessage {
    [CMDLetBinding(DefaultParameterSetName = 'RFC5424')]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [Syslog_Severity]$Severity,

        [Parameter(Mandatory = $true)]
        [Syslog_Facility]$Facility,

        [string]$Hostname = '',
        [string]$ApplicationName = '',
        [string]$ProcessID = $PID,
        [string]$MessageID = '-',
        [string]$StructuredData = '-',
        [datetime]$Timestamp = (Get-Date),
        [UInt16]$UDPPort = 514,
        [switch]$RFC3164
    )

    $Facility_Number = $Facility.value__
    $Severity_Number = $Severity.value__
    $Priority = ($Facility_Number * 8) + $Severity_Number

    if ($ApplicationName -eq '') {
        if (($null -ne $myInvocation.ScriptName) -and ($myInvocation.ScriptName -ne '')) {
            $ApplicationName = Split-Path -Leaf -Path $myInvocation.ScriptName
        } else {
            $ApplicationName = 'PowerShell'
        }
    }

    if ($Hostname -eq '') {
        if ($null -ne $ENV:userdnsdomain) {
            $Hostname = $ENV:Computername + '.' + $ENV:userdnsdomain
        } elseif (($null -ne (Get-NetIPAddress -PrefixOrigin Manual -SuffixOrigin Manual -ErrorAction SilentlyContinue)) -and ((Test-NetConnection -ComputerName $Server -ErrorAction SilentlyContinue).SourceAddress.PrefixOrigin -eq 'Manual')) {
            $Hostname = (Test-NetConnection -ComputerName $Server -ErrorAction SilentlyContinue).SourceAddress.IPAddress
        } else {
            $Hostname = $ENV:Computername
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'RFC3164') {
        $FormattedTimestamp = (Get-Culture).TextInfo.ToTitleCase($Timestamp.ToString('MMM dd HH:mm:ss'))
        $FullSyslogMessage = "<{0}>{1} {2} {3} {4}" -f $Priority, $FormattedTimestamp, $Hostname, $ApplicationName, $Message
    } else {
        $FormattedTimestamp = $Timestamp.ToString('yyyy-MM-ddTHH:mm:ss.ffffffzzz')
        $FullSyslogMessage = "<{0}>1 {1} {2} {3} {4} {5} {6} {7}" -f $Priority, $FormattedTimestamp, $Hostname, $ApplicationName, $ProcessID, $MessageID, $StructuredData, $Message
    }

    $Encoding = [System.Text.Encoding]::ASCII
    $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)

    if ($ByteSyslogMessage.Length -gt 1024) {
        $ByteSyslogMessage = $ByteSyslogMessage.SubString(0, 1024)
    }

    $UDPClient = New-Object System.Net.Sockets.UdpClient
    $UDPClient.Connect($Server, $UDPPort)
    $null = $UDPClient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)
    $UDPClient.Close()
}

# --- ÚJ rész: interaktív futás ---
$TargetIP = Read-Host "Add meg a cél SYSLOG szerver IP-címét"
$ComputerName = $env:COMPUTERNAME

# Lekérjük a lokális IPv4 címet (nem loopback)
$LocalIP = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
    Select-Object -First 1 -ExpandProperty IPAddress)

# Üzenet formázása
$MessageText = "SIKER:$ComputerName-$LocalIP"

Write-Host "Küldés SYSLOG szerverre: $TargetIP"
Write-Host "Üzenet: $MessageText"

# Syslog üzenet küldése Informational szinten, local0 facility-vel
Send-SyslogMessage -Server $TargetIP -Message $MessageText -Severity Informational -Facility local0
