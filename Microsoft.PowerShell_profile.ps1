# ════════════════════════════════════════════════════════════════════════════
# Microsoft.PowerShell_profile.ps1
# Modern PowerShell Profile - SOLID Principles Edition
# Version: 5.2.0
# ════════════════════════════════════════════════════════════════════════════

#Requires -Version 5.1

# ═════════════════════════════════════════════════════════════════════════════
#  PERFORMANCE OPTIMIZATION
# ═════════════════════════════════════════════════════════════════════════════

$global:ProfileLoadStart = Get-Date
$global:ProgressPreference = 'SilentlyContinue'

# ═════════════════════════════════════════════════════════════════════════════
#  COMMAND REGISTRY SYSTEM (Auto-generates help)
# ═════════════════════════════════════════════════════════════════════════════

$global:ProfileCommands = @{
    Categories = [ordered]@{}
    Metadata = @{
        Version = "5.2.0"
        LoadTime = 0
        LastUpdate = (Get-Date).ToString("yyyy-MM-dd")
    }
}

function Register-ProfileCommand {
    <#
    .SYNOPSIS
        Register a command for auto-generated help (Open/Closed principle)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,
        
        [Parameter(Mandatory)]
        [string]$Description,
        
        [Parameter(Mandatory)]
        [ValidateSet('Package', 'Security', 'Developer', 'System', 'Network', 'Files', 'Performance', 'Custom')]
        [string]$Category,
        
        [string]$Alias,
        [scriptblock]$Action
    )
    
    if (-not $global:ProfileCommands.Categories.Contains($Category)) {
        $global:ProfileCommands.Categories[$Category] = @()
    }
    
    $global:ProfileCommands.Categories[$Category] += [PSCustomObject]@{
        Command = $Command
        Description = $Description
        Alias = $Alias
        Action = $Action
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  ENVIRONMENT & CONFIGURATION LOADER
# ═════════════════════════════════════════════════════════════════════════════

function Initialize-ProfileEnvironment {
    [CmdletBinding()]
    param()
    
    # Fast defaults first (avoid slow file I/O)
    $global:ProfileConfig = @{
        theme = "default"
        features = @{
            starship = $true
            psreadline = $true
            performance = $true
        }
    }
    
    # Load environment variables only if file exists
    $envFile = Join-Path $HOME ".config/shell-profile/.env"
    if (Test-Path -LiteralPath $envFile) {
        try {
            Get-Content -LiteralPath $envFile -ReadCount 0 | 
                Where-Object { $_ -match '^([^=]+)=(.*)$' -and -not $_.StartsWith('#') } | 
                ForEach-Object {
                    [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
                }
        } catch {
            Write-Verbose "Failed to load environment file: $_"
        }
    }
    
    # Load configuration (override defaults)
    $configFile = Join-Path $HOME ".config/shell-profile/config.json"
    if (Test-Path -LiteralPath $configFile) {
        try {
            $customConfig = Get-Content -LiteralPath $configFile -Raw | ConvertFrom-Json
            # Merge with defaults
            if ($customConfig.theme) { $global:ProfileConfig.theme = $customConfig.theme }
            if ($customConfig.features) { $global:ProfileConfig.features = $customConfig.features }
        } catch {
            Write-Verbose "Failed to load config file: $_"
        }
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  CORE MODULE LOADER
# ═════════════════════════════════════════════════════════════════════════════

function Initialize-ProfileCoreModule {
    [CmdletBinding()]
    param()
    
    # OPTIMIZATION: Use module auto-loading instead of explicit import
    # This saves ~1100ms on startup!
    # Module will auto-load when any of its commands are first used
    
    # Verify module is available in path
    $modulePath = Join-Path $PSScriptRoot "modules\ProfileCore"
    if (Test-Path -LiteralPath $modulePath) {
        # Add to PSModulePath if not already there
        $paths = $env:PSModulePath -split ';'
        $moduleParent = Join-Path $PSScriptRoot "modules"
        if ($paths -notcontains $moduleParent) {
            $env:PSModulePath = "$moduleParent;$env:PSModulePath"
        }
        Write-Verbose "✅ ProfileCore module available for auto-loading"
        return $true
    } else {
        Write-Warning "⚠️  ProfileCore module not found at: $modulePath"
        return $false
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  PLUGIN SYSTEM (Open for Extension)
# ═════════════════════════════════════════════════════════════════════════════

function Import-ProfilePlugins {
    [CmdletBinding()]
    param()
    
    $pluginPath = Join-Path $HOME ".config/shell-profile/plugins"
    
    if (Test-Path $pluginPath) {
        Get-ChildItem -Path $pluginPath -Filter "*.ps1" -ErrorAction SilentlyContinue | 
            ForEach-Object {
                try {
                    Write-Verbose "Loading plugin: $($_.Name)"
                    . $_.FullName
                } catch {
                    Write-Warning "Failed to load plugin $($_.Name): $_"
                }
            }
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  AUTO-GENERATED HELPER SYSTEM
# ═════════════════════════════════════════════════════════════════════════════

function Get-Helper {
    <#
    .SYNOPSIS
        Auto-generated command reference (builds from registered commands)
    .DESCRIPTION
        This help system is automatically generated based on registered commands.
        Following Open/Closed Principle: closed for modification, open for extension.
    #>
    [CmdletBinding()]
    param(
        [string]$Category,
        [switch]$Detailed
    )
    
    # Lazy load command registry on first call
    if (-not $global:CommandsRegistered) {
        Register-CoreCommands
    }
    
    $categoryIcons = @{
        'Package' = '📦'
        'Security' = '🔐'
        'Developer' = '🔧'
        'System' = '💻'
        'Network' = '🌐'
        'Files' = '📁'
        'Performance' = '⚡'
        'Custom' = '🎨'
    }
    
    # Import ProfileCore.Common for output functions
    if (-not (Get-Module ProfileCore.Common)) {
        Import-Module ProfileCore.Common -ErrorAction SilentlyContinue
    }
    
    # Display header with dynamic version
    $headerMessage = "🚀 ProfileCore v$($global:ProfileCommands.Metadata.Version) - Command Reference"
    Write-BoxHeader $headerMessage -Width 60
    
    # Filter by category if specified
    $categoriesToShow = if ($Category) {
        $global:ProfileCommands.Categories.GetEnumerator() | Where-Object { $_.Key -eq $Category }
    } else {
        $global:ProfileCommands.Categories.GetEnumerator()
    }
    
    foreach ($cat in $categoriesToShow) {
        if ($cat.Value.Count -eq 0) { continue }
        
        $icon = $categoryIcons[$cat.Key]
        Write-Host "$icon $($cat.Key):" -ForegroundColor Yellow
        
        foreach ($cmd in $cat.Value) {
            $commandText = if ($cmd.Alias) {
                "$($cmd.Command) ($($cmd.Alias))"
            } else {
                $cmd.Command
            }
            
            if ($Detailed) {
                Write-Host "  $commandText" -ForegroundColor White
                Write-Host "    $($cmd.Description)" -ForegroundColor Gray
            } else {
                $padding = 30 - $commandText.Length
                if ($padding -lt 1) { $padding = 1 }
                Write-Host "  $commandText$(' ' * $padding)$($cmd.Description)" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
    
    Write-Host "💡 Tips:" -ForegroundColor Cyan
    Write-Host "  Get-Helper -Category <name>     Filter by category" -ForegroundColor Gray
    Write-Host "  Get-Helper -Detailed            Show detailed help" -ForegroundColor Gray
    Write-Host "  Get-Command -Module ProfileCore List all module commands" -ForegroundColor Gray
    Write-Host ""
    
    # Show performance stats
    Write-Host "📊 Profile Stats:" -ForegroundColor Cyan
    Write-Host "  Commands registered: $($global:ProfileCommands.Categories.Values.Count | Measure-Object -Sum | Select-Object -ExpandProperty Sum)" -ForegroundColor Gray
    Write-Host "  Categories: $($global:ProfileCommands.Categories.Keys.Count)" -ForegroundColor Gray
    Write-Host "  Load time: $($global:ProfileCommands.Metadata.LoadTime)ms" -ForegroundColor Gray
    Write-Host ""
}

# ═════════════════════════════════════════════════════════════════════════════
#  REGISTER CORE COMMANDS (Extensible - add more via plugins)
#  LAZY LOADED: Only registered when Get-Helper is called
# ═════════════════════════════════════════════════════════════════════════════

$global:CommandsRegistered = $false

function Register-CoreCommands {
    # Skip if already registered
    if ($global:CommandsRegistered) { return }
    
    # Ensure ProfileCore module is loaded
    if (-not (Get-Module ProfileCore)) {
        Import-Module ProfileCore -DisableNameChecking -ErrorAction SilentlyContinue
    }
    
    # Package Management (if ProfileCore loaded)
    if (Get-Command Install-CrossPlatformPackage -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'pkg <name>' -Description 'Install package' -Category 'Package' -Alias 'Install-CrossPlatformPackage'
        Register-ProfileCommand -Command 'pkg-search <query>' -Description 'Search packages' -Category 'Package' -Alias 'Search-CrossPlatformPackage'
        Register-ProfileCommand -Command 'pkg-info <name>' -Description 'Package information' -Category 'Package' -Alias 'Get-PackageInfo'
        Register-ProfileCommand -Command 'pkgu' -Description 'Update all packages' -Category 'Package' -Alias 'Update-AllPackages'
    }
    
    # Security Tools
    if (Get-Command Test-Port -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'scan-port <host> <ports>' -Description 'Port scanner' -Category 'Security' -Alias 'Test-PortRange'
        Register-ProfileCommand -Command 'check-ssl <domain>' -Description 'SSL certificate checker' -Category 'Security' -Alias 'Test-SSLCertificate'
        Register-ProfileCommand -Command 'dns-lookup <domain>' -Description 'DNS lookup' -Category 'Security' -Alias 'Get-DNSInfo'
        Register-ProfileCommand -Command 'whois-lookup <domain>' -Description 'WHOIS information' -Category 'Security' -Alias 'Get-WHOISInfo'
        Register-ProfileCommand -Command 'gen-password <length>' -Description 'Generate secure password' -Category 'Security' -Alias 'New-SecurePassword'
        Register-ProfileCommand -Command 'check-password <pwd>' -Description 'Check password strength' -Category 'Security' -Alias 'Test-PasswordStrength'
        Register-ProfileCommand -Command 'check-headers <url>' -Description 'HTTP security headers' -Category 'Security' -Alias 'Test-SecurityHeaders'
    }
    
    # Developer Tools
    if (Get-Command Invoke-GitQuickCommit -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'gqc <message>' -Description 'Quick git commit & push' -Category 'Developer' -Alias 'Invoke-GitQuickCommit'
        Register-ProfileCommand -Command 'git-status' -Description 'Enhanced git status' -Category 'Developer' -Alias 'Get-GitBranchInfo'
        Register-ProfileCommand -Command 'git-cleanup' -Description 'Clean merged branches' -Category 'Developer' -Alias 'Remove-GitMergedBranches'
        Register-ProfileCommand -Command 'new-branch <name>' -Description 'Create new git branch' -Category 'Developer' -Alias 'New-GitBranch'
        Register-ProfileCommand -Command 'docker-status' -Description 'Docker containers status' -Category 'Developer' -Alias 'Get-DockerStatus'
        Register-ProfileCommand -Command 'dc-up / dc-down' -Description 'Docker Compose' -Category 'Developer' -Alias 'Start-DockerCompose'
        Register-ProfileCommand -Command 'init-project <name>' -Description 'Initialize new project' -Category 'Developer' -Alias 'New-DevProject'
    }
    
    # System Administration
    if (Get-Command Get-SystemInfo -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'sysinfo' -Description 'System information' -Category 'System' -Alias 'Get-SystemInfo'
        Register-ProfileCommand -Command 'pinfo <count> <CPU|MEM>' -Description 'Top processes' -Category 'System' -Alias 'Get-ProcessInfo'
        Register-ProfileCommand -Command 'diskinfo' -Description 'Disk usage' -Category 'System' -Alias 'Get-DiskInfo'
        Register-ProfileCommand -Command 'killp <process>' -Description 'Kill process by name' -Category 'System' -Alias 'Stop-ProcessByName'
        Register-ProfileCommand -Command 'connections' -Description 'Active network connections' -Category 'System' -Alias 'Get-NetworkConnections'
    }
    
    # Network
    if (Get-Command Get-PublicIP -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'myip' -Description 'Get public IP' -Category 'Network' -Alias 'Get-PublicIP'
        Register-ProfileCommand -Command 'localips' -Description 'Get local network IPs' -Category 'Network' -Alias 'Get-LocalNetworkIPs'
        Register-ProfileCommand -Command 'reverse-dns <ip>' -Description 'Reverse DNS lookup' -Category 'Network' -Alias 'Get-ReverseDNS'
        Register-ProfileCommand -Command 'dns-propagation <domain>' -Description 'Check DNS propagation' -Category 'Network' -Alias 'Test-DNSPropagation'
    }
    
    # Files
    if (Get-Command Open-CurrentDirectory -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'Open-cd' -Description 'Open current directory' -Category 'Files' -Alias 'Open-CurrentDirectory'
    }
    
    # Performance
    if (Get-Command Measure-ProfilePerformance -ErrorAction SilentlyContinue) {
        Register-ProfileCommand -Command 'perf' -Description 'Performance analysis' -Category 'Performance' -Alias 'Measure-ProfilePerformance'
        Register-ProfileCommand -Command 'optimize' -Description 'Auto-optimize settings' -Category 'Performance' -Alias 'Optimize-ProfileCore'
        Register-ProfileCommand -Command 'clear-cache' -Description 'Clear profile cache' -Category 'Performance' -Alias 'Reset-ProfileCache'
    }
    
    $global:CommandsRegistered = $true
}

# ═════════════════════════════════════════════════════════════════════════════
#  SECURITY TOOLS - Now available via Plugin
# ═════════════════════════════════════════════════════════════════════════════

# Security tools have been moved to a proper plugin architecture
# To use these tools:
# 1. Copy examples/plugins/security-tools to ~/.profilecore/plugins/security-tools
# 2. Enable-ProfileCorePlugin -Name 'security-tools'
# 3. Reload your profile
#
# Available commands:
# - Copy-SshId / ssh-copy-id         Copy SSH key to remote server
# - Test-FileHash                     Verify file integrity
# - Test-FileOnVirusTotal            Check file on VirusTotal
# - Get-ShodanIPInfo                 Lookup IP on Shodan
#
# For more information, see: examples/plugins/security-tools/README.md

# ═════════════════════════════════════════════════════════════════════════════
#  PSREADLINE CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════

function Initialize-PSReadLine {
    if (Get-Module -Name PSReadLine) {
        Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -MaximumHistoryCount 5000 -ErrorAction SilentlyContinue
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  PROMPT CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════

function Initialize-Prompt {
    param([switch]$Fast)
    
    if (-not $Fast -and (Get-Command starship -ErrorAction SilentlyContinue)) {
        Invoke-Expression (&starship init powershell)
    } else {
        # Fast simple prompt (doesn't trigger module loading)
        function global:prompt {
            $os = if ($IsWindows -or $env:OS -eq 'Windows_NT') { 'PS' }
                  elseif ($IsLinux) { 'PS' }
                  elseif ($IsMacOS) { 'PS' }
                  else { 'PS' }
            "$os $($PWD.Path)> "
        }
    }
}

function Initialize-StarshipAsync {
    # Initialize Starship in background after profile loads (truly async)
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        # Schedule Starship initialization for later (after prompt appears)
        $null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
            try {
                if (Get-Command starship -ErrorAction SilentlyContinue) {
                    Invoke-Expression (&starship init powershell)
                }
            } catch {
                # Silently ignore errors in async initialization
            }
        }
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  QUICK REINSTALL FUNCTION
# ═════════════════════════════════════════════════════════════════════════════

function Update-ProfileCore {
    <#
    .SYNOPSIS
        Quick reinstall/update ProfileCore from GitHub
    .DESCRIPTION
        Downloads and installs the latest ProfileCore version while preserving your configuration
    .PARAMETER Force
        Force reinstall even if up to date
    .PARAMETER Quiet
        Minimal output mode
    .EXAMPLE
        Update-ProfileCore
    .EXAMPLE
        Update-ProfileCore -Force -Quiet
    #>
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$Quiet
    )
    
    # Import ProfileCore.Common for output functions
    if (-not (Get-Module ProfileCore.Common)) {
        Import-Module ProfileCore.Common -ErrorAction SilentlyContinue
    }
    
    $repoUrl = "https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1"
    
    Write-BoxHeader "ProfileCore Quick Update/Reinstall" -Width 62
    
    Write-Info "Current version: $($global:ProfileCore.Version)" -Quiet:$Quiet
    Write-Info "Fetching latest installer..." -Quiet:$Quiet
    Write-Host ""
    
    try {
        # Download and execute installer
        $installer = Invoke-RestMethod $repoUrl -ErrorAction Stop
        
        # Create temp file
        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $installer | Out-File $tempFile -Encoding UTF8
        
        Write-Success "Installer downloaded" -Quiet:$Quiet
        Write-Info "Starting installation..." -Quiet:$Quiet
        Write-Host ""
        
        # Run installer with appropriate flags
        $installArgs = @()
        if ($Force) { $installArgs += '-Force' }
        if ($Quiet) { $installArgs += '-NonInteractive' }
        
        & $tempFile @installArgs
        
        # Cleanup
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        
        Write-Host ""
        Write-Success "Update complete! Restart PowerShell to see changes."
        
    } catch {
        Write-Host ""
        Write-ErrorMsg "Update failed: $_"
        Write-Info "Try manual installation: https://github.com/mythic3011/ProfileCore"
    }
}

Set-Alias -Name 'update-profile' -Value Update-ProfileCore
Set-Alias -Name 'reinstall-profile' -Value Update-ProfileCore

# ═════════════════════════════════════════════════════════════════════════════
#  INITIALIZATION SEQUENCE
# ═════════════════════════════════════════════════════════════════════════════

Initialize-ProfileEnvironment

# Initialize Starship async FIRST (starts loading in background)
# This gives Starship maximum time to load while other things initialize
Initialize-StarshipAsync

$coreLoaded = Initialize-ProfileCoreModule

# Command registration now lazy-loaded on first Get-Helper call
# This saves ~1700ms on startup!

Import-ProfilePlugins

Initialize-PSReadLine
Initialize-Prompt -Fast  # Use simple prompt initially until Starship is ready

# ═════════════════════════════════════════════════════════════════════════════
#  WELCOME MESSAGE
# ═════════════════════════════════════════════════════════════════════════════

$loadTime = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
$global:ProfileCommands.Metadata.LoadTime = [math]::Round($loadTime, 0)

# Fast OS detection (doesn't trigger module loading)
$os = if ($IsWindows -or $env:OS -eq 'Windows_NT') { 'Windows' }
      elseif ($IsLinux) { 'Linux' }
      elseif ($IsMacOS) { 'macOS' }
      else { 'Unknown' }

# Display welcome message using custom formatting (emojis for visual appeal)
# Note: Could use Write-Info but this is intentionally styled for startup experience
Write-Host "🚀 Welcome to PowerShell $($PSVersionTable.PSVersion) on $os " -NoNewline -ForegroundColor Cyan
Write-Host "($($global:ProfileCommands.Metadata.LoadTime)ms)" -ForegroundColor Gray
Write-Host "💡 Type 'Get-Helper' for available commands" -ForegroundColor Yellow
Write-Host "⚡ Optimized: Lazy loading enabled (Command registry & Starship deferred)" -ForegroundColor DarkGray

Remove-Variable -Name ProfileLoadStart -Scope Global -ErrorAction SilentlyContinue
