# Plugin System Implementation Guide

**Phase 3 of v5.0 Roadmap - Extensible Plugin Architecture**

---

## 🎯 Overview

Phase 3 introduces a comprehensive plugin system to ProfileCore, enabling community contributions and custom extensions without modifying core code.

**Goals:**

1. **Easy Plugin Development** - Simple API for creating plugins
2. **Secure Execution** - Sandboxed plugin environment
3. **Auto-Discovery** - Automatic plugin loading and registration
4. **Community Marketplace** - Central registry for sharing plugins
5. **Version Management** - Handle dependencies and updates

---

## 🏗️ Architecture

### Plugin Lifecycle

```
Discovery → Validation → Loading → Registration → Execution → Unloading
     ↓
Auto-Update Check
```

### Directory Structure

```
~/.profilecore/
├── plugins/
│   ├── kubernetes-tools/
│   │   ├── plugin.psd1           # Manifest
│   │   ├── kubernetes-tools.psm1 # Main module
│   │   ├── README.md
│   │   └── functions/
│   │       ├── Get-K8sPods.ps1
│   │       └── Switch-K8sContext.ps1
│   ├── aws-cli-enhanced/
│   │   ├── plugin.psd1
│   │   ├── aws-cli-enhanced.psm1
│   │   └── functions/
│   └── docker-shortcuts/
│       ├── plugin.psd1
│       └── docker-shortcuts.psm1
├── plugins.json                   # Installed plugins registry
└── plugin-cache/                  # Cache for plugin data
```

---

## 📦 Plugin Manifest

### plugin.psd1 Format

```powershell
@{
    # Plugin metadata
    Name = 'kubernetes-tools'
    Version = '1.0.0'
    Author = 'YourName'
    Description = 'Enhanced Kubernetes management tools for ProfileCore'

    # Requirements
    PowerShellVersion = '5.1'
    ProfileCoreVersion = '4.0.0'

    # Dependencies
    RequiredModules = @(
        @{ ModuleName = 'powershell-yaml'; ModuleVersion = '0.4.0' }
    )

    # Plugin capabilities
    Capabilities = @{
        Commands = @('Get-K8sPods', 'Switch-K8sContext', 'Get-K8sStatus')
        Aliases = @('k8s-pods', 'k8s-ctx', 'k8s-status')
        Hooks = @('PreCommand', 'PostCommand')
        Configuration = $true
        BackgroundTasks = $false
    }

    # Security
    Permissions = @{
        FileSystem = 'Read'      # Read, Write, None
        Network = 'Full'         # Full, Limited, None
        Registry = 'None'
        ExecuteCommands = $true
    }

    # Lifecycle hooks
    OnInstall = 'Initialize-Plugin'
    OnLoad = 'Start-Plugin'
    OnUnload = 'Stop-Plugin'
    OnUninstall = 'Remove-Plugin'

    # Resources
    ProjectUri = 'https://github.com/username/kubernetes-tools'
    LicenseUri = 'https://github.com/username/kubernetes-tools/blob/main/LICENSE'
    IconUri = 'https://github.com/username/kubernetes-tools/blob/main/icon.png'

    # Tags for discovery
    Tags = @('kubernetes', 'k8s', 'containers', 'devops')
}
```

---

## 🔧 Plugin Development

### Step 1: Create Plugin Template

