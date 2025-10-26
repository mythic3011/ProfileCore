# build.ps1
# ProfileCore Build Script
# Creates optimized, minified releases

<#
.SYNOPSIS
    Build and package ProfileCore releases
.DESCRIPTION
    This script:
    - Minifies PowerShell code
    - Removes comments and extra whitespace
    - Bundles shell scripts
    - Creates release archives
    - Generates checksums
    - Creates release notes
.PARAMETER Version
    Release version (e.g., "5.0.0")
.PARAMETER Configuration
    Build configuration: Release or Debug
.PARAMETER SkipMinify
    Skip code minification
.PARAMETER SkipTests
    Skip running tests
.EXAMPLE
    .\build.ps1 -Version "5.0.0" -Configuration Release
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Version,
    
    [Parameter()]
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release',
    
    [Parameter()]
    [switch]$SkipMinify,
    
    [Parameter()]
    [switch]$SkipTests,
    
    [Parameter()]
    [switch]$SkipArchive
)

# ═════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = 'Stop'
$script:BuildStart = Get-Date

# Paths
$script:RootDir = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$script:BuildDir = Join-Path $script:RootDir "build"
$script:OutputDir = Join-Path $script:BuildDir "output"
$script:ReleaseDir = Join-Path $script:OutputDir "ProfileCore-v$Version"
$script:ArchiveDir = Join-Path $script:BuildDir "releases"

# Build configuration
$script:BuildConfig = @{
    Version = $Version
    Configuration = $Configuration
    Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    MinifyCode = (-not $SkipMinify)
    SkipTests = $SkipTests
}

# ═════════════════════════════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════

function Write-BuildStep {
    param([string]$Message, [string]$Color = 'Cyan')
    Write-Host "`n$Message" -ForegroundColor $Color
    Write-Host ("=" * 80) -ForegroundColor Gray
}

