#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ProfileCore Development Environment Setup
.DESCRIPTION
    Sets up the development environment for ProfileCore including:
    - Required PowerShell modules
    - Shell utilities and dependencies
    - Development tools
    - Testing frameworks
.PARAMETER InstallTools
    Install additional development tools (PSScriptAnalyzer, Pester, etc.)
.PARAMETER SetupShells
    Configure all shell environments (Zsh, Bash, Fish)
.PARAMETER Force
    Force reinstallation of modules even if already installed
.EXAMPLE
    .\setup-dev-environment.ps1
.EXAMPLE
    .\setup-dev-environment.ps1 -InstallTools -SetupShells
#>

param(
    [switch]$InstallTools,
    [switch]$SetupShells,
    [switch]$Force
)

# ═════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ═════════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"
$Script:RequiredModules = @{
    'Pester'             = '5.7.1'
    'PSScriptAnalyzer'   = '1.24.0'
    'Microsoft.WinGet.Client' = '1.8.1911'
}

# ═════════════════════════════════════════════════════════════════
#  LOAD SHARED UTILITIES
# ═════════════════════════════════════════════════════════════════

# Import ProfileCore.Common for shared output functions
. "$PSScriptRoot\shared\ScriptHelpers.ps1"
$commonLoaded = Import-ProfileCoreCommon -Quiet

if (-not $commonLoaded) {
    # Fallback helper functions if Common module isn't available
    function Write-Step {
        param([string]$Message)
        Write-Host "🔹 $Message" -ForegroundColor Cyan
    }

    function Write-Success {
        param([string]$Message)
        Write-Host "✅ $Message" -ForegroundColor Green
    }

    function Write-Info {
        param([string]$Message)
        Write-Host "ℹ️  $Message" -ForegroundColor Yellow
    }
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ═════════════════════════════════════════════════════════════════
#  MODULE INSTALLATION
# ═════════════════════════════════════════════════════════════════

function Install-RequiredModule {
    param(
        [string]$ModuleName,
        [string]$MinimumVersion
    )
    
    $installed = Get-Module -ListAvailable -Name $ModuleName | 
        Where-Object { $_.Version -ge [version]$MinimumVersion } |
        Select-Object -First 1
    
    if ($installed -and -not $Force) {
        Write-Info "$ModuleName already installed (v$($installed.Version))"
        return
    }
    
    Write-Step "Installing $ModuleName (v$MinimumVersion)..."
    
    try {
        Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Scope CurrentUser -Force -SkipPublisherCheck
        Write-Success "$ModuleName installed successfully"
    } catch {
        Write-Error-Custom "Failed to install $ModuleName - $_"
        throw
    }
}

# ═════════════════════════════════════════════════════════════════
#  ENVIRONMENT DETECTION
# ═════════════════════════════════════════════════════════════════

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Get-OSInfo {
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)) {
        return @{
            OS = 'Windows'
            PackageManager = if (Test-Command 'winget') { 'winget' } 
                            elseif (Test-Command 'choco') { 'choco' }
                            elseif (Test-Command 'scoop') { 'scoop' }
                            else { $null }
        }
    } elseif ($IsMacOS) {
        return @{
            OS = 'macOS'
            PackageManager = if (Test-Command 'brew') { 'brew' } else { $null }
        }
    } else {
        $pm = if (Test-Command 'apt') { 'apt' }
              elseif (Test-Command 'dnf') { 'dnf' }
              elseif (Test-Command 'pacman') { 'pacman' }
              elseif (Test-Command 'zypper') { 'zypper' }
              else { $null }
        
        return @{
            OS = 'Linux'
            PackageManager = $pm
        }
    }
}

# ═════════════════════════════════════════════════════════════════
#  MAIN SETUP
# ═════════════════════════════════════════════════════════════════

