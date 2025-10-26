# ProfileCore v5 to v6 Architecture Migration Guide

**Last Updated:** 2025-10-26  
**Target Audience:** Plugin Developers, Contributors, Advanced Users

---

## Overview

ProfileCore v5.2.0 introduces the v6 dependency injection (DI) architecture while maintaining backward compatibility with v5. This guide helps you migrate custom code, plugins, and scripts to use the new v6 architecture.

## Deprecation Timeline

| Version    | Status                        | Notes                               |
| ---------- | ----------------------------- | ----------------------------------- |
| **v5.2.0** | v5 deprecated, warnings added | v6 available, v5 fallback supported |
| **v5.3.0** | v5 removed                    | v6 mandatory, breaking changes      |
| **v6.0.0** | Full v6 release               | Complete DI architecture            |

## What's Changing

### Module Structure

**V5 (Deprecated):**

```
modules/ProfileCore/
├── private/           ← DEPRECATED
│   ├── OSDetection.ps1
│   ├── CacheProvider.ps1
│   └── ...
├── public/
└── ProfileCore.psm1  (imports private/)
```

**V6 (Current):**

```
modules/ProfileCore/
├── private-v6/        ← USE THIS
│   ├── core/
│   │   ├── Bootstrap.ps1
│   │   ├── DependencyInjection.ps1
│   │   └── ServiceRegistration.ps1
│   ├── interfaces/
│   ├── providers/
│   └── ...
├── public/
└── ProfileCore.psm1  (imports private-v6/core/Bootstrap.ps1)
```

### Key Differences

| Aspect            | V5               | V6                         |
| ----------------- | ---------------- | -------------------------- |
| **Architecture**  | Procedural       | Dependency Injection       |
| **Loading**       | Import all files | Lazy loading via Bootstrap |
| **Dependencies**  | Global variables | DI Container               |
| **Testing**       | Difficult        | Easy with interfaces       |
| **Extensibility** | Limited          | Plugin-based               |

## Migration Steps

### 1. Update Module Imports

**Before (V5):**

```powershell
# Direct function calls from private/
Import-Module ProfileCore
$os = Get-OperatingSystem  # From private/OSDetection.ps1
```

**After (V6):**

```powershell
# Use DI container
Import-Module ProfileCore
$osProvider = Get-Service 'IOperatingSystem'
$os = $osProvider.GetOperatingSystem()
```

### 2. Migrate Custom Functions

**Before (V5):**

```powershell
# Custom function using v5 pattern
function My-CustomFunction {
    $os = Get-OperatingSystem
    $cache = $global:ProfileCore.Cache
    # ... rest of function
}
```

**After (V6):**

```powershell
# Custom function using v6 DI pattern
function My-CustomFunction {
    [CmdletBinding()]
    param(
        [Parameter()]
        $OSProvider = (Get-Service 'IOperatingSystem'),

        [Parameter()]
        $CacheProvider = (Get-Service 'ICacheProvider')
    )

    $os = $OSProvider.GetOperatingSystem()
    $cacheValue = $CacheProvider.Get('mykey')
    # ... rest of function
}
```

### 3. Update Plugin Code

**Before (V5):**

```powershell
# Plugin using global variables
$pluginConfig = $global:ProfileCore.Config
$pluginCache = $global:ProfileCore.Cache
```

**After (V6):**

```powershell
# Plugin using DI container
$configProvider = Get-Service 'IConfigProvider'
$cacheProvider = Get-Service 'ICacheProvider'
$pluginConfig = $configProvider.Get('plugin-settings')
$pluginCache = $cacheProvider.Get('plugin-cache-key')
```

### 4. Migrate Scripts Using Shared Utilities

**Before (V5):**

```powershell
# Script with duplicate Write-BoxHeader function
function Write-BoxHeader {
    param([string]$Message)
    # ... implementation
}
Write-BoxHeader "My Script"
```

**After (V6):**

```powershell
# Script using ProfileCore.Common
Import-Module ProfileCore.Common
Write-BoxHeader "My Script"  # Function from Common module
```

## Available Services in V6

Access services via `Get-Service '<ServiceName>'`:

| Service Interface | Purpose                  | Example                                    |
| ----------------- | ------------------------ | ------------------------------------------ |
| `ICacheProvider`  | Caching operations       | `$cache = Get-Service 'ICacheProvider'`    |
| `ILogProvider`    | Logging operations       | `$logger = Get-Service 'ILogProvider'`     |
| `IConfigProvider` | Configuration management | `$config = Get-Service 'IConfigProvider'`  |
| `IPackageManager` | Package operations       | `$pkgMgr = Get-Service 'IPackageManager'`  |
| `IUpdateProvider` | Update management        | `$updater = Get-Service 'IUpdateProvider'` |
| `IPluginManager`  | Plugin system            | `$plugins = Get-Service 'IPluginManager'`  |
| `ISystemInfo`     | System information       | `$sysInfo = Get-Service 'ISystemInfo'`     |

