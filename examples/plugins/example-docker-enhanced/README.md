# Docker Enhanced Plugin

## Overview

This is an example plugin demonstrating ProfileCore's SOLID architecture and extensibility features.

## Features

- **🏥 Docker Health Check** - Comprehensive Docker daemon and container health monitoring
- **🧹 Smart Cleanup** - Intelligent cleanup of old containers, images, volumes, and networks
- **🧙 Compose Wizard** - Interactive Docker Compose file generator

## Architecture

This plugin demonstrates:

### 1. **Plugin Base Class Inheritance**
```powershell
class DockerEnhancedPlugin : PluginBaseV2 {
    # Inherits lifecycle management, DI, logging, etc.
}
```

### 2. **Dependency Injection**
```powershell
DockerEnhancedPlugin([ServiceContainer]$services) : base(..., $services) {
    # Services injected via constructor
}

$configManager = $this.GetConfigurationManager()
$packageManager = $this.GetPackageManager()
```

### 3. **Command Provider Capability**
```powershell
$cmdCapability = [CommandProviderCapability]::new()
$cmdCapability.RegisterCommand('docker-health', { ... }, @{
    EnableCache = $false
    RequiresElevation = $false
})
$this.RegisterCapability('CommandProvider', $cmdCapability)
```

### 4. **Lifecycle Hooks**
```powershell
[void] OnInitialize() { ... }
[void] OnLoad() { ... }
[void] OnUnload() { ... }
```

### 5. **Configuration Integration**
```powershell
$configManager = $this.GetConfigurationManager()
$config = $configManager.GetConfig('docker-enhanced')
```

## Installation

### Option 1: Copy to Plugins Directory

```powershell
# Copy plugin to user plugins directory
$pluginSource = "./examples/plugins/example-docker-enhanced"
$pluginDest = "$HOME/.profilecore/plugins/example-docker-enhanced"

Copy-Item -Path $pluginSource -Destination $pluginDest -Recurse -Force
```

### Option 2: Symlink (for development)

```powershell
# Create symlink for easier development
$pluginSource = (Resolve-Path "./examples/plugins/example-docker-enhanced").Path
$pluginDest = "$HOME/.profilecore/plugins/example-docker-enhanced"

New-Item -ItemType SymbolicLink -Path $pluginDest -Target $pluginSource
```

### Enable the Plugin

```powershell
# Enable plugin
Enable-ProfileCorePlugin -Name 'example-docker-enhanced'

# Reload profile
. $PROFILE
```

## Usage

### Docker Health Check

```powershell
docker-health

# Output:
# 🐳 Docker Health Check
# ==================================================
# ✅ Docker daemon is running
#    Containers: 15
#    Images: 42
#    Server Version: 24.0.0
# ✅ Docker Compose: docker-compose version 2.20.0
#
# 📊 Resource Usage:
# NAME        CPU %    MEM USAGE
# webapp      5.23%    256MB / 4GB
# database    2.45%    1.2GB / 4GB
```

### Smart Cleanup

```powershell
docker-cleanup-smart

# Output:
# 🧹 Smart Docker Cleanup
# ==================================================
#
# 📦 Stopping old containers...
#   Stopping container: abc123
#
# 🗑️  Removing stopped containers...
# Deleted Containers: 5
#
# 🖼️  Removing unused images...
# Deleted Images: 12
#
# 💾 Removing unused volumes...
# Deleted Volumes: 3
#
# 🌐 Removing unused networks...
# Deleted Networks: 2
#
# ✅ Cleanup completed!
```

### Docker Compose Wizard

```powershell
docker-compose-wizard

# Interactive prompts:
# Enter service name: webapp
# Enter Docker image (e.g., nginx:latest): nginx:alpine
# Enter port mapping (e.g., 8080:80): 8080:80
#
# ✅ Created: docker-compose-webapp.yml
#
# 📝 To start: docker-compose -f docker-compose-webapp.yml up -d
```

## Configuration

Create a configuration file at `~/.config/shell-profile/docker-enhanced.json`:

```json
{
  "DefaultComposeFile": "docker-compose.yml",
  "AutoCleanup": true,
  "LogRetention": 7,
  "CleanupSchedule": "weekly"
}
```

## Extending This Plugin

### Add New Commands

```powershell
# In OnLoad() method
$cmdCapability.RegisterCommand('docker-backup', {
    param($params)
    # Your backup logic here
}, @{
    EnableCache = $false
    RequiresElevation = $true  # Needs admin
})
```

### Add Configuration Provider

```powershell
# Create custom config provider
class DockerConfigProvider : ConfigurationProvider {
    DockerConfigProvider() : base('docker-config', 85) { }
    
    [hashtable] Load([string]$key) {
        # Load Docker-specific config
    }
}

# Register in OnLoad()
$configManager = $this.GetConfigurationManager()
$configManager.RegisterProvider([DockerConfigProvider]::new())
```

### Use Services

```powershell
# Package Manager
$pkgManager = $this.GetPackageManager()
$bestPM = $pkgManager.GetBestProvider()
$bestPM.Install('docker', @{})

# Configuration Manager
$configManager = $this.GetConfigurationManager()
$theme = $configManager.GetValue('config', 'theme', 'default')
```

## Development

### File Structure

```
example-docker-enhanced/
├── plugin.psd1                   # Plugin manifest
├── example-docker-enhanced.psm1  # Plugin implementation
├── README.md                     # This file
└── config.json                   # Default configuration (optional)
```

### Debugging

```powershell
# Enable verbose logging
$VerbosePreference = 'Continue'

# Check logs
Get-Content "$HOME/.profilecore/logs/plugin-example-docker-enhanced.log"

# Reload plugin
Disable-ProfileCorePlugin -Name 'example-docker-enhanced'
Enable-ProfileCorePlugin -Name 'example-docker-enhanced'
. $PROFILE
```

### Testing

```powershell
# Test plugin loading
Test-ProfileCorePlugin -Name 'example-docker-enhanced'

# Get plugin info
Get-ProfileCorePluginInfo -Name 'example-docker-enhanced'
```

## SOLID Principles Demonstrated

### Single Responsibility Principle (SRP)
- Plugin handles only Docker management
- Separate capabilities for commands, config, etc.

### Open/Closed Principle (OCP)
- Extends `PluginBaseV2` without modifying it
- Registers capabilities without changing core

### Liskov Substitution Principle (LSP)
- Can replace base plugin class
- Implements expected interface

### Interface Segregation Principle (ISP)
- Uses only needed capabilities (CommandProvider)
- Doesn't implement unnecessary interfaces

### Dependency Inversion Principle (DIP)
- Depends on `ServiceContainer` abstraction
- Uses injected services, not concrete implementations

## License

MIT License - See ProfileCore LICENSE file

## Contributing

Contributions welcome! See [Contributing Guide](../../../docs/development/contributing.md)

---

<div align="center">

**Example Plugin** - _Demonstrating SOLID Architecture in Practice_

**[📖 Architecture Docs](../../../docs/development/SOLID_ARCHITECTURE.md)** • **[🏠 ProfileCore](../../../README.md)**

</div>

