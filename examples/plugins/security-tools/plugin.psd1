@{
    # Plugin manifest for ProfileCore Security Tools
    Name = 'security-tools'
    Version = '1.0.0'
    Author = 'ProfileCore Team'
    Description = 'Essential security tools including SSH, file verification, VirusTotal, and Shodan integration'
    
    # Dependencies
    RequiredModules = @()
    RequiredPlugins = @()
    
    # Requirements
    PowerShellVersion = '5.1'
    
    # Capabilities this plugin provides
    Capabilities = @(
        'CommandProvider',
        'ConfigurationProvider'
    )
    
    # Lifecycle hooks
    OnLoad = 'Initialize-SecurityTools'
    OnUnload = 'Unload-SecurityTools'
    
    # Permissions required
    Permissions = @{
        FileSystem = $true
        Network = $true
        ExecuteCommands = $true
        Registry = $false
    }
    
    # Metadata
    Tags = @('Security', 'SSH', 'FileVerification', 'VirusTotal', 'Shodan', 'InfoSec')
    ProjectUri = 'https://github.com/mythic3011/ProfileCore'
    LicenseUri = 'https://github.com/mythic3011/ProfileCore/blob/main/LICENSE'
}

