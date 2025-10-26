# Migration Guide: v5.0.0 to v5.1.0

**ProfileCore v5.1.0** - Performance Optimization Release

---

## 📋 Overview

ProfileCore v5.1.0 is a **performance-focused** release that delivers a **63% faster startup experience** with **zero breaking changes**.

**Key Points:**
- ✅ Drop-in replacement - no migration needed
- ✅ All existing functionality preserved
- ✅ 2+ seconds saved on every shell startup
- ✅ Lazy loading and async initialization
- ✅ Zero configuration required

---

## ⚡ Quick Migration

### Step 1: Update ProfileCore

**Option A: Git Pull (Recommended)**
```powershell
# Navigate to ProfileCore directory
cd C:\Users\YourUsername\JetbrainsProject\ProfileCore  # Windows
cd ~/ProfileCore  # macOS/Linux

# Pull latest changes
git pull

# Done! Restart PowerShell
```

**Option B: Use Update-ProfileCore**
```powershell
# Update using built-in command
Update-ProfileCore

# Restart PowerShell
```

**Option C: Reinstall**
```powershell
# Windows
.\scripts\installation\install.ps1 -Force

# macOS/Linux
./scripts/installation/install.sh --force
```

### Step 2: Restart PowerShell

```powershell
# Simply restart your PowerShell session
# Or reload profile
. $PROFILE
```

### Step 3: Enjoy!

That's it! You're now running ProfileCore v5.1.0 with 63% faster startup.

---

## 🎯 What's Changed

### Performance Improvements

| Aspect | Before (v5.0.0) | After (v5.1.0) | Change |
|--------|-----------------|----------------|--------|
| **Startup Time** | ~3.3s | ~1.2s | **63% faster** |
| **User Perceived** | ~3.3s | <1s | **70% faster** |
| **Memory Usage** | ~25MB | ~17MB | **32% less** |
| **Command Registry** | 1.7s upfront | On-demand | **Lazy loaded** |
| **Starship** | 325ms blocking | Async | **Non-blocking** |

### Behavioral Changes

#### 1. Lazy Command Registration

**Before (v5.0.0):**
- All commands registered during startup
- Added ~1.7s to every shell launch
- Help available immediately

**After (v5.1.0):**
- Commands register only when `Get-Helper` is first called
- Saves ~1.7s on startup
- First `Get-Helper` call takes ~1.7s
- Subsequent calls are instant

**Impact:** ✅ Instant startup, minor delay on first help access

#### 2. Async Starship Initialization

**Before (v5.0.0):**
- Starship initialized synchronously
- Added ~325ms to startup
- Full prompt ready immediately

**After (v5.1.0):**
- Simple prompt appears instantly
- Starship loads in background
- Full Starship prompt appears after ~300ms

**Impact:** ✅ Instant usable shell, slight delay for fancy prompt

#### 3. Optimized Environment Loading

**Before (v5.0.0):**
- Loaded configs, then set defaults
- Multiple file I/O operations

**After (v5.1.0):**
- Set defaults first
- Load configs only if present
- Use `-LiteralPath` for faster checks

**Impact:** ✅ ~20ms faster, more reliable

---

## 🔧 No Changes Required

### Commands Work Identically

All ProfileCore commands work exactly as before:

```powershell
# Package management - unchanged
pkg install neovim
pkgs python
pkgu

# System tools - unchanged
sysinfo
pinfo
diskinfo

# Network tools - unchanged
myip
localips
scan-port localhost 1-100

# Security tools - unchanged
check-ssl github.com
dns-lookup google.com
gen-password 16

# Git tools - unchanged
gqc "commit message"
git-status
git-cleanup

# Docker tools - unchanged
docker-status
dc-up
dlogs

# Everything works the same!
```

### Configurations Remain Valid

All your existing configurations continue to work:

```powershell
# Config files - no changes needed
~/.config/shell-profile/.env
~/.config/shell-profile/config.json
~/.config/shell-profile/paths.json
~/.config/shell-profile/aliases.json

# Profile customizations - no changes needed
$PROFILE  # Your customizations preserved

# Plugin system - no changes needed
Get-ProfileCorePlugins  # All plugins work
```

---

## 🆕 New Behavior to Understand

### Lazy Loading of Get-Helper

**First Call (one-time ~1.7s delay):**
```powershell
PS> Get-Helper
# Registers all commands (~1.7s one-time cost)
# Then displays help
```

**Subsequent Calls (instant):**
```powershell
PS> Get-Helper
# Instant! Commands already registered
```

**Workaround (if you want commands registered immediately):**

Add to your `$PROFILE` (after ProfileCore loads):
```powershell
# Pre-register commands on startup (optional)
# This will add ~1.7s back to startup
if ($Host.Name -eq 'ConsoleHost') {
    Get-Helper -ErrorAction SilentlyContinue | Out-Null
}
```

### Async Starship Loading

**What You'll See:**

1. **Shell starts with simple prompt:** `PS C:\Users\YourName>`
2. **After ~300ms, Starship appears:** Full fancy prompt

**This is normal and expected!**

**Workaround (if you want Starship immediately):**

Edit `Microsoft.PowerShell_profile.ps1`:
```powershell
# Replace this line:
Initialize-Prompt -Fast  # Use simple prompt initially

# With:
Initialize-Prompt  # Use Starship synchronously (adds ~325ms)
```

Then **comment out or remove:**
```powershell
# Initialize-StarshipAsync  # Comment this out
```

---

## ✅ Verification

### Check Your Version

```powershell
# Method 1: Check module version
(Get-Module ProfileCore -ListAvailable).Version
# Should show: 5.1.0

# Method 2: Check profile version
$global:ProfileCommands.Metadata.Version
# Should show: 5.1.0

# Method 3: Check installed version
Get-ProfileCoreVersion
# Should show: v5.1.0
```

### Benchmark Your Startup

```powershell
# Run profiler (10 iterations)
.\scripts\utilities\Profile-MainScript.ps1

# You should see:
# - Total time: ~1200ms (vs ~3300ms before)
# - Command registry: 0ms (lazy loaded)
# - Starship: 0ms (async)
```

### Test Core Functionality

```powershell
# Test a few commands
Get-SystemInfo       # Should work
myip                 # Should work
Get-Helper           # Should work (registers commands first time)
pkg-search python    # Should work
sysinfo              # Should work
```

---

## 🐛 Troubleshooting

### Issue: Commands not working

**Symptom:** `Get-SystemInfo: The term 'Get-SystemInfo' is not recognized...`

**Solution:**
```powershell
# Verify module path is set
$env:PSModulePath -split ';' | Select-String "ProfileCore"

# If not found, add it:
$moduleParent = Join-Path $PSScriptRoot "modules"
$env:PSModulePath = "$moduleParent;$env:PSModulePath"

# Reload profile
. $PROFILE
```

### Issue: Get-Helper not showing commands

**Symptom:** `Get-Helper` shows empty or incomplete list

**Solution:**
```powershell
# Force re-registration
$global:CommandsRegistered = $false
Get-Helper

# Or reload profile
. $PROFILE
```

### Issue: Starship not loading

**Symptom:** Simple prompt persists, Starship never appears

**Solution:**
```powershell
# Check if Starship is installed
Get-Command starship -ErrorAction SilentlyContinue

# If not installed:
winget install starship  # Windows
brew install starship    # macOS
# Then restart PowerShell
```

### Issue: Slow startup (not seeing improvement)

**Symptom:** Startup still takes 3+ seconds

**Solution:**
```powershell
# Profile the startup
.\scripts\utilities\Profile-MainScript.ps1

# Check for issues:
# 1. Verify lazy loading is enabled
# 2. Check for other profile customizations
# 3. Look for slow plugins or custom code

# To see what's slow:
Measure-Command { . $PROFILE }
```

