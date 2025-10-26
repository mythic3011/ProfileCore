#
# build-rust-all.ps1
# Build Rust binary for all supported platforms
#

[CmdletBinding()]
param(
    [string[]]$Targets = @('windows', 'linux', 'macos'),
    [switch]$Release,
    [switch]$SkipTests,
    [switch]$CopyToModule
)

$ErrorActionPreference = 'Stop'

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host   "║  ProfileCore Rust Build - Multi-Platform          ║" -ForegroundColor Cyan
Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Determine project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
$rustProjectPath = Join-Path $projectRoot "modules\ProfileCore-rs"
$binaryModulePath = Join-Path $projectRoot "modules\ProfileCore\rust-binary\bin"

# Ensure Rust project exists
if (-not (Test-Path $rustProjectPath)) {
    throw "Rust project not found at: $rustProjectPath"
}

# Check if Rust is installed
try {
    $cargoVersion = cargo --version
    Write-Host "✅ Rust toolchain found: $cargoVersion" -ForegroundColor Green
} catch {
    throw "Rust toolchain not found. Please install Rust from https://rustup.rs/"
}

# Build configuration
$buildArgs = @()
if ($Release) {
    $buildArgs += '--release'
    $buildDir = 'release'
} else {
    $buildDir = 'debug'
}

Write-Host "`n━━━ Build Configuration ━━━" -ForegroundColor Cyan
Write-Host "  Project:     $rustProjectPath" -ForegroundColor White
Write-Host "  Targets:     $($Targets -join ', ')" -ForegroundColor White
Write-Host "  Config:      $(if ($Release) { 'Release' } else { 'Debug' })" -ForegroundColor White
Write-Host "  Tests:       $(if ($SkipTests) { 'Skipped' } else { 'Enabled' })" -ForegroundColor White
Write-Host ""

# Change to Rust project directory
Push-Location $rustProjectPath

