# ProfileCore SOLID Architecture Guide

## 🏗️ Architecture Overview

ProfileCore has been redesigned following **SOLID principles** and design patterns to create a maintainable, extensible, and testable codebase. This guide explains the architecture and how to extend it.

---

## 📐 SOLID Principles Implementation

### 1. **Single Responsibility Principle (SRP)**

Each class has one reason to change:

- `PackageManagerProvider` - Package management logic
- `ConfigurationProvider` - Configuration loading logic  
- `OSProvider` - OS-specific operations
- `PluginBaseV2` - Plugin lifecycle and capabilities

### 2. **Open/Closed Principle (OCP)** ✅

**Classes are open for extension, closed for modification:**

#### Package Manager Providers
```powershell
# ❌ OLD WAY: Modify existing code to add new package manager
function Install-Package {
    if (scoop) { scoop install $pkg }
    elseif (choco) { choco install $pkg }
    # Need to modify this function for each new package manager
}

# ✅ NEW WAY: Extend by creating new provider class
class MyCustomProvider : PackageManagerProvider {
    MyCustomProvider() : base('mycustom', 'MyCustom', 10) { }
    
    [void] Install([string]$packageName, [hashtable]$options) {
        # Custom implementation
    }
    # ... other methods
}

# Register it (no modification to existing code)
$registry = Initialize-PackageManagerRegistry
$registry.RegisterProvider([MyCustomProvider]::new())
```

#### Configuration Providers
```powershell
# Create custom configuration source
class DatabaseConfigProvider : ConfigurationProvider {
    DatabaseConfigProvider() : base('database', 110) { }
    
    [hashtable] Load([string]$key) {
        # Load from database
    }
    
    [void] Save([string]$key, [hashtable]$config) {
        # Save to database
    }
}

# Register without modifying existing code
Register-ConfigurationProvider -Provider ([DatabaseConfigProvider]::new())
```

### 3. **Liskov Substitution Principle (LSP)**

Derived classes can replace base classes without breaking functionality:

```powershell
# Any PackageManagerProvider can be used interchangeably
$provider = [ScoopProvider]::new()
$provider = [ChocolateyProvider]::new()
$provider = [HomebrewProvider]::new()

# All support the same interface
$provider.Install('git', @{})
$provider.Search('python')
$provider.Update()
```

### 4. **Interface Segregation Principle (ISP)**

Clients depend only on methods they use:

```powershell
# Plugin capabilities are segregated
class MyPlugin : PluginBaseV2 {
    [void] OnLoad() {
        # Only implement what you need
        $cmdCapability = [CommandProviderCapability]::new()
        $cmdCapability.RegisterCommand('my-cmd', { Write-Host "Hello" })
        $this.RegisterCapability('CommandProvider', $cmdCapability)
    }
}
```

### 5. **Dependency Inversion Principle (DIP)**

Depend on abstractions, not concretions:

```powershell
# ❌ OLD WAY: Direct dependency on concrete implementation
function Do-Something {
    $config = Get-Content "C:\config.json" | ConvertFrom-Json
    # Tightly coupled to JSON files
}

# ✅ NEW WAY: Depend on abstraction
function Do-Something {
    $configManager = [ServiceLocator]::Get('ConfigurationManager')
    $config = $configManager.GetConfig('myconfig')
    # Works with any configuration provider
}
```

---

## 🎨 Design Patterns

### 1. **Strategy Pattern** - Package Managers

Different package managers are strategies that can be swapped:

```powershell
# Package manager strategy
$registry = Initialize-PackageManagerRegistry
$pm = $registry.GetBestProvider()  # Automatically selects best available
$pm = $registry.GetProvider('scoop')  # Specific strategy
$pm.Install('git', @{})
```

**Benefits:**
- Easy to add new package managers
- No code changes to add support
- Pluggable architecture

### 2. **Factory Pattern** - OS Abstraction

OS-specific implementations created by factory:

