# ProfileCore v6 Migration Guide

**Version:** 6.0.0  
**Date:** 2025-01-26  
**Status:** Complete

## Overview

ProfileCore v6 represents a major architectural improvement with:

- **v6 DI Architecture**: Full dependency injection with service locator pattern
- **ProfileCore.Common**: Shared library for output and installation helpers
- **Rust Integration**: Enhanced performance with 39 production-grade libraries
- **Cross-Shell CLI**: Single `profilecore` binary for all shells
- **Module Consolidation**: Simplified structure, deprecated sub-modules

## What's New in v6

### 1. v6 Dependency Injection Architecture ✅

**Before (v5):**

```powershell
# Direct function calls, tight coupling
$cache = Get-ConfigCache
$config = Load-Config
```

**After (v6):**

```powershell
# Service-based, loose coupling
$cache = Resolve-Service 'CacheManager'
$config = Resolve-Service 'ConfigurationManager'
```

**Services Available:**

- `ServiceLocator` - Central service registry
- `CacheManager` - Intelligent caching (38x faster)
- `PerformanceMetricsManager` - Performance tracking
- `PackageManagerRegistry` - Package manager abstraction
- `ConfigurationManager` - Configuration management
- `OSProvider` - OS-specific implementations

### 2. ProfileCore.Common Shared Library ✅

**Created:** `modules/ProfileCore.Common/`

**Output Functions:**

```powershell
Import-Module ProfileCore.Common

Write-BoxHeader "Title" -Width 60 -Color Cyan
Write-Step "Step 1" -Message "Processing..."
Write-Success "Operation completed"
Write-Info "Information message"
Write-Warn "Warning message"
Write-Fail "Error occurred"
Write-ErrorMsg "Detailed error"
Write-CheckMark "Validation" -Success $true
Write-SectionHeader "Section Title"
Write-InstallProgress "Installing..." -Percent 75
```

**Installation Helpers:**

```powershell
Test-GitHubConnectivity -Timeout 5000
Get-UserConfirmation "Proceed?" -NonInteractive:$NonInteractive
Test-Prerequisites @('git', 'pwsh')
Invoke-WithRetry -ScriptBlock { ... } -MaxAttempts 3
```

**Rust-Backed Functions** (for high performance):

```powershell
Write-RustBoxHeader "Title" -Width 60
Write-RustInstallProgress "Loading..." -Percent 50
Test-RustCommandExists 'git'
Test-RustGitHubConnectivity -Timeout 5000
```

### 3. Rust CLI Integration ✅

**New Binary:** `profilecore` (cross-platform)

**Commands:**

```bash
# Shell initialization
profilecore init bash | source
profilecore init zsh  | source
profilecore init fish | source

# System information (beautiful tables)
profilecore system info
profilecore system disk
profilecore system process

# Network utilities (with tables)
profilecore network stats
profilecore network test-port 443

# Helper commands (with spinners)
profilecore helper test-github
profilecore helper test-cmd git

# Interactive features
profilecore setup        # Interactive setup wizard
profilecore doctor       # Health check
profilecore examples     # Show examples

# Shell completions
profilecore completions bash > ~/.bash_completion.d/profilecore
profilecore completions zsh > ~/.zsh/completions/_profilecore
```

**Performance:** 20-36x faster string generation in Rust vs PowerShell

### 4. Module Structure Changes ✅

**Deprecated Modules** (moved to `modules/deprecated-v5.2/`):

- ❌ `ProfileCore.Binary` → Now: `modules/ProfileCore/rust-binary/`
- ❌ `ProfileCore.Performance` → Integrated into main module
- ❌ `ProfileCore.PackageManagement` → Integrated into main module

**New Modules:**

- ✅ `ProfileCore.Common` - Shared utilities (required dependency)
- ✅ `ProfileCore` - Main module with v6 DI architecture
- ✅ `ProfileCore-rs` - Rust library & CLI binary

**Directory Structure:**

