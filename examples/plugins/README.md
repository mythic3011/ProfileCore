# ProfileCore Plugins

## Overview

This directory contains example plugins demonstrating ProfileCore v5.0's SOLID architecture and plugin system.

---

## 📦 Available Example Plugins

### 1. **security-tools** - Essential Security Utilities

Essential security tools migrated from legacy commands.

**Features:**

- 🔑 SSH key management (`ssh-copy-id`)
- 🔍 File hash verification
- 🛡️ VirusTotal file scanning
- 🌐 Shodan IP lookup

**[📖 Full Documentation](security-tools/README.md)**

**Installation:**

```powershell
Copy-Item ./examples/plugins/security-tools ~/.profilecore/plugins/ -Recurse
Enable-ProfileCorePlugin -Name 'security-tools'
```

### 2. **example-docker-enhanced** - Docker Management

Advanced Docker management with health monitoring and cleanup.

**Features:**

- 🏥 Docker health check
- 🧹 Smart cleanup (age-based)
- 🧙 Docker Compose wizard

**[📖 Full Documentation](example-docker-enhanced/README.md)**

**Installation:**

```powershell
Copy-Item ./examples/plugins/example-docker-enhanced ~/.profilecore/plugins/ -Recurse
Enable-ProfileCorePlugin -Name 'example-docker-enhanced'
```

---

## 🏗️ Plugin Architecture

ProfileCore v5.0 uses a professional plugin architecture based on SOLID principles.

### Plugin Structure

```
plugin-name/
├── plugin.psd1                # Manifest (metadata, dependencies, capabilities)
├── plugin-name.psm1           # Implementation (using PluginBaseV2)
├── README.md                  # Documentation
├── config.json                # Default configuration (optional)
└── functions/                 # Additional functions (optional)
```

### Minimal Plugin Example

**plugin.psd1:**

```powershell
@{
    Name = 'my-plugin'
    Version = '1.0.0'
    Author = 'Your Name'
    Description = 'My awesome plugin'

    RequiredModules = @()
    RequiredPlugins = @()
    PowerShellVersion = '5.1'

    Capabilities = @('CommandProvider')

    OnLoad = 'Initialize-MyPlugin'
    OnUnload = 'Unload-MyPlugin'

    Permissions = @{
        FileSystem = $true
        Network = $false
        ExecuteCommands = $false
        Registry = $false
    }
}
```

**my-plugin.psm1:**

```powershell
# Import ProfileBaseV2 and create plugin class
class MyPlugin : PluginBaseV2 {
    MyPlugin([ServiceContainer]$services) : base('my-plugin', [version]'1.0.0', $services) {
        $this.Author = "Your Name"
        $this.Description = "My awesome plugin"
    }

    [void] OnLoad() {
        # Register commands
        $cmdCapability = [CommandProviderCapability]::new()

        $cmdCapability.RegisterCommand('my-command', {
            param($params)
            Write-Host "Hello from my plugin!"
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })

        $this.RegisterCapability('CommandProvider', $cmdCapability)
    }
}

# Initialize function
function Initialize-MyPlugin {
    param([ServiceContainer]$Services)

    $plugin = [MyPlugin]::new($Services)
    $plugin.OnLoad()

    # Export commands
    New-Item -Path "Function:\global:my-command" -Value {
        # Command implementation
    } -Force | Out-Null

    return $plugin
}

# Unload function
function Unload-MyPlugin {
    Remove-Item -Path "Function:\global:my-command" -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function @('Initialize-MyPlugin', 'Unload-MyPlugin')
```

---

## 🎯 Plugin Capabilities

### CommandProvider

Provides commands that users can execute.

```powershell
$cmdCapability = [CommandProviderCapability]::new()

$cmdCapability.RegisterCommand('command-name', {
    param($params)
    # Command logic
}, @{
    EnableCache = $true          # Cache results
    RequiresElevation = $false   # Need admin?
    ValidationRules = @{         # Parameter validation
        Param1 = { param($v) $v -match '^\w+$' }
    }
})

$this.RegisterCapability('CommandProvider', $cmdCapability)
```

### ConfigurationProvider

Provides configuration from custom sources.

```powershell
class MyConfigProvider : ConfigurationProvider {
    MyConfigProvider() : base('myconfig', 85) { }

    [hashtable] Load([string]$key) {
        # Load configuration
    }

    [void] Save([string]$key, [hashtable]$config) {
        # Save configuration
    }
}

$configCapability = [ConfigurationProviderCapability]::new($myProvider)
$this.RegisterCapability('ConfigurationProvider', $configCapability)
```

---

## 🔧 Using Services

Plugins can access ProfileCore services via dependency injection.

### Package Manager

```powershell
[void] OnLoad() {
    # Get package manager service
    $pkgMgr = $this.GetPackageManager()

    # Use it
    $bestPM = $pkgMgr.GetBestProvider()
    $bestPM.Install('git', @{})
}
```

### Configuration Manager

```powershell
[void] OnLoad() {
    # Get configuration service
    $configMgr = $this.GetConfigurationManager()

    # Load plugin config
    $config = $configMgr.GetConfig('my-plugin')
    $theme = $configMgr.GetValue('config', 'theme', 'default')
}
```

### OS Provider

```powershell
[void] OnLoad() {
    # Get OS provider service
    $osProvider = $this.GetService('OSProvider')

    # Use OS-specific features
    if ($osProvider.Name -eq 'Windows') {
        # Windows-specific code
    }
}
```

---

## 📝 Plugin Lifecycle

### Lifecycle Hooks

