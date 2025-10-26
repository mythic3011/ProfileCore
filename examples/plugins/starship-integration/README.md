# Starship Integration Plugin

Beautiful, cross-platform prompt customization for ProfileCore v6.1.0.

## Overview

This plugin demonstrates ProfileCore's PluginSystem by integrating [Starship](https://starship.rs/) - a fast, customizable prompt for any shell. It showcases:

- **PluginBaseV2 Usage**: Modern plugin architecture with DI integration
- **Cross-Shell Support**: Works in PowerShell, Bash, Zsh, and Fish
- **Rust Acceleration**: Optional 10x faster prompt rendering with Rust FFI
- **Unified Configuration**: Single config file for all shells
- **Auto-Installation**: Automatic Starship installation and setup

## Features

✨ **Beautiful Prompts**: Modern, informative prompt with git integration  
⚡ **Fast**: Rust-powered rendering (when available)  
🌍 **Universal**: Same config across PowerShell, Bash, Zsh, Fish  
🔧 **Customizable**: Easy theming and configuration  
🔌 **Plugin Architecture**: Cleanly integrates with ProfileCore DI  

## Requirements

- ProfileCore v6.1.0+
- PowerShell 7+ (recommended)
- Starship (auto-installed if missing)

## Quick Start

### Installation

```powershell
# Option 1: Use ProfileCore's plugin system
Enable-ProfileCorePlugin -Name Starship

# Option 2: Manual installation for all shells
.\shells\common\starship\install.ps1 -InstallStarship -Shell All
```

### Basic Usage

```powershell
# Enable Starship prompt
Enable-StarshipPrompt

# Check status
Get-StarshipStatus

# Disable (restore default)
Disable-StarshipPrompt
```

## Commands

| Command | Description |
|---------|-------------|
| `Enable-StarshipPrompt` | Activate Starship prompt |
| `Disable-StarshipPrompt` | Restore default prompt |
| `Get-StarshipStatus` | View plugin status |
| `Update-StarshipConfig` | Apply theme or custom config |
| `Test-StarshipInstalled` | Check if Starship is installed |
| `Install-Starship` | Install Starship (if missing) |

## Configuration

### Location

Configuration file: `~/.profilecore/starship.toml`

This file is shared across all shells for consistency.

### Using Preset Themes

```powershell
# Apply minimal theme
Update-StarshipConfig -Theme minimal

# Apply nerd-font theme (requires Nerd Font)
Update-StarshipConfig -Theme nerd-font

# Apply classic theme
Update-StarshipConfig -Theme classic
```

### Custom Configuration

```powershell
# Use your own starship.toml
Update-StarshipConfig -CustomConfig ~/my-starship.toml
```

### Manual Editing

```powershell
# Edit config file directly
code ~/.profilecore/starship.toml

# Or use your favorite editor
nano ~/.profilecore/starship.toml
```

## Cross-Shell Installation

### PowerShell Only

```powershell
.\shells\common\starship\install.ps1 -InstallStarship -Shell PowerShell
```

### All Shells

```powershell
.\shells\common\starship\install.ps1 -InstallStarship -Shell All
```

### Unix (Bash/Zsh/Fish)

```bash
# From project root
cd shells/common/starship
chmod +x install.sh

# Install for Bash
./install.sh --install-starship --shell bash

# Install for all shells
./install.sh --install-starship --shell all
```

## How It Works

### Architecture

```
┌────────────────────────────────────────────┐
│ PowerShell Commands                         │
│ (Enable-StarshipPrompt, etc.)               │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│ StarshipPlugin : PluginBaseV2               │
│ • Implements lifecycle methods              │
│ • Uses DI for Logger, Config                │
│ • Manages prompt state                      │
└──────────────┬─────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────┐
│ Starship Binary                             │
│ • Renders prompt segments                   │
│ • Fast git status                           │
│ • Cross-shell compatible                    │
└──────────────┬─────────────────────────────┘
               │
               ▼ (Optional)
┌────────────────────────────────────────────┐
│ ProfileCore Rust Module                     │
│ • RenderPromptSegment() - 10x faster        │
│ • GetCurrentShell() - shell detection       │
│ • BenchmarkPromptRender() - performance     │
└────────────────────────────────────────────┘
```

### Plugin Lifecycle