```
modules/
├── ProfileCore/
│   ├── private/              # v5 compatibility functions
│   ├── private-v6/           # v6 DI architecture
│   │   ├── core/            # Core DI classes
│   │   ├── interfaces/      # Interface definitions
│   │   ├── providers/       # Service implementations
│   │   └── managers/        # Manager classes
│   ├── public/              # Public commands (97 functions)
│   ├── rust-binary/         # Rust integration (moved from ProfileCore.Binary)
│   ├── ProfileCore.psm1     # Main module loader
│   └── ProfileCore.psd1     # Module manifest
├── ProfileCore.Common/       # NEW: Shared library
│   ├── public/
│   │   ├── OutputHelpers.ps1
│   │   ├── InstallHelpers.ps1
│   │   ├── RustOutputHelpers.ps1
│   │   └── RustInstallHelpers.ps1
│   ├── ProfileCore.Common.psm1
│   └── ProfileCore.Common.psd1
├── ProfileCore-rs/          # Rust source & CLI
│   ├── src/
│   │   ├── cli/             # CLI commands
│   │   ├── output.rs        # Output functions
│   │   ├── helpers.rs       # Installation helpers
│   │   ├── system/          # System info
│   │   ├── network/         # Network utilities
│   │   ├── platform/        # OS-specific
│   │   ├── main.rs          # CLI entry point
│   │   └── lib.rs           # Library exports
│   ├── Cargo.toml
│   └── target/              # Build artifacts
└── deprecated-v5.2/         # Archived modules
    ├── ProfileCore.Binary/
    ├── ProfileCore.Performance/
    └── ProfileCore.PackageManagement/
```

## Migration Steps

### For Users (Updating from v5.x)

#### Option 1: Quick Update (Recommended)

```powershell
# From within PowerShell with ProfileCore already loaded
Update-ProfileCore

# Or using alias
update-profile

# Force reinstall
Update-ProfileCore -Force
```

#### Option 2: Manual Update

```powershell
# Download latest installer
$url = "https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1"
Invoke-RestMethod $url | Invoke-Expression

# Or download and run
Invoke-WebRequest $url -OutFile install.ps1
.\install.ps1
```

**What's Preserved:**

- ✅ Your configuration files
- ✅ Custom plugins
- ✅ Environment variables
- ✅ Existing aliases and functions

**What's New:**

- ✅ v6 DI services automatically initialized
- ✅ ProfileCore.Common automatically installed
- ✅ Rust binary available (if compiled)
- ✅ Backward compatibility maintained

### For Developers (Custom Scripts/Plugins)

#### 1. Update Output Functions

**Before (v5):**

```powershell
Write-Host "╔═══════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       My Module v1.0.0        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════╝" -ForegroundColor Cyan

Write-Host "[OK] Success" -ForegroundColor Green
Write-Host "[ERROR] Failed" -ForegroundColor Red
```

**After (v6):**

```powershell
# Import shared library
Import-Module ProfileCore.Common -ErrorAction Stop

# Use shared functions
Write-BoxHeader "My Module v1.0.0" -Width 40 -Color Cyan
Write-Success "Success"
Write-ErrorMsg "Failed"
```

#### 2. Update Installation Logic

**Before (v5):**

```powershell
# Manual connectivity check
try {
    $null = Invoke-WebRequest "https://api.github.com" -TimeoutSec 5
    $githubOK = $true
} catch {
    $githubOK = $false
}

# Manual command check
$gitExists = Get-Command git -ErrorAction SilentlyContinue
```

**After (v6):**

```powershell
Import-Module ProfileCore.Common

# Use helper functions
$githubOK = Test-GitHubConnectivity -Timeout 5000
$gitExists = Test-Prerequisites @('git')

# With retry logic
Invoke-WithRetry -ScriptBlock {
    # Your installation logic
} -MaxAttempts 3 -BaseDelay 1000
```

#### 3. Use v6 DI Services

**For Module Developers:**

```powershell
# Get services from DI container
function MyCommand {
    [CmdletBinding()]
    param()

    # Resolve services
    $cache = Resolve-Service 'CacheManager'
    $config = Resolve-Service 'ConfigurationManager'
    $metrics = Resolve-Service 'PerformanceMetricsManager'

    # Use services
    $cachedValue = $cache.Get('mykey')
    $setting = $config.Get('MySetting')
    $metrics.StartOperation('MyOperation')

    # Your logic here

    $metrics.EndOperation('MyOperation')
}
```

**Service Creation:**

```powershell
# Create new service
class MyService {
    [string]$Name

    MyService([string]$name) {
        $this.Name = $name
    }

    [void]DoWork() {
        Write-Verbose "Working on $($this.Name)"
    }
}

# Register service
$provider = Get-ServiceProvider
$provider.RegisterSingleton('MyService', [MyService]::new('MyApp'))

# Resolve and use
$myService = Resolve-Service 'MyService'
$myService.DoWork()
```

#### 4. Use Rust CLI in Scripts

