# ProfileCore Update & Reinstall Guide

**Quick Reference** for keeping ProfileCore up to date

---

## 🚀 Quick Update Commands

### Option 1: In-Shell Update (Easiest)

```powershell
# Quick update from GitHub (preserves configuration)
Update-ProfileCore

# Force reinstall
Update-ProfileCore -Force

# Quiet mode (minimal output)
Update-ProfileCore -Quiet

# Aliases
update-profile          # Same as Update-ProfileCore
reinstall-profile       # Same as Update-ProfileCore
```

### Option 2: One-Line Update

```powershell
# Download and run installer directly
iex (irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1)
```

### Option 3: Manual Update

```powershell
# From your ProfileCore directory
cd C:\path\to\ProfileCore
git pull
.\scripts\installation\install.ps1 -Force
```

---

## 📦 What Gets Preserved

During updates, **your customizations are automatically preserved**:

✅ **Always Preserved:**

- Custom aliases in `~/.config/shell-profile/example-aliases.json`
- Environment variables in `~/.config/shell-profile/.env`
- Custom paths in `~/.config/shell-profile/example-paths.json`
- Plugin configurations
- Your `$PROFILE` customizations (backed up automatically)

✅ **Automatically Backed Up:**

- PowerShell profile (`Microsoft.PowerShell_profile.ps1`)
- Module configurations
- Shell RC files (`.bashrc`, `.zshrc`, etc.)

---

## 🔄 Upgrade Experience

### What Happens During Upgrade

1. **Detection**: Installer detects existing version

   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║              UPGRADE DETECTED                            ║
   ╚══════════════════════════════════════════════════════════════╝

   Current Version: 5.1.0
   New Version:     5.2.0

   What's New in v5.2.0:
     • v6 DI Architecture with 5 core services
     • ProfileCore.Common shared library
     • Enhanced Rust binary integration
     • Improved error handling & stability
     • Faster startup (~180ms load time)

   Your configuration will be preserved ✓

   Continue with upgrade? (Y/n)
   ```

2. **Automatic Backup**: Creates timestamped backups
3. **Installation**: Installs new version
4. **Configuration Merge**: Preserves your settings
5. **Verification**: Validates installation

### Upgrade Flags

```powershell
# Skip backup (not recommended)
.\scripts\installation\install.ps1 -Force -SkipBackup

# Quiet mode (automated)
.\scripts\installation\install.ps1 -Quiet

# Skip dependency checks
.\scripts\installation\install.ps1 -SkipDependencies

# Skip antivirus prompt
.\scripts\installation\install.ps1 -SkipAntivirusPrompt
```

---

## 🔧 Troubleshooting Updates

### Update Failed

```powershell
# Try with Force flag
Update-ProfileCore -Force

# Or manual installation
cd $HOME\ProfileCore
git pull
.\scripts\installation\install.ps1 -Force
```

### Connection Issues

```powershell
# Use local installer if GitHub is unreachable
cd $HOME\ProfileCore
.\scripts\quick-install.ps1
```

### Restore Previous Version

```powershell
# Find backup
ls ~\Documents\PowerShell\*backup*

# Restore from backup
Copy-Item ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1.20241026_123456.backup $PROFILE -Force

# Reload
. $PROFILE
```

---

## 📊 Version Check

### Check Current Version

```powershell
# From PowerShell
$global:ProfileCore.Version

# Detailed info
Get-Module ProfileCore -ListAvailable | Select Name, Version, Path

# Full system info
Get-SystemInfo
```

### Check for Updates

```powershell
# View latest releases
Start-Process "https://github.com/mythic3011/ProfileCore/releases"

# Check current architecture
$global:ProfileCore.Architecture  # Should show: v6-DI or v5-stable
```

---

## 🎯 Update Scenarios

### Fresh Install

```powershell
iex (irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1)
```

### Upgrade Existing

```powershell
Update-ProfileCore
# or
update-profile
```

### Repair Installation

```powershell
Update-ProfileCore -Force
```

### Silent/Automated Update

```powershell
Update-ProfileCore -Quiet -Force
```

---

## ⚡ After Update

### Reload Profile

```powershell
# Reload in current session
. $PROFILE

# Or restart PowerShell
exit  # Then reopen
```

### Verify Update

```powershell
# Check version
$global:ProfileCore.Version

# Test functionality
Get-Helper
Get-SystemInfo
myip
```

---

## 💡 Best Practices

1. **Always Backup**: Backups are automatic, but you can create manual backups:

   ```powershell
   Copy-Item $PROFILE "$PROFILE.$(Get-Date -Format 'yyyyMMdd_HHmmss').backup"
   ```

2. **Check Release Notes**: Before upgrading:

   ```powershell
   Start-Process "https://github.com/mythic3011/ProfileCore/blob/main/CHANGELOG.md"
   ```

3. **Test After Update**: Run a few commands to verify:

   ```powershell
   Get-SystemInfo
   Get-Helper
   ```

4. **Keep Dependencies Updated**:
   ```powershell
   Update-Module PSReadLine, Pester, PSScriptAnalyzer
   winget upgrade Starship.Starship
   ```

---

## 📅 Update Frequency

**Recommended**: Check for updates monthly

**Critical Updates**: Watch for security notifications

**Stable Releases**: Major versions (5.x → 6.x)

**Point Releases**: Bug fixes (5.1.x → 5.2.x)

---

## 🆘 Support

**Issues**: https://github.com/mythic3011/ProfileCore/issues

**Discussions**: https://github.com/mythic3011/ProfileCore/discussions

**Quick Help**: Run `Get-Helper` in PowerShell

---

**Pro Tip**: Set up automatic update checks in your profile:

```powershell
# Add to your $PROFILE
$lastCheck = Get-Content "$HOME\.profilecore_last_check" -ErrorAction SilentlyContinue
if (-not $lastCheck -or ((Get-Date) - [DateTime]$lastCheck).Days -gt 7) {
    Write-Host "[INFO] ProfileCore: Check for updates with 'update-profile'" -ForegroundColor Yellow
    (Get-Date).ToString() | Out-File "$HOME\.profilecore_last_check"
}
```