function Write-BuildSuccess {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-BuildWarning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-BuildError {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ═════════════════════════════════════════════════════════════════════════════
#  CODE OPTIMIZATION
# ═════════════════════════════════════════════════════════════════════════════

function Optimize-PowerShellScript {
    <#
    .SYNOPSIS
        Minify PowerShell script
    #>
    param(
        [Parameter(Mandatory)]
        [string]$InputPath,
        
        [Parameter(Mandatory)]
        [string]$OutputPath
    )
    
    if (-not $script:BuildConfig.MinifyCode) {
        Copy-Item $InputPath $OutputPath -Force
        return
    }
    
    try {
        $content = Get-Content $InputPath -Raw
        
        # Remove multi-line comments
        $content = $content -replace '(?s)<#.*?#>', ''
        
        # Remove single-line comments (but keep shebang)
        $lines = $content -split "`n"
        $optimized = @()
        
        foreach ($line in $lines) {
            # Keep shebang
            if ($line -match '^#!') {
                $optimized += $line
                continue
            }
            
            # Remove comments but preserve strings
            if ($line -match '^\s*#' -and $line -notmatch '["''].*#.*["'']') {
                continue
            }
            
            # Remove trailing comments
            $line = $line -replace '\s+#.*$', ''
            
            # Skip empty lines in Release mode
            if ($Configuration -eq 'Release' -and $line -match '^\s*$') {
                continue
            }
            
            # Remove extra whitespace
            if ($Configuration -eq 'Release') {
                $line = $line -replace '^\s+', '' -replace '\s+$', ''
            }
            
            $optimized += $line
        }
        
        # Join lines
        $content = $optimized -join "`n"
        
        # Create output directory if needed
        $outputDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        # Save optimized content
        $content | Out-File $OutputPath -Encoding UTF8 -NoNewline
        
        # Calculate size reduction
        $originalSize = (Get-Item $InputPath).Length
        $optimizedSize = (Get-Item $OutputPath).Length
        $reduction = [math]::Round((1 - ($optimizedSize / $originalSize)) * 100, 1)
        
        Write-Verbose "  Optimized: $(Split-Path $InputPath -Leaf) (${reduction}% smaller)"
        
    } catch {
        Write-BuildWarning "Failed to optimize $InputPath`: $_"
        Copy-Item $InputPath $OutputPath -Force
    }
}

function Optimize-ShellScript {
    <#
    .SYNOPSIS
        Minify shell script (Bash/Zsh/Fish)
    #>
    param(
        [Parameter(Mandatory)]
        [string]$InputPath,
        
        [Parameter(Mandatory)]
        [string]$OutputPath
    )
    
    if (-not $script:BuildConfig.MinifyCode) {
        Copy-Item $InputPath $OutputPath -Force
        return
    }
    
    try {
        $content = Get-Content $InputPath -Raw
        $lines = $content -split "`n"
        $optimized = @()
        
        foreach ($line in $lines) {
            # Keep shebang
            if ($line -match '^#!') {
                $optimized += $line
                continue
            }
            
            # Remove comments
            if ($line -match '^\s*#' -and $line -notmatch '["''].*#.*["'']') {
                continue
            }
            
            # Remove trailing comments
            $line = $line -replace '\s+#.*$', ''
            
            # Skip empty lines in Release mode
            if ($Configuration -eq 'Release' -and $line -match '^\s*$') {
                continue
            }
            
            $optimized += $line
        }
        
        $content = $optimized -join "`n"
        
        $outputDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        $content | Out-File $OutputPath -Encoding UTF8 -NoNewline
        
    } catch {
        Write-BuildWarning "Failed to optimize $InputPath`: $_"
        Copy-Item $InputPath $OutputPath -Force
    }
}

# ═════════════════════════════════════════════════════════════════════════════
#  BUILD STEPS
# ═════════════════════════════════════════════════════════════════════════════

function Initialize-Build {
    Write-BuildStep "Initializing Build" "Cyan"
    
    # Clean build directory
    if (Test-Path $script:BuildDir) {
        Write-Host "Cleaning build directory..."
        Remove-Item $script:BuildDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Create directories
    New-Item -ItemType Directory -Path $script:ReleaseDir -Force | Out-Null
    New-Item -ItemType Directory -Path $script:ArchiveDir -Force | Out-Null
    
    Write-BuildSuccess "Build initialized"
    Write-Host "  Version: $Version"
    Write-Host "  Configuration: $Configuration"
    Write-Host "  Minify: $($script:BuildConfig.MinifyCode)"
    Write-Host "  Output: $script:ReleaseDir"
}

function Test-ProfileCore {
    if ($SkipTests) {
        Write-BuildWarning "Skipping tests"
        return
    }
    
    Write-BuildStep "Running Tests" "Cyan"
    
    $testsDir = Join-Path $script:RootDir "tests"
    
    if (-not (Test-Path $testsDir)) {
        Write-BuildWarning "Tests directory not found"
        return
    }
    
    try {
        # Check if Pester is available
        if (-not (Get-Module -ListAvailable -Name Pester)) {
            Write-BuildWarning "Pester not installed, skipping tests"
            return
        }
        
        Import-Module Pester -ErrorAction Stop
        
        # Run tests
        $result = Invoke-Pester -Path $testsDir -PassThru -Output Minimal
        
        if ($result.FailedCount -gt 0) {
            Write-BuildError "Tests failed: $($result.FailedCount) failed"
            throw "Build aborted due to test failures"
        }
        
        Write-BuildSuccess "All tests passed ($($result.PassedCount) tests)"
        
    } catch {
        Write-BuildError "Test execution failed: $_"
        throw
    }
}

function Build-PowerShellModule {
    Write-BuildStep "Building PowerShell Module" "Cyan"
    
    # Build ProfileCore.Common shared library module
    Write-Host "Building ProfileCore.Common..."
    $sourceCommonDir = Join-Path $script:RootDir "modules\ProfileCore.Common"
    $targetCommonDir = Join-Path $script:ReleaseDir "modules\ProfileCore.Common"
    
    if (Test-Path $sourceCommonDir) {
        New-Item -ItemType Directory -Path $targetCommonDir -Force | Out-Null
        
        # Copy manifests
        Copy-Item "$sourceCommonDir\ProfileCore.Common.psd1" "$targetCommonDir\ProfileCore.Common.psd1" -Force
        Copy-Item "$sourceCommonDir\ProfileCore.Common.psm1" "$targetCommonDir\ProfileCore.Common.psm1" -Force
        
        # Copy public functions
        $commonPublicDir = Join-Path $sourceCommonDir "public"
        if (Test-Path $commonPublicDir) {
            $targetCommonPublicDir = Join-Path $targetCommonDir "public"
            New-Item -ItemType Directory -Path $targetCommonPublicDir -Force | Out-Null
            
            Get-ChildItem $commonPublicDir -Filter "*.ps1" | ForEach-Object {
                Optimize-PowerShellScript `
                    -InputPath $_.FullName `
                    -OutputPath (Join-Path $targetCommonPublicDir $_.Name)
            }
        }
        Write-Host "  ✓ ProfileCore.Common built"
    }
    
    # Build main ProfileCore module
    Write-Host "Building ProfileCore..."
    $sourceModuleDir = Join-Path $script:RootDir "modules\ProfileCore"
    $targetModuleDir = Join-Path $script:ReleaseDir "modules\ProfileCore"
    
    # Create target directory
    New-Item -ItemType Directory -Path $targetModuleDir -Force | Out-Null
    
    # Copy and optimize module manifest
    Copy-Item "$sourceModuleDir\ProfileCore.psd1" "$targetModuleDir\ProfileCore.psd1" -Force
    
    # Copy and optimize module file
    Optimize-PowerShellScript `
        -InputPath "$sourceModuleDir\ProfileCore.psm1" `
        -OutputPath "$targetModuleDir\ProfileCore.psm1"
    
    # Process private functions (v5 - deprecated)
    $privateDir = Join-Path $sourceModuleDir "private"
    if (Test-Path $privateDir) {
        $targetPrivateDir = Join-Path $targetModuleDir "private"
        New-Item -ItemType Directory -Path $targetPrivateDir -Force | Out-Null
        
        Get-ChildItem $privateDir -Filter "*.ps1" | ForEach-Object {
            Optimize-PowerShellScript `
                -InputPath $_.FullName `
                -OutputPath (Join-Path $targetPrivateDir $_.Name)
        }
    }
    
    # Process private-v6 directory (v6 DI architecture)
    $privatev6Dir = Join-Path $sourceModuleDir "private-v6"
    if (Test-Path $privatev6Dir) {
        Write-Host "  Building v6 architecture..."
        $targetPrivatev6Dir = Join-Path $targetModuleDir "private-v6"
        
        # Copy entire private-v6 directory structure
        Copy-Item $privatev6Dir $targetPrivatev6Dir -Recurse -Force
    }
    
    # Process public functions
    $publicDir = Join-Path $sourceModuleDir "public"
    if (Test-Path $publicDir) {
        $targetPublicDir = Join-Path $targetModuleDir "public"
        New-Item -ItemType Directory -Path $targetPublicDir -Force | Out-Null
        
        Get-ChildItem $publicDir -Filter "*.ps1" | ForEach-Object {
            Optimize-PowerShellScript `
                -InputPath $_.FullName `
                -OutputPath (Join-Path $targetPublicDir $_.Name)
        }
    }
    
    # Process rust-binary subdirectory (optional Rust binary component)
    $rustBinaryDir = Join-Path $sourceModuleDir "rust-binary"
    if (Test-Path $rustBinaryDir) {
        Write-Host "  Building Rust binary component..."
        $targetRustBinaryDir = Join-Path $targetModuleDir "rust-binary"
        New-Item -ItemType Directory -Path $targetRustBinaryDir -Force | Out-Null
        
        # Copy manifests and loader
        Copy-Item "$rustBinaryDir\RustBinary.psd1" "$targetRustBinaryDir\RustBinary.psd1" -Force
        Copy-Item "$rustBinaryDir\RustBinary.psm1" "$targetRustBinaryDir\RustBinary.psm1" -Force
        Copy-Item "$rustBinaryDir\README.md" "$targetRustBinaryDir\README.md" -Force -ErrorAction SilentlyContinue
        
        # Copy bin directory with DLLs
        $binDir = Join-Path $rustBinaryDir "bin"
        if (Test-Path $binDir) {
            $targetBinDir = Join-Path $targetRustBinaryDir "bin"
            New-Item -ItemType Directory -Path $targetBinDir -Force | Out-Null
            Copy-Item "$binDir\*" $targetBinDir -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  ✓ Rust binary component included"
    }
    
    Write-BuildSuccess "PowerShell module built"
}

function Build-ShellFunctions {
    Write-BuildStep "Building Shell Functions" "Cyan"
    
    $shells = @('zsh', 'bash', 'fish')
    
    foreach ($shell in $shells) {
        $sourceShellDir = Join-Path $script:RootDir "shells\$shell"
        $targetShellDir = Join-Path $script:ReleaseDir "shells\$shell"
        
        if (-not (Test-Path $sourceShellDir)) {
            continue
        }
        
        Write-Host "Building $shell functions..."
        
        # Create target directory structure
        New-Item -ItemType Directory -Path "$targetShellDir\lib" -Force | Out-Null
        
        # Copy and optimize lib files
        $libDir = Join-Path $sourceShellDir "lib"
        if (Test-Path $libDir) {
            Get-ChildItem $libDir -File | ForEach-Object {
                Optimize-ShellScript `
                    -InputPath $_.FullName `
                    -OutputPath (Join-Path "$targetShellDir\lib" $_.Name)
            }
        }
        
        # Copy and optimize main loader
        $loaderFile = "profilecore.$shell"
        if ($shell -eq 'fish') {
            $loaderFile = "profilecore.fish"
        }
        
        $loaderPath = Join-Path $sourceShellDir $loaderFile
        if (Test-Path $loaderPath) {
            Optimize-ShellScript `
                -InputPath $loaderPath `
                -OutputPath (Join-Path $targetShellDir $loaderFile)
        }
    }
    
    Write-BuildSuccess "Shell functions built"
}

function Build-Profile {
    Write-BuildStep "Building Profile Script" "Cyan"
    
    $sourceProfile = Join-Path $script:RootDir "Microsoft.PowerShell_profile.ps1"
    $targetProfile = Join-Path $script:ReleaseDir "Microsoft.PowerShell_profile.ps1"
    
    Optimize-PowerShellScript `
        -InputPath $sourceProfile `
        -OutputPath $targetProfile
    
    Write-BuildSuccess "Profile script built"
}

function Build-Plugins {
    Write-BuildStep "Building Example Plugins" "Cyan"
    
    $sourcePluginsDir = Join-Path $script:RootDir "examples\plugins"
    $targetPluginsDir = Join-Path $script:ReleaseDir "examples\plugins"
    
    if (-not (Test-Path $sourcePluginsDir)) {
        Write-BuildWarning "Plugins directory not found"
        return
    }
    
    # Get all plugin directories
    Get-ChildItem $sourcePluginsDir -Directory | ForEach-Object {
        $pluginName = $_.Name
        $sourcePluginDir = $_.FullName
        $targetPluginDir = Join-Path $targetPluginsDir $pluginName
        
        Write-Host "Building plugin: $pluginName..."
        
        New-Item -ItemType Directory -Path $targetPluginDir -Force | Out-Null
        
        # Copy manifest
        Copy-Item "$sourcePluginDir\plugin.psd1" "$targetPluginDir\plugin.psd1" -Force -ErrorAction SilentlyContinue
        
        # Optimize module file
        $moduleFile = Get-ChildItem $sourcePluginDir -Filter "*.psm1" | Select-Object -First 1
        if ($moduleFile) {
            Optimize-PowerShellScript `
                -InputPath $moduleFile.FullName `
                -OutputPath (Join-Path $targetPluginDir $moduleFile.Name)
        }
        
        # Copy README
        Copy-Item "$sourcePluginDir\README.md" "$targetPluginDir\README.md" -Force -ErrorAction SilentlyContinue
    }
    
    Write-BuildSuccess "Plugins built"
}

function Build-Documentation {
    Write-BuildStep "Copying Documentation" "Cyan"
    
    # Essential documentation
    $docs = @(
        'README.md',
        'QUICK_START.md',
        'INSTALL.md',
        'LICENSE',
        'MIGRATION_V5.md'
    )
    
    foreach ($doc in $docs) {
        $sourcePath = Join-Path $script:RootDir $doc
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath (Join-Path $script:ReleaseDir $doc) -Force
        }
    }
    
    # Copy docs directory (selective)
    $sourceDocsDir = Join-Path $script:RootDir "docs"
    $targetDocsDir = Join-Path $script:ReleaseDir "docs"
    
    # Copy essential docs
    $essentialDocs = @(
        'PROFILECORE_V5_SUMMARY.md',
        'development\SOLID_ARCHITECTURE.md',
        'development\OPTIMIZATION_SUMMARY.md',
        'development\contributing.md'
    )
    
    foreach ($doc in $essentialDocs) {
        $sourcePath = Join-Path $sourceDocsDir $doc
        $targetPath = Join-Path $targetDocsDir $doc
        
        if (Test-Path $sourcePath) {
            $targetDir = Split-Path $targetPath -Parent
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Copy-Item $sourcePath $targetPath -Force
        }
    }
    
    Write-BuildSuccess "Documentation copied"
}

function Build-Scripts {
    Write-BuildStep "Building Installation Scripts" "Cyan"
    
    $sourceScriptsDir = Join-Path $script:RootDir "scripts\installation"
    $targetScriptsDir = Join-Path $script:ReleaseDir "scripts\installation"
    
    if (Test-Path $sourceScriptsDir) {
        New-Item -ItemType Directory -Path $targetScriptsDir -Force | Out-Null
        
        # Copy install scripts
        Get-ChildItem $sourceScriptsDir -Filter "install.*" | ForEach-Object {
            if ($_.Extension -eq '.ps1') {
                Optimize-PowerShellScript `
                    -InputPath $_.FullName `
                    -OutputPath (Join-Path $targetScriptsDir $_.Name)
            } else {
                Copy-Item $_.FullName (Join-Path $targetScriptsDir $_.Name) -Force
            }
        }
    }
    
    Write-BuildSuccess "Scripts built"
}

function New-ReleaseArchive {
    if ($SkipArchive) {
        Write-BuildWarning "Skipping archive creation"
        return
    }
    
    Write-BuildStep "Creating Release Archive" "Cyan"
    
    $archiveName = "ProfileCore-v$Version-$Configuration.zip"
    $archivePath = Join-Path $script:ArchiveDir $archiveName
    
    # Create archive
    Compress-Archive -Path "$script:ReleaseDir\*" -DestinationPath $archivePath -Force
    
    $archiveSize = [math]::Round((Get-Item $archivePath).Length / 1MB, 2)
    Write-BuildSuccess "Archive created: $archiveName ($archiveSize MB)"
    
    # Generate checksums
    Write-Host "Generating checksums..."
    $checksums = @{
        MD5 = (Get-FileHash $archivePath -Algorithm MD5).Hash
        SHA256 = (Get-FileHash $archivePath -Algorithm SHA256).Hash
    }
    
    $checksumsFile = Join-Path $script:ArchiveDir "ProfileCore-v$Version-checksums.txt"
    @"
ProfileCore v$Version - Checksums
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

File: $archiveName
Size: $archiveSize MB

MD5:    $($checksums.MD5)
SHA256: $($checksums.SHA256)
"@ | Out-File $checksumsFile -Encoding UTF8
    
    Write-BuildSuccess "Checksums generated"
}

function New-ReleaseNotes {
    Write-BuildStep "Generating Release Notes" "Cyan"
    
    $releaseNotes = @"
# ProfileCore v$Version Release Notes

**Release Date:** $(Get-Date -Format 'yyyy-MM-dd')
**Configuration:** $Configuration

## 📦 What's Included

### Core Components
- ✅ PowerShell Module (SOLID Architecture)
- ✅ Zsh Functions (Optimized)
- ✅ Bash Functions (Optimized)
- ✅ Fish Functions (Optimized)

### Features
- ✅ Provider Pattern for Package Managers (8 providers)
- ✅ Configuration Provider Pattern (4 providers)
- ✅ Service Container (Dependency Injection)
- ✅ Command Handler (Middleware Pipeline)
- ✅ OS Abstraction (Factory Pattern)
- ✅ Enhanced Plugin System

### Plugins
- ✅ security-tools - SSH, file verification, VirusTotal, Shodan
- ✅ example-docker-enhanced - Docker management

### Documentation
- ✅ SOLID Architecture Guide
- ✅ Optimization Summary
- ✅ Migration Guide
- ✅ Quick Start Guide
- ✅ Installation Guide

## 🚀 Installation

````powershell
# Extract archive
Expand-Archive ProfileCore-v$Version-$Configuration.zip -DestinationPath C:\ProfileCore

# Run installer
cd C:\ProfileCore
.\scripts\installation\install.ps1

# Reload profile
. `$PROFILE
````

## 📊 Build Information

- **Version:** $Version
- **Configuration:** $Configuration
- **Build Date:** $($script:BuildConfig.Date)
- **Minified:** $($script:BuildConfig.MinifyCode)

## 🔗 Links

- [GitHub Repository](https://github.com/mythic3011/ProfileCore)
- [Documentation](https://github.com/mythic3011/ProfileCore/tree/main/docs)
- [Issues](https://github.com/mythic3011/ProfileCore/issues)

---

**ProfileCore v$Version** - _Professional • Extensible • Cross-Platform • SOLID_
"@
    
    $releaseNotesPath = Join-Path $script:ArchiveDir "RELEASE_NOTES_v$Version.md"
    $releaseNotes | Out-File $releaseNotesPath -Encoding UTF8
    
    Write-BuildSuccess "Release notes generated"
}

# ═════════════════════════════════════════════════════════════════════════════
#  MAIN BUILD PROCESS
# ═════════════════════════════════════════════════════════════════════════════

try {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║" -NoNewline -ForegroundColor Cyan
    Write-Host "         ProfileCore Build System v$Version                " -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    # Execute build steps
    Initialize-Build
    Test-ProfileCore
    Build-PowerShellModule
    Build-ShellFunctions
    Build-Profile
    Build-Plugins
    Build-Documentation
    Build-Scripts
    New-ReleaseArchive
    New-ReleaseNotes
    
    # Calculate build time
    $buildTime = ((Get-Date) - $script:BuildStart).TotalSeconds
    
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║" -NoNewline -ForegroundColor Green
    Write-Host "                  BUILD SUCCESSFUL                           " -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`n📊 Build Summary:" -ForegroundColor Cyan
    Write-Host "  Version:       $Version"
    Write-Host "  Configuration: $Configuration"
    Write-Host "  Build Time:    $([math]::Round($buildTime, 2))s"
    Write-Host "  Output:        $script:ReleaseDir"
    if (-not $SkipArchive) {
        Write-Host "  Archive:       $script:ArchiveDir"
    }
    
    Write-Host "`n🎉 Release ready for distribution!`n" -ForegroundColor Green
    
} catch {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║" -NoNewline -ForegroundColor Red
    Write-Host "                    BUILD FAILED                             " -NoNewline -ForegroundColor White
    Write-Host "║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    
    Write-Host "`n❌ Error: $_`n" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    
    exit 1
}