```````powershell
function New-ProfileCorePlugin {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('Basic', 'Advanced', 'DevOps', 'Security')]
        [string]$Template = 'Basic',

        [string]$OutputPath = "~/.profilecore/plugins"
    )

    $pluginPath = Join-Path $OutputPath $Name

    # Create directory structure
    New-Item -Path $pluginPath -ItemType Directory -Force
    New-Item -Path "$pluginPath/functions" -ItemType Directory -Force

    # Create manifest
    $manifest = @{
        Name = $Name
        Version = '0.1.0'
        Author = $env:USERNAME
        Description = "A ProfileCore plugin for $Name"
        PowerShellVersion = '5.1'
        ProfileCoreVersion = '4.0.0'
        Capabilities = @{
            Commands = @()
            Aliases = @()
        }
        Permissions = @{
            FileSystem = 'Read'
            Network = 'None'
            Registry = 'None'
            ExecuteCommands = $false
        }
    }

    $manifest | Export-Clixml -Path "$pluginPath/plugin.psd1"

    # Create main module
    $moduleContent = @"
<#
.SYNOPSIS
    $Name Plugin for ProfileCore
.DESCRIPTION
    Plugin created from template: $Template
#>

# Import plugin framework
using module ProfileCore.PluginFramework

# Plugin initialization
function Initialize-Plugin {
    Write-Host "Initializing $Name plugin..." -ForegroundColor Cyan
}

# Add your functions here
function Get-Example {
    [CmdletBinding()]
    param()

    Write-Host "Example function from $Name plugin" -ForegroundColor Green
}

# Export functions
Export-ModuleMember -Function Get-Example
"@

    $moduleContent | Out-File "$pluginPath/$Name.psm1"

    # Create README
    $readme = @"
# $Name Plugin

## Description
Plugin for ProfileCore

## Installation
``````powershell
Install-ProfileCorePlugin -Name $Name
```````

## Usage

```powershell
Get-Example
```

## License

MIT
"@

    $readme | Out-File "$pluginPath/README.md"

    Write-Host "`n✅ Plugin created at: $pluginPath" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. Edit $pluginPath/$Name.psm1" -ForegroundColor White
    Write-Host "  2. Add your functions to $pluginPath/functions/" -ForegroundColor White
    Write-Host "  3. Update $pluginPath/plugin.psd1" -ForegroundColor White
    Write-Host "  4. Test with: Test-ProfileCorePlugin -Path $pluginPath" -ForegroundColor White

}

````

### Step 2: Plugin Framework Base Class

```powershell
# ProfileCore.PluginFramework module

class PluginBase {
    [string]$Name
    [version]$Version
    [hashtable]$Config
    [bool]$IsLoaded

    # Constructor
    PluginBase([string]$name, [version]$version) {
        $this.Name = $name
        $this.Version = $version
        $this.IsLoaded = $false
        $this.Config = @{}
    }

    # Lifecycle methods (override in plugins)
    [void] OnLoad() {
        Write-Verbose "Loading plugin: $($this.Name)"
    }

    [void] OnUnload() {
        Write-Verbose "Unloading plugin: $($this.Name)"
    }

    [void] OnConfigChange([hashtable]$newConfig) {
        $this.Config = $newConfig
    }

    # Utility methods available to all plugins
    [string] GetConfigValue([string]$key) {
        if ($this.Config.ContainsKey($key)) {
            return $this.Config[$key]
        }
        return $null
    }

    [void] Log([string]$message, [string]$level = 'Info') {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logMessage = "[$timestamp] [$($this.Name)] [$level] $message"
        Add-Content -Path "~/.profilecore/logs/plugin-$($this.Name).log" -Value $logMessage
    }

    [void] EmitEvent([string]$eventName, [hashtable]$data) {
        $global:ProfileCore.EventBus.Emit($eventName, $data)
    }
}
````

### Step 3: Example Plugin - Kubernetes Tools

```powershell
# kubernetes-tools.psm1

using module ProfileCore.PluginFramework

class KubernetesPlugin : PluginBase {
    [string]$CurrentContext

    KubernetesPlugin() : base('kubernetes-tools', '1.0.0') {
    }

    [void] OnLoad() {
        $this.Log("Kubernetes plugin loaded", "Info")
        $this.CurrentContext = $this.GetCurrentK8sContext()
    }

    [string] GetCurrentK8sContext() {
        try {
            $context = kubectl config current-context
            return $context
        } catch {
            return "none"
        }
    }
}

# Initialize plugin instance
$script:PluginInstance = [KubernetesPlugin]::new()

# Plugin functions
function Get-K8sPods {
    [CmdletBinding()]
    param(
        [string]$Namespace = "default",
        [switch]$AllNamespaces
    )

    $script:PluginInstance.Log("Getting pods in namespace: $Namespace", "Info")

    if ($AllNamespaces) {
        kubectl get pods --all-namespaces --output=wide
    } else {
        kubectl get pods -n $Namespace --output=wide
    }
}