## ProfileCore.Common Module

New in v5.2.0, the `ProfileCore.Common` module provides shared utilities:

### Output Helpers

```powershell
Write-BoxHeader "My Header" -Color Cyan
Write-Step "Processing..." -Quiet:$Quiet
Write-Success "Complete!" -Quiet:$Quiet
Write-Info "Information" -Quiet:$Quiet
Write-Warn "Warning" -Quiet:$Quiet
Write-Fail "Error" -Quiet:$Quiet
Write-InstallProgress "Installing..." -Percent 50
```

### Installation Helpers

```powershell
# Test GitHub connectivity
if (Test-GitHubConnectivity) { ... }

# Get user confirmation
$confirmed = Get-UserConfirmation "Continue?" -Default $true -NonInteractive:$false

# Test prerequisites
Test-Prerequisites -ThrowOnError -Quiet:$Quiet

# Retry logic
Invoke-WithRetry { Install-Package MyPackage } -MaxAttempts 3
```

## Common Migration Scenarios

### Scenario 1: Custom Cache Function

**Before:**

```powershell
function Get-MyData {
    if ($global:ProfileCore.Cache.ContainsKey('mydata')) {
        return $global:ProfileCore.Cache['mydata']
    }
    # ... fetch data
    $global:ProfileCore.Cache['mydata'] = $data
    return $data
}
```

**After:**

```powershell
function Get-MyData {
    param($CacheProvider = (Get-Service 'ICacheProvider'))

    $cached = $CacheProvider.Get('mydata')
    if ($cached) { return $cached }

    # ... fetch data
    $CacheProvider.Set('mydata', $data, 3600)  # 1 hour TTL
    return $data
}
```

### Scenario 2: Installation Script

**Before:**

```powershell
# Installation script with custom functions
function Write-Step { ... }
function Write-Success { ... }
function Test-Prerequisites { ... }

Write-Step "Installing..."
Test-Prerequisites
Write-Success "Done!"
```

**After:**

```powershell
# Installation script using Common module
Import-Module ProfileCore.Common

Write-Step "Installing..." -Quiet:$Quiet
Test-Prerequisites -ThrowOnError
Write-Success "Done!" -Quiet:$Quiet
```

### Scenario 3: Plugin Development

**Before:**

```powershell
# V5 Plugin
$plugin = @{
    Name = "MyPlugin"
    Init = {
        $global:MyPluginData = @{}
    }
    Commands = @{
        'my-command' = {
            $global:MyPluginData['key'] = 'value'
        }
    }
}
```

**After:**

```powershell
# V6 Plugin with DI
class MyPlugin : IPlugin {
    [string] $Name = "MyPlugin"
    [hashtable] $Services

    MyPlugin([hashtable]$services) {
        $this.Services = $services
    }

    [void] Initialize() {
        $cache = $this.Services['ICacheProvider']
        $cache.Set('myplugin:key', 'value', 3600)
    }
}
```

## Backward Compatibility

### V5 Fallback Mode

If v6 Bootstrap fails to load, ProfileCore automatically falls back to v5 compatibility mode:

```powershell
# ProfileCore.psm1 automatic fallback
try {
    . $bootstrapPath  # Load v6
    Initialize-ProfileCoreV6
} catch {
    Write-Warning "Falling back to v5 compatibility mode"
    # Loads critical v5 files
}
```

### Deprecation Warnings

When running v5 code in v5.2.0, you'll see warnings:

```
WARNING: [DEPRECATED] Loading v5 private/ directory. This will be removed in v5.3.0
WARNING: [V5-COMPAT] Imported OSDetection.ps1
```

## Testing Your Migration

### 1. Test Module Loading

```powershell
Import-Module ProfileCore -Force -Verbose
# Should see: "ProfileCore v6 architecture initialized"
```

### 2. Test DI Container

```powershell
$cache = Get-Service 'ICacheProvider'
$cache.Set('test', 'value', 60)
$result = $cache.Get('test')
# Should return: 'value'
```

### 3. Test Common Module

```powershell
Import-Module ProfileCore.Common -Force
Write-BoxHeader "Test" -Color Green
# Should display a green box with "Test"
```

## Getting Help

- **Documentation**: `docs/architecture/shared-libraries.md`
- **Examples**: `modules/ProfileCore/private-v6/README.md`
- **Issues**: https://github.com/mythic3011/ProfileCore/issues
- **Discussions**: https://github.com/mythic3011/ProfileCore/discussions

## Summary Checklist

- [ ] Update module imports to use DI container (`Get-Service`)
- [ ] Replace global variable usage with service providers
- [ ] Migrate custom functions to accept service providers as parameters
- [ ] Update plugins to use v6 plugin architecture
- [ ] Replace custom utility functions with ProfileCore.Common
- [ ] Test with v5.2.0 to see deprecation warnings
- [ ] Fix all warnings before v5.3.0 release
- [ ] Update documentation and examples

---

**Need Help?** Open an issue or discussion on GitHub. We're here to help with your migration!