```powershell
# Factory creates appropriate OS provider
$osProvider = [OSProviderFactory]::Create()

# Returns WindowsOSProvider, LinuxOSProvider, or MacOSProvider
$osProvider.OpenFileExplorer($path)
$osProvider.GetAvailablePackageManagers()
```

**Benefits:**
- Platform-agnostic code
- Easy to add new OS support
- Centralized creation logic

### 3. **Provider Pattern** - Configuration

Multiple configuration sources with priority:

```powershell
# Configuration cascade (highest priority wins)
# Registry (80) -> Environment (90) -> .env (95) -> JSON (100)

$configManager = [ConfigurationManager]::new()
$value = $configManager.GetValue('config', 'theme', 'default')
```

**Benefits:**
- Multiple configuration sources
- Easy to add new sources
- Priority-based merging

### 4. **Chain of Responsibility** - Middleware Pipeline

Commands flow through middleware chain:

```powershell
# Middleware pipeline
# Request → Logging → Validation → Authorization → Caching → Handler

$registry = [CommandHandlerRegistry]::new()
$registry.RegisterHandler('my-command', {
    param($params)
    # Command logic
}, @{
    RequiresElevation = $true
    EnableCache = $true
})

$context = $registry.ExecuteCommand('my-command', @{ name = 'value' })
```

**Benefits:**
- Extensible command processing
- Reusable middleware
- Clear separation of concerns

### 5. **Dependency Injection** - Service Container

Services injected rather than hard-coded:

```powershell
# Register services
$container = [ServiceContainer]::new()
$container.RegisterSingleton('Logger', [Logger], { [Logger]::new() })
$container.RegisterTransient('EmailService', [EmailService], { [EmailService]::new() })

# Resolve with dependencies
$emailService = $container.Resolve('EmailService')
$logger = $emailService.GetService('Logger')  # Auto-injected
```

**Benefits:**
- Loose coupling
- Easy testing (mock services)
- Configurable lifetimes

---

## 📦 Extension Points

### 1. Custom Package Manager

```powershell
# 1. Create provider class
class NixProvider : PackageManagerProvider {
    NixProvider() : base('nix', 'Nix', 9) { }
    
    [bool] CheckAvailability() {
        return $null -ne (Get-Command nix -ErrorAction SilentlyContinue)
    }
    
    [void] Install([string]$packageName, [hashtable]$options) {
        nix-env -i $packageName
    }
    
    # Implement other methods...
}

# 2. Register it
Register-CustomPackageManager -Provider ([NixProvider]::new())
```

### 2. Custom Configuration Provider

```powershell
# 1. Create provider class
class VaultConfigProvider : ConfigurationProvider {
    [string]$VaultUrl
    
    VaultConfigProvider([string]$vaultUrl) : base('vault', 105) {
        $this.VaultUrl = $vaultUrl
    }
    
    [hashtable] Load([string]$key) {
        # Load from Vault
        $response = Invoke-RestMethod -Uri "$($this.VaultUrl)/v1/secret/$key"
        return $response.data
    }
    
    # Implement other methods...
}

# 2. Register it
Register-ConfigurationProvider -Provider ([VaultConfigProvider]::new('https://vault.local'))
```

### 3. Custom Middleware

```powershell
# 1. Create middleware class
class RateLimitMiddleware : CommandMiddleware {
    [hashtable]$RateLimits
    
    RateLimitMiddleware() : base('RateLimit', 15) {
        $this.RateLimits = @{}
    }
    
    [CommandContext] Process([CommandContext]$context, [scriptblock]$next) {
        $key = "$($context.CommandName):$(Get-Date -Format 'yyyyMMddHHmm')"
        
        if (-not $this.RateLimits.ContainsKey($key)) {
            $this.RateLimits[$key] = 0
        }
        
        $this.RateLimits[$key]++
        
        if ($this.RateLimits[$key] -gt 100) {
            $context.AddError("Rate limit exceeded")
            return $context
        }
        
        return & $next $context
    }
}

# 2. Register it
$registry = [CommandHandlerRegistry]::new()
$registry.AddMiddleware([RateLimitMiddleware]::new())
```