function Switch-K8sContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Context
    )

    try {
        kubectl config use-context $Context
        $script:PluginInstance.CurrentContext = $Context
        $script:PluginInstance.Log("Switched to context: $Context", "Info")

        Write-Host "✅ Switched to Kubernetes context: $Context" -ForegroundColor Green
    } catch {
        $script:PluginInstance.Log("Failed to switch context: $_", "Error")
        Write-Error "Failed to switch context: $_"
    }
}

function Get-K8sStatus {
    [CmdletBinding()]
    param()

    Write-Host "`n📊 Kubernetes Status" -ForegroundColor Cyan
    Write-Host "  Context: $($script:PluginInstance.CurrentContext)" -ForegroundColor White

    $nodes = kubectl get nodes --no-headers 2>$null
    Write-Host "  Nodes: $(($nodes | Measure-Object).Count)" -ForegroundColor White

    $pods = kubectl get pods --all-namespaces --no-headers 2>$null
    Write-Host "  Pods: $(($pods | Measure-Object).Count)" -ForegroundColor White
}

# Aliases
Set-Alias -Name k8s-pods -Value Get-K8sPods
Set-Alias -Name k8s-ctx -Value Switch-K8sContext
Set-Alias -Name k8s-status -Value Get-K8sStatus

# Export
Export-ModuleMember -Function Get-K8sPods, Switch-K8sContext, Get-K8sStatus -Alias k8s-pods, k8s-ctx, k8s-status
```

---

## 🔍 Plugin Discovery & Loading

### Plugin Manager

```powershell
class PluginManager {
    [hashtable]$LoadedPlugins
    [string]$PluginDirectory
    [hashtable]$PluginRegistry

    PluginManager() {
        $this.LoadedPlugins = @{}
        $this.PluginDirectory = "~/.profilecore/plugins"
        $this.PluginRegistry = @{}

        # Ensure directory exists
        if (-not (Test-Path $this.PluginDirectory)) {
            New-Item -Path $this.PluginDirectory -ItemType Directory -Force
        }
    }

    # Discover all plugins
    [void] DiscoverPlugins() {
        Write-Verbose "Discovering plugins in: $($this.PluginDirectory)"

        $pluginDirs = Get-ChildItem -Path $this.PluginDirectory -Directory

        foreach ($dir in $pluginDirs) {
            $manifestPath = Join-Path $dir.FullName "plugin.psd1"

            if (Test-Path $manifestPath) {
                try {
                    $manifest = Import-PowerShellDataFile -Path $manifestPath
                    $this.PluginRegistry[$manifest.Name] = @{
                        Path = $dir.FullName
                        Manifest = $manifest
                        Loaded = $false
                    }

                    Write-Verbose "Discovered plugin: $($manifest.Name) v$($manifest.Version)"
                } catch {
                    Write-Warning "Failed to load manifest for: $($dir.Name)"
                }
            }
        }
    }

    # Load a specific plugin
    [bool] LoadPlugin([string]$pluginName) {
        if (-not $this.PluginRegistry.ContainsKey($pluginName)) {
            Write-Error "Plugin not found: $pluginName"
            return $false
        }

        $plugin = $this.PluginRegistry[$pluginName]
        $manifest = $plugin.Manifest

        # Validate requirements
        if (-not $this.ValidateRequirements($manifest)) {
            return $false
        }

        # Check permissions
        if (-not $this.CheckPermissions($manifest)) {
            Write-Warning "Plugin $pluginName requires additional permissions"
            return $false
        }

        try {
            # Load dependencies first
            if ($manifest.RequiredModules) {
                foreach ($module in $manifest.RequiredModules) {
                    if (-not (Get-Module -ListAvailable -Name $module.ModuleName)) {
                        Write-Host "Installing dependency: $($module.ModuleName)" -ForegroundColor Yellow
                        Install-Module -Name $module.ModuleName -RequiredVersion $module.ModuleVersion -Force
                    }
                }
            }

            # Import plugin module
            $modulePath = Join-Path $plugin.Path "$pluginName.psm1"
            Import-Module $modulePath -Force -Global

            # Run OnLoad hook
            if ($manifest.OnLoad) {
                & $manifest.OnLoad
            }

            $this.LoadedPlugins[$pluginName] = $plugin
            $plugin.Loaded = $true

            Write-Host "✅ Plugin loaded: $pluginName v$($manifest.Version)" -ForegroundColor Green
            return $true

        } catch {
            Write-Error "Failed to load plugin $pluginName`: $_"
            return $false
        }
    }

