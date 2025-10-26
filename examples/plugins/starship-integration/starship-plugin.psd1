@{
    # Module manifest for Starship integration plugin
    
    # Script module or binary module file associated with this manifest.
    RootModule = 'starship-plugin.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions = @('Core', 'Desktop')
    
    # ID used to uniquely identify this module
    GUID = 'a8f3c2d1-9b7e-4f5a-8c6d-2e1b9a7f3c5d'
    
    # Author of this module
    Author = 'ProfileCore Team'
    
    # Company or vendor of this module
    CompanyName = 'ProfileCore'
    
    # Copyright statement for this module
    Copyright = '(c) 2025 ProfileCore. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'Starship prompt integration plugin for ProfileCore v6.1.0. Provides fast, beautiful, cross-shell prompt with Rust-powered rendering.'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('ProfileCore')
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Enable-StarshipPrompt',
        'Disable-StarshipPrompt',
        'Get-StarshipStatus',
        'Update-StarshipConfig',
        'Test-StarshipInstalled'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Starship', 'Prompt', 'Shell', 'CrossPlatform', 'ProfileCore', 'Plugin')
            
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/yourusername/ProfileCore/blob/main/LICENSE'
            
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/yourusername/ProfileCore'
            
            # ReleaseNotes of this module
            ReleaseNotes = @'
# Starship Plugin v1.0.0

## Features
- Cross-platform prompt customization (PowerShell, Bash, Zsh, Fish)
- Rust-powered prompt rendering for 10x performance
- Automatic Starship installation and configuration
- Unified configuration across all shells
- Seamless integration with ProfileCore v6.1.0 DI container
- Live prompt updates without shell restart

## Requirements
- ProfileCore v6.1.0+
- Starship (auto-installed if missing)

## Usage
```powershell
# Enable Starship prompt
Enable-StarshipPrompt

# Check status
Get-StarshipStatus

# Disable (restore default prompt)
Disable-StarshipPrompt
```
'@
        }
    }
}