```powershell
# Check if Rust CLI is available
if (Get-Command profilecore -ErrorAction SilentlyContinue) {
    # Use Rust CLI for performance
    $systemInfo = profilecore system info --format json | ConvertFrom-Json
    $diskInfo = profilecore system disk --format json | ConvertFrom-Json

    Write-Host "OS: $($systemInfo.os_name)"
    Write-Host "Disk: $($diskInfo[0].mount_point)"
} else {
    # Fallback to PowerShell commands
    $systemInfo = Get-SystemInfo
}
```

## Backward Compatibility

### v5 Functions Still Work ✅

All v5 public functions are still available:

```powershell
# These still work in v6
Get-SystemInfo
Get-PublicIP
Test-Port 443
Install-CrossPlatformPackage git
Get-Helper
```

### v5 Private Functions ⚠️

Some v5 private functions are deprecated but still loaded for compatibility:

- `OSDetection.ps1` - Still loaded in v6 for backward compatibility
- `SecretManager.ps1` - Still loaded in v6
- `OSAbstraction.ps1` - Still loaded in v6

**Migration Recommended:**

```powershell
# Old way (still works)
$isWindows = Test-IsWindows

# New way (v6 DI)
$osProvider = Resolve-Service 'OSProvider'
$isWindows = $osProvider.IsWindows()
```

## Breaking Changes

### 1. Module Dependencies

**v6 Requires:**

- `ProfileCore.Common` module (automatically installed)
- PowerShell 5.1+ (unchanged)

**Update Manifest:**

```powershell
# ProfileCore.psd1
RequiredModules = @('ProfileCore.Common')
```

### 2. Deprecated Modules

These modules no longer exist as standalone modules:

- `ProfileCore.Binary` → Use `modules/ProfileCore/rust-binary/`
- `ProfileCore.Performance` → Functions now in main module
- `ProfileCore.PackageManagement` → Functions now in main module

**Migration:**

```powershell
# Old imports (v5)
Import-Module ProfileCore.Performance
Import-Module ProfileCore.PackageManagement

# New (v6) - just import ProfileCore
Import-Module ProfileCore  # Performance & PackageManagement included
```

### 3. Service Initialization

**v5:**

```powershell
# Services were created directly
$cache = New-Object ConfigCache
```

**v6:**

```powershell
# Services come from DI container
$cache = Resolve-Service 'CacheManager'
```

## Rust Binary Installation

### Automatic (Recommended)

The Rust binary is automatically built and installed if Rust toolchain is detected:

```powershell
# Check if Rust binary is available
$global:ProfileCore.RustBinary

# Check binary location
Get-Command profilecore
```

### Manual Build

```powershell
# Navigate to Rust source
cd modules/ProfileCore-rs

# Build release binary
cargo build --release --bin profilecore

# Binary location
# Windows: target/release/profilecore.exe
# Linux/macOS: target/release/profilecore

# Copy to PATH (optional)
# Windows
Copy-Item target/release/profilecore.exe C:\Windows\System32\

# Linux/macOS
sudo cp target/release/profilecore /usr/local/bin/
```

### Cross-Compilation

```powershell
# Build for all platforms
.\scripts\build\build-rust-all.ps1

# Outputs:
# - Windows: target/x86_64-pc-windows-msvc/release/profilecore.exe
# - Linux: target/x86_64-unknown-linux-gnu/release/profilecore
# - macOS Intel: target/x86_64-apple-darwin/release/profilecore
# - macOS ARM: target/aarch64-apple-darwin/release/profilecore
```

## Testing Your Migration

### 1. Check Module Load

```powershell
# Restart PowerShell
pwsh

# Verify ProfileCore loads
Get-Module ProfileCore -ListAvailable

# Check version
$global:ProfileCore.Version  # Should be "5.2.0" or "6.0.0"
$global:ProfileCore.Architecture  # Should be "v6-DI"
```

### 2. Test v6 Services

```powershell
# Test service resolution
Resolve-Service 'CacheManager'
Resolve-Service 'ConfigurationManager'
Resolve-Service 'PerformanceMetricsManager'

# All should return service objects
```

### 3. Test ProfileCore.Common

```powershell
# Test output functions
Write-BoxHeader "Test Header" -Width 40
Write-Success "Success test"
Write-Info "Info test"

# Test helpers
Test-GitHubConnectivity
Test-Prerequisites @('git', 'pwsh')
```

### 4. Test Rust CLI (if available)

