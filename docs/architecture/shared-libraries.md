# ProfileCore Shared Libraries Architecture

**Version:** 5.2.0  
**Last Updated:** 2025-10-26

---

## Overview

ProfileCore v5.2.0 introduces a shared library architecture to eliminate code duplication, improve maintainability, and provide consistent utilities across all scripts and modules.

## Architecture Diagram

```
ProfileCore Ecosystem
│
├── ProfileCore.Common (v1.0.0) ← Shared Utilities
│   ├── OutputHelpers.ps1
│   └── InstallHelpers.ps1
│
├── ProfileCore (v5.2.0) ← Core Module
│   ├── private-v6/ (DI Architecture)
│   ├── public/ (97 functions)
│   └── Requires: ProfileCore.Common
│
└── Scripts & Tools
    ├── quick-install.ps1 → Uses ProfileCore.Common
    ├── installation/install.ps1 → Uses ProfileCore.Common
    └── Other scripts → Can use ProfileCore.Common
```

## ProfileCore.Common Module

### Purpose

Provides shared utilities for:

- Installation scripts
- Build scripts
- Development tools
- Plugin systems
- Any script needing consistent output and validation

### Location

`modules/ProfileCore.Common/`

### Functions

#### Output Helpers (8 functions)

| Function                | Purpose                  | Example                                                    |
| ----------------------- | ------------------------ | ---------------------------------------------------------- |
| `Write-BoxHeader`       | Formatted box headers    | `Write-BoxHeader "Title" -Color Cyan`                      |
| `Write-Step`            | Step indicators          | `Write-Step "Processing..." -Quiet:$Quiet`                 |
| `Write-Progress`        | Progress with percentage | `Write-Progress "Installing..." -Percent 50 -Quiet:$Quiet` |
| `Write-Success`         | Success messages         | `Write-Success "Done!" -Quiet:$Quiet`                      |
| `Write-Info`            | Information messages     | `Write-Info "Details..." -Quiet:$Quiet`                    |
| `Write-Warn`            | Warning messages         | `Write-Warn "Warning!" -Quiet:$Quiet`                      |
| `Write-Fail`            | Failure messages         | `Write-Fail "Error!" -Quiet:$Quiet`                        |
| `Write-InstallProgress` | Visual progress bar      | `Write-InstallProgress "Installing..." -Percent 75`        |

#### Installation Helpers (4 functions)

| Function                  | Purpose                      | Example                                                                  |
| ------------------------- | ---------------------------- | ------------------------------------------------------------------------ |
| `Test-GitHubConnectivity` | Check GitHub availability    | `if (Test-GitHubConnectivity) { ... }`                                   |
| `Get-UserConfirmation`    | Prompt for confirmation      | `Get-UserConfirmation "Continue?" -Default $true -NonInteractive:$false` |
| `Test-Prerequisites`      | Validate system requirements | `Test-Prerequisites -ThrowOnError -Quiet:$Quiet`                         |
| `Invoke-WithRetry`        | Retry logic wrapper          | `Invoke-WithRetry { Install-Package } -MaxAttempts 3`                    |

### Usage Example

```powershell
# Import the module
Import-Module ProfileCore.Common

# Use output helpers
Write-BoxHeader "My Installation Script" -Color Cyan
Write-Step "Step 1: Checking prerequisites" -Quiet:$Quiet

# Use installation helpers
if (-not (Test-GitHubConnectivity)) {
    Write-Warn "GitHub not reachable" -Quiet:$Quiet
    exit 1
}

if (Test-Prerequisites -ThrowOnError) {
    Write-Success "Prerequisites met!" -Quiet:$Quiet
}

# Use retry logic
Invoke-WithRetry {
    Install-Package MyPackage
} -MaxAttempts 3 -Operation "Installing MyPackage"

Write-InstallProgress "Installing..." -Percent 100
Write-Success "Installation complete!" -Quiet:$Quiet
```

## Benefits

### Code Reduction

- **Before v5.2.0**: Each script had its own Write-\* functions (200+ lines duplicated)
- **After v5.2.0**: Single source of truth in ProfileCore.Common
- **Reduction**: 40% less duplication

### Consistency

All scripts use the same:

- Box header formatting (dynamic width, centered text)
- Progress indicators
- Error messages
- Validation logic

### Maintainability

- **Single Update Point**: Fix a bug once, all scripts benefit
- **Easy Testing**: Test functions in isolation
- **Clear Dependencies**: Explicit module import shows what's being used

### Flexibility

- All functions support `-Quiet` switch for silent operation
- Customizable colors, widths, and behaviors
- Non-interactive mode support

## Integration with V6 Architecture

ProfileCore.Common works alongside the v6 DI architecture:

```powershell
# ProfileCore v6 uses DI for internal services
Import-Module ProfileCore
$cache = Get-Service 'ICacheProvider'

# Scripts use Common for utilities
Import-Module ProfileCore.Common
Write-Step "Using cached data" -Quiet:$Quiet
$data = $cache.Get('mykey')
```

## Migration Guide

### Before (Duplicated Code)

```powershell
# Script 1
function Write-BoxHeader {
    param([string]$Message)
    $line = "═" * 60
    Write-Host "╔$line╗"
    Write-Host "║ $Message ║"
    Write-Host "╚$line╝"
}

# Script 2 (duplicate!)
function Write-BoxHeader {
    param([string]$Message)
    $line = "═" * 60
    Write-Host "╔$line╗"
    Write-Host "║ $Message ║"
    Write-Host "╚$line╝"
}
```

### After (Shared Library)

```powershell
# Script 1
Import-Module ProfileCore.Common
Write-BoxHeader "My Script 1"

# Script 2
Import-Module ProfileCore.Common
Write-BoxHeader "My Script 2"
```

## Best Practices

### 1. Always Import at Script Start

```powershell
# At the top of your script
Import-Module ProfileCore.Common -ErrorAction Stop
```

### 2. Use -Quiet Parameter Consistently

```powershell
# Support quiet mode
param([switch]$Quiet)

Write-Step "Processing..." -Quiet:$Quiet
Write-Success "Done!" -Quiet:$Quiet
```

### 3. Handle Missing Module Gracefully

```powershell
$commonModulePath = Join-Path $PSScriptRoot "path\to\ProfileCore.Common"
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -ErrorAction Stop
} else {
    Write-Error "ProfileCore.Common module not found"
    exit 1
}
```

### 4. Use Appropriate Function for Context

```powershell
Write-Step "Starting installation..."      # For major steps
Write-Progress "Copying files..." -Percent 50  # For detailed progress
Write-Info "Optional dependency found"     # For information
Write-Warn "Low disk space"                # For warnings
Write-Success "Installation complete!"     # For success
Write-Fail "Installation failed"           # For failures
```

## Future Enhancements

Planned for future versions:

- **Logging Integration**: Optional logging to files
- **Telemetry Helpers**: Anonymous usage statistics
- **Validation Helpers**: More validation functions
- **Network Helpers**: Download with progress, proxy support
- **File Helpers**: Safe file operations with rollback

## Related Documentation

- **Migration Guide**: `docs/developer/v5-to-v6-migration.md`
- **V6 Architecture**: `modules/ProfileCore/private-v6/README.md`
- **Contributing**: `docs/developer/contributing.md`

## Version History

| Version | Date       | Changes                           |
| ------- | ---------- | --------------------------------- |
| 1.0.0   | 2025-10-26 | Initial release with 12 functions |

---

**ProfileCore.Common** - Shared utilities for a consistent, maintainable codebase.