    # Validate plugin requirements
    [bool] ValidateRequirements([hashtable]$manifest) {
        # Check PowerShell version
        if ($manifest.PowerShellVersion) {
            $requiredVersion = [version]$manifest.PowerShellVersion
            $currentVersion = $PSVersionTable.PSVersion

            if ($currentVersion -lt $requiredVersion) {
                Write-Error "Plugin requires PowerShell $requiredVersion (current: $currentVersion)"
                return $false
            }
        }

        # Check ProfileCore version
        if ($manifest.ProfileCoreVersion) {
            $requiredVersion = [version]$manifest.ProfileCoreVersion
            $currentVersion = Get-ProfileCoreVersion

            if ($currentVersion -lt $requiredVersion) {
                Write-Error "Plugin requires ProfileCore $requiredVersion (current: $currentVersion)"
                return $false
            }
        }

        return $true
    }

    # Check security permissions
    [bool] CheckPermissions([hashtable]$manifest) {
        if (-not $manifest.Permissions) {
            return $true
        }

        $permissions = $manifest.Permissions
        $dangerous = @()

        if ($permissions.FileSystem -eq 'Write') {
            $dangerous += "File System Write Access"
        }
        if ($permissions.Network -eq 'Full') {
            $dangerous += "Full Network Access"
        }
        if ($permissions.ExecuteCommands -eq $true) {
            $dangerous += "Execute External Commands"
        }

        if ($dangerous.Count -gt 0) {
            Write-Warning "Plugin requests the following permissions:"
            $dangerous | ForEach-Object { Write-Warning "  - $_" }

            $response = Read-Host "Grant these permissions? (y/N)"
            return ($response -eq 'y')
        }

        return $true
    }

    # Load all enabled plugins
    [void] LoadAllPlugins() {
        $this.DiscoverPlugins()

        foreach ($pluginName in $this.PluginRegistry.Keys) {
            $this.LoadPlugin($pluginName)
        }
    }

    # Unload plugin
    [void] UnloadPlugin([string]$pluginName) {
        if ($this.LoadedPlugins.ContainsKey($pluginName)) {
            $plugin = $this.LoadedPlugins[$pluginName]
            $manifest = $plugin.Manifest

            # Run OnUnload hook
            if ($manifest.OnUnload) {
                & $manifest.OnUnload
            }

            # Remove module
            Remove-Module -Name $pluginName -Force -ErrorAction SilentlyContinue

            $this.LoadedPlugins.Remove($pluginName)
            $plugin.Loaded = $false

            Write-Host "✅ Plugin unloaded: $pluginName" -ForegroundColor Green
        }
    }

    # Get loaded plugins
    [array] GetLoadedPlugins() {
        return $this.LoadedPlugins.Keys
    }
}

