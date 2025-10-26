# ProfileCore Global Variables Documentation

**Last Updated**: 2025-01-11  
**Module Version**: v5.0.0  
**Total Global Variable References**: 156

---

## Overview

ProfileCore uses global variables sparingly and intentionally to maintain module state across PowerShell sessions. This document explains each global variable's purpose, lifecycle, and best practices for usage.

---

## Global Variable Hierarchy

```
$global:ProfileCore (Root State Container)
├── .PluginManager       - Plugin system state
├── .Cache               - Performance caching system
├── .Config              - Configuration management
├── .Logger              - Logging system
├── .PerformanceOptimizer - Performance monitoring & optimization
├── .SyncManager         - Cloud synchronization state
└── .UpdateManager       - Update tracking & management
```

---

## 1. `$global:ProfileCore`

### Purpose

**Main module state container** - Root hashtable that holds all ProfileCore subsystems.

### Location

- Initialized in: `ProfileCore.psm1` (module load)
- Used across: All public and private functions

### Lifecycle

- **Created**: During module import
- **Exists**: Throughout PowerShell session
- **Destroyed**: When PowerShell session ends or module is removed

### Structure

```powershell
$global:ProfileCore = @{
    PluginManager = [PluginManager]::new()
    Cache = [CacheProvider]::new()
    Config = @{...}
    Logger = [LoggingProvider]::new()
    PerformanceOptimizer = [PerformanceOptimizer]::new()
    SyncManager = [CloudSyncManager]::new()
    UpdateManager = [UpdateManager]::new()
}
```

### Usage Pattern

```powershell
# Check if initialized
if (-not $global:ProfileCore) {
    $global:ProfileCore = @{}
}

# Access subsystems
$cache = $global:ProfileCore.Cache
$plugins = $global:ProfileCore.PluginManager
```

### Occurrences

**66 references** across 16 files

### Why Global?

- **Persistence**: State must survive across function calls
- **Performance**: Avoid re-initialization overhead
- **Sharing**: Multiple functions need access to same state
- **Caching**: Expensive operations cached for session lifetime

---

## 2. `$global:ProfileCore.PluginManager`

### Purpose

**Plugin system state management** - Tracks loaded plugins, their metadata, and lifecycle.

### Location

- Initialized in: `PluginManagement.ps1` → `Initialize-ProfileCorePluginSystem`
- Used in: `PluginManagement.ps1` (12 functions)

### Lifecycle

- **Created**: On first plugin operation or explicit initialization
- **Updated**: When plugins are loaded/unloaded
- **Persisted**: Throughout session

### Structure

```powershell
[PluginManager] {
    LoadedPlugins = @{}        # Name → Plugin instance
    PluginPaths = @()          # Discovered plugin paths
    EnabledPlugins = @()       # Auto-load list
}
```

### Usage Pattern

```powershell
# Initialize
if (-not $global:ProfileCore.PluginManager) {
    $global:ProfileCore.PluginManager = [PluginManager]::new()
}

# Use
$manager = $global:ProfileCore.PluginManager
$manager.LoadPlugin("MyPlugin")
```

### Occurrences

**14 references** in `PluginManagement.ps1`

### Why Global?

- Plugins must remain loaded across function calls
- State tracking for enabled/disabled plugins
- Prevent duplicate plugin loading

---

## 3. `$global:ProfileCore.PerformanceOptimizer`

### Purpose

**Performance monitoring and optimization** - Tracks metrics, profiling data, and optimization state.

### Location

- Initialized in: `AdvancedPerformanceCommands.ps1`
- Used in: `AdvancedPerformanceCommands.ps1`, `PerformanceAnalytics.ps1`

### Lifecycle

- **Created**: On first performance operation
- **Updated**: Continuously during profiling
- **Cleared**: Via `Clear-ProfileCorePerformanceCache`

### Structure

```powershell
[PerformanceOptimizer] {
    Profiler = [ProfilerEngine]::new()
    Cache = [CacheProvider]::new()
    Metrics = @{}              # Performance measurements
    Optimizations = @{}        # Applied optimizations
}
```

### Usage Pattern

```powershell
# Start profiling
$global:ProfileCore.PerformanceOptimizer.Profiler.StartRecording()

# Get report
$report = $global:ProfileCore.PerformanceOptimizer.GetOptimizationReport()

# Clear cache
$global:ProfileCore.PerformanceOptimizer.Cache.Clear()
```

### Occurrences

**20 references** in `AdvancedPerformanceCommands.ps1`

### Why Global?

- Profiling must span multiple operations
- Cache persists across function calls for performance
- Metrics accumulated over session lifetime

