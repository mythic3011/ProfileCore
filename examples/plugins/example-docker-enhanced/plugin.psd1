@{
    # Plugin manifest for ProfileCore
    Name = 'example-docker-enhanced'
    Version = '1.0.0'
    Author = 'ProfileCore Team'
    Description = 'Enhanced Docker management plugin demonstrating SOLID architecture'
    
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
    OnLoad = 'Initialize-DockerEnhanced'
    OnUnload = 'Unload-DockerEnhanced'
    
    # Permissions required
    Permissions = @{
        FileSystem = $true
        Network = $true
        ExecuteCommands = $true
        Registry = $false
    }
    
    # Metadata
    Tags = @('Docker', 'Containers', 'DevOps')
    ProjectUri = 'https://github.com/mythic3011/ProfileCore'
    LicenseUri = 'https://github.com/mythic3011/ProfileCore/blob/main/LICENSE'
}