# Global plugin manager instance
$global:ProfileCore.PluginManager = [PluginManager]::new()
```

---

## 📥 Plugin Installation

### Install from Registry

```powershell
function Install-ProfileCorePlugin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [string]$Version = 'latest',

        [string]$Source = 'https://registry.profilecore.dev',

        [switch]$Force
    )

    Write-Host "📥 Installing plugin: $Name" -ForegroundColor Cyan

    # Check if already installed
    $pluginPath = "~/.profilecore/plugins/$Name"
    if ((Test-Path $pluginPath) -and -not $Force) {
        Write-Warning "Plugin already installed. Use -Force to reinstall."
        return
    }

    try {
        # Query registry
        $pluginInfo = Invoke-RestMethod -Uri "$Source/api/plugins/$Name" -Method Get

        if ($Version -eq 'latest') {
            $Version = $pluginInfo.latestVersion
        }

        # Download plugin
        $downloadUrl = "$Source/api/plugins/$Name/versions/$Version/download"
        $tempFile = New-TemporaryFile

        Write-Host "Downloading from: $downloadUrl" -ForegroundColor Gray
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

        # Extract
        if (Test-Path $pluginPath) {
            Remove-Item $pluginPath -Recurse -Force
        }

        Expand-Archive -Path $tempFile -DestinationPath $pluginPath
        Remove-Item $tempFile

        # Verify manifest
        $manifestPath = Join-Path $pluginPath "plugin.psd1"
        if (-not (Test-Path $manifestPath)) {
            throw "Invalid plugin: manifest not found"
        }

        Write-Host "✅ Plugin installed: $Name v$Version" -ForegroundColor Green
        Write-Host "`nLoad the plugin with:" -ForegroundColor Yellow
        Write-Host "  Enable-ProfileCorePlugin -Name $Name" -ForegroundColor Cyan

    } catch {
        Write-Error "Failed to install plugin: $_"

        # Cleanup on failure
        if (Test-Path $pluginPath) {
            Remove-Item $pluginPath -Recurse -Force
        }
    }
}
```

### Install from GitHub

```powershell
function Install-ProfileCorePluginFromGitHub {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Repository,  # Format: owner/repo

        [string]$Branch = 'main'
    )

    $pluginName = ($Repository -split '/')[1]
    $downloadUrl = "https://github.com/$Repository/archive/refs/heads/$Branch.zip"

    Write-Host "📥 Installing plugin from GitHub: $Repository" -ForegroundColor Cyan

    $tempFile = New-TemporaryFile
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }

    try {
        # Download
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

        # Extract
        Expand-Archive -Path $tempFile -DestinationPath $tempDir

        # Find plugin directory
        $extractedDir = Get-ChildItem $tempDir -Directory | Select-Object -First 1
        $pluginPath = "~/.profilecore/plugins/$pluginName"

        # Move to plugins directory
        if (Test-Path $pluginPath) {
            Remove-Item $pluginPath -Recurse -Force
        }

        Move-Item $extractedDir.FullName $pluginPath

        Write-Host "✅ Plugin installed from GitHub: $pluginName" -ForegroundColor Green

    } finally {
        Remove-Item $tempFile -ErrorAction SilentlyContinue
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
```

---

## 🔌 Plugin Management Commands

### Enable/Disable Plugins

```powershell
function Enable-ProfileCorePlugin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $result = $global:ProfileCore.PluginManager.LoadPlugin($Name)

    if ($result) {
        # Save to auto-load list
        $autoLoad = Get-Content "~/.profilecore/plugins.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
        if (-not $autoLoad) {
            $autoLoad = @{ enabled = @() }
        }

        if ($Name -notin $autoLoad.enabled) {
            $autoLoad.enabled += $Name
            $autoLoad | ConvertTo-Json | Set-Content "~/.profilecore/plugins.json"
        }
    }
}