### 4. Custom Plugin with New Architecture

```powershell
# plugin-name.psm1
class MyAwesomePlugin : PluginBaseV2 {
    MyAwesomePlugin([ServiceContainer]$services) : base('MyAwesome', [version]'1.0.0', $services) {
        $this.Author = "YourName"
        $this.Description = "Does awesome things"
    }
    
    [void] OnLoad() {
        # Get services via dependency injection
        $pkgManager = $this.GetPackageManager()
        $configManager = $this.GetConfigurationManager()
        
        # Register command capability
        $cmdCapability = [CommandProviderCapability]::new()
        $cmdCapability.RegisterCommand('awesome', {
            param($params)
            Write-Host "Awesome command executed!"
        }, @{
            EnableCache = $true
            RequiresElevation = $false
        })
        
        $this.RegisterCapability('CommandProvider', $cmdCapability)
        
        $this.Log("Plugin loaded successfully", "Info")
    }
}

# Initialization function
function Initialize-MyAwesome {
    param([ServiceContainer]$Services)
    
    $plugin = [MyAwesomePlugin]::new($Services)
    $plugin.OnLoad()
    
    return $plugin
}

Export-ModuleMember -Function Initialize-MyAwesome
```

---

## 🔄 Data Flow

### Package Installation Flow

```
User calls Install-Package
    ↓
Initialize-PackageManagerRegistry (if needed)
    ↓
Get appropriate provider (Strategy Pattern)
    ↓
Execute provider.Install() (Provider Pattern)
    ↓
Package installed
```

### Configuration Loading Flow

```
User calls Get-ProfileConfiguration
    ↓
Initialize-ConfigurationManager (if needed)
    ↓
Load from all providers (Provider Pattern)
    ↓
Merge with priority (highest priority wins)
    ↓
Return configuration
```

### Command Execution Flow

```
User executes command
    ↓
Command Handler Registry
    ↓
Middleware Pipeline (Chain of Responsibility)
    ├─ Logging Middleware
    ├─ Validation Middleware
    ├─ Authorization Middleware
    ├─ Caching Middleware
    ↓
Command Handler
    ↓
Result returned through pipeline
```

### Plugin Loading Flow

```
Initialize-PluginSystem
    ↓
Discover plugins in ~/.profilecore/plugins
    ↓
Resolve dependencies (topological sort)
    ↓
Load dependencies first
    ↓
Initialize plugin with ServiceContainer (DI)
    ↓
Register capabilities
    ↓
Plugin ready
```

---

## 🧪 Testing Strategy

### Unit Testing

```powershell
# Test provider in isolation
Describe "ScoopProvider" {
    It "Should detect Scoop availability" {
        $provider = [ScoopProvider]::new()
        $provider.IsAvailable | Should -Be $true
    }
    
    It "Should install package" {
        $provider = [ScoopProvider]::new()
        { $provider.Install('git', @{}) } | Should -Not -Throw
    }
}
```

### Integration Testing

```powershell
# Test with service container
Describe "Package Manager Integration" {
    BeforeAll {
        $container = [ServiceContainer]::new()
    }
    
    It "Should resolve package manager from container" {
        $pm = $container.Resolve('PackageManager')
        $pm | Should -Not -BeNullOrEmpty
    }
}
```

### Mock Services

