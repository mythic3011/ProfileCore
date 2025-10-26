# ScriptHelpers.ps1
# Shared helper functions for ProfileCore scripts
# This module provides a convenient way to load ProfileCore.Common from scripts

<#
.SYNOPSIS
    Imports ProfileCore.Common module for use in scripts

.DESCRIPTION
    This helper function attempts to import ProfileCore.Common module.
    It searches in common locations and provides helpful error messages if not found.

.PARAMETER Quiet
    Suppress informational messages

.EXAMPLE
    # At the top of your script
    . "$PSScriptRoot\..\shared\ScriptHelpers.ps1"
    Import-ProfileCoreCommon

.EXAMPLE
    # With quiet mode
    Import-ProfileCoreCommon -Quiet
#>

function Import-ProfileCoreCommon {
    [CmdletBinding()]
    param(
        [switch]$Quiet
    )
    
    # Check if already loaded
    if (Get-Module ProfileCore.Common) {
        if (-not $Quiet) {
            Write-Verbose "ProfileCore.Common already loaded"
        }
        return $true
    }
    
    # Try to find ProfileCore.Common module
    $searchPaths = @(
        # From scripts directory
        (Join-Path $PSScriptRoot "..\..\modules\ProfileCore.Common"),
        # From utilities subdirectory
        (Join-Path $PSScriptRoot "..\..\..\modules\ProfileCore.Common"),
        # From installation subdirectory  
        (Join-Path $PSScriptRoot "..\..\modules\ProfileCore.Common"),
        # From build subdirectory
        (Join-Path $PSScriptRoot "..\..\modules\ProfileCore.Common")
    )
    
    $commonPath = $null
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $commonPath = $path
            break
        }
    }
    
    if (-not $commonPath) {
        Write-Error @"
ProfileCore.Common module not found!

Searched in:
$(($searchPaths | ForEach-Object { "  - $_" }) -join "`n")

Please ensure ProfileCore.Common is installed at:
  modules/ProfileCore.Common/

"@
        return $false
    }
    
    try {
        Import-Module $commonPath -DisableNameChecking -ErrorAction Stop -Global
        if (-not $Quiet) {
            Write-Verbose "ProfileCore.Common loaded from: $commonPath"
        }
        return $true
    } catch {
        Write-Error "Failed to import ProfileCore.Common: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Gets the ProfileCore root directory from any script location

.DESCRIPTION
    Attempts to determine the root ProfileCore directory by looking for
    characteristic files like ProfileCore.psd1 or the modules/ directory

.EXAMPLE
    $rootDir = Get-ProfileCoreRoot
    $modulesDir = Join-Path $rootDir "modules"
#>
function Get-ProfileCoreRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    $current = $PSScriptRoot
    $maxDepth = 5
    $depth = 0
    
    while ($depth -lt $maxDepth) {
        # Check for characteristic files/directories
        $indicators = @(
            (Join-Path $current "modules\ProfileCore"),
            (Join-Path $current "README.md"),
            (Join-Path $current "CHANGELOG.md")
        )
        
        $found = $indicators | Where-Object { Test-Path $_ }
        
        if ($found.Count -ge 2) {
            return $current
        }
        
        # Go up one directory
        $parent = Split-Path $current -Parent
        if (-not $parent -or $parent -eq $current) {
            break
        }
        $current = $parent
        $depth++
    }
    
    # Fallback: assume we're in scripts/ subdirectory
    $scriptRoot = Split-Path $PSScriptRoot -Parent
    if (Test-Path (Join-Path $scriptRoot "modules")) {
        return $scriptRoot
    }
    
    Write-Warning "Could not determine ProfileCore root directory"
    return $PSScriptRoot
}

# Export functions
Export-ModuleMember -Function @(
    'Import-ProfileCoreCommon',
    'Get-ProfileCoreRoot'
)

