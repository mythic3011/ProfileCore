# Installation Troubleshooting Guide

**ProfileCore v5.2.0+**

This guide helps you troubleshoot common installation issues.

---

## Quick Install Script Issues

### Issue: `irm` Returns Empty String

**Error Message:**

```
iex : Cannot bind argument to parameter 'Path' because it is an empty string.
```

**Cause:** The `irm` (Invoke-RestMethod) alias might not be working correctly in your PowerShell session, or there's a network/proxy issue.

**Solutions:**

#### Solution 1: Use Full Cmdlet Names (Recommended)

```powershell
# Instead of: irm URL | iex
# Use this:
Invoke-RestMethod https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | Invoke-Expression
```

Or in two steps for better visibility:

```powershell
$script = Invoke-RestMethod https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1
Invoke-Expression $script
```

#### Solution 2: Enable TLS 1.2

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1')
```

#### Solution 3: Download First, Then Execute

```powershell
$tempFile = "$env:TEMP\profilecore-install.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1' -OutFile $tempFile
& $tempFile
```

#### Solution 4: Clone Repository

```powershell
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore
.\scripts\quick-install.ps1
```

---

## Proxy Issues

### Corporate Proxy Blocking Downloads

**Symptoms:**

- Downloads timeout
- "Unable to connect to remote server" errors
- Authentication prompts

**Solutions:**

#### Configure Proxy Credentials

```powershell
# Use default network credentials
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

# Then retry installation
```

#### Manual Proxy Configuration

```powershell
$proxy = New-Object System.Net.WebProxy("http://proxy.company.com:8080")
$proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[System.Net.WebRequest]::DefaultWebProxy = $proxy

# Then retry installation
```

#### Bypass Proxy for GitHub

```powershell
# Add to your $PROFILE before installing
$env:NO_PROXY = "raw.githubusercontent.com,github.com"
```

---

## Execution Policy Issues

### "Running scripts is disabled"

**Error Message:**

```
File cannot be loaded because running scripts is disabled on this system.
```

**Solutions:**

#### Temporary Bypass (Current Session Only)

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
# Then run installation
```

#### Permanent Change (Requires Admin)

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Alternative: Run with Bypass Flag

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\quick-install.ps1
```

---

## Git Not Found

### "git: command not found"

**Symptoms:**

- Installation fails at Git clone step
- "git is not recognized" error

**Solutions:**

#### Windows

```powershell
# Using winget
winget install Git.Git

# Using Chocolatey
choco install git -y

# Using Scoop
scoop install git
```

#### Linux

```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install git -y

# RHEL/Fedora/CentOS
sudo dnf install git -y

# Arch Linux
sudo pacman -S git
```

#### macOS

```bash
# Using Homebrew
brew install git

# Using Xcode Command Line Tools
xcode-select --install
```

---

## Module Import Issues

### "The specified module was not loaded"

**Error Message:**

```
Import-Module : The specified module 'ProfileCore' was not loaded because no valid module file was found
```

**Diagnosis:**

```powershell
# Check if module is in PSModulePath
$env:PSModulePath -split [IO.Path]::PathSeparator

# Check if ProfileCore directory exists
Test-Path "$HOME/Documents/PowerShell/Modules/ProfileCore"
```

**Solutions:**

#### Manual Module Path Addition

```powershell
# Add to current session
$env:PSModulePath += ";$HOME\ProfileCore\modules"

# Add permanently (add to $PROFILE)
$profilePath = if ($IsWindows) { "$HOME\Documents\PowerShell" } else { "$HOME/.config/powershell" }
$modulePath = "$HOME\ProfileCore\modules"
if ($env:PSModulePath -notcontains $modulePath) {
    $env:PSModulePath += [IO.Path]::PathSeparator + $modulePath
}
```

#### Reinstall Module

```powershell
# Remove existing installation
Remove-Item -Path "$HOME/Documents/PowerShell/Modules/ProfileCore" -Recurse -Force -ErrorAction SilentlyContinue

# Run installer again
.\scripts\quick-install.ps1
```

---

## Permission Issues

### "Access Denied" or "UnauthorizedAccessException"

**Symptoms:**

- Can't create directories
- Can't copy files
- Can't modify profile script

**Solutions:**

#### Check Directory Permissions

```powershell
# Check if you have write access
$testFile = "$HOME\Documents\PowerShell\test.txt"
try {
    Set-Content -Path $testFile -Value "test"
    Remove-Item $testFile
    Write-Host "✅ Write access OK"
} catch {
    Write-Host "❌ No write access: $_"
}
```

#### Run as Administrator (Windows)

```powershell
# Right-click PowerShell → "Run as Administrator"
# Then run installation
```

#### Fix Permissions (Linux/macOS)

```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x scripts/**/*.sh

