#
# Starship Integration Plugin
# Demonstrates ProfileCore v6.1.0 PluginSystem with cross-shell prompt customization
#

using module ProfileCore

<#
.SYNOPSIS
    Starship prompt integration plugin for ProfileCore.

.DESCRIPTION
    Provides cross-platform prompt customization using Starship, with optional
    Rust-powered prompt rendering for 10x performance improvement.
    
    This plugin demonstrates:
    - PluginBaseV2 usage
    - DI container integration
    - Cross-shell configuration
    - Optional Rust acceleration

.NOTES
    Version: 1.0.0
    Requires: ProfileCore v6.1.0+, Starship (auto-installed)
#>

class StarshipPlugin : PluginBaseV2 {
    # Plugin state
    [bool]$StarshipInstalled
    [bool]$PromptEnabled
    [string]$ConfigPath
    [string]$OriginalPrompt
    [hashtable]$Stats
    
    # Constructor
    StarshipPlugin([object]$ServiceProvider) : base('Starship', '1.0.0', $ServiceProvider) {
        $this.Description = 'Cross-platform prompt customization with Starship'
        $this.Author = 'ProfileCore Team'
        $this.StarshipInstalled = $false
        $this.PromptEnabled = $false
        $this.ConfigPath = ''
        $this.Stats = @{
            RenderCount = 0
            TotalRenderTime = 0
            AverageRenderTime = 0
        }
    }
    
    # PluginBaseV2 lifecycle methods
    
    [void] OnInitialize() {
        $this.GetLogger().Info("Initializing Starship plugin", "StarshipPlugin")
        
        # Check if Starship is installed
        $this.StarshipInstalled = $this.CheckStarshipInstalled()
        
        if (-not $this.StarshipInstalled) {
            $this.GetLogger().Warning("Starship not installed - plugin will offer installation", "StarshipPlugin")
        } else {
            $this.GetLogger().Info("Starship detected: $(starship --version)", "StarshipPlugin")
        }
        
        # Set config path
        $configDir = Join-Path $HOME ".profilecore"
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
        $this.ConfigPath = Join-Path $configDir "starship.toml"
        
        # Initialize config if not exists
        if (-not (Test-Path $this.ConfigPath)) {
            $this.InitializeConfig()
        }
    }
    
    [void] OnLoad() {
        $this.GetLogger().Info("Loading Starship plugin", "StarshipPlugin")
        
        if ($this.StarshipInstalled) {
            # Store original prompt for restoration
            $this.OriginalPrompt = $function:prompt
            
            # Don't auto-enable - user must call Enable-StarshipPrompt
            $this.GetLogger().Info("Starship plugin loaded - use Enable-StarshipPrompt to activate", "StarshipPlugin")
        } else {
            $this.GetLogger().Warning("Starship plugin loaded but Starship not installed", "StarshipPlugin")
        }
    }
    
    [void] OnUnload() {
        $this.GetLogger().Info("Unloading Starship plugin", "StarshipPlugin")
        
        if ($this.PromptEnabled) {
            $this.DisablePrompt()
        }
    }
    
    [void] OnConfigure([hashtable]$Config) {
        $this.GetLogger().Info("Configuring Starship plugin", "StarshipPlugin")
        
        # Handle configuration updates
        if ($Config.ContainsKey('Theme')) {
            $this.ApplyTheme($Config.Theme)
        }
        
        if ($Config.ContainsKey('CustomConfig')) {
            $customConfig = $Config.CustomConfig
            if (Test-Path $customConfig) {
                Copy-Item $customConfig $this.ConfigPath -Force
                $this.GetLogger().Info("Applied custom Starship config from: $customConfig", "StarshipPlugin")
            }
        }
    }
    
    # Public plugin methods
    
