<#
.SYNOPSIS
    ProfileCore v5.1.1 Quick Installer - One-Line Installation for Windows
.DESCRIPTION
    Downloads ProfileCore to Documents/PowerShell, runs the installer with Rust binary
    support, and optionally launches the configuration wizard. Repository is kept for
    easy updates. Includes antivirus compatibility support for Rust DLL.
    
    Automatically detects and installs missing prerequisites (Git) without prompting
    using winget or Chocolatey package managers.
.PARAMETER Branch
    Git branch to install (default: main)
.PARAMETER NonInteractive
    Run in non-interactive mode (no prompts)
.PARAMETER SkipConfig
    Skip configuration wizard
.PARAMETER InstallPath
    Custom installation path (default: Documents/PowerShell)
.EXAMPLE
    irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
.EXAMPLE
    & $QuickInstall -NonInteractive -SkipConfig
.EXAMPLE
    & $QuickInstall -Branch develop
.NOTES
    Author: Mythic3011
    Version: 5.1.1
    Features: Auto-prerequisite installation, lazy loading, performance optimizations
#>

[CmdletBinding()]
param(
    [string]$Branch = "main",
    [switch]$NonInteractive,
    [switch]$SkipConfig,
    [string]$InstallPath
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$script:StartTime = Get-Date

# Import ProfileCore.Common module for shared utilities (with fallback)
$commonModulePath = Join-Path $PSScriptRoot "..\modules\ProfileCore.Common"
$commonModuleLoaded = $false

if (Test-Path $commonModulePath) {
    try {
        Import-Module $commonModulePath -DisableNameChecking -ErrorAction Stop
        $commonModuleLoaded = $true
    } catch {
        Write-Verbose "Could not load ProfileCore.Common from repository: $_"
    }
}

# If not loaded from repository, try from installed modules
if (-not $commonModuleLoaded) {
    try {
        Import-Module ProfileCore.Common -ErrorAction Stop
        $commonModuleLoaded = $true
    } catch {
        Write-Verbose "ProfileCore.Common not in module path either, using fallback functions"
    }
}

# Fallback functions if ProfileCore.Common not available
if (-not $commonModuleLoaded) {
    function Write-BoxHeader {
        param([string]$Message, [string]$Color = 'Cyan', [int]$Width = 60)
        $line = "=" * $Width
        $padding = $Width - $Message.Length
        $leftPad = [Math]::Floor($padding / 2)
        $rightPad = [Math]::Ceiling($padding / 2)
        Write-Host "`n╔$line╗" -ForegroundColor $Color
        Write-Host "║$(' ' * $leftPad)$Message$(' ' * $rightPad)║" -ForegroundColor $Color
        Write-Host "╚$line╝`n" -ForegroundColor $Color
    }
    
    function Write-InstallProgress {
        param([string]$Message, [int]$Percent)
        $bar = "[" + ("=" * [math]::Floor($Percent / 5)) + (" " * (20 - [math]::Floor($Percent / 5))) + "]"
        Write-Host "$bar $Percent% - $Message" -ForegroundColor Cyan
    }
}

try {
    Write-BoxHeader "ProfileCore v5.1.1 Quick Installer - Windows" -Color Cyan
    
    if (-not $NonInteractive) {
        Write-Host "[NEW] New in v5.1.1:" -ForegroundColor Magenta
        Write-Host "  * Auto-installs missing prerequisites (Git) - no manual setup!" -ForegroundColor White
        Write-Host "  * 63% faster startup (1.2s vs 3.3s)" -ForegroundColor White
        Write-Host "  * Lazy loading for instant profile activation" -ForegroundColor White
        Write-Host "  * Parser error fixes for reliable module loading" -ForegroundColor White
        Write-Host ""
    }

    # Step 1: Prerequisites (0-20%)
    Write-InstallProgress "Checking prerequisites" 5
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan
    
    # Check PowerShell version first
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5) {
        Write-Host "[ERROR] PowerShell 5.1 or higher is required. Current: $psVersion" -ForegroundColor Red
        Write-Host "   Download PowerShell 7: https://aka.ms/install-powershell" -ForegroundColor Yellow
        Write-Host "   https://aka.ms/install-powershell" -ForegroundColor Cyan
        exit 1
    }
    Write-Host "[OK] PowerShell $psVersion" -ForegroundColor Green
    
    # Check and auto-install Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "[WARN] Git is not installed" -ForegroundColor Yellow
        Write-Host "[CONFIG] Attempting to install Git automatically..." -ForegroundColor Cyan
        
        $gitInstalled = $false
        
        # Try winget first (Windows 10+)
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "  Using winget to install Git..." -ForegroundColor Gray
            try {
                # Use --accept-source-agreements and --accept-package-agreements for non-interactive
                winget install --id Git.Git --exact --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
                
                # Refresh PATH to find git
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                
                # Verify installation
                if (Get-Command git -ErrorAction SilentlyContinue) {
                    Write-Host "[OK] Git installed successfully: $(git --version)" -ForegroundColor Green
                    $gitInstalled = $true
                } else {
                    Write-Host "[WARN] Git was installed but requires a new PowerShell session to be available" -ForegroundColor Yellow
                    Write-Host "   Please close and reopen PowerShell, then run this script again" -ForegroundColor Cyan
                    exit 1
                }
            } catch {
                Write-Host "[ERROR] Failed to install Git using winget: $_" -ForegroundColor Red
            }
        }
        
        # Try Chocolatey if winget failed
        if (-not $gitInstalled -and (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "  Using Chocolatey to install Git..." -ForegroundColor Gray
            try {
                choco install git -y --no-progress 2>&1 | Out-Null
                
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                
                if (Get-Command git -ErrorAction SilentlyContinue) {
                    Write-Host "[OK] Git installed successfully: $(git --version)" -ForegroundColor Green
                    $gitInstalled = $true
                } else {
                    Write-Host "[WARN] Git was installed but requires a new PowerShell session" -ForegroundColor Yellow
                    Write-Host "   Please close and reopen PowerShell, then run this script again" -ForegroundColor Cyan
                    exit 1
                }
            } catch {
                Write-Host "[ERROR] Failed to install Git using Chocolatey: $_" -ForegroundColor Red
            }
        }
        
        # If still not installed, show manual instructions
        if (-not $gitInstalled) {
            Write-Host "[ERROR] Could not install Git automatically" -ForegroundColor Red
            Write-Host "   Please install Git manually:" -ForegroundColor Yellow
            Write-Host "   * Download from: https://git-scm.com/" -ForegroundColor Cyan
            Write-Host "   * Or install winget: https://aka.ms/getwinget" -ForegroundColor Cyan
            exit 1
        }
    } else {
        Write-Host "[OK] Git found: $(git --version)" -ForegroundColor Green
    }
    
    # Check GitHub connectivity
    Write-InstallProgress "Testing GitHub connectivity" 10
    if (-not (Test-GitHubConnectivity)) {
        Write-Host "[WARN] Cannot connect to GitHub. Check your internet connection." -ForegroundColor Yellow
        if (-not (Get-UserConfirmation "Continue anyway?" -Default $false -NonInteractive:$NonInteractive)) {
            exit 1
        }
    } else {
        Write-Host "[OK] GitHub is reachable" -ForegroundColor Green
    }

    # Determine installation directory
    Write-InstallProgress "Determining installation path" 15
    if ($InstallPath) {
        $installDir = $InstallPath
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
        }
    } else {
        $installDir = if (Test-Path (Join-Path $HOME "Documents")) {
            Join-Path $HOME "Documents\PowerShell"
        } else {
            Join-Path $HOME ".local\share\powershell"
        }
    }
    
    $targetPath = Join-Path $installDir "ProfileCore"
    
    Write-Host "`n[PATH] Installation directory: $targetPath" -ForegroundColor White
    if ($Branch -ne "main") {
        Write-Host "[BRANCH] Branch: $Branch" -ForegroundColor Gray
    }
    
    # Step 2: Check/Update/Clone (20-50%)
    if (Test-Path $targetPath) {
        Write-Host "`n[WARN] ProfileCore directory already exists!" -ForegroundColor Yellow
        
        if (-not (Get-UserConfirmation "Do you want to update it?" -Default $true -NonInteractive:$NonInteractive)) {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            exit 0
        }
        
        Write-InstallProgress "Updating existing installation" 25
        Write-Host "`n[UPDATE] Updating existing installation..." -ForegroundColor Cyan
        
        Push-Location $targetPath
        try {
            # Stash any local changes
            $hasChanges = (git status --porcelain 2>&1) -ne ""
            if ($hasChanges) {
                Write-Host "  Stashing local changes..." -ForegroundColor Gray
                git stash push -m "Auto-stash before update $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 2>&1 | Out-Null
            }
            
            # Fetch and pull
            Write-Host "  Fetching updates from GitHub..." -ForegroundColor Gray
            git fetch origin $Branch 2>&1 | Out-Null
            
            Write-InstallProgress "Pulling latest changes" 40
            git pull origin $Branch 2>&1 | Out-Null
            
            if ($LASTEXITCODE -ne 0) {
                throw "Git pull failed. Check for conflicts."
            }
            
            Write-Host "[OK] Update complete" -ForegroundColor Green
        } catch {
            throw "Failed to update repository: $_"
        } finally {
            Pop-Location
        }
    } else {
        # Clone repository
        Write-InstallProgress "Downloading ProfileCore" 25
        Write-Host "`n[DOWNLOAD] Downloading ProfileCore from GitHub..." -ForegroundColor Cyan
        
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
        }
        
        Push-Location $installDir
        try {
            Write-Host "  Cloning repository (this may take a moment)..." -ForegroundColor Gray
            
            $cloneArgs = @(
                "clone",
                "--branch", $Branch,
                "--depth", "1",
                "--quiet",
                "https://github.com/mythic3011/ProfileCore.git"
            )
            
            & git @cloneArgs 2>&1 | Out-Null
            
            Write-InstallProgress "Clone complete" 45
            
            if (-not (Test-Path $targetPath)) {
                throw "Failed to clone repository. Check your network connection."
            }
            
            Write-Host "[OK] Download complete" -ForegroundColor Green
        } catch {
            throw "Failed to clone repository: $_"
        } finally {
            Pop-Location
        }
    }
    
    Set-Location $targetPath

    # Step 3: Run installer (50-90%)
    Write-InstallProgress "Running installer" 50
    Write-Host "`n[RUN] Running installer..." -ForegroundColor Cyan
    Write-Host "================================================================`n" -ForegroundColor Gray
    
    try {
        $installerPath = Join-Path $targetPath "scripts\installation\install.ps1"
        if (-not (Test-Path $installerPath)) {
            throw "Installer script not found at: $installerPath"
        }
        
        & $installerPath
        
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            throw "Installation failed with exit code: $LASTEXITCODE"
        }
    } catch {
        throw "Installer execution failed: $_"
    }

    Write-InstallProgress "Installation complete" 90
    Write-Host "`n================================================================" -ForegroundColor Gray
    
    $installTime = ((Get-Date) - $script:StartTime).TotalSeconds
    Write-Host "`n[OK] ProfileCore installed successfully in $([math]::Round($installTime, 1))s!" -ForegroundColor Green
    
    if (-not $SkipConfig) {
        Write-InstallProgress "Configuration check" 95
        Write-Host "`n[CONFIG] Configuration Setup" -ForegroundColor Cyan
        Write-Host "   This will set up API keys, paths, and preferences." -ForegroundColor Gray
        
        if (Get-UserConfirmation "Would you like to configure ProfileCore now?" -Default $true -NonInteractive:$NonInteractive) {
            Write-Host "`n[SETUP] Launching configuration wizard..." -ForegroundColor Cyan
            
            # Try to load profile and run config
            try {
                . $PROFILE
                Start-Sleep -Milliseconds 500
                
                if (Get-Command Initialize-ProfileCoreConfig -ErrorAction SilentlyContinue) {
                    Initialize-ProfileCoreConfig
                } else {
                    Write-Host "[WARN] Configuration wizard not available yet. Please reload your profile first:" -ForegroundColor Yellow
                    Write-Host "   . `$PROFILE" -ForegroundColor Cyan
                    Write-Host "   Initialize-ProfileCoreConfig" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "[WARN] Could not auto-launch configuration: $_" -ForegroundColor Yellow
                Write-Host "   Run manually: Initialize-ProfileCoreConfig" -ForegroundColor Cyan
            }
        } else {
            Write-Host "`n[NOTE] You can configure ProfileCore later by running:" -ForegroundColor Yellow
            Write-Host "   Initialize-ProfileCoreConfig" -ForegroundColor Cyan
        }
    }
    
    Write-InstallProgress "Complete" 100
    
    # Success summary
    Write-BoxHeader "[SUCCESS] Installation Complete!" -Color Green
    
    Write-Host "`n[NEXT] Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Reload your profile:" -ForegroundColor White
    Write-Host "      . `$PROFILE" -ForegroundColor Cyan
    Write-Host "`n   2. Test installation:" -ForegroundColor White
    Write-Host "      Get-SystemInfo       # System information" -ForegroundColor Cyan
    Write-Host "      myip                 # Get public IP" -ForegroundColor Cyan
    Write-Host "      perf                 # Performance metrics" -ForegroundColor Cyan
    Write-Host "`n   3. View all commands:" -ForegroundColor White
    Write-Host "      Get-Helper           # Help system" -ForegroundColor Cyan
    Write-Host "      Get-Command -Module ProfileCore" -ForegroundColor Cyan
    
    Write-Host "`n[INFO] Installation Details:" -ForegroundColor Cyan
    Write-Host "   Location: $targetPath" -ForegroundColor White
    Write-Host "   Branch:   $Branch" -ForegroundColor White
    Write-Host "   Time:     $([math]::Round($installTime, 1))s" -ForegroundColor White
    
    Write-Host "`n[TIP] Useful Commands:" -ForegroundColor Yellow
    Write-Host "   Update:   cd `"$targetPath`"; git pull; .\scripts\installation\install.ps1" -ForegroundColor Gray
    Write-Host "   Validate: .\scripts\installation\install.ps1 -Validate" -ForegroundColor Gray
    Write-Host "   Optimize: Optimize-ProfileCore" -ForegroundColor Gray
    
    Write-Host "`n[SUCCESS] Happy scripting!`n" -ForegroundColor Green

} catch {
    Write-BoxHeader "[ERROR] Installation Failed" -Color Red
    
    Write-Host "`n[ERROR] Error: $_" -ForegroundColor Red
    
    if ($_.ScriptStackTrace) {
        Write-Host "`nStack Trace:" -ForegroundColor Gray
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    
    Write-Host "`n[TIP] Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Check your internet connection" -ForegroundColor White
    Write-Host "   2. Ensure Git is properly installed" -ForegroundColor White
    Write-Host "   3. Try running PowerShell as Administrator" -ForegroundColor White
    Write-Host "   4. Check execution policy: Get-ExecutionPolicy" -ForegroundColor White
    
    Write-Host "`n[TIP] Manual Installation:" -ForegroundColor Yellow
    Write-Host "   git clone https://github.com/mythic3011/ProfileCore.git" -ForegroundColor Cyan
    Write-Host "   cd ProfileCore" -ForegroundColor Cyan
    Write-Host "   .\scripts\installation\install.ps1" -ForegroundColor Cyan
    
    Write-Host "`n[HELP] Need help? Open an issue at:" -ForegroundColor White
    Write-Host "   https://github.com/mythic3011/ProfileCore/issues`n" -ForegroundColor Cyan
    
    exit 1
} finally {
    $ProgressPreference = 'Continue'
}