```bash
# Test CLI
profilecore --version
profilecore --help

# Test commands
profilecore system info
profilecore network stats
profilecore helper test-github
```

## Performance Improvements

### v6 vs v5 Benchmarks

| Operation              | v5 (PowerShell) | v6 (Rust) | Speedup |
| ---------------------- | --------------- | --------- | ------- |
| Box header generation  | 2.5ms           | 0.07ms    | 36x     |
| Progress bar format    | 1.8ms           | 0.09ms    | 20x     |
| GitHub connectivity    | 150ms           | 45ms      | 3.3x    |
| System info collection | 85ms            | 12ms      | 7x      |

**Cache Performance:**

- Config cache hit: 38x faster than file read
- Command lookup: 5x faster with dashmap

**Startup Time:**

- v5: ~250ms average
- v6: ~180ms average (28% faster)

## Troubleshooting

### Issue: "ProfileCore.Common module not found"

**Solution:**

```powershell
# Reinstall ProfileCore
Update-ProfileCore -Force

# Or manually install Common module
git clone https://github.com/mythic3011/ProfileCore
cd ProfileCore
Copy-Item modules/ProfileCore.Common $env:PSModulePath.Split(';')[0] -Recurse
```

### Issue: "Unable to find type [ServiceLocator]"

**Cause:** v6 DI not fully initialized

**Solution:**

```powershell
# Check architecture
$global:ProfileCore.Architecture  # Should be "v6-DI"

# If "v5-stable", check for errors
Import-Module ProfileCore -Verbose

# Force v6 initialization
Remove-Module ProfileCore
$env:PROFILECORE_FORCE_V6 = "true"
Import-Module ProfileCore
```

### Issue: "Rust binary not found"

**Not Critical:** Rust binary is optional. ProfileCore works without it.

**To Install:**

```powershell
# Install Rust
winget install Rustlang.Rustup  # Windows
# or
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  # Linux/macOS

# Build binary
cd modules/ProfileCore-rs
cargo build --release --bin profilecore

# Add to PATH
# (see Rust Binary Installation section above)
```

### Issue: "Get-Helper shows 0 commands"

**Cause:** Command registry not initialized

**Solution:**

```powershell
# Explicitly load ProfileCore
Import-Module ProfileCore -Force

# Re-register commands
if (Get-Command Register-CoreCommands -ErrorAction SilentlyContinue) {
    Register-CoreCommands
}

# Verify
Get-Helper
```

## Rollback to v5 (If Needed)

If you encounter issues with v6, you can temporarily rollback:

```powershell
# Uninstall v6
Remove-Module ProfileCore
Uninstall-Module ProfileCore -AllVersions

# Install v5.1.0 from PSGallery (when published)
Install-Module ProfileCore -RequiredVersion 5.1.0

# Or use git to checkout v5.1.0 tag
git clone https://github.com/mythic3011/ProfileCore -b v5.1.0
cd ProfileCore
.\scripts\installation\install.ps1
```

**Note:** v5 will not receive new features, only critical bug fixes.

## Getting Help

### Documentation

- **Architecture:** `docs/architecture/`
- **Developer Guides:** `docs/developer/`
- **User Guides:** `docs/user-guide/`

### Commands

```powershell
Get-Helper                    # Command reference
Get-Helper -Detailed          # Detailed help
Get-Command -Module ProfileCore  # All module commands
```

### Support

- **GitHub Issues:** https://github.com/mythic3011/ProfileCore/issues
- **Discussions:** https://github.com/mythic3011/ProfileCore/discussions

## Next Steps

1. **Update to v6:** Run `Update-ProfileCore`
2. **Test Your Setup:** Follow "Testing Your Migration" section
3. **Update Custom Scripts:** Migrate to ProfileCore.Common functions
4. **Try Rust CLI:** Explore `profilecore` commands
5. **Read New Docs:** Check `docs/developer/V6_ARCHITECTURE.md`

## Summary

v6 is a major upgrade focused on:

- ✅ **Better Architecture:** DI pattern, loose coupling
- ✅ **Shared Libraries:** Reduce duplication, easier maintenance
- ✅ **Performance:** Rust integration, intelligent caching
- ✅ **Cross-Shell Support:** Single CLI for all shells
- ✅ **Backward Compatibility:** v5 functions still work

**Upgrade today and enjoy a faster, more maintainable PowerShell experience!** 🚀

---

**ProfileCore v6.0.0** - Modern, Fast, Cross-Platform  
**Built with ❤️ using PowerShell & Rust** 🦀