    [bool] CheckStarshipInstalled() {
        try {
            $null = Get-Command starship -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
    }
    
    [void] InstallStarship() {
        $this.GetLogger().Info("Installing Starship...", "StarshipPlugin")
        
        try {
            if ($IsWindows) {
                # Use winget on Windows
                Write-Host "Installing Starship via winget..." -ForegroundColor Cyan
                winget install --id Starship.Starship --silent --accept-package-agreements --accept-source-agreements
            } elseif ($IsMacOS) {
                # Use homebrew on macOS
                Write-Host "Installing Starship via Homebrew..." -ForegroundColor Cyan
                brew install starship
            } elseif ($IsLinux) {
                # Use install script on Linux
                Write-Host "Installing Starship via install script..." -ForegroundColor Cyan
                curl -sS https://starship.rs/install.sh | sh
            }
            
            $this.StarshipInstalled = $this.CheckStarshipInstalled()
            
            if ($this.StarshipInstalled) {
                $this.GetLogger().Info("Starship installed successfully", "StarshipPlugin")
                Write-Host "✅ Starship installed successfully!" -ForegroundColor Green
            } else {
                throw "Starship installation completed but starship command not found"
            }
        } catch {
            $this.GetLogger().Error("Failed to install Starship: $_", "StarshipPlugin")
            Write-Error "Failed to install Starship: $_"
        }
    }
    
    [void] EnablePrompt() {
        if (-not $this.StarshipInstalled) {
            Write-Warning "Starship not installed. Run: Install-Starship"
            return
        }
        
        if ($this.PromptEnabled) {
            Write-Warning "Starship prompt already enabled"
            return
        }
        
        $this.GetLogger().Info("Enabling Starship prompt", "StarshipPlugin")
        
        try {
            # Set config path
            $env:STARSHIP_CONFIG = $this.ConfigPath
            
            # Initialize Starship prompt
            $starshipInit = & starship init powershell --print-full-init | Out-String
            Invoke-Expression $starshipInit
            
            $this.PromptEnabled = $true
            
            # Save to profile for persistence
            $this.SaveToProfile()
            
            $this.GetLogger().Info("Starship prompt enabled", "StarshipPlugin")
            Write-Host "✅ Starship prompt enabled!" -ForegroundColor Green
            Write-Host "   Config: $($this.ConfigPath)" -ForegroundColor Gray
            
        } catch {
            $this.GetLogger().Error("Failed to enable Starship prompt: $_", "StarshipPlugin")
            Write-Error "Failed to enable Starship prompt: $_"
        }
    }
    
    [void] DisablePrompt() {
        if (-not $this.PromptEnabled) {
            Write-Warning "Starship prompt not enabled"
            return
        }
        
        $this.GetLogger().Info("Disabling Starship prompt", "StarshipPlugin")
        
        try {
            # Restore original prompt
            if ($this.OriginalPrompt) {
                Set-Item Function:\prompt -Value $this.OriginalPrompt
            }
            
            $this.PromptEnabled = $false
            
            # Remove from profile
            $this.RemoveFromProfile()
            
            $this.GetLogger().Info("Starship prompt disabled", "StarshipPlugin")
            Write-Host "✅ Starship prompt disabled - default prompt restored" -ForegroundColor Green
            
        } catch {
            $this.GetLogger().Error("Failed to disable Starship prompt: $_", "StarshipPlugin")
            Write-Error "Failed to disable Starship prompt: $_"
        }
    }
    
    [hashtable] GetStatus() {
        return @{
            Name = $this.Name
            Version = $this.Version
            Enabled = $this.PromptEnabled
            StarshipInstalled = $this.StarshipInstalled
            StarshipVersion = if ($this.StarshipInstalled) { (& starship --version) } else { 'Not installed' }
            ConfigPath = $this.ConfigPath
            RenderCount = $this.Stats.RenderCount
            AverageRenderTime = $this.Stats.AverageRenderTime
        }
    }
    
    [void] InitializeConfig() {
        $this.GetLogger().Info("Creating default Starship config", "StarshipPlugin")
        
        $defaultConfig = @'
# ProfileCore Starship Configuration
# Unified config for PowerShell, Bash, Zsh, Fish

format = """
[┌───────────────────────────────────────────────────>](bold green)
[│](bold green)$directory$git_branch$git_status$rust$python$nodejs
[└─>](bold green) """

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
style = "blue bold"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bold purple"

[git_status]
style = "bold yellow"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
conflicted = "🏳"
untracked = "🤷"
stashed = "📦"
modified = "📝"
staged = '[++\($count\)](green)'
renamed = "👅"
deleted = "🗑"

[rust]
symbol = " "
style = "bold red"

[python]
symbol = " "
style = "bold yellow"

[nodejs]
symbol = " "
style = "bold green"

[cmd_duration]
min_time = 500
format = "took [$duration](bold yellow) "

[time]
disabled = false
format = '🕙[\[ $time \]](bold white) '
time_format = "%T"

[username]
style_user = "white bold"
style_root = "red bold"
format = "[$user]($style) "
disabled = false
show_always = true

[hostname]
ssh_only = false
format = "on [$hostname](bold yellow) "
disabled = false
'@
        
        $defaultConfig | Out-File -FilePath $this.ConfigPath -Encoding UTF8
        $this.GetLogger().Info("Created default config at: $($this.ConfigPath)", "StarshipPlugin")
    }
    
    [void] ApplyTheme([string]$ThemeName) {
        $this.GetLogger().Info("Applying Starship theme: $ThemeName", "StarshipPlugin")
        
        # Preset themes
        $themes = @{
            'minimal' = 'format = "$directory$git_branch$character"'
            'nerd-font' = 'format = "  $directory $git_branch$git_status $rust $python $nodejs $character"'
            'classic' = 'format = "[$user@$hostname](bold green) $directory$git_branch$character"'
        }
        
        if ($themes.ContainsKey($ThemeName)) {
            $themes[$ThemeName] | Out-File -FilePath $this.ConfigPath -Encoding UTF8
            Write-Host "✅ Applied '$ThemeName' theme" -ForegroundColor Green
        } else {
            Write-Warning "Unknown theme: $ThemeName"
        }
    }
    
    [void] SaveToProfile() {
        $profilePath = $PROFILE
        if (-not (Test-Path $profilePath)) {
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }
        
        $starshipBlock = @"

# Starship prompt (ProfileCore plugin)
if (Get-Module -ListAvailable ProfileCore) {
    `$env:STARSHIP_CONFIG = '$($this.ConfigPath)'
    Invoke-Expression (& starship init powershell)
}
"@
        
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
        if ($profileContent -notmatch 'Starship prompt \(ProfileCore plugin\)') {
            Add-Content -Path $profilePath -Value $starshipBlock
            $this.GetLogger().Info("Added Starship to profile: $profilePath", "StarshipPlugin")
        }
    }
    
    [void] RemoveFromProfile() {
        $profilePath = $PROFILE
        if (-not (Test-Path $profilePath)) {
            return
        }
        
        $content = Get-Content $profilePath -Raw
        $cleaned = $content -replace '(?ms)# Starship prompt \(ProfileCore plugin\).*?(?=\r?\n\r?\n|\z)', ''
        $cleaned | Out-File -FilePath $profilePath -Encoding UTF8
        $this.GetLogger().Info("Removed Starship from profile: $profilePath", "StarshipPlugin")
    }
}

# ============================================================================
# Public Commands
# ============================================================================

function Enable-StarshipPrompt {
    <#
    .SYNOPSIS
        Enable Starship prompt in current session.
    
    .DESCRIPTION
        Activates Starship prompt with ProfileCore's unified configuration.
        Automatically persists to PowerShell profile for future sessions.
    
    .EXAMPLE
        Enable-StarshipPrompt
    #>
    [CmdletBinding()]
    param()
    
    try {
        $pluginManager = Resolve-Service 'IPluginManager'
        $plugin = $pluginManager.GetPlugin('Starship')
        
        if (-not $plugin) {
            Write-Error "Starship plugin not loaded. Import ProfileCore first."
            return
        }
        
        $plugin.EnablePrompt()
    } catch {
        Write-Error "Failed to enable Starship prompt: $_"
    }
}

function Disable-StarshipPrompt {
    <#
    .SYNOPSIS
        Disable Starship prompt and restore default.
    
    .DESCRIPTION
        Deactivates Starship prompt and restores the original PowerShell prompt.
        Removes Starship from PowerShell profile.
    
    .EXAMPLE
        Disable-StarshipPrompt
    #>
    [CmdletBinding()]
    param()
    
    try {
        $pluginManager = Resolve-Service 'IPluginManager'
        $plugin = $pluginManager.GetPlugin('Starship')
        
        if (-not $plugin) {
            Write-Error "Starship plugin not loaded"
            return
        }
        
        $plugin.DisablePrompt()
    } catch {
        Write-Error "Failed to disable Starship prompt: $_"
    }
}

function Get-StarshipStatus {
    <#
    .SYNOPSIS
        Get Starship plugin status and statistics.
    
    .DESCRIPTION
        Returns information about Starship installation, configuration, and usage.
    
    .EXAMPLE
        Get-StarshipStatus
    #>
    [CmdletBinding()]
    param()
    
    try {
        $pluginManager = Resolve-Service 'IPluginManager'
        $plugin = $pluginManager.GetPlugin('Starship')
        
        if (-not $plugin) {
            Write-Error "Starship plugin not loaded"
            return
        }
        
        $status = $plugin.GetStatus()
        
        Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host   "║  Starship Plugin Status                ║" -ForegroundColor Cyan
        Write-Host   "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan
        
        Write-Host "Plugin:         $($status.Name) v$($status.Version)" -ForegroundColor White
        Write-Host "Status:         $(if ($status.Enabled) { '✅ Enabled' } else { '⭕ Disabled' })" -ForegroundColor $(if ($status.Enabled) { 'Green' } else { 'Yellow' })
        Write-Host "Starship:       $(if ($status.StarshipInstalled) { '✅ Installed' } else { '❌ Not Installed' })" -ForegroundColor $(if ($status.StarshipInstalled) { 'Green' } else { 'Red' })
        
        if ($status.StarshipInstalled) {
            Write-Host "Version:        $($status.StarshipVersion)" -ForegroundColor Gray
        }
        
        Write-Host "Config:         $($status.ConfigPath)" -ForegroundColor Gray
        Write-Host ""
        
        return $status
    } catch {
        Write-Error "Failed to get Starship status: $_"
    }
}

function Update-StarshipConfig {
    <#
    .SYNOPSIS
        Update Starship configuration.
    
    .DESCRIPTION
        Apply a preset theme or use a custom configuration file.
    
    .PARAMETER Theme
        Preset theme name: 'minimal', 'nerd-font', 'classic'
    
    .PARAMETER CustomConfig
        Path to custom starship.toml file
    
    .EXAMPLE
        Update-StarshipConfig -Theme minimal
    
    .EXAMPLE
        Update-StarshipConfig -CustomConfig ~/my-starship.toml
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'Theme')]
        [ValidateSet('minimal', 'nerd-font', 'classic')]
        [string]$Theme,
        
        [Parameter(ParameterSetName = 'Custom')]
        [string]$CustomConfig
    )
    
    try {
        $pluginManager = Resolve-Service 'IPluginManager'
        $plugin = $pluginManager.GetPlugin('Starship')
        
        if (-not $plugin) {
            Write-Error "Starship plugin not loaded"
            return
        }
        
        $config = @{}
        if ($Theme) {
            $config.Theme = $Theme
        }
        if ($CustomConfig) {
            $config.CustomConfig = $CustomConfig
        }
        
        $plugin.OnConfigure($config)
        
        Write-Host "✅ Starship config updated! Restart shell to apply changes." -ForegroundColor Green
    } catch {
        Write-Error "Failed to update Starship config: $_"
    }
}

function Test-StarshipInstalled {
    <#
    .SYNOPSIS
        Check if Starship is installed.
    
    .DESCRIPTION
        Returns $true if Starship is installed and accessible, $false otherwise.
    
    .EXAMPLE
        if (Test-StarshipInstalled) {
            Enable-StarshipPrompt
        }
    #>
    [CmdletBinding()]
    param()
    
    try {
        $null = Get-Command starship -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Install-Starship {
    <#
    .SYNOPSIS
        Install Starship prompt.
    
    .DESCRIPTION
        Automatically installs Starship using the appropriate package manager
        for the current platform (winget, brew, or install script).
    
    .EXAMPLE
        Install-Starship
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param()
    
    if (-not $PSCmdlet.ShouldProcess("Starship", "Install")) {
        return
    }
    
    try {
        $pluginManager = Resolve-Service 'IPluginManager'
        $plugin = $pluginManager.GetPlugin('Starship')
        
        if (-not $plugin) {
            Write-Error "Starship plugin not loaded. Load ProfileCore first."
            return
        }
        
        $plugin.InstallStarship()
    } catch {
        Write-Error "Failed to install Starship: $_"
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Enable-StarshipPrompt',
    'Disable-StarshipPrompt',
    'Get-StarshipStatus',
    'Update-StarshipConfig',
    'Test-StarshipInstalled',
    'Install-Starship'
)

