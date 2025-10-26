<#
.SYNOPSIS
    ProfileCore v6.0 Zero-Prerequisite Installer
    
.DESCRIPTION
    Installs ProfileCore with NO requirements except PowerShell 5.1+
    
    Features:
    - Auto-downloads from GitHub releases (no Git needed)
    - Includes pre-built Rust binaries (no Rust toolchain needed)
    - Works offline with pre-downloaded package
    - No admin rights required
    - Cross-platform: Windows, Linux, macOS
    
.PARAMETER Version
    Specific version to install (default: latest)
    
.PARAMETER Offline
    Install from local package (for air-gapped systems)
    
.PARAMETER OfflinePackage
    Path to offline package ZIP file
    
.PARAMETER NoOptimizations
    Skip downloading Rust binaries, use pure PowerShell only
    
.PARAMETER SkipWelcome
    Skip the welcome wizard
    
.PARAMETER Quiet
    Minimal output mode
    
.PARAMETER Force
    Force reinstall even if already installed
    
.EXAMPLE
    .\install-v6.ps1
    Install latest version with interactive setup
    
.EXAMPLE
    .\install-v6.ps1 -Version 6.0.0 -Quiet
    Install specific version silently
    
.EXAMPLE
    .\install-v6.ps1 -Offline -OfflinePackage .\ProfileCore-offline.zip
    Install from offline package
    
.EXAMPLE
    .\install-v6.ps1 -NoOptimizations
    Install without Rust binaries (pure PowerShell)
    
.NOTES
    Author: Mythic3011
    Version: 6.0.0
    Zero prerequisites required!
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Version = 'latest',
    [switch]$Offline,
    [string]$OfflinePackage,
    [switch]$NoOptimizations,
    [switch]$SkipWelcome,
    [switch]$Quiet,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# ============================================================================
# CONSTANTS
# ============================================================================

$script:InstallConfig = @{
    RepoOwner = 'mythic3011'
    RepoName = 'ProfileCore'
    InstallPath = Join-Path $HOME '.profilecore'
    TempPath = Join-Path ([System.IO.Path]::GetTempPath()) "ProfileCore-Install-$PID"
    BackupPath = Join-Path $HOME '.profilecore-backup'
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Step {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "🔹 $Message" -ForegroundColor Cyan
    }
}

function Write-Success {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "✅ $Message" -ForegroundColor Green
    }
}

function Write-Info {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "ℹ️  $Message" -ForegroundColor White
    }
}

function Write-Warn {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "⚠️  $Message" -ForegroundColor Yellow
    }
}

