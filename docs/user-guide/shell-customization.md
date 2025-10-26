# Shell Customization Guide

ProfileCore v6.1.0 provides powerful shell customization capabilities across multiple shells with unified configuration.

## Table of Contents

1. [Overview](#overview)
2. [Supported Shells](#supported-shells)
3. [Starship Integration](#starship-integration)
4. [Cross-Shell Configuration](#cross-shell-configuration)
5. [Custom Plugins](#custom-plugins)
6. [Performance Optimization](#performance-optimization)
7. [Troubleshooting](#troubleshooting)

## Overview

ProfileCore's shell plugin system enables:

- **Unified Configuration**: Same settings across PowerShell, Bash, Zsh, Fish
- **Beautiful Prompts**: Modern, informative prompts with git integration
- **High Performance**: Rust-powered rendering for 10x speedup
- **Easy Setup**: One-command installation and configuration
- **Extensible**: Build your own shell plugins using PluginBaseV2

## Supported Shells

| Shell | Platform | Status | Features |
|-------|----------|--------|----------|
| **PowerShell** | Windows, Linux, macOS | ✅ Full Support | Plugin system, DI integration, Rust acceleration |
| **Bash** | Linux, macOS, WSL | ✅ Full Support | Unified config, cross-platform |
| **Zsh** | macOS, Linux | ✅ Full Support | Unified config, Oh-My-Zsh compatible |
| **Fish** | All platforms | ✅ Full Support | Unified config, modern syntax |

## Starship Integration

[Starship](https://starship.rs/) is a fast, customizable prompt for any shell.

### Quick Start

#### PowerShell

```powershell
# 1. Import ProfileCore
Import-Module ProfileCore

# 2. Load Starship plugin
Enable-ProfileCorePlugin -Name Starship

# 3. Enable prompt
Enable-StarshipPrompt
```

#### All Shells (One Command)

```powershell
# From ProfileCore directory
.\shells\common\starship\install.ps1 -InstallStarship -Shell All
```

#### Unix Shells (Bash/Zsh/Fish)

```bash
# From ProfileCore directory
cd shells/common/starship
chmod +x install.sh
./install.sh --install-starship --shell all
```

### Commands

```powershell
# Enable Starship prompt
Enable-StarshipPrompt

# Disable (restore default)
Disable-StarshipPrompt

# Check status
Get-StarshipStatus

# Apply preset theme
Update-StarshipConfig -Theme minimal

# Use custom config
Update-StarshipConfig -CustomConfig ~/my-starship.toml

# Check if installed
Test-StarshipInstalled

# Install if missing
Install-Starship
```

### Themes

ProfileCore includes three built-in themes:

#### Minimal Theme

```powershell
Update-StarshipConfig -Theme minimal
```

Simple, fast prompt:
```
~/Projects/ProfileCore main ➜
```

#### Nerd Font Theme

```powershell
Update-StarshipConfig -Theme nerd-font
```

Rich prompt with icons (requires Nerd Font):
```
  ~/Projects/ProfileCore  main  ➜
```

#### Classic Theme

```powershell
Update-StarshipConfig -Theme classic
```

Traditional prompt:
```
user@hostname ~/Projects/ProfileCore main ➜
```

### Custom Configuration

Edit `~/.profilecore/starship.toml` to customize your prompt.

Common customizations:

#### Change Colors

```toml
[directory]
style = "cyan bold"  # Change directory color

[git_branch]
style = "bold green"  # Change git branch color
```

#### Add/Remove Modules

```toml
# Enable Go version display
[golang]
symbol = " "
disabled = false

# Disable Java version
[java]
disabled = true
```

#### Modify Format

```toml
# Customize prompt layout
format = """
$username$hostname$directory$git_branch$character
"""
```

#### Add Custom Commands

```toml
[custom.disk_usage]
command = "df -h / | tail -1 | awk '{print $5}'"
when = "true"
symbol = "💾 "
style = "bold yellow"
format = "[$symbol$output]($style) "
```

## Cross-Shell Configuration

### Unified Config Approach

ProfileCore uses a single configuration file (`~/.profilecore/starship.toml`) shared across all shells. This ensures consistency whether you're in PowerShell, Bash, Zsh, or Fish.

### Per-Shell Overrides

If needed, you can create shell-specific configs:

**PowerShell**:
```powershell
$env:STARSHIP_CONFIG = "$HOME\.profilecore\starship-pwsh.toml"
```

**Bash/Zsh**:
```bash
export STARSHIP_CONFIG="$HOME/.profilecore/starship-bash.toml"
```

**Fish**:
```fish
set -gx STARSHIP_CONFIG "$HOME/.profilecore/starship-fish.toml"
```

### Cross-Platform Considerations

#### Windows (PowerShell)

- Config location: `C:\Users\<username>\.profilecore\starship.toml`
- Path separator: `\`
- Default shell: PowerShell 7+

#### macOS/Linux (Bash/Zsh/Fish)

- Config location: `~/.profilecore/starship.toml`
- Path separator: `/`
- Default shell: Varies (bash, zsh, fish)

#### WSL (Windows Subsystem for Linux)

- Runs Linux shells on Windows
- Use Unix path format
- Can access Windows files via `/mnt/c/`

## Custom Plugins

### Creating a Shell Plugin

```powershell
using module ProfileCore

class MyShellPlugin : PluginBaseV2 {
    MyShellPlugin([object]$ServiceProvider) : base('MyShell', '1.0.0', $ServiceProvider) {
        $this.Description = 'Custom shell enhancements'
    }
    
    [void] OnInitialize() {
        # Initialize plugin
    }
    
    [void] OnLoad() {
        # Called when plugin is loaded
        # Modify prompt, add aliases, etc.
    }
    
    [void] OnUnload() {
        # Cleanup
    }
}
```

### Plugin Examples

#### Custom Greeting

```powershell
class GreetingPlugin : PluginBaseV2 {
    [void] OnLoad() {
        $user = $env:USERNAME
        $time = Get-Date -Format "HH:mm"
        Write-Host "Welcome, $user! Current time: $time" -ForegroundColor Cyan
    }
}
```

#### Git Enhancements

```powershell
class GitPlugin : PluginBaseV2 {
    [void] OnLoad() {
        # Add git aliases
        Set-Alias -Name gst -Value 'git status'
        Set-Alias -Name gco -Value 'git checkout'
        Set-Alias -Name gcm -Value 'git commit -m'
        
        # Custom git prompt function
        function prompt {
            $path = (Get-Location).Path
            $branch = git branch --show-current 2>$null
            
            Write-Host "$path " -NoNewline -ForegroundColor Blue
            if ($branch) {
                Write-Host "($branch) " -NoNewline -ForegroundColor Green
            }
            return "➜ "
        }
    }
}
```

## Performance Optimization

### Rust Acceleration

When ProfileCore's Rust module is available, prompt rendering is 10x faster.

#### Check Rust Availability

```powershell
Test-ProfileCoreRustAvailable
```

#### Benchmark Performance

```powershell
# Measure prompt render time
Measure-Command { prompt }

# With Rust: ~0.5-1ms
# Without Rust: ~5-10ms
```

### Optimization Tips

1. **Disable Unused Modules**
   ```toml
   [java]
   disabled = true  # Disable if not using Java
   ```

2. **Increase Scan Timeout**
   ```toml
   [directory]
   scan_timeout = 10  # Default is 30ms
   ```

3. **Limit Git Status**
   ```toml
   [git_status]
   disabled = false
   ignore_submodules = true  # Skip submodules
   ```

4. **Use Command Timeout**
   ```toml
   [custom.example]
   command_timeout = 100  # 100ms max
   ```

### Lazy Loading

Load plugins on-demand rather than at startup:

```powershell
# In profile
function Load-GitPlugin {
    if (-not (Get-Module GitPlugin)) {
        Enable-ProfileCorePlugin -Name Git
    }
}

# Load only when entering git repository
function cd {
    param([string]$Path)
    Set-Location $Path
    
    if (Test-Path .git) {
        Load-GitPlugin
    }
}
```

## Troubleshooting

### Slow Prompt

**Symptoms**: Prompt takes >100ms to render

**Diagnosis**:
```powershell
# Profile prompt function
Measure-Command { prompt }

# Check which modules are slow
starship timings
```

**Solutions**:
1. Disable unused modules
2. Enable Rust acceleration
3. Increase timeout values
4. Use `ignore_submodules` for git

### Prompt Not Updating

**Symptoms**: Changes to config not visible

**Solutions**:
1. Restart shell
2. Clear cache: `$env:STARSHIP_CACHE = $null`
3. Force reload: `Disable-StarshipPrompt; Enable-StarshipPrompt`

### Characters Not Displaying

**Symptoms**: Boxes, question marks, or missing icons

**Solutions**:
1. Install a Nerd Font: [nerdfonts.com](https://www.nerdfonts.com/)
2. Configure terminal to use Nerd Font
3. Use theme without icons: `Update-StarshipConfig -Theme minimal`

### Git Status Slow

**Symptoms**: Delay when entering git repositories

**Solutions**:
```toml
[git_status]
disabled = false
ignore_submodules = true
ahead_behind = false  # Skip ahead/behind calculation
```

### Permission Errors

**Symptoms**: Cannot write to config directory

**Solutions**:
```powershell
# Ensure config directory exists with correct permissions
$configDir = Join-Path $HOME ".profilecore"
New-Item -ItemType Directory -Path $configDir -Force
```

### Cross-Shell Inconsistencies

**Symptoms**: Prompt looks different in different shells

**Solutions**:
1. Verify all shells use same config:
   ```bash
   echo $STARSHIP_CONFIG  # Should be ~/.profilecore/starship.toml
   ```

2. Check Starship version:
   ```bash
   starship --version  # Should match across shells
   ```

3. Restart all shells after config changes

## Advanced Topics

### Multi-Line Prompts

```toml
format = """
[┌─[$user@$hostname]─[$directory]─[$git_branch$git_status]─[$time]](bold green)
[└─>](bold green) $character"""
```

### Conditional Prompts

```toml
# Show Python version only in Python projects
[python]
symbol = " "
detect_extensions = ['py']
detect_files = ['requirements.txt', 'pyproject.toml']
```

### Integration with Oh-My-Zsh

Starship works alongside Oh-My-Zsh:

```bash
# In .zshrc (after Oh-My-Zsh)
eval "$(starship init zsh)"
```

### Integration with Tmux

Display prompt info in tmux status bar:

```bash
# In .tmux.conf
set -g status-right '#(starship prompt --right)'
```

## Resources

- **Starship Documentation**: [starship.rs/config](https://starship.rs/config/)
- **Starship Presets**: [starship.rs/presets](https://starship.rs/presets/)
- **Nerd Fonts**: [nerdfonts.com](https://www.nerdfonts.com/)
- **ProfileCore Plugins**: [Plugin Development Guide](../developer/PLUGIN_DEVELOPMENT.md)
- **Rust Integration**: [Rust Integration Guide](../developer/RUST_INTEGRATION_GUIDE.md)

## Examples Gallery

### Developer Prompt

```toml
format = """
$username$hostname$directory
$git_branch$git_status$rust$python$nodejs$docker_context
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

### Minimal Prompt

```toml
format = "$directory$git_branch$character"

[directory]
truncation_length = 2

[git_branch]
symbol = ""
format = "[$branch]($style) "
```

### Power User Prompt

```toml
format = """
[╭─]($style)[$username]($style_user)[@]($style)[$hostname]($style) \
[$directory]($style_directory) \
$git_branch$git_status $rust$python$nodejs$golang
[╰─>]($style) """
```

---

For more examples and inspiration, visit:
- [Starship Configuration Examples](https://starship.rs/presets/)
- [ProfileCore Examples Directory](../../examples/plugins/)