---

## 4. `$global:ProfileCore.SyncManager`

### Purpose

**Cloud synchronization state** - Manages sync providers (GitHub Gist, etc.) and sync operations.

### Location

- Initialized in: `CloudSyncCommands.ps1` → `Enable-ProfileCoreSync`
- Used in: `CloudSyncCommands.ps1` (10 functions)

### Lifecycle

- **Created**: When cloud sync is enabled
- **Updated**: During sync operations (push/pull)
- **Destroyed**: When sync is disabled

### Structure

```powershell
[CloudSyncManager] {
    SyncProvider = [GitHubGistProvider]::new()
    SyncConfig = @{
        GistId = "..."
        LastSync = [DateTime]
        AutoSync = $false
    }
}
```

### Usage Pattern

```powershell
# Enable sync
if (-not $global:ProfileCore.SyncManager) {
    $global:ProfileCore.SyncManager = [CloudSyncManager]::new()
}
$global:ProfileCore.SyncManager.SetProvider($provider)

# Sync operations
$global:ProfileCore.SyncManager.Push()
$global:ProfileCore.SyncManager.Pull()

# Check status
$status = $global:ProfileCore.SyncManager.GetStatus()
```

### Occurrences

**14 references** in `CloudSyncCommands.ps1`

### Why Global?

- Sync state must persist across sync operations
- Provider configuration maintained for session
- Last sync timestamp tracking

---

## 5. `$global:ProfileCore.UpdateManager`

### Purpose

**Module update management** - Tracks update checks, auto-update settings, and version information.

### Location

- Initialized in: `CloudSyncCommands.ps1` → `Get-ProfileCoreHealth`
- Used in: `CloudSyncCommands.ps1` (4 functions)

### Lifecycle

- **Created**: On first health check or update operation
- **Updated**: During update checks
- **Persisted**: Auto-update settings saved to config file

### Structure

```powershell
[UpdateManager] {
    UpdateConfig = @{
        AutoUpdate = $false
        Schedule = "Weekly"
        LastCheck = [DateTime]
    }
    LatestVersion = "..."
}
```

### Usage Pattern

```powershell
# Initialize
if (-not $global:ProfileCore.UpdateManager) {
    $global:ProfileCore.UpdateManager = [UpdateManager]::new()
}

# Check for updates
$updateInfo = $global:ProfileCore.UpdateManager.CheckForUpdates()

# Configure auto-update
$global:ProfileCore.UpdateManager.UpdateConfig.AutoUpdate = $true
$global:ProfileCore.UpdateManager.SaveUpdateConfig()
```

### Occurrences

**10 references** in `CloudSyncCommands.ps1`

### Why Global?

- Last check timestamp must persist
- Auto-update settings maintained across sessions
- Prevents duplicate update checks

---

## 6. `$global:ProfileCore.Cache`

### Purpose

**General-purpose caching system** - Stores expensive operation results with TTL support.

### Location

- Initialized in: `ProfileCore.psm1` (module load)
- Used in: `CacheManagement.ps1`, `CacheProvider.ps1`

### Lifecycle

- **Created**: During module initialization
- **Updated**: Continuously as cache operations occur
- **Cleared**: Manually via `Clear-ProfileCoreCache` or on TTL expiration

### Structure

```powershell
[CacheProvider] {
    Cache = @{}                # Key → CacheEntry
    Stats = @{
        Hits = 0
        Misses = 0
        Evictions = 0
    }
}

[CacheEntry] {
    Value = ...
    Timestamp = [DateTime]
    TTL = [TimeSpan]
}
```

### Usage Pattern

```powershell
# Set cache
$global:ProfileCore.Cache.Set("key", $value, 300)  # 5 min TTL

# Get cache
$cached = $global:ProfileCore.Cache.Get("key")

# Check existence
$exists = $global:ProfileCore.Cache.Contains("key")

# Clear
$global:ProfileCore.Cache.Clear()
```

### Occurrences

**10 references** in `CacheProvider.ps1`, `CacheManagement.ps1`

### Why Global?

- Cache must persist across function calls
- Performance optimization requires session-level caching
- Stats tracking for monitoring

---

## 7. `$global:ProfileCore.Logger`

### Purpose

**Logging system** - Centralized logging with file and console output.

### Location

- Initialized in: `ProfileCore.psm1` (module load)
- Used in: `LogManagement.ps1`, `LoggingProvider.ps1`

### Lifecycle

- **Created**: During module initialization
- **Updated**: As log entries are written
- **Persisted**: Log files written to disk

### Structure