function Disable-ProfileCorePlugin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $global:ProfileCore.PluginManager.UnloadPlugin($Name)

    # Remove from auto-load list
    $autoLoad = Get-Content "~/.profilecore/plugins.json" -ErrorAction SilentlyContinue | ConvertFrom-Json
    if ($autoLoad -and $autoLoad.enabled) {
        $autoLoad.enabled = $autoLoad.enabled | Where-Object { $_ -ne $Name }
        $autoLoad | ConvertTo-Json | Set-Content "~/.profilecore/plugins.json"
    }
}
```

### List Plugins

```powershell
function Get-ProfileCorePlugins {
    [CmdletBinding()]
    param(
        [switch]$LoadedOnly
    )

    $manager = $global:ProfileCore.PluginManager
    $manager.DiscoverPlugins()

    $plugins = @()

    foreach ($name in $manager.PluginRegistry.Keys) {
        $plugin = $manager.PluginRegistry[$name]
        $manifest = $plugin.Manifest

        if ($LoadedOnly -and -not $plugin.Loaded) {
            continue
        }

        $plugins += [PSCustomObject]@{
            Name = $name
            Version = $manifest.Version
            Author = $manifest.Author
            Description = $manifest.Description
            Loaded = $plugin.Loaded
            Commands = $manifest.Capabilities.Commands.Count
        }
    }

    if ($plugins.Count -eq 0) {
        Write-Host "No plugins found." -ForegroundColor Yellow
        Write-Host "Install plugins with: Install-ProfileCorePlugin -Name <plugin-name>" -ForegroundColor Gray
        return
    }

    $plugins | Format-Table -AutoSize
}
```

---

## 🧪 Testing Plugins

```powershell
function Test-ProfileCorePlugin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    Write-Host "🧪 Testing plugin at: $Path" -ForegroundColor Cyan

    $tests = @{
        "Manifest exists" = Test-Path (Join-Path $Path "plugin.psd1")
        "Module exists" = $false
        "Manifest valid" = $false
        "No syntax errors" = $false
    }

    # Check manifest
    if ($tests["Manifest exists"]) {
        try {
            $manifest = Import-PowerShellDataFile -Path (Join-Path $Path "plugin.psd1")
            $tests["Manifest valid"] = $true

            # Check for module
            $modulePath = Join-Path $Path "$($manifest.Name).psm1"
            $tests["Module exists"] = Test-Path $modulePath

            # Check syntax
            if ($tests["Module exists"]) {
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $modulePath -Raw), [ref]$errors)
                $tests["No syntax errors"] = ($errors.Count -eq 0)
            }

        } catch {
            Write-Warning "Manifest validation failed: $_"
        }
    }

    # Display results
    Write-Host "`nTest Results:" -ForegroundColor Yellow
    foreach ($test in $tests.GetEnumerator()) {
        $status = if ($test.Value) { "✅ PASS" } else { "❌ FAIL" }
        Write-Host "  $status - $($test.Key)" -ForegroundColor $(if ($test.Value) { "Green" } else { "Red" })
    }

    $passCount = ($tests.Values | Where-Object { $_ }).Count
    $totalCount = $tests.Count

    Write-Host "`nScore: $passCount/$totalCount" -ForegroundColor Cyan

    return ($passCount -eq $totalCount)
}
```

---

## 🌐 Plugin Registry (Community Marketplace)

### Registry API

```powershell
# Search plugins
function Search-ProfileCorePlugins {
    [CmdletBinding()]
    param(
        [string]$Query,
        [string[]]$Tags
    )

    $registryUrl = "https://registry.profilecore.dev/api/plugins/search"

    $params = @{
        q = $Query
        tags = $Tags -join ','
    }

    try {
        $results = Invoke-RestMethod -Uri $registryUrl -Method Get -Body $params

        Write-Host "`n🔍 Search Results:" -ForegroundColor Cyan

        foreach ($plugin in $results) {
            Write-Host "`n📦 $($plugin.name) v$($plugin.latestVersion)" -ForegroundColor Green
            Write-Host "   $($plugin.description)" -ForegroundColor White
            Write-Host "   Author: $($plugin.author)" -ForegroundColor Gray
            Write-Host "   Downloads: $($plugin.downloads)" -ForegroundColor Gray
            Write-Host "   Tags: $($plugin.tags -join ', ')" -ForegroundColor Gray
            Write-Host "   Install: Install-ProfileCorePlugin -Name $($plugin.name)" -ForegroundColor Yellow
        }

    } catch {
        Write-Error "Failed to search plugins: $_"
    }
}

