# Migration Guide to ProfileCore v5.0

## 🚀 Quick Start - What You Need to Know

ProfileCore v5.0 is **100% backward compatible**. Your existing setup will continue to work without any changes.

However, you can benefit from new features by following this migration guide.

---

## ✅ What's New

### 1. SOLID Architecture

- Provider pattern for package managers
- Dependency injection
- Middleware pipeline
- Enhanced plugin system

### 2. Security Tools Plugin

- Legacy security commands moved to plugin
- Better error handling
- Configuration management

### 3. Optimized Shell Functions

- Zsh, Bash, and Fish optimized
- Consistent API across all shells
- Performance caching

---

## 📋 Migration Steps

### Step 1: Update ProfileCore Module

```powershell
# Navigate to ProfileCore directory
cd C:\Users\a1667\JetbrainsProject\03-Development-Projects\ProfileCore

# Pull latest changes (if using git)
git pull

# Or reload the module
Import-Module .\modules\ProfileCore\ProfileCore.psm1 -Force
```

### Step 2: Enable Security Tools Plugin (Optional)

If you use security tools (ssh-copy-id, Test-FileOnVirusTotal, etc.):

```powershell
# Copy plugin to user directory
$pluginSource = ".\examples\plugins\security-tools"
$pluginDest = "$HOME\.profilecore\plugins\security-tools"

Copy-Item -Path $pluginSource -Destination $pluginDest -Recurse -Force

# Enable plugin
Enable-ProfileCorePlugin -Name 'security-tools'

# Reload profile
. $PROFILE
```

**API Keys Configuration:**

Create `~/.config/shell-profile/secrets.json`:

```json
{
  "VIRUSTOTAL_API": "your-api-key",
  "SHODAN_API": "your-api-key"
}
```

### Step 3: Use New Package Management (Optional)

```powershell
# Old way (still works)
Install-CrossPlatformPackage -PackageName 'git'

# New way (recommended - more features)
Install-Package -PackageName 'git'
Install-Package -PackageName 'nodejs' -Provider 'scoop'

# New commands available
Get-PackageManagers                    # List all package managers
Update-Packages -All                   # Update from all managers
Get-InstalledPackages -All            # List all installed packages
```

### Step 4: Load Optimized Shell Functions (For Unix Shells)

#### Zsh

Add to `~/.zshrc`:

```bash
# Load ProfileCore
source /path/to/ProfileCore/shells/zsh/profilecore.zsh

# Optional: Disable welcome message
export PROFILECORE_QUIET=1
```

#### Bash

Add to `~/.bashrc`:

```bash
# Load ProfileCore
source /path/to/ProfileCore/shells/bash/profilecore.bash

# Optional: Disable welcome message
export PROFILECORE_QUIET=1
```

#### Fish

Add to `~/.config/fish/config.fish`:

```fish
# Load ProfileCore
source /path/to/ProfileCore/shells/fish/profilecore.fish

# Optional: Disable welcome message
set -gx PROFILECORE_QUIET 1
```

---

## 🔄 Command Changes

### Security Tools

| Old Command             | New Command                  | Status        |
| ----------------------- | ---------------------------- | ------------- |
| Built-in profile        | `Copy-SshId` / `ssh-copy-id` | Now in plugin |
| `Get-Verify-FileHash`   | `Test-FileHash`              | Now in plugin |
| `Test-FileOnVirusTotal` | Same                         | Now in plugin |
| `Check-IPonShodan`      | `Get-ShodanIPInfo`           | Now in plugin |

### Package Management

| Old Command                    | New Command             | Notes         |
| ------------------------------ | ----------------------- | ------------- |
| `Install-CrossPlatformPackage` | `Install-Package`       | More features |
| `Search-CrossPlatformPackage`  | `Search-Package`        | More features |
| `Update-AllPackages`           | `Update-Packages`       | More options  |
| N/A                            | `Get-PackageManagers`   | New           |
| N/A                            | `Get-InstalledPackages` | New           |

**Backward compatibility:** Old commands still work!

---

## 🎯 Benefits of Migrating

### For PowerShell Users

✅ **Better package management**

- Choose specific provider
- Update from all managers at once
- List available package managers

✅ **Improved security tools**

- Better error handling
- Configuration management
- Detailed output

✅ **Plugin system**

- Easy to extend
- Proper dependency injection
- Clean architecture

### For Shell Users (Zsh/Bash/Fish)

✅ **Consistent API** across all shells
✅ **Performance caching** (faster repeated operations)
✅ **Modular structure** (easier to customize)
✅ **Better error messages**

---

## 🐛 Troubleshooting

### Issue: "Plugin not found"

**Solution:**

```powershell
# Check plugin directory
Test-Path "$HOME\.profilecore\plugins\security-tools"

# If false, copy plugin again
Copy-Item .\examples\plugins\security-tools "$HOME\.profilecore\plugins\" -Recurse -Force
```

### Issue: "Command not found after enabling plugin"

**Solution:**

```powershell
# Reload profile
. $PROFILE

# Check if plugin loaded
Get-ProfileCorePluginInfo -Name 'security-tools'
```

### Issue: "Shell functions not loading"

**Solution:**

```bash
# Check path in your shell config
# For Zsh (.zshrc):
source /full/path/to/ProfileCore/shells/zsh/profilecore.zsh

# For Bash (.bashrc):
source /full/path/to/ProfileCore/shells/bash/profilecore.bash

# For Fish (config.fish):
source /full/path/to/ProfileCore/shells/fish/profilecore.fish
```

### Issue: "Package manager not detected"

**Solution:**

```powershell
# List available package managers
Get-PackageManagers

# Use specific provider
Install-Package -PackageName 'git' -Provider 'scoop'
```

---

## 📚 Learn More

- **[SOLID Architecture Guide](docs/development/SOLID_ARCHITECTURE.md)** - How it works
- **[Optimization Summary](docs/development/OPTIMIZATION_SUMMARY.md)** - What changed
- **[v5.0 Summary](docs/PROFILECORE_V5_SUMMARY.md)** - Complete overview

---

## ❓ FAQ

**Q: Do I have to migrate?**  
A: No, v5.0 is backward compatible. Migration is optional.

**Q: Will my old commands still work?**  
A: Yes! Old commands are aliased to new ones.

**Q: Should I use the security-tools plugin?**  
A: If you use those tools, yes. Better architecture and features.

**Q: What's the performance impact?**  
A: Module load is ~50ms slower, but operations are faster due to caching.

**Q: Can I create my own plugins?**  
A: Yes! See the example plugins in `examples/plugins/`.

**Q: How do I contribute?**  
A: See [Contributing Guide](docs/development/contributing.md).

---

## 🎉 Welcome to v5.0!

ProfileCore v5.0 brings professional architecture without breaking existing functionality.

Migrate at your own pace and enjoy the new features!

---

<div align="center">

**ProfileCore v5.0** - _Professional. Extensible. Backward Compatible._

**[🏠 Home](README.md)** • **[📖 Docs](docs/)** • **[🚀 Quick Start](QUICK_START.md)**

</div>