function Start-DevEnvironmentSetup {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  ProfileCore Development Environment Setup           ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Detect environment
    $osInfo = Get-OSInfo
    Write-Info "Operating System: $($osInfo.OS)"
    Write-Info "Package Manager: $(if ($osInfo.PackageManager) { $osInfo.PackageManager } else { 'None detected' })"
    Write-Host ""
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-Step "PowerShell Version: $psVersion"
    
    if ($psVersion.Major -lt 7) {
        Write-Info "PowerShell 7+ recommended for best experience"
    } else {
        Write-Success "PowerShell version meets requirements"
    }
    Write-Host ""
    
    # Install PowerShell modules
    Write-Step "Installing required PowerShell modules..."
    foreach ($module in $Script:RequiredModules.GetEnumerator()) {
        Install-RequiredModule -ModuleName $module.Key -MinimumVersion $module.Value
    }
    Write-Host ""
    
    # Install development tools
    if ($InstallTools) {
        Write-Step "Installing development tools..."
        
        switch ($osInfo.PackageManager) {
            'winget' {
                # Install Git, VS Code, etc. via winget
                Write-Info "Installing tools via winget..."
                $tools = @('Git.Git', 'Microsoft.VisualStudioCode')
                foreach ($tool in $tools) {
                    try {
                        winget install --id $tool --silent --accept-package-agreements 2>$null
                        Write-Success "$tool installed"
                    } catch {
                        Write-Info "$tool may already be installed"
                    }
                }
            }
            'brew' {
                Write-Info "Installing tools via Homebrew..."
                brew install git jq curl shellcheck 2>$null
                Write-Success "Tools installed via Homebrew"
            }
            'apt' {
                Write-Info "Installing tools via APT..."
                sudo apt-get update && sudo apt-get install -y git jq curl shellcheck
                Write-Success "Tools installed via APT"
            }
            default {
                Write-Info "No package manager detected - skipping tool installation"
            }
        }
        Write-Host ""
    }
    
    # Setup shell environments
    if ($SetupShells) {
        Write-Step "Setting up shell environments..."
        
        # Check for Zsh
        if (Test-Command 'zsh') {
            Write-Info "Zsh detected - shell configuration available in shells/zsh/"
            Write-Success "Zsh ready"
        }
        
        # Check for Bash
        if (Test-Command 'bash') {
            Write-Info "Bash detected - shell configuration available in shells/bash/"
            Write-Success "Bash ready"
        }
        
        # Check for Fish
        if (Test-Command 'fish') {
            Write-Info "Fish detected - shell configuration available in shells/fish/"
            Write-Success "Fish ready"
        }
        Write-Host ""
    }
    
    # Create necessary directories
    Write-Step "Creating development directories..."
    $dirs = @(
        "$HOME/.profilecore/cache",
        "$HOME/.profilecore/plugins",
        "$HOME/.profilecore/backups",
        "$HOME/.config/shell-profile"
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Success "Created: $dir"
        } else {
            Write-Info "Exists: $dir"
        }
    }
    Write-Host ""
    
    # Summary
    Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  Development Environment Setup Complete ✅            ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Run tests: ./scripts/run-tests.ps1" -ForegroundColor White
    Write-Host "  2. Validate code: ./scripts/lint-code.ps1" -ForegroundColor White
    Write-Host "  3. Build release: ./scripts/build/build.ps1" -ForegroundColor White
    Write-Host "  4. Read docs: ./docs/development/contributing.md" -ForegroundColor White
    Write-Host ""
    Write-Host "📚 Available Scripts:" -ForegroundColor Cyan
    Write-Host "  • ./scripts/installation/install.ps1 - Install ProfileCore" -ForegroundColor White
    Write-Host "  • ./scripts/installation/uninstall.ps1 - Uninstall ProfileCore" -ForegroundColor White
    Write-Host "  • ./scripts/build/build.ps1 - Build release package" -ForegroundColor White
    Write-Host ""
}

# ═════════════════════════════════════════════════════════════════
#  EXECUTION
# ═════════════════════════════════════════════════════════════════

try {
    Start-DevEnvironmentSetup
} catch {
    Write-Error-Custom "Setup failed - $_"
    Write-Host ""
    Write-Host "For help, see: docs/development/contributing.md" -ForegroundColor Yellow
    exit 1
}

