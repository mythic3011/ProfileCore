# Scripts Shared Library

This directory contains shared helper functions for ProfileCore scripts.

## Purpose

Provides consistent utilities across all ProfileCore scripts by:

- Importing ProfileCore.Common module
- Finding ProfileCore root directory
- Centralizing common script patterns

## Usage

### Import ProfileCore.Common in Your Script

```powershell
# At the top of your script (PowerShell)
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"
Import-ProfileCoreCommon

# Now use ProfileCore.Common functions
Write-BoxHeader "My Script Title"
Write-Step "Doing something..."
Write-Success "Done!"
```

### From Different Subdirectories

```powershell
# From scripts/installation/
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"

# From scripts/utilities/
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"

# From scripts/build/
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"

# All work the same way!
Import-ProfileCoreCommon
```

### Get ProfileCore Root Directory

```powershell
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"

$rootDir = Get-ProfileCoreRoot
$modulesDir = Join-Path $rootDir "modules"
$docsDir = Join-Path $rootDir "docs"
```

## Available Functions

### Import-ProfileCoreCommon

Imports the ProfileCore.Common module, providing access to:

**Output Helpers:**

- `Write-BoxHeader` - Formatted box headers
- `Write-Step` - Step indicators
- `Write-Success` - Success messages
- `Write-Info` - Info messages
- `Write-Warn` - Warning messages
- `Write-Fail` - Failure messages
- `Write-Progress` - Progress with percentage
- `Write-InstallProgress` - Visual progress bar

**Installation Helpers:**

- `Test-GitHubConnectivity` - Check GitHub availability
- `Get-UserConfirmation` - Prompt for confirmation
- `Test-Prerequisites` - Validate system requirements
- `Invoke-WithRetry` - Retry logic wrapper

### Get-ProfileCoreRoot

Finds the ProfileCore root directory from any script location.

## Benefits

- **No Code Duplication**: All scripts use the same utility functions
- **Consistent UX**: Standardized output formatting across all scripts
- **Easy Maintenance**: Update once, benefits all scripts
- **Discoverable**: Clear location for shared code

## Migration from Old Pattern

**Before (Duplicate Functions):**

```powershell
function Write-Step {
    param([string]$Message)
    Write-Host "🔹 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

# ... script code
```

**After (Shared Library):**

```powershell
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"
Import-ProfileCoreCommon

# Use functions directly - they support -Quiet and more!
Write-Step "Processing..." -Quiet:$Quiet
Write-Success "Complete!" -Quiet:$Quiet
```

## See Also

- **ProfileCore.Common**: `modules/ProfileCore.Common/`
- **Shared Libraries Doc**: `docs/architecture/shared-libraries.md`
- **Migration Guide**: `docs/developer/v5-to-v6-migration.md`