function Write-Fail {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ============================================================================
# PLATFORM DETECTION
# ============================================================================

function Get-PlatformInfo {
    [CmdletBinding()]
    param()
    
    $platform = if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        "windows"
    } elseif ($IsMacOS) {
        "macos"
    } elseif ($IsLinux) {
        "linux"
    } else {
        throw "Unsupported platform"
    }
    
    # Detect architecture
    $arch = try {
        [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString().ToLower()
    } catch {
        # Fallback for PowerShell 5.1
        if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
    }
    
    # Normalize architecture names
    $arch = switch ($arch) {
        { $_ -in @('x64', 'amd64', 'x86_64') } { 'x64' }
        { $_ -in @('arm64', 'aarch64') } { 'arm64' }
        default { $_ }
    }
    
    return @{
        Platform = $platform
        Architecture = $arch
        PSVersion = $PSVersionTable.PSVersion.Major
        IsAdmin = Test-IsAdministrator
    }
}

function Test-IsAdministrator {
    if ($PSVersionTable.PSVersion.Major -le 5 -or $IsWindows) {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $false
}

# ============================================================================
# GITHUB API FUNCTIONS
# ============================================================================

function Get-GitHubRelease {
    [CmdletBinding()]
    param([string]$Version)
    
    Write-Step "Fetching release information from GitHub..."
    
    $apiUrl = if ($Version -eq 'latest') {
        "https://api.github.com/repos/$($script:InstallConfig.RepoOwner)/$($script:InstallConfig.RepoName)/releases/latest"
    } else {
        "https://api.github.com/repos/$($script:InstallConfig.RepoOwner)/$($script:InstallConfig.RepoName)/releases/tags/v$Version"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{
            'User-Agent' = 'ProfileCore-Installer'
            'Accept' = 'application/vnd.github.v3+json'
        }
        
        Write-Success "Found ProfileCore $($response.tag_name)"
        return $response
        
    } catch {
        throw "Failed to fetch release info from GitHub: $_`nURL: $apiUrl`nTry using -Offline mode or check your internet connection."
    }
}

function Download-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Url,
        
        [Parameter(Mandatory)]
        [string]$Destination
    )
    
    $fileName = Split-Path $Destination -Leaf
    Write-Step "Downloading $fileName..."
    
    try {
        # Ensure destination directory exists
        $destDir = Split-Path $Destination -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Download with progress
        if (-not $Quiet) {
            $ProgressPreference = 'Continue'
        }
        
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        
        $ProgressPreference = 'SilentlyContinue'
        
        Write-Success "Downloaded $fileName"
        
    } catch {
        throw "Failed to download $fileName from $Url : $_"
    }
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

function Install-ProfileCore {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         ProfileCore v6.0 - Zero-Prerequisite Installer        ║" -ForegroundColor Cyan
    Write-Host "║                  World-Class Shell Experience                  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # 1. Detect environment
    Write-Step "Detecting system environment..."
    $platformInfo = Get-PlatformInfo
    Write-Info "Platform: $($platformInfo.Platform) ($($platformInfo.Architecture))"
    Write-Info "PowerShell: v$($platformInfo.PSVersion)"
    
    # 2. Check if already installed
    if ((Test-Path $script:InstallConfig.InstallPath) -and -not $Force) {
        Write-Warn "ProfileCore is already installed at: $($script:InstallConfig.InstallPath)"
        $response = Read-Host "Reinstall? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Installation cancelled."
            return
        }
        $Force = $true
    }
    
    # 3. Create temp directory
    if (-not (Test-Path $script:InstallConfig.TempPath)) {
        New-Item -ItemType Directory -Path $script:InstallConfig.TempPath -Force | Out-Null
    }
    
    try {
        # 4. Get release info or use offline package
        if ($Offline) {
            if (-not $OfflinePackage) {
                throw "Offline mode requires -OfflinePackage parameter"
            }
            if (-not (Test-Path $OfflinePackage)) {
                throw "Offline package not found: $OfflinePackage"
            }
            $packagePath = $OfflinePackage
            Write-Info "Using offline package: $OfflinePackage"
        } else {
            $release = Get-GitHubRelease -Version $Version
            
            # Find main package asset
            $mainAsset = $release.assets | Where-Object { $_.name -match 'ProfileCore.*\.zip$' -and $_.name -notmatch 'binary' } | Select-Object -First 1
            
            if (-not $mainAsset) {
                throw "Could not find ProfileCore package in release assets"
            }
            
            $packagePath = Join-Path $script:InstallConfig.TempPath $mainAsset.name
            Download-File -Url $mainAsset.browser_download_url -Destination $packagePath
        }
        
        # 5. Backup existing installation
        if ((Test-Path $script:InstallConfig.InstallPath) -and $Force) {
            Write-Step "Backing up existing installation..."
            if (Test-Path $script:InstallConfig.BackupPath) {
                Remove-Item -Path $script:InstallConfig.BackupPath -Recurse -Force
            }
            Copy-Item -Path $script:InstallConfig.InstallPath -Destination $script:InstallConfig.BackupPath -Recurse -Force
            Write-Success "Backup created at: $($script:InstallConfig.BackupPath)"
        }
        
        # 6. Extract package
        Write-Step "Extracting ProfileCore..."
        if (Test-Path $script:InstallConfig.InstallPath) {
            Remove-Item -Path $script:InstallConfig.InstallPath -Recurse -Force
        }
        Expand-Archive -Path $packagePath -DestinationPath $script:InstallConfig.InstallPath -Force
        Write-Success "Extracted to: $($script:InstallConfig.InstallPath)"
        
        # 7. Download Rust binary if available and wanted
        if (-not $NoOptimizations -and -not $Offline) {
            Install-RustBinary -Release $release -PlatformInfo $platformInfo
        }
        
        # 8. Integrate with PowerShell profile
        Install-ProfileIntegration -PlatformInfo $platformInfo
        
        # 9. Run welcome wizard
        if (-not $SkipWelcome) {
            Start-WelcomeWizard
        }
        
        Write-Host ""
        Write-Success "🎉 ProfileCore installed successfully!"
        Write-Host ""
        Write-Info "Next steps:"
        Write-Host "  1. Restart your shell OR run: . `$PROFILE" -ForegroundColor Yellow
        Write-Host "  2. Type 'Get-Helper' for available commands" -ForegroundColor Yellow
        Write-Host "  3. Type 'Start-ProfileCoreSetup' to customize" -ForegroundColor Yellow
        Write-Host ""
        
    } catch {
        Write-Fail "Installation failed: $_"
        
        # Attempt rollback
        if ((Test-Path $script:InstallConfig.BackupPath)) {
            Write-Warn "Attempting rollback..."
            try {
                if (Test-Path $script:InstallConfig.InstallPath) {
                    Remove-Item -Path $script:InstallConfig.InstallPath -Recurse -Force
                }
                Copy-Item -Path $script:InstallConfig.BackupPath -Destination $script:InstallConfig.InstallPath -Recurse -Force
                Write-Success "Rolled back to previous installation"
            } catch {
                Write-Fail "Rollback failed: $_"
                Write-Warn "Manual recovery needed. Backup location: $($script:InstallConfig.BackupPath)"
            }
        }
        
        throw
    } finally {
        # Cleanup temp directory
        if (Test-Path $script:InstallConfig.TempPath) {
            Remove-Item -Path $script:InstallConfig.TempPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-RustBinary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Release,
        
        [Parameter(Mandatory)]
        $PlatformInfo
    )
    
    Write-Step "Looking for Rust performance binary..."
    
    # Construct binary name
    $binaryExt = switch ($PlatformInfo.Platform) {
        'windows' { 'dll' }
        'macos' { 'dylib' }
        'linux' { 'so' }
    }
    
    $binaryPattern = "ProfileCore-$($PlatformInfo.Platform)-$($PlatformInfo.Architecture)\.$binaryExt"
    $binaryAsset = $Release.assets | Where-Object { $_.name -match $binaryPattern } | Select-Object -First 1
    
    if ($binaryAsset) {
        $binaryPath = Join-Path $script:InstallConfig.InstallPath "modules/ProfileCore.Binary/bin/$($binaryAsset.name)"
        Download-File -Url $binaryAsset.browser_download_url -Destination $binaryPath
        Write-Success "✨ Installed Rust performance binary (5-10x faster operations!)"
    } else {
        Write-Info "ℹ️  Rust binary not available for $($PlatformInfo.Platform)-$($PlatformInfo.Architecture)"
        Write-Info "Using pure PowerShell implementation (still fast!)"
    }
}

function Install-ProfileIntegration {
    [CmdletBinding()]
    param($PlatformInfo)
    
    Write-Step "Integrating with PowerShell profile..."
    
    $profilePath = $PROFILE
    $profileContent = if (Test-Path $profilePath) {
        Get-Content $profilePath -Raw
    } else {
        ""
    }
    
    # Check if already integrated
    if ($profileContent -match 'ProfileCore') {
        Write-Info "ProfileCore already integrated in profile"
        return
    }
    
    # Add ProfileCore initialization
    $integration = @"

# ============================================================================
# ProfileCore v6.0 - World-Class Shell Experience
# ============================================================================

# Add ProfileCore to module path
`$env:PSModulePath += ";$($script:InstallConfig.InstallPath)/modules"

# Try to load Rust binary module first (fast path)
`$script:UseBinaryModule = `$false
if (`$env:PROFILECORE_USE_BINARY -ne '0') {
    try {
        Import-Module ProfileCore.Binary -ErrorAction Stop
        `$script:UseBinaryModule = `$true
    } catch {
        # Silently fall back to PowerShell implementation
    }
}

# Import main ProfileCore module
Import-Module ProfileCore

# Welcome message (first time only)
if (-not (Test-Path `"`$env:USERPROFILE\.profilecore-initialized`")) {
    Write-Host "🎉 Welcome to ProfileCore v6.0!" -ForegroundColor Cyan
    Write-Host "Type 'Get-Helper' for available commands" -ForegroundColor Yellow
    New-Item -Path "`$env:USERPROFILE\.profilecore-initialized" -ItemType File -Force | Out-Null
}

"@
    
    # Ensure profile directory exists
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Add integration to profile
    Add-Content -Path $profilePath -Value $integration
    Write-Success "Profile integration complete"
}

function Start-WelcomeWizard {
    [CmdletBinding()]
    param()
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    Welcome to ProfileCore! 🎉                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "ProfileCore is now installed with:"
    Write-Host "  ✅ 97 powerful functions across 4 shells" -ForegroundColor Green
    Write-Host "  ✅ Universal package management" -ForegroundColor Green
    Write-Host "  ✅ Security and networking tools" -ForegroundColor Green
    Write-Host "  ✅ Git and Docker automation" -ForegroundColor Green
    Write-Host "  ✅ System monitoring and optimization" -ForegroundColor Green
    
    if ($script:UseBinaryModule) {
        Write-Host "  ✨ Rust performance binary (5-10x faster!)" -ForegroundColor Magenta
    }
    
    Write-Host ""
    Write-Host "Quick Start Commands:" -ForegroundColor Cyan
    Write-Host "  Get-Helper              - Show all commands"
    Write-Host "  Get-SystemInfo          - System information"
    Write-Host "  pkg install <name>      - Install packages"
    Write-Host "  scan-port <host>        - Port scanning"
    Write-Host "  Start-ProfileCoreSetup  - Customize settings"
    Write-Host ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

Install-ProfileCore


