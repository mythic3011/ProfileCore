@{
    RootModule = 'ProfileCore.Common.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Mythic3011'
    CompanyName = 'ProfileCore Project'
    Copyright = '(c) 2025 Mythic3011. All rights reserved.'
    Description = 'Shared utilities module for ProfileCore. Provides common functions for installation scripts, build scripts, and utilities including output helpers, installation helpers, and validation functions.'
    PowerShellVersion = '5.1'
    
FunctionsToExport = @(
    # Output Helpers (PowerShell)
    'Write-BoxHeader',
    'Write-Step',
    'Write-Progress',
    'Write-Success',
    'Write-Info',
    'Write-Warn',
    'Write-Fail',
    'Write-ErrorMsg',
    'Write-CheckMark',
    'Write-SectionHeader',
    'Write-InstallProgress',
    # Output Helpers (Rust-backed)
    'Initialize-RustOutput',
    'Write-RustBoxHeader',
    'Write-RustSectionHeader',
    'Write-RustInstallProgress',
    'Write-RustMessage',
    'Write-RustSuccess',
    'Write-RustInfo',
    'Write-RustWarn',
    'Write-RustError',
    'Write-RustFail',
    'Write-RustStep',
    # Installation Helpers (PowerShell)
    'Test-GitHubConnectivity',
    'Get-UserConfirmation',
    'Test-Prerequisites',
    'Invoke-WithRetry',
    # Installation Helpers (Rust-backed)
    'Initialize-RustHelpers',
    'Test-RustGitHubConnectivity',
    'Test-RustCommandExists',
    'Test-RustPrerequisites',
    'Invoke-RustWithRetry'
)
    
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    
    PrivateData = @{
        PSData = @{
            Tags = @('ProfileCore', 'Utilities', 'Common', 'Shared', 'Helpers')
            ProjectUri = 'https://github.com/mythic3011/ProfileCore'
            LicenseUri = 'https://github.com/mythic3011/ProfileCore/blob/main/LICENSE'
            ReleaseNotes = @'
v1.0.0 - Initial Release
- Shared output helpers for consistent UI across scripts
- Installation and validation utilities
- Retry logic and prerequisite checking
- Extracted from ProfileCore v5.2.0 restructuring
'@
        }
    }
}