```powershell
class MyPlugin : PluginBaseV2 {
    # 1. Called when plugin is discovered
    [void] OnInitialize() {
        $this.Log("Initializing...", "Info")
        $this.LoadConfig()
    }

    # 2. Called when plugin is loaded
    [void] OnLoad() {
        $this.Log("Loading...", "Info")
        $this.RegisterCommands()
    }

    # 3. Called when plugin is unloaded
    [void] OnUnload() {
        $this.Log("Unloading...", "Info")
        # Cleanup
    }

    # 4. Called when config changes
    [void] OnConfigChange([hashtable]$newConfig) {
        $this.Config = $newConfig
        # React to changes
    }
}
```

### Dependency Resolution

```powershell
# In plugin.psd1
@{
    # Plugin dependencies (loaded first)
    RequiredPlugins = @('base-plugin')

    # Module dependencies (installed if missing)
    RequiredModules = @('Pester', 'PSScriptAnalyzer')
}
```

---

## 🧪 Testing Plugins

### Test Plugin Loading

```powershell
# Test if plugin can be loaded
Test-ProfileCorePlugin -Name 'my-plugin'
```

### Get Plugin Info

```powershell
# Get detailed plugin information
Get-ProfileCorePluginInfo -Name 'my-plugin'
```

### Enable/Disable

```powershell
# Enable plugin
Enable-ProfileCorePlugin -Name 'my-plugin'

# Disable plugin
Disable-ProfileCorePlugin -Name 'my-plugin'
```

### Debug Mode

```powershell
# Enable verbose logging
$VerbosePreference = 'Continue'

# Check logs
Get-Content "$HOME/.profilecore/logs/plugin-my-plugin.log"
```

---

## 🎨 Best Practices

### 1. **Single Responsibility**

One plugin = one purpose

### 2. **Use Dependency Injection**

```powershell
# ✅ Good
$configMgr = $this.GetConfigurationManager()

# ❌ Bad
$config = Get-Content "C:\config.json" | ConvertFrom-Json
```

### 3. **Error Handling**

```powershell
$cmdCapability.RegisterCommand('my-cmd', {
    param($params)

    try {
        # Command logic
        Write-Host "✅ Success" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed: $_"
        $this.Log($_.Exception.Message, "Error")
    }
})
```

### 4. **Configuration Management**

```powershell
# Load from ConfigurationManager
$configMgr = $this.GetConfigurationManager()
$myConfig = $configMgr.GetConfig('my-plugin')

# Provide defaults
$timeout = $configMgr.GetValue('my-plugin', 'timeout', 30)
```

### 5. **Logging**

```powershell
# Use built-in logging
$this.Log("Operation started", "Info")
$this.Log("Warning message", "Warning")
$this.Log("Error occurred", "Error")
```

### 6. **Caching**

```powershell
# Enable caching for expensive operations
$cmdCapability.RegisterCommand('expensive-op', {
    # ...
}, @{
    EnableCache = $true  # Results cached for 60s
})
```

---

## 📦 Publishing Plugins

### GitHub Repository Structure

```
my-plugin-repo/
├── plugin.psd1
├── my-plugin.psm1
├── README.md
├── LICENSE
└── examples/
    └── config.json
```

### Installation from GitHub

```powershell
# Users can install from GitHub
Install-ProfileCorePluginFromGitHub -Url "https://github.com/user/my-plugin" -Name "my-plugin"
```

---

## 🔍 Example Plugins Comparison

| Feature           | security-tools           | docker-enhanced                      |
| ----------------- | ------------------------ | ------------------------------------ |
| **Capabilities**  | CommandProvider          | CommandProvider                      |
| **Services Used** | ConfigurationManager     | ConfigurationManager, PackageManager |
| **External APIs** | VirusTotal, Shodan       | None                                 |
| **Configuration** | API keys in secrets.json | Settings in config.json              |
| **Complexity**    | Medium                   | Low                                  |
| **Best For**      | Security analysis        | Docker workflows                     |

---

## 📚 Learning Path

1. **Start Here:** Read this README
2. **Study Examples:** Look at `security-tools` and `docker-enhanced`
3. **Read Architecture Guide:** [SOLID_ARCHITECTURE.md](../../docs/development/SOLID_ARCHITECTURE.md)
4. **Create Simple Plugin:** Use minimal example above
5. **Add Features:** Services, caching, validation
6. **Test Thoroughly:** Use Test-ProfileCorePlugin
7. **Share:** Publish to GitHub

---

## 🤝 Contributing

Want to contribute a plugin?

1. Create plugin following structure above
2. Test thoroughly
3. Write comprehensive README
4. Submit PR to ProfileCore repository

**Plugin Checklist:**

- [ ] Follows PluginBaseV2 architecture
- [ ] Uses dependency injection
- [ ] Includes plugin.psd1 manifest
- [ ] Has README with examples
- [ ] Error handling implemented
- [ ] Logging included
- [ ] Tested on multiple platforms

---

## 📞 Support

- **Documentation:** [ProfileCore Docs](../../docs/)
- **Architecture Guide:** [SOLID_ARCHITECTURE.md](../../docs/development/SOLID_ARCHITECTURE.md)
- **Issues:** [GitHub Issues](https://github.com/mythic3011/ProfileCore/issues)

---

## 📄 License

Plugins in this directory are part of ProfileCore and licensed under MIT License.

---

<div align="center">

**ProfileCore Plugin System** - _Extend Without Limits_

**[🏠 ProfileCore](../../README.md)** • **[📖 Architecture](../../docs/development/SOLID_ARCHITECTURE.md)** • **[🚀 Quick Start](../../QUICK_START.md)**

</div>
