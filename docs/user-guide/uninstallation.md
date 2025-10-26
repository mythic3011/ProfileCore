# ProfileCore Uninstallation Guide

Complete guide for safely uninstalling ProfileCore from your system.

## 📋 Table of Contents

- [Quick Uninstall](#quick-uninstall)
- [Uninstall Options](#uninstall-options)
- [What Gets Removed](#what-gets-removed)
- [Backup and Restore](#backup-and-restore)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Troubleshooting](#troubleshooting)
- [Manual Uninstallation](#manual-uninstallation)

---

## 🚀 Quick Uninstall

### Windows (PowerShell)

```powershell
# Navigate to ProfileCore directory
cd C:\Path\To\ProfileCore

# Run uninstaller
.\scripts\installation\uninstall.ps1
```

### Linux/macOS (Bash/Zsh)

```bash
# Navigate to ProfileCore directory
cd ~/ProfileCore

# Run uninstaller
./scripts/installation/uninstall.sh
```

---

## ⚙️ Uninstall Options

### PowerShell (Windows)

```powershell
# Interactive uninstall (default)
.\scripts\installation\uninstall.ps1

# Force uninstall without prompts
.\scripts\installation\uninstall.ps1 -Force

# Keep configuration files
.\scripts\installation\uninstall.ps1 -KeepConfig

# Keep backup files
.\scripts\installation\uninstall.ps1 -KeepBackups

# Restore previous profile backup
.\scripts\installation\uninstall.ps1 -RestoreBackup

# Quiet mode (minimal output)
.\scripts\installation\uninstall.ps1 -Quiet

# Combined options
.\scripts\installation\uninstall.ps1 -KeepConfig -KeepBackups -Force
```

### Bash/Zsh (Linux/macOS)

```bash
# Interactive uninstall (default)
./scripts/installation/uninstall.sh

# Force uninstall without prompts
./scripts/installation/uninstall.sh --force

# Keep configuration files
./scripts/installation/uninstall.sh --keep-config

# Keep backup files
./scripts/installation/uninstall.sh --keep-backups

# Restore previous profile backup
./scripts/installation/uninstall.sh --restore-backup

# Quiet mode (minimal output)
./scripts/installation/uninstall.sh --quiet

# Combined options
./scripts/installation/uninstall.sh --keep-config --keep-backups --force
```

---

## 🗑️ What Gets Removed

### By Default (Standard Uninstall)

The uninstaller removes:

1. **ProfileCore Module**

   - Windows: `$HOME\Documents\PowerShell\Modules\ProfileCore\`
   - Linux/macOS: `$HOME/.profilecore/`

2. **Profile Modifications**

   - Removes ProfileCore initialization code
   - Cleans up import statements
   - Removes ProfileCore references

3. **Configuration Files**

   - `$HOME/.config/shell-profile/`
   - `config.json`
   - `.env` file
   - Cache directory

4. **Backup Files**
   - All `*.backup` files created during installation
   - Pre-uninstall backup files

### Preserved by Default

- PowerShell/shell still works normally
- Other modules remain intact
- Original profile backup (if created during install)

### With `--keep-config` / `-KeepConfig`

Preserves:

- Configuration directory (`~/.config/shell-profile/`)
- User settings and preferences
- Environment variables (`.env`)
- Cache data

### With `--keep-backups` / `-KeepBackups`

Preserves:

- All profile backup files
- Installation backups
- Pre-uninstall backups

---

## 💾 Backup and Restore

### Automatic Backups

The uninstaller automatically creates a backup before removing ProfileCore:

```
$PROFILE.pre-uninstall-YYYYMMDD_HHMMSS.backup
```

### Restore Previous Profile

If you want to restore your profile to the state before ProfileCore was installed:

#### Windows (PowerShell)

```powershell
# Restore most recent backup during uninstall
.\scripts\installation\uninstall.ps1 -RestoreBackup

# Or manually restore after uninstall
$backups = Get-ChildItem $PROFILE.*.backup | Sort-Object LastWriteTime -Descending
Copy-Item $backups[0].FullName $PROFILE -Force
```

#### Linux/macOS (Bash/Zsh)

```bash
# Restore most recent backup during uninstall
./scripts/installation/uninstall.sh --restore-backup

# Or manually restore after uninstall
latest_backup=$(ls -t ~/.bashrc.*.backup 2>/dev/null | head -1)
cp "$latest_backup" ~/.bashrc
```

### View Available Backups

#### Windows

```powershell
Get-ChildItem $PROFILE.*.backup | Select-Object Name, LastWriteTime
```

#### Linux/macOS

```bash
ls -lh ~/.bashrc.*.backup 2>/dev/null
# or for zsh
ls -lh ~/.zshrc.*.backup 2>/dev/null
```

---

## 🖥️ Platform-Specific Instructions

### Windows PowerShell

1. **Open PowerShell as Administrator** (recommended)
2. Navigate to ProfileCore directory
3. Run uninstaller:
   ```powershell
   .\scripts\installation\uninstall.ps1
   ```
4. Follow prompts
5. **Restart PowerShell** to complete uninstallation

#### Locations Cleaned

- `$HOME\Documents\PowerShell\Modules\ProfileCore\`
- `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` (modified)
- `$HOME\.config\shell-profile\`

### Linux/macOS

1. **Open Terminal**
2. Navigate to ProfileCore directory
3. Make script executable (if needed):
   ```bash
   chmod +x scripts/installation/uninstall.sh
   ```
4. Run uninstaller:
   ```bash
   ./scripts/installation/uninstall.sh
   ```
5. Follow prompts
6. **Restart your shell** or run:
   ```bash
   source ~/.bashrc  # or ~/.zshrc for zsh
   ```

#### Locations Cleaned

**Bash:**

- `$HOME/.profilecore/`
- `$HOME/.bashrc` (modified)
- `$HOME/.bash_profile` (macOS, modified)
- `$HOME/.config/shell-profile/`

**Zsh:**

- `$HOME/.profilecore/`
- `$HOME/.zshrc` (modified)
- `$HOME/.zsh/profilecore.zsh`
- `$HOME/.config/shell-profile/`

**Fish:**

- `$HOME/.config/fish/functions/profilecore/`
- `$HOME/.config/fish/config.fish` (modified)
- `$HOME/.config/shell-profile/`

---

## 🔧 Troubleshooting

### "Module Not Found" Error

If the uninstaller can't find ProfileCore:

```powershell
# Check if module is installed
Get-Module -ListAvailable ProfileCore

# Check installation location
$env:PSModulePath -split ';' | ForEach-Object {
    if (Test-Path "$_\ProfileCore") {
        Write-Host "Found: $_\ProfileCore"
    }
}
```

**Solution**: Use `--force` or `-Force` to continue anyway, or proceed to [Manual Uninstallation](#manual-uninstallation).

### Permission Denied

**Windows:**

```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs
```

**Linux/macOS:**

```bash
# Make script executable
chmod +x scripts/installation/uninstall.sh

# Or run with bash explicitly
bash scripts/installation/uninstall.sh
```

### Profile Still Loading ProfileCore

If your profile still tries to load ProfileCore after uninstall:

**Windows:**

```powershell
# Edit profile
notepad $PROFILE

# Remove or comment out ProfileCore lines
# Import-Module ProfileCore
```

**Linux/macOS:**

```bash
# Edit profile
nano ~/.bashrc  # or ~/.zshrc

# Remove or comment out ProfileCore lines
# source ~/.profilecore/profilecore.bash
```

### Uninstaller Won't Start

**Check Prerequisites:**

```powershell
# Windows
$PSVersionTable.PSVersion  # Should be 5.1+

# Linux/macOS
bash --version  # Should be 4.0+
```

### Files Still Present After Uninstall

If files remain, see [Manual Uninstallation](#manual-uninstallation).

---

## 🔨 Manual Uninstallation

If the automatic uninstaller fails, you can manually remove ProfileCore:

### Windows (Manual)

```powershell
# 1. Remove ProfileCore module
$modulePath = "$HOME\Documents\PowerShell\Modules\ProfileCore"
if (Test-Path $modulePath) {
    Remove-Item $modulePath -Recurse -Force
}

# 2. Clean profile
$profilePath = $PROFILE
if (Test-Path $profilePath) {
    # Create backup
    Copy-Item $profilePath "$profilePath.manual-backup"

    # Remove ProfileCore lines
    $content = Get-Content $profilePath
    $content | Where-Object { $_ -notmatch 'ProfileCore|Initialize-ProfileEnvironment' } |
        Set-Content $profilePath
}

# 3. Remove configuration (optional)
$configPath = "$HOME\.config\shell-profile"
if (Test-Path $configPath) {
    Remove-Item $configPath -Recurse -Force
}

# 4. Remove backups (optional)
Get-ChildItem "$PROFILE*.backup" | Remove-Item -Force

Write-Host "✅ Manual uninstallation complete"
Write-Host "⚠️  Restart PowerShell to complete"
```

### Linux/macOS (Manual)

```bash
# 1. Remove ProfileCore module
rm -rf ~/.profilecore

# 2. Clean profile
profile_file="$HOME/.bashrc"  # or ~/.zshrc for zsh

if [ -f "$profile_file" ]; then
    # Create backup
    cp "$profile_file" "${profile_file}.manual-backup"

    # Remove ProfileCore lines
    sed -i.tmp '/ProfileCore/d;/profilecore/d' "$profile_file"
    rm -f "${profile_file}.tmp"
fi

# 3. Remove configuration (optional)
rm -rf ~/.config/shell-profile

# 4. Remove backups (optional)
rm -f ~/.bashrc.*.backup
rm -f ~/.zshrc.*.backup

echo "✅ Manual uninstallation complete"
echo "⚠️  Restart your shell or run: source $profile_file"
```

### Verify Manual Uninstallation

```powershell
# Windows
Get-Module ProfileCore  # Should return nothing
Test-Path "$HOME\Documents\PowerShell\Modules\ProfileCore"  # Should be False

# Linux/macOS
ls ~/.profilecore  # Should not exist
ls ~/.config/shell-profile  # Should not exist
```

---

## 📝 Post-Uninstallation

### After Uninstalling

1. **Restart Your Shell**

   - Close and reopen PowerShell/Terminal
   - Or run: `source ~/.bashrc` (Linux/macOS)

2. **Verify Removal**

   ```powershell
   # Windows
   Get-Module ProfileCore  # Should be empty

   # Linux/macOS
   which profilecore  # Should not be found
   ```

3. **Check Profile**
   - Your shell should still work normally
   - No ProfileCore commands should be available
   - Profile should load without errors

### If You Want to Reinstall

```powershell
# Windows
.\scripts\installation\install.ps1

# Linux/macOS
./scripts/installation/install.sh
```

### Uninstall Logs

Uninstall logs are saved to:

- **Windows**: `$env:TEMP\profilecore-uninstall-YYYYMMDD-HHMMSS.log`
- **Linux/macOS**: `/tmp/profilecore-uninstall-YYYYMMDD-HHMMSS.log`

View the log:

```powershell
# Windows
notepad (Get-ChildItem $env:TEMP\profilecore-uninstall-*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName

# Linux/macOS
cat $(ls -t /tmp/profilecore-uninstall-*.log | head -1)
```

---

## 📞 Need Help?

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review the uninstall log file
3. Try [Manual Uninstallation](#manual-uninstallation)
4. Open an issue on GitHub with:
   - Operating System and version
   - Shell type and version
   - Error messages
   - Uninstall log (if available)

---

## ✅ Uninstall Checklist

Before uninstalling:

- [ ] Backup any custom configurations
- [ ] Note any custom functions you added
- [ ] Save your `.env` file if needed
- [ ] Review what will be removed

After uninstalling:

- [ ] Restart your shell
- [ ] Verify ProfileCore is removed
- [ ] Check your profile loads correctly
- [ ] Confirm no errors appear
- [ ] Delete uninstall logs (optional)

---

**Version**: 5.0.0  
**Last Updated**: 2025-01-11  
**Status**: ✅ Complete
