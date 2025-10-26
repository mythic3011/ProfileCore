# Utility Scripts 🔧

**Maintenance and utility scripts for ProfileCore**

---

## 📦 Scripts (Planned for v4.2.0)

### Planned Utility Scripts

| Script                | Purpose                     | Status     |
| --------------------- | --------------------------- | ---------- |
| `backup-profile.ps1`  | Backup ProfileCore settings | 📋 Planned |
| `restore-profile.ps1` | Restore from backup         | 📋 Planned |
| `export-settings.ps1` | Export settings to file     | 📋 Planned |
| `import-settings.ps1` | Import settings from file   | 📋 Planned |
| `clean-cache.ps1`     | Clean all caches            | 📋 Planned |
| `diagnose.ps1`        | Diagnostic tool             | 📋 Planned |

---

## 🚀 Current Utilities

### Use Built-in Commands

ProfileCore has built-in utilities:

```powershell
# Performance
Clear-ProfileCorePerformanceCache  # Clear caches
Optimize-ProfileCoreMemory         # Free memory
Test-ProfileCorePerformance        # Run diagnostics

# Configuration
Clear-ConfigCache                  # Clear config cache

# Updates
Update-ProfileCore                 # Check for updates

# Cloud Sync
Push-ProfileCore                   # Backup to cloud
Sync-ProfileCore                   # Restore from cloud

# Plugins
Get-ProfileCorePlugins             # List plugins
Test-ProfileCorePlugin             # Validate plugin
```

---

## 💡 Manual Utilities

### Backup Settings

```powershell
# Manual backup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "~/.profilecore/backups/$timestamp"

# Copy configuration
Copy-Item ~/.config/shell-profile $backupDir -Recurse
```

### Export Settings

```powershell
# Export to JSON
$settings = @{
    config = Get-Content ~/.config/shell-profile/config.json -Raw
    paths = Get-Content ~/.config/shell-profile/paths.json -Raw
    aliases = Get-Content ~/.config/shell-profile/aliases.json -Raw
}

$settings | ConvertTo-Json | Out-File "profilecore-export.json"
```

### Clean All Caches

```powershell
# Clear all ProfileCore caches
Clear-ConfigCache
Clear-ProfileCorePerformanceCache
Optimize-ProfileCoreMemory
```

---

## 🔮 Future Features

### Coming in v4.2.0

**Backup/Restore:**

- Automated backup scheduling
- Point-in-time restore
- Backup compression
- Cloud backup integration

**Export/Import:**

- Full settings export
- Selective import
- Migration tools
- Profile templates

**Maintenance:**

- Cache cleanup automation
- Log rotation
- Dependency updates
- Health checks

---

<div align="center">

**Utility Scripts** - _Coming Soon in v4.2.0_

**[📖 Main Docs](../../README.md)** • **[🔧 Configuration](../configuration/)**

</div>