```powershell
# Mock for testing
class MockPackageManager : PackageManagerProvider {
    MockPackageManager() : base('mock', 'Mock', 999) { }
    
    [void] Install([string]$pkg, [hashtable]$opts) {
        # No-op for testing
    }
}

$registry.RegisterProvider([MockPackageManager]::new())
```

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface                        │
│          (PowerShell Profile / Commands)                 │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  Service Container (DI)                  │
│  ┌────────────┬─────────────┬──────────────────────┐    │
│  │ PackageMgr │ ConfigMgr   │ Other Services       │    │
│  └────────────┴─────────────┴──────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌──────────────┐ ┌─────────────┐ ┌──────────────┐
    │   Provider   │ │  Provider   │ │   Factory    │
    │   Pattern    │ │  Pattern    │ │   Pattern    │
    ├──────────────┤ ├─────────────┤ ├──────────────┤
    │ PackageMgrs  │ │   Config    │ │  OS Provider │
    │ - Scoop      │ │ - JSON      │ │ - Windows    │
    │ - Chocolatey │ │ - Env       │ │ - Linux      │
    │ - WinGet     │ │ - Registry  │ │ - macOS      │
    │ - Homebrew   │ │ - Vault     │ │              │
    │ - apt/dnf    │ │             │ │              │
    └──────────────┘ └─────────────┘ └──────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌──────────────┐ ┌─────────────┐ ┌──────────────┐
    │  Middleware  │ │   Plugin    │ │   Command    │
    │   Pipeline   │ │  Framework  │ │   Handler    │
    ├──────────────┤ ├─────────────┤ ├──────────────┤
    │ - Logging    │ │ Base Class  │ │ Registration │
    │ - Validation │ │ Lifecycle   │ │ Execution    │
    │ - Auth       │ │ DI Support  │ │ Metadata     │
    │ - Caching    │ │ Capability  │ │              │
    └──────────────┘ └─────────────┘ └──────────────┘
```

---

## 🎯 Best Practices

### 1. **Always Use Abstractions**

```powershell
# ❌ Bad: Direct implementation
$config = Get-Content "config.json" | ConvertFrom-Json

# ✅ Good: Use abstraction
$config = Get-ProfileConfiguration -Key 'config'
```

### 2. **Depend on Interfaces, Not Implementations**

```powershell
# ❌ Bad: Tight coupling
class MyFeature {
    [ScoopProvider]$PackageManager  # Tied to Scoop
}

# ✅ Good: Loose coupling
class MyFeature {
    [PackageManagerProvider]$PackageManager  # Any provider works
}
```

### 3. **Use Dependency Injection**

```powershell
# ❌ Bad: Create dependencies internally
class MyService {
    [Logger]$Logger
    
    MyService() {
        $this.Logger = [Logger]::new()  # Hard-coded dependency
    }
}

# ✅ Good: Inject dependencies
class MyService {
    [Logger]$Logger
    
    MyService([Logger]$logger) {
        $this.Logger = $logger  # Injected, testable
    }
}
```

### 4. **Single Responsibility**

```powershell
# ❌ Bad: God class
class ProfileManager {
    Install-Package() { }
    Load-Config() { }
    Detect-OS() { }
    Log-Event() { }
    # Too many responsibilities
}

# ✅ Good: Separate responsibilities
class PackageManager { Install-Package() { } }
class ConfigLoader { Load-Config() { } }
class OSDetector { Detect-OS() { } }
class Logger { Log-Event() { } }
```

### 5. **Open for Extension, Closed for Modification**

```powershell
# ❌ Bad: Modify existing code
function Install-Package {
    # Add new if/elseif for each package manager
}

# ✅ Good: Extend through new classes
class NewPackageManager : PackageManagerProvider {
    # Just add new class, no modification needed
}
```

---

## 📚 Further Reading

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns](https://refactoring.guru/design-patterns)
- [Dependency Injection](https://martinfowler.com/articles/injection.html)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🤝 Contributing

When adding new features:

1. ✅ Follow SOLID principles
2. ✅ Use existing patterns (Provider, Strategy, Factory)
3. ✅ Create abstractions (base classes/interfaces)
4. ✅ Support dependency injection
5. ✅ Add unit tests
6. ✅ Document extension points

**Example Pull Request Checklist:**

- [ ] New feature extends existing abstraction (not modifies)
- [ ] Added provider/strategy for extensibility
- [ ] Supports dependency injection
- [ ] Includes unit tests
- [ ] Updated documentation
- [ ] Follows naming conventions

---

<div align="center">

**ProfileCore** - _Architecture that scales with your needs_

**[📖 Back to Docs](../README.md)** • **[🏠 Home](../../README.md)** • **[🚀 Quick Start](../../QUICK_START.md)**

</div>