1. **OnInitialize()**: Check Starship installation, set config path
2. **OnLoad()**: Store original prompt for restoration
3. **EnablePrompt()**: Initialize Starship, set environment, update prompt
4. **OnUnload()**: Restore original prompt if enabled

### DI Integration

The plugin uses ProfileCore's DI container to access:

- **ILogProvider**: Structured logging
- **IConfigProvider**: Configuration storage
- **IPluginManager**: Plugin lifecycle management

## Examples

### Example 1: Basic Setup

```powershell
# Import ProfileCore
Import-Module ProfileCore

# Enable Starship plugin
Enable-ProfileCorePlugin -Name Starship

# Activate prompt
Enable-StarshipPrompt

# Check status
Get-StarshipStatus
```

### Example 2: Custom Theme

```powershell
# Enable with minimal theme
Enable-StarshipPrompt
Update-StarshipConfig -Theme minimal

# Restart shell to see changes
```

### Example 3: Conditional Loading

```powershell
# Only enable if Starship is installed
if (Test-StarshipInstalled) {
    Enable-StarshipPrompt
} else {
    Write-Host "Install Starship with: Install-Starship"
}
```

### Example 4: Programmatic Control

```powershell
# Get plugin instance
$pluginManager = Resolve-Service 'IPluginManager'
$starship = $pluginManager.GetPlugin('Starship')

# Check if enabled
if ($starship.PromptEnabled) {
    Write-Host "Starship is active"
    
    # Get configuration path
    Write-Host "Config: $($starship.ConfigPath)"
}
```

## Performance

### Rust Acceleration

When ProfileCore's Rust module is available, Starship can use `RenderPromptSegment()` for 10x faster prompt rendering:

```
Without Rust: ~5-10ms per prompt
With Rust:    ~0.5-1ms per prompt
```

Check Rust availability:
```powershell
Test-ProfileCoreRustAvailable
```

### Benchmarking

```powershell
# Measure prompt render time
Measure-Command { prompt }

# Or use Rust benchmark
$metrics = Get-ProfileCoreSystemInfoMetrics
Write-Host "Average render time: $($metrics.AverageRenderTime)ms"
```

## Troubleshooting

### Starship Not Found

**Problem**: `Enable-StarshipPrompt` fails

**Solution**:
```powershell
# Install Starship
Install-Starship

# Or manual installation:
# Windows: winget install Starship.Starship
# macOS:   brew install starship
# Linux:   curl -sS https://starship.rs/install.sh | sh
```

### Prompt Not Changing

**Problem**: Prompt looks the same after enabling

**Solution**:
1. Restart PowerShell
2. Check if plugin loaded: `Get-StarshipStatus`
3. Check logs: `Get-Content ~/.profilecore/logs/profilecore.log`

### Config Not Applied

**Problem**: Changes to `starship.toml` not visible

**Solution**:
```powershell
# Disable and re-enable
Disable-StarshipPrompt
Enable-StarshipPrompt

# Or restart shell
```

### Rust Module Not Loading

**Problem**: Rust acceleration not available

**Solution**:
```powershell
# Check Rust module
Test-ProfileCoreRustAvailable

# If false, see:
# docs/developer/RUST_INTEGRATION_GUIDE.md
```

## Customization Examples

### Add Language Indicators

Edit `~/.profilecore/starship.toml`:

```toml
[golang]
symbol = " "
disabled = false

[java]
symbol = " "
disabled = false
```

### Change Colors

```toml
[directory]
style = "cyan bold"  # Change from blue to cyan

[git_branch]
style = "bold green"  # Change from purple to green
```

### Add Battery Indicator

```toml
[battery]
full_symbol = "🔋"
charging_symbol = "⚡"
discharging_symbol = "💀"
disabled = false

[[battery.display]]
threshold = 10
style = "bold red"
```

## See Also

- [Starship Documentation](https://starship.rs/config/)
- [Starship Presets](https://starship.rs/presets/)
- [ProfileCore Plugin Development](../../../docs/developer/PLUGIN_DEVELOPMENT.md)
- [Shell Customization Guide](../../../docs/user-guide/shell-customization.md)

## License

MIT License - Part of ProfileCore project

## Contributing

Found a bug or have an idea? Open an issue or submit a PR!

