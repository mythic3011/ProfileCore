# Repository Migration Guide

## Moving ProfileCore Repository While Keeping Configuration

This guide explains how to move your ProfileCore repository to a different directory while preserving your PowerShell configuration, module installation, and settings.

---

## 🎯 Understanding the Setup

ProfileCore has two important locations:

1. **Repository Location** - Where you cloned/downloaded the code

   - Default: `C:\Users\...\Documents\PowerShell\ProfileCore`
   - Contains: Source code, git history, development files

2. **Module Installation** - Where PowerShell loads the module from

   - Location: `C:\Users\...\Documents\PowerShell\modules\ProfileCore`
   - Contains: Installed module files used by PowerShell

3. **Configuration** - Your settings and customizations
   - Location: `C:\Users\...\.config\shell-profile`
   - Contains: config.json, .env, your API keys

**Important:** You can move the repository anywhere, but the module and configuration stay in standard PowerShell locations for easy access.

---

## 🚀 Quick Migration (Recommended)

### Option 1: Using the Migration Script

```powershell
# Move repository to a new location
.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "D:\Projects\ProfileCore"

# With symbolic link for easy reference
.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "D:\Dev\ProfileCore" -KeepModuleSymlink
```

The script will:

- ✅ Check for uncommitted changes
- ✅ Copy repository to new location
- ✅ Preserve git history and remotes
- ✅ Keep module installation intact
- ✅ Verify everything works
- ✅ Optionally clean up old location

---

## 🔧 Manual Migration (Alternative)

If you prefer to do it manually:

### Step 1: Check Git Status

```powershell
cd C:\Users\...\Documents\PowerShell\ProfileCore
git status

# If you have changes, stash them
git stash push -m "Before repository move"
```

### Step 2: Copy Repository

```powershell
# Copy entire repository to new location
Copy-Item -Path "C:\Users\...\Documents\PowerShell\ProfileCore" `
          -Destination "D:\Projects\ProfileCore" `
          -Recurse -Force
```

### Step 3: Verify New Location

```powershell
cd D:\Projects\ProfileCore

# Check git is working
git status
git remote -v

# Check files are present
dir
```

### Step 4: Test PowerShell Module (No Changes Needed!)

```powershell
# Module still works from its installation location
Get-Command -Module ProfileCore
Get-SystemInfo
```

### Step 5: Update Module (Optional)

```powershell
# If you want to update the installed module from new location
cd D:\Projects\ProfileCore
.\scripts\installation\install.ps1 -Force
```

### Step 6: Remove Old Location

```powershell
# ONLY after verifying everything works
Remove-Item -Path "C:\Users\...\Documents\PowerShell\ProfileCore" -Recurse -Force
```

---

## 📋 What Gets Preserved

### ✅ Always Preserved (Automatic)

- PowerShell module installation
- Your profile configuration (`$PROFILE`)
- Config files (`.config/shell-profile`)
- Environment variables (`.env`)
- All PowerShell aliases and functions
- PSScriptAnalyzer settings
- Pester, PSScriptAnalyzer modules

### ✅ Preserved by Migration Script

- Git history (`.git`)
- Git remotes (origin, etc.)
- Uncommitted changes (via stash)
- All repository files
- Documentation
- Examples

---

## 🎯 Common Scenarios

### Scenario 1: Move to Different Drive

```powershell
# Current: C:\Users\...\Documents\PowerShell\ProfileCore
# Target:  D:\Dev\ProfileCore

.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "D:\Dev\ProfileCore"
```

### Scenario 2: Organize with Other Projects

```powershell
# Current: C:\Users\...\Documents\PowerShell\ProfileCore
# Target:  C:\Projects\PowerShell\ProfileCore

.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "C:\Projects\PowerShell\ProfileCore"
```

### Scenario 3: Network/Cloud Drive

```powershell
# Move to OneDrive for sync across machines
.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "C:\Users\...\OneDrive\Projects\ProfileCore"
```

---

## 🔍 Verification Checklist

After migration, verify these items:

### 1. PowerShell Module

```powershell
# Should show module loaded successfully
Get-Module ProfileCore

# Should show all functions
Get-Command -Module ProfileCore | Measure-Object
# Expected: 100+ functions
```

### 2. Core Functions