try {
    # Build for each target
    foreach ($target in $Targets) {
        Write-Host "`n━━━ Building for $target ━━━" -ForegroundColor Yellow
        
        switch ($target) {
            'windows' {
                $rustTarget = 'x86_64-pc-windows-msvc'
                $outputFile = "target\$rustTarget\$buildDir\profilecore_rs.dll"
                $moduleFile = Join-Path $binaryModulePath "ProfileCore.dll"
                
                Write-Host "  Target:      $rustTarget" -ForegroundColor Gray
                Write-Host "  Output:      $outputFile" -ForegroundColor Gray
                
                # Check if target is installed
                $installedTargets = rustup target list --installed
                if ($installedTargets -notcontains $rustTarget) {
                    Write-Host "  Installing target: $rustTarget..." -ForegroundColor Yellow
                    rustup target add $rustTarget
                }
                
                # Build
                Write-Host "  Building..." -ForegroundColor Gray
                $buildCommand = @('build') + $buildArgs + @('--target', $rustTarget)
                & cargo $buildCommand
                
                if ($LASTEXITCODE -ne 0) {
                    throw "Build failed for $target"
                }
                
                Write-Host "  ✅ Build successful!" -ForegroundColor Green
                
                # Copy to module if requested
                if ($CopyToModule) {
                    if (Test-Path $outputFile) {
                        Write-Host "  Copying to module: $moduleFile" -ForegroundColor Gray
                        
                        # Ensure directory exists
                        $moduleDir = Split-Path $moduleFile -Parent
                        if (-not (Test-Path $moduleDir)) {
                            New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
                        }
                        
                        # Copy with retry (in case DLL is locked)
                        try {
                            Copy-Item -Path $outputFile -Destination $moduleFile -Force
                            Write-Host "  ✅ Copied to module!" -ForegroundColor Green
                        } catch {
                            Write-Warning "  ⚠️  Failed to copy DLL (may be locked): $_"
                            Write-Warning "  Please close PowerShell and copy manually:"
                            Write-Warning "    Copy-Item '$outputFile' '$moduleFile'"
                        }
                    } else {
                        Write-Warning "  ⚠️  Output file not found: $outputFile"
                    }
                }
            }
            
            'linux' {
                $rustTarget = 'x86_64-unknown-linux-gnu'
                $outputFile = "target/$rustTarget/$buildDir/libprofilecore_rs.so"
                $moduleFile = Join-Path $binaryModulePath "ProfileCore-linux-x64.so"
                
                Write-Host "  Target:      $rustTarget" -ForegroundColor Gray
                Write-Host "  Output:      $outputFile" -ForegroundColor Gray
                
                # Check if target is installed
                $installedTargets = rustup target list --installed
                if ($installedTargets -notcontains $rustTarget) {
                    Write-Host "  Installing target: $rustTarget..." -ForegroundColor Yellow
                    rustup target add $rustTarget
                }
                
                # Build
                Write-Host "  Building..." -ForegroundColor Gray
                Write-Warning "  Note: Linux cross-compilation may require additional setup"
                Write-Warning "  Consider using WSL or Docker for Linux builds"
                
                try {
                    $buildCommand = @('build') + $buildArgs + @('--target', $rustTarget)
                    & cargo $buildCommand
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "  ✅ Build successful!" -ForegroundColor Green
                        
                        # Copy to module if requested
                        if ($CopyToModule -and (Test-Path $outputFile)) {
                            $moduleDir = Split-Path $moduleFile -Parent
                            if (-not (Test-Path $moduleDir)) {
                                New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
                            }
                            Copy-Item -Path $outputFile -Destination $moduleFile -Force
                            Write-Host "  ✅ Copied to module!" -ForegroundColor Green
                        }
                    } else {
                        Write-Warning "  ⚠️  Build failed (cross-compilation may not be configured)"
                    }
                } catch {
                    Write-Warning "  ⚠️  Build failed: $_"
                }
            }
            
            'macos' {
                # Build for both Intel and Apple Silicon
                $macTargets = @(
                    @{ RustTarget = 'x86_64-apple-darwin'; Arch = 'x64' },
                    @{ RustTarget = 'aarch64-apple-darwin'; Arch = 'arm64' }
                )
                
                foreach ($macTarget in $macTargets) {
                    $macRustTarget = $macTarget.RustTarget
                    $macArch = $macTarget.Arch
                    $outputFile = "target/$macRustTarget/$buildDir/libprofilecore_rs.dylib"
                    $moduleFile = Join-Path $binaryModulePath "ProfileCore-macos-$macArch.dylib"
                    
                    Write-Host "`n  Sub-target:  $macRustTarget" -ForegroundColor Gray
                    Write-Host "  Output:      $outputFile" -ForegroundColor Gray
                    
                    # Check if target is installed
                    $installedTargets = rustup target list --installed
                    if ($installedTargets -notcontains $macRustTarget) {
                        Write-Host "  Installing target: $macRustTarget..." -ForegroundColor Yellow
                        rustup target add $macRustTarget
                    }
                    
                    # Build
                    Write-Host "  Building..." -ForegroundColor Gray
                    Write-Warning "  Note: macOS cross-compilation may require macOS or specific setup"
                    
                    try {
                        $buildCommand = @('build') + $buildArgs + @('--target', $macRustTarget)
                        & cargo $buildCommand
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "  ✅ Build successful!" -ForegroundColor Green
                            
                            # Copy to module if requested
                            if ($CopyToModule -and (Test-Path $outputFile)) {
                                $moduleDir = Split-Path $moduleFile -Parent
                                if (-not (Test-Path $moduleDir)) {
                                    New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
                                }
                                Copy-Item -Path $outputFile -Destination $moduleFile -Force
                                Write-Host "  ✅ Copied to module!" -ForegroundColor Green
                            }
                        } else {
                            Write-Warning "  ⚠️  Build failed (cross-compilation may not be configured)"
                        }
                    } catch {
                        Write-Warning "  ⚠️  Build failed: $_"
                    }
                }
            }
            
            default {
                Write-Warning "Unknown target: $target"
            }
        }
    }
    
    # Run tests if not skipped
    if (-not $SkipTests) {
        Write-Host "`n━━━ Running Tests ━━━" -ForegroundColor Yellow
        cargo test $buildConfig
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ All tests passed!" -ForegroundColor Green
        } else {
            Write-Warning "⚠️  Some tests failed"
        }
    }
    
    # Summary
    Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host   "║  Build Complete!                                   ║" -ForegroundColor Green
    Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Green
    
    Write-Host "Build artifacts:" -ForegroundColor Cyan
    Write-Host "  Windows: target\x86_64-pc-windows-msvc\$buildDir\profilecore_rs.dll" -ForegroundColor White
    Write-Host "  Linux:   target/x86_64-unknown-linux-gnu/$buildDir/libprofilecore_rs.so" -ForegroundColor White
    Write-Host "  macOS:   target/x86_64-apple-darwin/$buildDir/libprofilecore_rs.dylib" -ForegroundColor White
    Write-Host "           target/aarch64-apple-darwin/$buildDir/libprofilecore_rs.dylib" -ForegroundColor White
    
    if ($CopyToModule) {
        Write-Host "`nModule binaries:" -ForegroundColor Cyan
        Write-Host "  $binaryModulePath\" -ForegroundColor White
    }
    
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Test the binaries on each platform" -ForegroundColor White
    Write-Host "  2. Run integration tests: Invoke-Pester tests/unit/ProfileCore.Rust.Tests.ps1" -ForegroundColor White
    Write-Host "  3. Verify FFI calls work correctly" -ForegroundColor White
    Write-Host ""
    
} finally {
    Pop-Location
}