# Fix ownership if needed
sudo chown -R $USER:$USER ~/ProfileCore
```

---

## Antivirus Blocking Rust Binary

### Rust DLL Quarantined or Blocked

**Symptoms:**

- Installation succeeds but Rust binary doesn't load
- `Test-ProfileCoreRustAvailable` returns `$false`
- Antivirus warnings about `ProfileCore.dll`

**Solutions:**

#### Check Rust Binary Status

```powershell
Test-Path "modules/ProfileCore/rust-binary/bin/ProfileCore.dll"
Test-ProfileCoreRustAvailable
```

#### Add Antivirus Exception

**Windows Defender:**

```powershell
# Run as Administrator
Add-MpPreference -ExclusionPath "$HOME\Documents\PowerShell\Modules\ProfileCore"
```

**Other Antivirus:**

- Add `ProfileCore` directory to exclusion list
- Add `ProfileCore.dll` specifically if needed

#### Use Without Rust Binary

```powershell
# Remove Rust binary (optional, uses PowerShell fallback)
Remove-Item "modules/ProfileCore/rust-binary" -Recurse -Force

# ProfileCore still works, just slightly slower
Import-Module ProfileCore
```

See: [Antivirus and Rust Guide](antivirus-and-rust.md)

---

## PowerShell Version Issues

### "This script requires PowerShell 5.1 or higher"

**Check Version:**

```powershell
$PSVersionTable.PSVersion
```

**Solutions:**

#### Windows

```powershell
# Install PowerShell 7 (recommended)
winget install Microsoft.PowerShell

# Or download from:
# https://github.com/PowerShell/PowerShell/releases
```

#### Linux

```bash
# Debian/Ubuntu
sudo apt-get install -y powershell

# RHEL/Fedora
sudo dnf install -y powershell
```

#### macOS

```bash
brew install --cask powershell
```

---

## Network Connectivity Issues

### "Unable to connect to GitHub"

**Diagnosis:**

```powershell
# Test GitHub connectivity
Test-NetConnection raw.githubusercontent.com -Port 443

# Test with web request
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/mythic3011/ProfileCore/main/README.md" -UseBasicParsing
```

**Solutions:**

#### DNS Issues

```powershell
# Flush DNS cache
ipconfig /flushdns  # Windows
sudo systemd-resolve --flush-caches  # Linux

# Try alternate DNS
# Set DNS to 8.8.8.8 (Google) or 1.1.1.1 (Cloudflare)
```

#### Firewall Blocking

```powershell
# Check firewall rules (Windows)
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*PowerShell*" }

# Temporarily disable to test (not recommended long-term)
# Then re-enable after testing
```

#### Use Local Installation

```powershell
# Download as ZIP from GitHub
# Extract and run local install
cd ProfileCore-main
.\scripts\quick-install.ps1
```

---

## Configuration Issues

### Module Loads But Commands Don't Work

**Diagnosis:**

```powershell
# Check module loaded correctly
Get-Module ProfileCore

# Check available commands
Get-Command -Module ProfileCore

# Check for errors
Get-Module ProfileCore | Select-Object -ExpandProperty ExportedCommands
```

**Solutions:**

#### Reimport Module

```powershell
Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
Import-Module ProfileCore -Force -Verbose
```

#### Check Dependencies

```powershell
# Check if ProfileCore.Common is loaded
Get-Module ProfileCore.Common

# Manually import if needed
Import-Module "$HOME/Documents/PowerShell/Modules/ProfileCore.Common" -Force
```

#### Verify Installation

```powershell
# Run diagnostics
Test-ModuleManifest "$HOME/Documents/PowerShell/Modules/ProfileCore/ProfileCore.psd1"
```

---

## Getting Help

If you're still having issues:

### Collect Diagnostic Information

```powershell
# Save diagnostic info
$diagnostics = @{
    PSVersion = $PSVersionTable.PSVersion
    OS = $PSVersionTable.OS
    Platform = $PSVersionTable.Platform
    ExecutionPolicy = Get-ExecutionPolicy
    ModulePath = $env:PSModulePath
    ProfileCoreVersion = (Get-Module ProfileCore).Version
    RustAvailable = Test-ProfileCoreRustAvailable
}
$diagnostics | ConvertTo-Json | Out-File "$HOME/profilecore-diagnostics.json"
```

### Contact Support

1. **GitHub Issues:** https://github.com/mythic3011/ProfileCore/issues
2. **Include:**
   - Error messages (full text)
   - PowerShell version (`$PSVersionTable`)
   - Operating system
   - Installation method attempted
   - Diagnostic file (if created)

### Community Resources

- **Documentation:** `docs/`
- **Examples:** `examples/`
- **Developer Guide:** `docs/developer/`

---

## Quick Reference

### Working Installation Methods

```powershell
# Method 1: Direct from GitHub (full cmdlet names)
Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1')

# Method 2: Clone and install
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore
.\scripts\quick-install.ps1

# Method 3: Download and run
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1' -OutFile "$env:TEMP\install.ps1"
& "$env:TEMP\install.ps1"

# Method 4: Local installation (if you have the repo)
cd C:\Path\To\ProfileCore
.\scripts\quick-install.ps1
```

---

**Last Updated:** October 2025  
**ProfileCore Version:** 5.2.0+

For more installation guides, see [Installation Guide](installation.md)
