# ProfileCore v1.0.0 - Quick Install Script for Windows
# Usage: irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ProfileCore v1.0.0 - Quick Installer (Windows)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if running with admin rights (for system-wide install)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "✓ Running with administrator privileges" -ForegroundColor Green
} else {
    Write-Host "ℹ Running without administrator privileges (user install)" -ForegroundColor Yellow
}
Write-Host ""

# Step 1: Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }
Write-Host "✓ Detected architecture: $arch" -ForegroundColor Green

# Step 2: Download URL
$version = "v1.0.0"
$binaryName = "profilecore.exe"
$downloadUrl = "https://github.com/mythic3011/ProfileCore/releases/download/$version/profilecore-windows-$arch.exe"
Write-Host "✓ Download URL: $downloadUrl" -ForegroundColor Green
Write-Host ""

# Step 3: Determine install location
if ($isAdmin) {
    # System-wide install
    $installDir = "$env:ProgramFiles\ProfileCore"
} else {
    # User install
    $installDir = "$env:LOCALAPPDATA\ProfileCore"
}

# Create install directory
if (!(Test-Path $installDir)) {
    Write-Host "Creating install directory: $installDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

$binaryPath = Join-Path $installDir $binaryName

# Step 4: Download binary
Write-Host "Downloading ProfileCore binary..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $binaryPath -UseBasicParsing
    Write-Host "✓ Download complete" -ForegroundColor Green
} catch {
    Write-Host "✗ Error downloading binary: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please manually download from:" -ForegroundColor Yellow
    Write-Host "  $downloadUrl" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 5: Verify binary
if (!(Test-Path $binaryPath)) {
    Write-Host "✗ Binary not found at: $binaryPath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Binary saved to: $binaryPath" -ForegroundColor Green
Write-Host ""

# Step 6: Add to PATH if not already there
$currentPath = [Environment]::GetEnvironmentVariable("Path", if ($isAdmin) { "Machine" } else { "User" })
if ($currentPath -notlike "*$installDir*") {
    Write-Host "Adding ProfileCore to PATH..." -ForegroundColor Cyan
    $newPath = "$currentPath;$installDir"
    [Environment]::SetEnvironmentVariable("Path", $newPath, if ($isAdmin) { "Machine" } else { "User" })
    $env:Path = "$env:Path;$installDir"
    Write-Host "✓ Added to PATH" -ForegroundColor Green
} else {
    Write-Host "✓ Already in PATH" -ForegroundColor Green
}
Write-Host ""

# Step 7: Run interactive installer
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Starting Interactive Installer..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Refresh PATH for current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Run the installer
try {
    & $binaryPath install
} catch {
    Write-Host "✗ Error running installer: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually run the installer later with:" -ForegroundColor Yellow
    Write-Host "  profilecore install" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  2. Try: profilecore system info" -ForegroundColor White
Write-Host ""

