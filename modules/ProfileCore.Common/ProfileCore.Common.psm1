# ProfileCore.Common.psm1
# Shared utilities module for ProfileCore
# Provides common functions for installation scripts, build scripts, and utilities
# Version: 1.0.0

# Get module root
$script:ModuleRoot = $PSScriptRoot

# Import public functions
$publicPath = Join-Path $PSScriptRoot "public"
if (Test-Path $publicPath) {
    $publicFunctions = @(Get-ChildItem -Path "$publicPath/*.ps1" -ErrorAction SilentlyContinue)
    foreach ($import in $publicFunctions) {
        try {
            . $import.FullName
            Write-Verbose "Imported public function: $($import.BaseName)"
        } catch {
            Write-Error "Failed to import function $($import.FullName): $_"
        }
    }
}

# Export all public functions
# Functions are already exported in their respective files via Export-ModuleMember

# Initialize Rust modules if available (silent initialization)
try {
    # Initialize Rust output helpers
    if (Get-Command Initialize-RustOutput -ErrorAction SilentlyContinue) {
        $null = Initialize-RustOutput -Verbose:$false -ErrorAction SilentlyContinue
    }
    
    # Initialize Rust installation helpers
    if (Get-Command Initialize-RustHelpers -ErrorAction SilentlyContinue) {
        $null = Initialize-RustHelpers -Verbose:$false -ErrorAction SilentlyContinue
    }
} catch {
    # Silently fall back to PowerShell implementation
}

