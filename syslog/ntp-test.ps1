$NtpServer = "deian-ip"
$UdpClient = New-Object System.Net.Sockets.UdpClient
$UdpClient.Connect($NtpServer,123)
$NtpData = New-Object byte[] 48
$NtpData[0] = 0x1B
$UdpClient.Send($NtpData, $NtpData.Length)
$RemoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any,0)
$NtpData = $UdpClient.Receive([ref]$RemoteEndPoint)
Write-Output "NTP server is responding"