```powershell
[LoggingProvider] {
    LogFile = "..."
    LogLevel = "Information"
    MaxLogSize = 10MB
    EnabledSinks = @("File", "Console")
}
```

### Usage Pattern

```powershell
# Write logs
$global:ProfileCore.Logger.LogInformation("Message")
$global:ProfileCore.Logger.LogError("Error", $exception)

# Configure
$global:ProfileCore.Logger.SetLogLevel("Debug")
$global:ProfileCore.Logger.EnableSink("File")
```

### Occurrences

**8 references** in `LoggingProvider.ps1`, `LogManagement.ps1`

### Why Global?

- Centralized logging across all modules
- Log file handle must persist
- Configuration applies to entire session

---

## 8. `$global:ProfileCore.Config`

### Purpose

**Module configuration** - User settings, preferences, and environment-specific config.

### Location

- Initialized in: `ProfileCore.psm1` (module load)
- Used in: `ConfigurationManagement.ps1`, `ConfigLoader.ps1`

### Lifecycle

- **Created**: Module load (reads from config file)
- **Updated**: Via `Update-ProfileConfiguration`
- **Saved**: To `powershell.config.json`

### Structure

```powershell
@{
    Paths = @{...}
    Aliases = @{...}
    Plugins = @{...}
    Performance = @{...}
}
```

### Usage Pattern

```powershell
# Access config
$paths = $global:ProfileCore.Config.Paths
$aliases = $global:ProfileCore.Config.Aliases

# Update config
$global:ProfileCore.Config.Performance.CacheSize = "100MB"
Save-ProfileCoreConfig
```

### Occurrences

**12 references** across configuration modules

### Why Global?

- Configuration must be accessible everywhere
- Avoids repeated file reads
- Single source of truth for settings

---

## 9. `$global:ProgressPreference`

### Purpose

**PowerShell built-in preference** - Controls progress bar visibility.

### Location

- Modified in: `PerformanceMonitor.ps1` → `Optimize-ProfileCoreStartup`
- Used in: Performance optimization features

### Lifecycle

- **Exists**: PowerShell built-in variable
- **Modified**: By ProfileCore for performance
- **Reset**: Can be reset by user

### Typical Values

- `'SilentlyContinue'` - No progress bars (faster)
- `'Continue'` - Show progress bars (default, slower)

### Usage Pattern

```powershell
# Disable for performance
$global:ProgressPreference = 'SilentlyContinue'

# Check setting
if (-not $global:ProgressPreference -eq 'SilentlyContinue') {
    Write-Warning "Progress bars enabled (slower)"
}
```

### Occurrences

**2 references** in `PerformanceMonitor.ps1`

### Why Global?

- PowerShell built-in preference variable
- Must be global to affect all cmdlets
- Session-wide performance optimization

---

## Best Practices

### ✅ DO

1. **Always check existence before access**

   ```powershell
   if (-not $global:ProfileCore) {
       $global:ProfileCore = @{}
   }
   ```

2. **Use lazy initialization**

   ```powershell
   if (-not $global:ProfileCore.PluginManager) {
       $global:ProfileCore.PluginManager = [PluginManager]::new()
   }
   ```

3. **Document global usage in function comments**

   ```powershell
   <#
   .NOTES
       Uses $global:ProfileCore.Cache for performance
   #>
   ```

4. **Clean up when appropriate**
   ```powershell
   function Disable-Feature {
       $global:ProfileCore.Feature = $null
   }
   ```

### ❌ DON'T

1. **Don't create new top-level globals**

   ```powershell
   # ❌ BAD
   $global:MyModuleState = @{}

   # ✅ GOOD
   $global:ProfileCore.MyFeature = @{}
   ```

2. **Don't bypass the global state**

   ```powershell
   # ❌ BAD - creates duplicate state
   $localCache = [CacheProvider]::new()

   # ✅ GOOD - uses global cache
   $cache = $global:ProfileCore.Cache
   ```

3. **Don't assume initialization**

   ```powershell
   # ❌ BAD - may fail
   $global:ProfileCore.PluginManager.LoadPlugin("X")

   # ✅ GOOD - checks first
   if ($global:ProfileCore -and $global:ProfileCore.PluginManager) {
       $global:ProfileCore.PluginManager.LoadPlugin("X")
   }
   ```

4. **Don't use globals for temporary data**

   ```powershell
   # ❌ BAD
   $global:TempResult = Process-Data

   # ✅ GOOD
   $script:TempResult = Process-Data
   ```

---

## Initialization Flow

