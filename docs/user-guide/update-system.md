# ProfileCore Update System

## Overview

ProfileCore v5 includes a completely redesigned update system that follows SOLID principles and provides robust, reliable updates with automatic backup and rollback capabilities.

## Features

### 🔄 Multiple Update Providers

The update system uses the **Strategy Pattern** to support different update methods:

- **Git Provider**: Updates via `git pull` (recommended for developers)
- **GitHub Release Provider**: Downloads and installs from GitHub releases (recommended for users)

### 🛡️ Safety Features

1. **Automatic Backups**: Creates backups before each update
2. **Health Checks**: Validates system state before updates
3. **Update Validation**: Verifies downloaded files
4. **Automatic Rollback**: Reverts to previous version if update fails
5. **Backup Retention**: Automatic cleanup of old backups

### 📊 Smart Update Detection

- Version comparison
- Commit tracking (Git provider)
- Release notes display
- Network connectivity checks

## Usage

### Check for Updates

```powershell
# Check if updates are available
Update-ProfileCore -CheckOnly

# Output:
# ╔═══════════════════════════════════════════════════════════╗
# ║          ProfileCore Update Manager v2.0                 ║
# ╚═══════════════════════════════════════════════════════════╝
#
# 🔍 Running system health checks...
#    ✅ PowerShell Version: OK
#    ✅ Disk Space: OK
#    ✅ Network Connectivity: OK
#    ✅ ProfileCore Module: OK
#
# 🔍 Checking for updates...
#
# 📊 Version Information:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#    Current Version:  v4.0.0
#    Latest Version:   v5.0.0
#    Update Provider:  Git
#    Commits Behind:   15
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Install Updates

```powershell
# Install available updates (interactive)
Update-ProfileCore

# Force update even if on latest version
Update-ProfileCore -Force

# Specify update provider
Update-ProfileCore -Provider GitHub

# Skip backup (not recommended)
Update-ProfileCore -SkipBackup

# Skip health checks (not recommended)
Update-ProfileCore -SkipHealthCheck
```

### Configure Auto-Updates

```powershell
# Enable weekly auto-updates
Set-ProfileCoreAutoUpdate -Schedule Weekly -Enabled

# Enable daily auto-updates
Set-ProfileCoreAutoUpdate -Schedule Daily -Enabled

# Disable auto-updates
Set-ProfileCoreAutoUpdate -Schedule Never

# Configure update settings
$global:ProfileCore.UpdateManager.UpdateConfig.PreferredProvider = "GitHub"
$global:ProfileCore.UpdateManager.UpdateConfig.BackupRetentionDays = 30
$global:ProfileCore.UpdateManager.UpdateConfig.Save()
```

### Get Version Information

```powershell
Get-ProfileCoreVersion