# Publish plugin
function Publish-ProfileCorePlugin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    # Validate plugin first
    if (-not (Test-ProfileCorePlugin -Path $Path)) {
        Write-Error "Plugin validation failed. Fix errors before publishing."
        return
    }

    # Create package
    $manifest = Import-PowerShellDataFile -Path (Join-Path $Path "plugin.psd1")
    $packagePath = "$env:TEMP/$($manifest.Name)-$($manifest.Version).zip"

    Compress-Archive -Path "$Path/*" -DestinationPath $packagePath -Force

    # Upload to registry
    try {
        $headers = @{
            "X-API-Key" = $ApiKey
        }

        $form = @{
            package = Get-Item $packagePath
            manifest = ($manifest | ConvertTo-Json)
        }

        $response = Invoke-RestMethod -Uri "https://registry.profilecore.dev/api/plugins/publish" `
            -Method Post -Headers $headers -Form $form

        Write-Host "✅ Plugin published successfully!" -ForegroundColor Green
        Write-Host "   Name: $($manifest.Name)" -ForegroundColor White
        Write-Host "   Version: $($manifest.Version)" -ForegroundColor White
        Write-Host "   URL: $($response.url)" -ForegroundColor Cyan

    } catch {
        Write-Error "Failed to publish plugin: $_"
    } finally {
        Remove-Item $packagePath -ErrorAction SilentlyContinue
    }
}
```

---

## 📊 Plugin Examples

### Example 1: AWS CLI Enhanced

```powershell
# aws-cli-enhanced.psm1

function Get-AWSProfiles {
    $config = Get-Content ~/.aws/config -Raw
    $profiles = $config | Select-String '(?<=\[profile ).*?(?=\])' -AllMatches
    return $profiles.Matches.Value
}

function Switch-AWSProfile {
    param([string]$ProfileName)
    $env:AWS_PROFILE = $ProfileName
    Write-Host "✅ Switched to AWS profile: $ProfileName" -ForegroundColor Green
}

function Get-AWSCurrentProfile {
    if ($env:AWS_PROFILE) {
        Write-Host "Current AWS Profile: $env:AWS_PROFILE" -ForegroundColor Cyan
    } else {
        Write-Host "Using default AWS profile" -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function Get-AWSProfiles, Switch-AWSProfile, Get-AWSCurrentProfile
```

### Example 2: Docker Shortcuts

```powershell
# docker-shortcuts.psm1

function Get-DockerQuickStatus {
    Write-Host "`n🐋 Docker Quick Status" -ForegroundColor Cyan
    Write-Host "  Containers running: $(docker ps --format '{{.ID}}' | Measure-Object -Line | Select-Object -ExpandProperty Lines)" -ForegroundColor White
    Write-Host "  Images: $(docker images --format '{{.ID}}' | Measure-Object -Line | Select-Object -ExpandProperty Lines)" -ForegroundColor White
    Write-Host "  Volumes: $(docker volume ls --format '{{.Name}}' | Measure-Object -Line | Select-Object -ExpandProperty Lines)" -ForegroundColor White
}

function Remove-DockerDangling {
    Write-Host "🗑️  Removing dangling images..." -ForegroundColor Yellow
    docker image prune -f
    Write-Host "✅ Done" -ForegroundColor Green
}

Set-Alias -Name dqs -Value Get-DockerQuickStatus
Set-Alias -Name dclean -Value Remove-DockerDangling

Export-ModuleMember -Function Get-DockerQuickStatus, Remove-DockerDangling -Alias dqs, dclean
```

---

## 🔒 Security Considerations

### Sandboxing

```powershell
# Execute plugin code in constrained runspace
function Invoke-PluginInSandbox {
    param(
        [scriptblock]$ScriptBlock,
        [hashtable]$Permissions
    )

    $initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

    # Remove dangerous commands if permissions not granted
    if ($Permissions.ExecuteCommands -ne $true) {
        $initialSessionState.Commands.Remove("Invoke-Expression")
        $initialSessionState.Commands.Remove("Invoke-Command")
    }

    if ($Permissions.FileSystem -ne 'Write') {
        $initialSessionState.Commands.Remove("Remove-Item")
        $initialSessionState.Commands.Remove("New-Item")
    }

    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($initialSessionState)
    $runspace.Open()

    $pipeline = $runspace.CreatePipeline($ScriptBlock.ToString())
    $result = $pipeline.Invoke()

    $runspace.Close()

    return $result
}
```

### Code Signing

```powershell
function Test-PluginSignature {
    param([string]$Path)

    $manifest = Join-Path $Path "plugin.psd1"
    $signature = Get-AuthenticodeSignature $manifest

    if ($signature.Status -eq 'Valid') {
        Write-Host "✅ Plugin signature valid" -ForegroundColor Green
        return $true
    } else {
        Write-Warning "Plugin is not signed or signature is invalid"
        return $false
    }
}
```

---

## 📚 Documentation

### Plugin Development Guide

- API Reference
- Best Practices
- Security Guidelines
- Publishing Guide

### Community Resources

- Plugin Template Repository
- Example Plugins
- Discussion Forum
- Plugin Registry

---

<div align="center">

**Phase 3: Plugin System** - _Extend ProfileCore Your Way_ 🔌

**[← Back to Roadmap](roadmap.md)** • **[📖 Full Docs](../../README.md)** • **[🤖 AI Features](ai-features-implementation.md)**

</div>