```
Module Import (ProfileCore.psm1)
    ↓
Initialize $global:ProfileCore = @{}
    ↓
Create Core Subsystems:
    ├── Logger (LoggingProvider)
    ├── Cache (CacheProvider)
    └── Config (ConfigurationProvider)
    ↓
Lazy Initialize on First Use:
    ├── PluginManager (first plugin operation)
    ├── PerformanceOptimizer (first performance operation)
    ├── SyncManager (when sync enabled)
    └── UpdateManager (first update check)
```

---

## Cleanup & Memory Management

### Session End

All global variables are automatically cleaned up when PowerShell session ends.

### Manual Cleanup

```powershell
# Remove module (cleans up globals)
Remove-Module ProfileCore -Force

# Clear specific subsystems
$global:ProfileCore.Cache.Clear()
$global:ProfileCore.PluginManager.UnloadAllPlugins()
```

### Memory Footprint

Typical memory usage:

- **Base state**: ~2-5 MB
- **With plugins**: +1-2 MB per plugin
- **With cache**: Varies by cached data (configurable limit)
- **Total typical**: 5-15 MB

---

## Migration Guide

### If You Need to Refactor Away from Globals

**Option 1: Dependency Injection**

```powershell
function Do-Something {
    param(
        [Parameter(Mandatory)]
        [CacheProvider]$Cache,

        [Parameter(Mandatory)]
        [LoggingProvider]$Logger
    )

    # Use injected dependencies instead of globals
}
```

**Option 2: Module-Scoped Variables**

```powershell
# In .psm1 file
$script:ModuleState = @{}

function Get-ModuleState {
    return $script:ModuleState
}
```

**Option 3: Singleton Pattern**

```powershell
class ProfileCoreState {
    static [ProfileCoreState]$Instance

    static [ProfileCoreState] Get() {
        if (-not [ProfileCoreState]::Instance) {
            [ProfileCoreState]::Instance = [ProfileCoreState]::new()
        }
        return [ProfileCoreState]::Instance
    }
}
```

---

## Debugging Global Variables

### List All ProfileCore Globals

```powershell
Get-Variable -Scope Global | Where-Object Name -like "*ProfileCore*"
```

### Inspect State

```powershell
# Full state
$global:ProfileCore | ConvertTo-Json -Depth 3

# Specific subsystem
$global:ProfileCore.PluginManager | Format-List *

# Cache stats
$global:ProfileCore.Cache.GetStats()
```

### Monitor Changes

```powershell
# Watch for changes
$watcher = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -Action {
    $global:ProfileCore | ConvertTo-Json | Out-File "state-snapshot.json"
}
```

---

## Performance Considerations

### Pros of Global State

- ✅ **Fast access**: No parameter passing overhead
- ✅ **Caching**: Expensive operations cached for session
- ✅ **Persistence**: State survives across function calls
- ✅ **Simplicity**: No complex dependency injection

### Cons of Global State

- ❌ **Testing**: Harder to unit test (requires cleanup)
- ❌ **Coupling**: Functions coupled to global state
- ❌ **Thread safety**: Not thread-safe by default
- ❌ **Namespace pollution**: Multiple modules may conflict

### Our Approach

ProfileCore mitigates cons by:

1. **Single namespace**: All state under `$global:ProfileCore`
2. **Lazy initialization**: Only create what's needed
3. **Public API**: Test through public functions
4. **Documentation**: This file! Clear usage patterns

---

## Summary Statistics

| Category                 | Count   | Purpose                                       |
| ------------------------ | ------- | --------------------------------------------- |
| **Root Container**       | 66      | `$global:ProfileCore` initialization & checks |
| **PluginManager**        | 14      | Plugin system state management                |
| **PerformanceOptimizer** | 20      | Performance monitoring & optimization         |
| **SyncManager**          | 14      | Cloud sync state                              |
| **UpdateManager**        | 10      | Update tracking                               |
| **Cache**                | 10      | Performance caching                           |
| **Logger**               | 8       | Centralized logging                           |
| **Config**               | 12      | Configuration management                      |
| **ProgressPreference**   | 2       | PowerShell performance optimization           |
| **TOTAL**                | **156** | Global variable references                    |

---

## Conclusion

Global variables in ProfileCore are used **intentionally and sparingly** for legitimate use cases:

- **State persistence** across session
- **Performance optimization** via caching
- **Shared subsystems** (plugins, logging, sync)

All globals are documented, initialized lazily, and follow consistent patterns. This approach balances performance, usability, and maintainability.

For questions or improvements, see `docs/development/contributing.md`.

---

**Document maintained by**: ProfileCore Development Team  
**Next Review**: With each major version release