# Output:
# 📦 ProfileCore Version Information
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Current Version: v5.0.0
# Module Path:     C:\Users\...\ProfileCore\modules\ProfileCore
# PowerShell:      7.4.1
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# 💡 Check for updates with: Update-ProfileCore -CheckOnly
```

## Update Process

### Standard Update Flow

1. **Pre-Update Checks**

   - System health validation
   - Disk space verification
   - Network connectivity test
   - ProfileCore module status

2. **Update Detection**

   - Query update provider
   - Compare versions
   - Fetch release notes

3. **Backup Creation**

   - Backup critical files
   - Save metadata
   - Store in `~/.profilecore/backups/`

4. **Download Update**

   - Fetch from provider
   - Validate download
   - Extract if needed

5. **Apply Update**

   - Install new files
   - Run post-update scripts
   - Verify installation

6. **Verification**
   - Validate new installation
   - Check for conflicts
   - Report success/failure

### Automatic Rollback

If update fails:

1. Detect failure
2. Display error information
3. Restore from backup
4. Verify restoration
5. Report status

## Configuration

### Update Config File

Location: `~/.profilecore/update-config.json`

```json
{
  "AutoUpdate": false,
  "Schedule": "Weekly",
  "LastCheck": "2025-10-10T10:00:00",
  "LastUpdate": "2025-10-01T15:30:00",
  "PreferredProvider": "Git",
  "AllowPreRelease": false,
  "BackupBeforeUpdate": true,
  "BackupRetentionDays": 30
}
```

### Configuration Options

| Option                | Description                                           | Default  |
| --------------------- | ----------------------------------------------------- | -------- |
| `AutoUpdate`          | Enable automatic updates on profile load              | `false`  |
| `Schedule`            | Update check frequency: Daily, Weekly, Monthly, Never | `Weekly` |
| `PreferredProvider`   | Preferred update method: Git, GitHub                  | `Git`    |
| `AllowPreRelease`     | Allow pre-release versions                            | `false`  |
| `BackupBeforeUpdate`  | Create backup before updating                         | `true`   |
| `BackupRetentionDays` | Days to keep old backups                              | `30`     |

## Update Providers

### Git Provider

**Best for**: Developers who cloned the repository

**Requirements**:

- Git installed
- ProfileCore cloned via git
- Repository has remote configured

**Advantages**:

- Fast updates
- Commit-level tracking
- Easy rollback via git
- Supports branches

**How it works**:

1. Detects repository location
2. Fetches remote changes
3. Counts commits behind
4. Stashes local changes
5. Pulls updates
6. Validates repository state

### GitHub Release Provider

**Best for**: End users who downloaded a release

**Requirements**:

- Internet connection
- GitHub API access

**Advantages**:

- No git required
- Stable releases only
- Smaller downloads
- Clean installations

**How it works**:

1. Queries GitHub API
2. Compares release versions
3. Downloads release ZIP
4. Extracts to temp location
5. Copies files to installation
6. Verifies integrity

## Health Checks

The update system includes built-in health checks:

### PowerShell Version

- **Critical**: Yes
- **Checks**: PowerShell 5.0 or higher
- **Why**: Ensures compatibility

### Disk Space

- **Critical**: Yes
- **Checks**: At least 1GB free space
- **Why**: Prevents failed updates due to full disk

### Network Connectivity

- **Critical**: Yes
- **Checks**: Can reach GitHub API
- **Why**: Required for update downloads

### ProfileCore Module

- **Critical**: No
- **Checks**: Module currently loaded
- **Why**: Informational only

### Custom Health Checks

Add your own health checks:

```powershell
$check = [UpdateHealthCheck]::new(
    "My Custom Check",
    { Test-Path "C:\MyRequiredFile.txt" },
    $true  # Critical
)

$global:ProfileCore.UpdateManager.HealthChecks.Add($check)
```

## Backup Management

### Backup Structure

```
~/.profilecore/backups/
├── backup_20251010_100000/
│   ├── modules/ProfileCore/
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── config/
│   ├── .profilecore/
│   └── backup-metadata.json
├── backup_20251009_150000/
└── backup_20251008_120000/
```

### Backup Metadata

Each backup includes metadata:

```json
{
  "Version": "4.0.0",
  "Created": "2025-10-10T10:00:00",
  "SourcePath": "C:\\Users\\...\\ProfileCore",
  "OS": "Windows 10.0.22000",
  "PSVersion": "7.4.1"
}
```

### Manual Restore

```powershell
# List available backups
Get-ChildItem "$HOME\.profilecore\backups"

# Restore specific backup
$backup = [UpdateBackup]::new("$HOME\.profilecore\backups\backup_20251010_100000", "4.0.0")
$profileCorePath = $global:ProfileCore.UpdateManager.ProfileCorePath
$backup.Restore($profileCorePath)
```

### Backup Cleanup

Automatic cleanup based on `BackupRetentionDays`:

```powershell
# Clean backups older than 30 days
$global:ProfileCore.UpdateManager.CleanOldBackups()

# Change retention period
$global:ProfileCore.UpdateManager.UpdateConfig.BackupRetentionDays = 60
$global:ProfileCore.UpdateManager.UpdateConfig.Save()
```

## Troubleshooting

### Update Check Fails

**Problem**: Cannot check for updates

**Solutions**:

1. Verify internet connection
2. Check GitHub is not blocked by firewall
3. Try different provider: `Update-ProfileCore -Provider GitHub`
4. Check proxy settings

### Git Provider Not Available

**Problem**: Git provider shows as unavailable

**Solutions**:

1. Install Git: `winget install Git.Git`
2. Verify repository: `cd ProfileCore && git status`
3. Add remote: `git remote add origin https://github.com/YourUsername/ProfileCore.git`

### Update Download Fails

**Problem**: Download interrupted or failed

**Solutions**:

1. Check disk space: `Get-PSDrive C`
2. Verify write permissions
3. Try again (downloads to temp directory)
4. Use different provider

### Health Check Failures

**Problem**: Health checks prevent update

**Solutions**:

1. Review specific failed check
2. Fix the issue (e.g., free disk space)
3. Retry update
4. Skip health checks only if necessary: `Update-ProfileCore -SkipHealthCheck`

### Update Applied but Not Working

**Problem**: Update succeeded but issues persist

**Solutions**:

1. Reload profile: `. $PROFILE`
2. Restart PowerShell
3. Check for conflicts: `Get-Module ProfileCore -ListAvailable`
4. Restore from backup if needed

### Manual Update

If automatic update fails:

```powershell
# Git method
cd ProfileCore
git pull origin main
.\scripts\installation\install.ps1

# Manual download
# 1. Download latest release from GitHub
# 2. Extract to temporary location
# 3. Copy files to ProfileCore directory
# 4. Run: .\scripts\installation\install.ps1
```

## Advanced Usage

### Programmatic Updates

```powershell
# Get update manager
$updateMgr = $global:ProfileCore.UpdateManager

# Check for updates programmatically
$updateInfo = $updateMgr.CheckForUpdates()

if ($updateInfo.UpdateAvailable) {
    Write-Host "Update available: $($updateInfo.LatestVersion)"

    # Perform update without prompts
    $success = $updateMgr.PerformUpdate("Git", $false)

    if ($success) {
        Write-Host "Update successful!"
    }
}
```

### Custom Update Provider

Create your own update provider:

```powershell
class CustomUpdateProvider : IUpdateProvider {
    [bool] IsAvailable() {
        # Check if provider can be used
        return $true
    }

    [hashtable] CheckForUpdates() {
        # Check for updates
        return @{
            CurrentVersion = "1.0.0"
            LatestVersion = "1.1.0"
            UpdateAvailable = $true
        }
    }

    [bool] DownloadUpdate([string]$version, [string]$destination) {
        # Download update
        return $true
    }

    [bool] ApplyUpdate([string]$source) {
        # Apply update
        return $true
    }

    [bool] ValidateUpdate([string]$path) {
        # Validate update
        return $true
    }
}

# Register custom provider
$provider = [CustomUpdateProvider]::new()
$global:ProfileCore.UpdateManager.ProviderRegistry.Register("Custom", $provider)

# Use custom provider
Update-ProfileCore -Provider Custom
```

### Silent Updates

For automation scenarios:

```powershell
# Silent update with all safety features
Update-ProfileCore -Force -Confirm:$false

# Silent update without backup (fast but risky)
Update-ProfileCore -Force -SkipBackup -Confirm:$false

# Scheduled task example
$action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-NoProfile -Command `"Import-Module ProfileCore; Update-ProfileCore -Force -Confirm:`$false`""
$trigger = New-ScheduledTaskTrigger -Weekly -At 3am
Register-ScheduledTask -TaskName "ProfileCore Update" -Action $action -Trigger $trigger
```

## Architecture

### Strategy Pattern

Update providers implement the `IUpdateProvider` interface:

```powershell
class IUpdateProvider {
    [bool] IsAvailable()
    [hashtable] CheckForUpdates()
    [bool] DownloadUpdate([string]$version, [string]$destination)
    [bool] ApplyUpdate([string]$source)
    [bool] ValidateUpdate([string]$path)
}
```

### Provider Registry

Manages available update providers:

```powershell
class UpdateProviderRegistry {
    [hashtable]$Providers
    [string]$DefaultProvider

    [void] Register([string]$name, [IUpdateProvider]$provider)
    [IUpdateProvider] Get([string]$name)
    [IUpdateProvider] GetAvailable()
    [string[]] GetAvailableProviders()
}
```

### Update Manager

Orchestrates the update process:

```powershell
class UpdateManager {
    [UpdateConfig]$UpdateConfig
    [UpdateProviderRegistry]$ProviderRegistry
    [System.Collections.ArrayList]$HealthChecks

    [hashtable] CheckForUpdates()
    [bool] PerformUpdate([string]$providerName, [bool]$skipBackup)
    [hashtable] RunHealthChecks()
    [bool] ShouldCheckForUpdates()
}
```

## Best Practices

1. **Always create backups** before updates
2. **Run health checks** to catch issues early
3. **Check for updates regularly** with `Update-ProfileCore -CheckOnly`
4. **Enable auto-update checks** for notifications
5. **Keep backups** for at least 30 days
6. **Test updates** in non-production first
7. **Read release notes** before updating
8. **Reload profile** after updates

## Related Documentation

- [Installation Guide](../guides/installation-guide.md)
- [Package Management](package-management.md)
- [Configuration Management](../PROFILECORE_V5_SUMMARY.md)
- [Plugin System](../examples/plugins/README.md)

## Support

If you encounter issues:

1. Check this documentation
2. Review error messages
3. Check backups: `~/.profilecore/backups`
4. Open an issue on GitHub
5. Restore from backup if needed

---

**Last Updated**: October 10, 2025  
**ProfileCore Version**: 5.0.0