---

## 🔄 Rollback to v5.0.0

If you encounter issues and need to rollback:

```powershell
# Navigate to ProfileCore directory
cd C:\Path\To\ProfileCore

# Checkout v5.0.0 tag
git checkout v5.0.0

# Reinstall
.\scripts\installation\install.ps1 -Force

# Restart PowerShell
```

**Note:** We don't anticipate any issues, but the option is available.

---

## 📊 Performance Comparison

### Startup Time Breakdown

**v5.0.0 (Before):**
```
Total: 3305ms
├─ Command Registry: 1770ms (53.6%)
├─ Module Import: 1148ms (34.7%)
├─ Starship: 325ms (9.8%)
├─ Environment: 48ms (1.5%)
└─ Other: 14ms (0.4%)
```

**v5.1.0 (After):**
```
Total: ~1200ms (63% improvement!)
├─ Command Registry: 0ms (lazy loaded ✓)
├─ Module Import: ~1100ms (can be deferred)
├─ Starship: 0ms (async ✓)
├─ Environment: ~28ms (optimized ✓)
└─ Other: ~72ms
```

### Real-World Impact

**Daily Usage (10 shell sessions):**
- v5.0.0: 33 seconds total
- v5.1.0: 12 seconds total
- **Savings: 21 seconds per day!**

**Monthly (assuming 22 workdays, 10 sessions/day):**
- v5.0.0: 12.1 minutes
- v5.1.0: 4.4 minutes
- **Savings: 7.7 minutes per month!**

**Yearly:**
- **Savings: ~1.5 hours per year!**

*Time is precious!* ⏱️

---

## 💡 Tips for Best Performance

### 1. Pre-register Commands (Optional)

If you use `Get-Helper` frequently, pre-register on startup:

```powershell
# Add to end of $PROFILE
if ($global:ProfileCommands -and -not $global:CommandsRegistered) {
    Get-Helper -ErrorAction SilentlyContinue | Out-Null
}
```

**Trade-off:** Adds ~1.7s to startup, but `Get-Helper` is instant

### 2. Use Module Auto-Loading

Let PowerShell load ProfileCore commands on first use:

```powershell
# Already enabled in v5.1.0!
# Just use commands - they auto-load
Get-SystemInfo  # Triggers module load first time
```

### 3. Benchmark Regularly

Track your performance over time:

```powershell
# Run profiler monthly
.\scripts\utilities\Profile-MainScript.ps1

# Keep baseline for comparison
# Target: <1500ms for good performance
```

### 4. Keep Profile Lean

Avoid adding slow operations to `$PROFILE`:

```powershell
# ❌ Bad - slow on every startup
Get-AllRepos | Update-GitStatus

# ✅ Good - fast startup, run manually
function Update-AllGitRepos {
    Get-AllRepos | Update-GitStatus
}
```

---

## 📚 Additional Resources

### Documentation

- [Performance Report](../../FINAL_OPTIMIZATION_REPORT.md) - Detailed optimization analysis
- [Release Notes](../../RELEASE_NOTES_v5.1.0.md) - Complete v5.1.0 release notes
- [Changelog](../../CHANGELOG.md) - Full version history
- [README](../../README.md) - Updated features and stats

### Community

- **Issues:** [GitHub Issues](https://github.com/mythic3011/ProfileCore/issues)
- **Discussions:** [GitHub Discussions](https://github.com/mythic3011/ProfileCore/discussions)
- **Updates:** Watch the repository for future releases

---

## 🎉 Welcome to v5.1.0!

Enjoy your **63% faster** ProfileCore experience!

If you have any questions or issues, please open an issue on GitHub.

**Happy scripting!** ⚡🚀

---

**Last Updated:** October 13, 2025  
**Version:** 5.1.0  
**Author:** Mythic3011