```powershell
# Test a few commands
Get-SystemInfo
Get-OperatingSystem
myip
perf
```

### 3. Git Repository

```powershell
cd <NewLocation>
git status
git remote -v
git log -1
```

### 4. Configuration

```powershell
# Check config exists
Test-Path "$HOME\.config\shell-profile\config.json"
Test-Path "$HOME\.config\shell-profile\.env"

# View config
Get-Content "$HOME\.config\shell-profile\config.json" | ConvertFrom-Json
```

### 5. Profile

```powershell
# Should source module correctly
. $PROFILE

# Check profile path
$PROFILE
Get-Content $PROFILE | Select-String "ProfileCore"
```

---

## ⚠️ Important Notes

### Module vs Repository

After migration, remember:

- **Repository** (for development/updates): New location
- **Module** (PowerShell loads from): `Documents\PowerShell\modules\ProfileCore`
- **Configuration** (your settings): `.config\shell-profile`

### Updating the Module

When you make changes to repository code:

```powershell
cd <NewRepositoryLocation>
.\scripts\installation\install.ps1 -Force
```

This copies updated files from repository → module installation.

### Development Workflow

```powershell
# 1. Edit files in repository
cd D:\Projects\ProfileCore
code .

# 2. Test changes
.\scripts\installation\install.ps1 -Force

# 3. Reload profile
. $PROFILE

# 4. Commit changes
git add .
git commit -m "Your changes"
git push
```

---

## 🐛 Troubleshooting

### Module Not Found After Migration

```powershell
# Verify module location
$env:PSModulePath -split ';'

# Should include: C:\Users\...\Documents\PowerShell\Modules

# Reinstall if needed
cd <NewRepositoryLocation>
.\scripts\installation\install.ps1 -Force
```

### Git Issues After Move

```powershell
cd <NewLocation>

# Check remote
git remote -v

# If remote is missing
git remote add origin https://github.com/mythic3011/ProfileCore.git

# Pull latest
git pull origin main
```

### Configuration Not Loading

```powershell
# Check config location
Test-Path "$HOME\.config\shell-profile"

# Recreate if needed
New-Item -Path "$HOME\.config\shell-profile" -ItemType Directory -Force

# Copy example config
Copy-Item -Path "<NewLocation>\examples\config-templates\*" `
          -Destination "$HOME\.config\shell-profile"
```

### Functions Not Available

```powershell
# Reload module
Remove-Module ProfileCore -Force
Import-Module ProfileCore -Force

# Reload profile
. $PROFILE

# Validate installation
.\scripts\installation\install.ps1 -Validate
```

---

## 💡 Pro Tips

### 1. Use Separate Repository and Module

**Benefits:**

- Edit code in repository without affecting live module
- Test changes before applying
- Keep git repository clean (no module clutter)
- Easy rollback

**Setup:**

```powershell
# Repository for development
D:\Projects\ProfileCore

# Module for PowerShell use (managed by installer)
C:\Users\...\Documents\PowerShell\modules\ProfileCore
```

### 2. Create Development Alias

```powershell
# Add to your profile
Set-Alias -Name 'pcdev' -Value 'D:\Projects\ProfileCore'

# Quick navigation
pcdev  # Opens in Windows Explorer
cd (pcdev)  # Changes to directory
```

### 3. Automated Updates

```powershell
# Create update function in profile
function Update-ProfileCore {
    Push-Location "D:\Projects\ProfileCore"
    git pull
    .\scripts\installation\install.ps1 -Quiet
    Pop-Location
    . $PROFILE
    Write-Host "✅ ProfileCore updated!" -ForegroundColor Green
}
```

---

## 📚 Related Documentation

- [Installation Guide](../installation-guide.md)
- [Quick Start](../../QUICK_START.md)
- [Development Guide](../development/contributing.md)

---

## 🆘 Need Help?

If you encounter issues:

1. **Check validation:**

   ```powershell
   .\scripts\installation\install.ps1 -Validate
   ```

2. **Review logs:**

   ```powershell
   Get-Content "$HOME\.config\shell-profile\install.log" -Tail 50
   ```

3. **Open an issue:**
   https://github.com/mythic3011/ProfileCore/issues

---

**Happy migrating! 🚀**
