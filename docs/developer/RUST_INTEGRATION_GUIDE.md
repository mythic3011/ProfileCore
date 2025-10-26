# Rust Integration Guide

## Overview

ProfileCore v6.1.0 includes a high-performance Rust binary module that provides 5-10x performance improvements for system information gathering operations. This guide covers how to use, integrate, and extend the Rust integration.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture](#architecture)
3. [Using Rust Providers](#using-rust-providers)
4. [Fallback Mechanism](#fallback-mechanism)
5. [Performance Characteristics](#performance-characteristics)
6. [Adding New Rust Functions](#adding-new-rust-functions)
7. [Troubleshooting](#troubleshooting)

## Quick Start

### Prerequisites

- PowerShell 7+ (recommended)
- ProfileCore v6.1.0 or later
- Rust binary module (included in distribution)

### Basic Usage

```powershell
# Import ProfileCore
Import-Module ProfileCore

# Check if Rust is available
Test-ProfileCoreRustAvailable
# Returns: $true if Rust binary loaded, $false otherwise

# Get system information (automatically uses Rust if available)
Get-ProfileCoreSystemInfo

# Force Rust implementation
Get-ProfileCoreSystemInfo -UseRust

# Force PowerShell fallback
Get-ProfileCoreSystemInfo -ForceFallback

# View performance metrics
Get-ProfileCoreSystemInfoMetrics
```

### Output Example

```powershell
PS> Get-ProfileCoreSystemInfoMetrics

RustAvailable    : True
RustCalls        : 150
FallbackCalls    : 10
TotalCalls       : 160
RustPercentage   : 93.75
LastCheck        : 2025-10-25 10:30:45
```

## Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────┐
│                  PowerShell Layer                        │
│  (Public Commands, DI Container, Service Providers)      │
└─────────────────────────────┬───────────────────────────┘
                              │
                              │ ISystemInfo Interface
                              ▼
┌─────────────────────────────────────────────────────────┐
│             RustSystemInfoProvider                       │
│  • Implements ISystemInfo interface                      │
│  • Delegates to Rust FFI when available                  │
│  • Falls back to PowerShell when Rust unavailable        │
└─────────────────────────────┬───────────────────────────┘
                              │
                              │ FFI (P/Invoke)
                              ▼
┌─────────────────────────────────────────────────────────┐
│              ProfileCore.Binary Module                   │
│  • PowerShell wrapper for Rust DLL                       │
│  • P/Invoke declarations                                 │
│  • Shadow copy to prevent file locking                   │
└─────────────────────────────┬───────────────────────────┘
                              │
                              │ C ABI
                              ▼
┌─────────────────────────────────────────────────────────┐
│                Rust Binary (DLL/SO/DYLIB)                │
│  • High-performance system operations                    │
│  • `#[no_mangle]` C-compatible exports                   │
│  • Safe Rust with FFI boundary layer                     │
└─────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **ISystemInfo Interface** (`private-v6/interfaces/ISystemInfo.ps1`)

- Defines the contract for system information services
- Ensures consistent API regardless of implementation
- Supports dependency injection

#### 2. **RustSystemInfoProvider** (`private-v6/providers/RustSystemInfoProvider.ps1`)

- Implements `ISystemInfo` interface
- Automatically detects Rust availability at initialization
- Provides transparent fallback to PowerShell
- Tracks performance metrics

#### 3. **ProfileCore.Binary Module** (`modules/ProfileCore.Binary/`)

- PowerShell wrapper for Rust DLL
- Uses shadow copy to prevent file locking
- Provides P/Invoke declarations for all Rust FFI functions
- Platform detection and binary selection

#### 4. **Rust Binary** (`modules/ProfileCore-rs/`)

- Written in safe Rust
- C-compatible FFI exports via `#[no_mangle]`
- High-performance implementations using `sysinfo`, `reqwest`, etc.

## Using Rust Providers

### Via DI Container (Recommended)

```powershell
# Resolve the system info service
$systemInfo = Resolve-Service 'ISystemInfo'

# Use any method from the ISystemInfo interface
$info = $systemInfo.GetSystemInfo()
$platform = $systemInfo.GetPlatformInfo()
$localIP = $systemInfo.GetLocalIP()
$portOpen = $systemInfo.TestPort('google.com', 443, 1000)
```

### Via Public Commands

```powershell
# High-level commands with user-friendly output
Get-ProfileCoreSystemInfo
Get-ProfileCorePlatformInfo
Get-ProfileCoreLocalIP
Test-ProfileCorePort -Host 'google.com' -Port 443
Get-ProfileCoreTopProcesses -Count 10 -SortBy CPU
Show-ProfileCoreSystemDashboard  # Formatted display
```

### Direct Binary Access (Advanced)

```powershell
# Import binary module directly
Import-Module ProfileCore.Binary

# Call Rust functions directly (returns raw JSON)
$json = Get-SystemInfoBinary
$data = $json | ConvertFrom-Json

# Note: Public commands are preferred for production use
```

## Fallback Mechanism

### Automatic Fallback

The `RustSystemInfoProvider` automatically handles Rust unavailability:

```powershell
class RustSystemInfoProvider : ISystemInfo {
    [hashtable] GetSystemInfo() {
        if (-not $this.RustAvailable) {
            return $this.GetFallbackSystemInfo()  # PowerShell impl
        }

        try {
            return Get-SystemInfoBinary  # Rust impl
        } catch {
            $this.Logger.Warning("Rust failed, using fallback")
            return $this.GetFallbackSystemInfo()  # Graceful degradation
        }
    }
}
```

### Fallback Scenarios

Fallback occurs when:

1. **Module Missing**: `ProfileCore.Binary` module not installed
2. **DLL Missing**: Binary file not found for current platform
3. **Load Failure**: DLL fails to load (incompatible architecture, etc.)
4. **Runtime Error**: Rust function throws an error during execution

### Performance Impact

- **Rust Available**: 5-10x faster
- **Fallback Active**: Normal PowerShell performance (still functional)
- **Overhead**: Minimal - fallback check is ~0.1ms

### Monitoring Fallback Usage

```powershell
# Check current status
Test-ProfileCoreRustAvailable

# Get detailed metrics
$metrics = Get-ProfileCoreSystemInfoMetrics
Write-Host "Rust usage: $($metrics.RustPercentage)%"
Write-Host "Fallback calls: $($metrics.FallbackCalls)"
```

## Performance Characteristics

### Benchmark Results

| Operation          | PowerShell | Rust  | Speedup |
| ------------------ | ---------- | ----- | ------- |
| System Info        | 45ms       | 6ms   | 7.5x    |
| Platform Detection | 12ms       | 1.5ms | 8x      |
| Local IP           | 80ms       | 10ms  | 8x      |
| Port Test          | 150ms      | 25ms  | 6x      |

_Based on 1000 iterations on Windows 11, Intel i7-12700K_

### When to Use Rust

✅ **Good Use Cases**:

- High-frequency system info queries
- Performance-critical paths
- Real-time monitoring
- Batch operations (1000+ queries)

❌ **Not Beneficial**:

- One-time queries (overhead > benefit)
- Already cached results
- Network-bound operations (external bottleneck)

### Optimization Tips

1. **Cache Results**: Use ProfileCore's cache system

   ```powershell
   $cache = Resolve-Service 'ICacheProvider'
   $cached = $cache.Get('system-info')
   if (-not $cached) {
       $cached = Get-ProfileCoreSystemInfo
       $cache.Set('system-info', $cached, 300)  # 5 min TTL
   }
   ```

2. **Batch Operations**: Group multiple calls

   ```powershell
   # Efficient: Single call
   $metrics = Get-ProfileCoreSystemInfoMetrics

   # Inefficient: Multiple resolution calls
   $info1 = Get-ProfileCoreSystemInfo
   $info2 = Get-ProfileCoreSystemInfo  # Resolves service again
   ```

3. **Use Service Provider**: Avoid repeated service resolution
   ```powershell
   # Efficient: Reuse service instance
   $systemInfo = Resolve-Service 'ISystemInfo'
   $info1 = $systemInfo.GetSystemInfo()
   $info2 = $systemInfo.GetPlatformInfo()
   $info3 = $systemInfo.GetLocalIP()
   ```

## Adding New Rust Functions

See [RUST_FFI_PATTERNS.md](./RUST_FFI_PATTERNS.md) for detailed instructions.

### Quick Example

1. **Add Rust function** (`modules/ProfileCore-rs/src/cmdlets/mod.rs`):

   ```rust
   #[no_mangle]
   pub extern "C" fn GetProfileMemoryInfo() -> *mut c_char {
       let memory = get_memory_info();
       to_c_string(serde_json::to_string(&memory).unwrap())
   }
   ```

2. **Add P/Invoke** (`modules/ProfileCore.Binary/ProfileCore.psm1`):

   ```powershell
   [DllImport("ProfileCore.dll", CallingConvention = CallingConvention.Cdecl)]
   public static extern IntPtr GetProfileMemoryInfo();

   function Get-MemoryInfoBinary {
       $ptr = [ProfileCoreBinary]::GetProfileMemoryInfo()
       $json = [Marshal]::PtrToStringAnsi($ptr)
       [ProfileCoreBinary]::FreeString($ptr)
       return $json | ConvertFrom-Json
   }
   ```

3. **Add to provider** (`private-v6/providers/RustSystemInfoProvider.ps1`):

   ```powershell
   [hashtable] GetMemoryInfo() {
       if ($this.RustAvailable) {
           return Get-MemoryInfoBinary
       }
       return $this.GetFallbackMemoryInfo()
   }
   ```

4. **Add public command** (`public/RustSystemInfo.ps1`):
   ```powershell
   function Get-ProfileCoreMemoryInfo {
       $systemInfo = Resolve-Service 'ISystemInfo'
       return $systemInfo.GetMemoryInfo()
   }
   ```

## Troubleshooting

### Rust Binary Not Loading

**Symptom**: `Test-ProfileCoreRustAvailable` returns `$false`

**Diagnosis**:

```powershell
# Check if binary module exists
Get-Module -ListAvailable ProfileCore.Binary

# Check for platform-specific binary
$platform = if ($IsWindows) { "windows" } elseif ($IsMacOS) { "macos" } else { "linux" }
$arch = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
Test-Path "modules/ProfileCore.Binary/bin/ProfileCore-$platform-$arch.*"

# Try manual import with verbose output
Import-Module ProfileCore.Binary -Verbose -Force
```

**Solutions**:

1. Ensure correct binary for your platform is present
2. Check file permissions (execute permission on Unix)
3. Verify architecture matches (x64 binary needs x64 PowerShell)
4. On macOS: Remove quarantine attribute (`xattr -d com.apple.quarantine profilecore.dylib`)

### DLL Locking (Windows)

**Symptom**: Cannot rebuild Rust DLL

**Solution**:

```powershell
# Close all PowerShell sessions
# Or use shadow copy (automatic in ProfileCore.Binary)
# Manual workaround:
Get-Process pwsh | Stop-Process -Force
cargo clean
cargo build --release
```

### Performance Lower Than Expected

**Check**:

1. Verify Rust is actually being used:

   ```powershell
   $metrics = Get-ProfileCoreSystemInfoMetrics
   $metrics.RustPercentage  # Should be close to 100%
   ```

2. Check for frequent fallbacks:

   ```powershell
   $metrics.FallbackCalls  # Should be low
   ```

3. Profile your code:
   ```powershell
   Measure-Command { Get-ProfileCoreSystemInfo }
   ```

### Runtime Errors

**Enable debug logging**:

```powershell
$env:PROFILECORE_DEBUG = '1'
Import-Module ProfileCore -Force

# Check logs
Get-Content ~/.profilecore/logs/profilecore.log
```

---

## See Also

- [RUST_BUILD_GUIDE.md](./RUST_BUILD_GUIDE.md) - Building and cross-compiling Rust binaries
- [RUST_FFI_PATTERNS.md](./RUST_FFI_PATTERNS.md) - FFI patterns and best practices
- [DI API Reference](./API_REFERENCE.md) - Dependency injection documentation
- [Performance Guide](../user-guide/optimization-reference.md) - General performance tips
