# =====================================================
# VMware PRO OPTIMALIZER
# Windows 11 / Windows 10
# Admin PowerShell required
# =====================================================

Write-Host ""
Write-Host "VMware PERFORMANCE OPTIMIZATION" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------------
# VM storage folder
# -----------------------------------------------------

$VMPath = "C:\_VM"

if (!(Test-Path $VMPath)) {
    Write-Host "VM mappa letrehozasa: $VMPath"
    New-Item -ItemType Directory -Path $VMPath | Out-Null
} else {
    Write-Host "VM mappa mar letezik"
}

# -----------------------------------------------------
# Defender exclusion (SYSTEM level)
# -----------------------------------------------------

Write-Host "Defender kivetel hozzaadasa..."

try {
    Add-MpPreference -ExclusionPath $VMPath
} catch {}

# -----------------------------------------------------
# Hypervisor kikapcsolása
# -----------------------------------------------------

Write-Host "Hypervisor kikapcsolasa..."

bcdedit /set hypervisorlaunchtype off | Out-Null

# -----------------------------------------------------
# Windows virtualization features OFF
# -----------------------------------------------------

Write-Host "Virtualizacios Windows feature-ok kikapcsolasa..."

$features = @(
"Microsoft-Hyper-V-All",
"VirtualMachinePlatform",
"WindowsHypervisorPlatform",
"Containers-DisposableClientVM",
"Microsoft-Windows-Subsystem-Linux"
)

foreach ($f in $features) {

    Disable-WindowsOptionalFeature `
        -Online `
        -FeatureName $f `
        -NoRestart `
        -ErrorAction SilentlyContinue | Out-Null

}

# -----------------------------------------------------
# VBS / Device Guard / Credential Guard OFF
# -----------------------------------------------------

Write-Host "VBS es Device Guard kikapcsolasa..."

reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f | Out-Null

reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f | Out-Null

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f | Out-Null

# -----------------------------------------------------
# High Performance Power Plan
# -----------------------------------------------------

Write-Host "High Performance power profile..."

powercfg -setactive SCHEME_MIN

# -----------------------------------------------------
# Indexing kikapcsolása VM mappára
# -----------------------------------------------------

Write-Host "Indexeles kikapcsolasa VM mappara..."

attrib +I $VMPath

# -----------------------------------------------------
# Large System Cache (disk IO improvement)
# -----------------------------------------------------

Write-Host "Disk cache optimalizalas..."

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
/v LargeSystemCache /t REG_DWORD /d 1 /f | Out-Null

# -----------------------------------------------------
# kész
# -----------------------------------------------------

Write-Host ""
Write-Host "KESZ!" -ForegroundColor Green
Write-Host "UJRAINDITAS SZUKSEGES!" -ForegroundColor Yellow
Write-Host ""
