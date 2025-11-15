# ==========================================
# Windows OpenSSH One-Click Install Script
# Based on official Microsoft documentation
# ==========================================

Write-Host "`n=== Checking OpenSSH capabilities ==="

$capabilities = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH*"
$capabilities | Format-Table -AutoSize

$clientState = ($capabilities | Where-Object Name -eq "OpenSSH.Client~~~~0.0.1.0").State
$serverState = ($capabilities | Where-Object Name -eq "OpenSSH.Server~~~~0.0.1.0").State

# ------------------------------------
# Install OpenSSH Client
# ------------------------------------
if ($clientState -ne "Installed") {
    Write-Host "`n=== Installing OpenSSH Client ==="
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Client is already installed. Skipping."
}

# ------------------------------------
# Install OpenSSH Server
# ------------------------------------
if ($serverState -ne "Installed") {
    Write-Host "`n=== Installing OpenSSH Server ==="
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "OpenSSH Server is already installed. Skipping."
}

# ------------------------------------
# Start SSHD service
# ------------------------------------
Write-Host "`n=== Starting sshd service ==="
Start-Service sshd -ErrorAction SilentlyContinue

# Set sshd to start automatically
Set-Service -Name sshd -StartupType Automatic
Write-Host "sshd is set to start automatically."

# ------------------------------------
# Configure firewall rule
# ------------------------------------
Write-Host "`n=== Checking firewall rule ==="
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    Write-Host "Firewall rule not found. Creating rule..."
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Host "Firewall rule already exists."
}

Write-Host "`n=== OpenSSH installation and setup complete! ==="
Write-Host "You can now connect to this machine via SSH:"
Write-Host "ssh YOUR_USERNAME@$(hostname)"
