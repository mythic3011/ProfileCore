#
# install.ps1
# Cross-shell Starship installer for ProfileCore
#

[CmdletBinding()]
param(
    [switch]$InstallStarship,
    [ValidateSet('PowerShell', 'Bash', 'Zsh', 'Fish', 'All')]
    [string]$Shell = 'PowerShell',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host   "║  ProfileCore Starship Installer                    ║" -ForegroundColor Cyan
Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ===========================================================================
# 1. Check/Install Starship
# ===========================================================================

$hasStarship = $null -ne (Get-Command starship -ErrorAction SilentlyContinue)

if (-not $hasStarship) {
    if ($InstallStarship) {
        Write-Host "📦 Installing Starship..." -ForegroundColor Yellow
        
        try {
            if ($IsWindows) {
                Write-Host "   Using winget..." -ForegroundColor Gray
                winget install --id Starship.Starship --silent --accept-package-agreements --accept-source-agreements
            } elseif ($IsMacOS) {
                Write-Host "   Using Homebrew..." -ForegroundColor Gray
                brew install starship
            } elseif ($IsLinux) {
                Write-Host "   Using install script..." -ForegroundColor Gray
                curl -sS https://starship.rs/install.sh | sh
            }
            
            $hasStarship = $null -ne (Get-Command starship -ErrorAction SilentlyContinue)
            
            if ($hasStarship) {
                Write-Host "   ✅ Starship installed successfully!" -ForegroundColor Green
            } else {
                throw "Starship installation completed but command not found"
            }
        } catch {
            Write-Error "Failed to install Starship: $_"
            Write-Host "`nManual installation:" -ForegroundColor Yellow
            Write-Host "  Visit: https://starship.rs/guide/#🚀-installation" -ForegroundColor White
            exit 1
        }
    } else {
        Write-Host "⚠️  Starship not installed" -ForegroundColor Yellow
        Write-Host "   Run with -InstallStarship to install automatically" -ForegroundColor Gray
        Write-Host "   Or visit: https://starship.rs/guide/#🚀-installation`n" -ForegroundColor Gray
        exit 1
    }
} else {
    $version = & starship --version
    Write-Host "✅ Starship installed: $version" -ForegroundColor Green
}

# ===========================================================================
# 2. Copy Unified Config
# ===========================================================================

Write-Host "`n📝 Setting up configuration..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceConfig = Join-Path $scriptDir "starship.toml"
$configDir = Join-Path $HOME ".profilecore"
$destConfig = Join-Path $configDir "starship.toml"

# Ensure config directory exists
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "   Created config directory: $configDir" -ForegroundColor Gray
}

# Copy config
if ((Test-Path $destConfig) -and -not $Force) {
    Write-Host "   ⚠️  Config already exists: $destConfig" -ForegroundColor Yellow
    Write-Host "   Use -Force to overwrite" -ForegroundColor Gray
} else {
    Copy-Item $sourceConfig $destConfig -Force
    Write-Host "   ✅ Copied unified config to: $destConfig" -ForegroundColor Green
}

# ===========================================================================
# 3. Configure Shells
# ===========================================================================

Write-Host "`n🐚 Configuring shells..." -ForegroundColor Yellow

$shellsToConfig = if ($Shell -eq 'All') {
    @('PowerShell', 'Bash', 'Zsh', 'Fish')
} else {
    @($Shell)
}

foreach ($targetShell in $shellsToConfig) {
    Write-Host "`n   $targetShell" -ForegroundColor Cyan
    
    switch ($targetShell) {
        'PowerShell' {
            $profilePath = $PROFILE
            
            if (-not (Test-Path $profilePath)) {
                New-Item -Path $profilePath -ItemType File -Force | Out-Null
                Write-Host "      Created profile: $profilePath" -ForegroundColor Gray
            }
            
            $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
            $starshipBlock = @"

# Starship prompt (ProfileCore)
`$env:STARSHIP_CONFIG = '$destConfig'
Invoke-Expression (& starship init powershell)
"@
            
            if ($profileContent -notmatch 'Starship prompt \(ProfileCore\)') {
                Add-Content -Path $profilePath -Value $starshipBlock
                Write-Host "      ✅ Added Starship to profile" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Starship already configured" -ForegroundColor Yellow
            }
        }
        
        'Bash' {
            $bashrc = Join-Path $HOME ".bashrc"
            
            if (-not (Test-Path $bashrc)) {
                New-Item -Path $bashrc -ItemType File -Force | Out-Null
                Write-Host "      Created .bashrc" -ForegroundColor Gray
            }
            
            $bashrcContent = Get-Content $bashrc -Raw -ErrorAction SilentlyContinue
            $starshipBlock = @"

# Starship prompt (ProfileCore)
export STARSHIP_CONFIG="$destConfig"
eval "`$(starship init bash)"
"@
            
            if ($bashrcContent -notmatch 'Starship prompt \(ProfileCore\)') {
                Add-Content -Path $bashrc -Value $starshipBlock
                Write-Host "      ✅ Added Starship to .bashrc" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Starship already configured" -ForegroundColor Yellow
            }
        }
        
        'Zsh' {
            $zshrc = Join-Path $HOME ".zshrc"
            
            if (-not (Test-Path $zshrc)) {
                New-Item -Path $zshrc -ItemType File -Force | Out-Null
                Write-Host "      Created .zshrc" -ForegroundColor Gray
            }
            
            $zshrcContent = Get-Content $zshrc -Raw -ErrorAction SilentlyContinue
            $starshipBlock = @"

# Starship prompt (ProfileCore)
export STARSHIP_CONFIG="$destConfig"
eval "`$(starship init zsh)"
"@
            
            if ($zshrcContent -notmatch 'Starship prompt \(ProfileCore\)') {
                Add-Content -Path $zshrc -Value $starshipBlock
                Write-Host "      ✅ Added Starship to .zshrc" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Starship already configured" -ForegroundColor Yellow
            }
        }
        
        'Fish' {
            $fishConfig = Join-Path $HOME ".config/fish/config.fish"
            $fishDir = Split-Path $fishConfig -Parent
            
            if (-not (Test-Path $fishDir)) {
                New-Item -ItemType Directory -Path $fishDir -Force | Out-Null
                Write-Host "      Created fish config directory" -ForegroundColor Gray
            }
            
            if (-not (Test-Path $fishConfig)) {
                New-Item -Path $fishConfig -ItemType File -Force | Out-Null
                Write-Host "      Created config.fish" -ForegroundColor Gray
            }
            
            $fishConfigContent = Get-Content $fishConfig -Raw -ErrorAction SilentlyContinue
            $starshipBlock = @"

# Starship prompt (ProfileCore)
set -gx STARSHIP_CONFIG "$destConfig"
starship init fish | source
"@
            
            if ($fishConfigContent -notmatch 'Starship prompt \(ProfileCore\)') {
                Add-Content -Path $fishConfig -Value $starshipBlock
                Write-Host "      ✅ Added Starship to config.fish" -ForegroundColor Green
            } else {
                Write-Host "      ⚠️  Starship already configured" -ForegroundColor Yellow
            }
        }
    }
}

# ===========================================================================
# 4. Summary
# ===========================================================================

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host   "║  Installation Complete!                            ║" -ForegroundColor Green
Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Starship Configuration:" -ForegroundColor Cyan
Write-Host "  Config file:  $destConfig" -ForegroundColor White
Write-Host "  Configured:   $($shellsToConfig -join ', ')" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your shell(s) to see the new prompt" -ForegroundColor White
Write-Host "  2. Customize: Edit $destConfig" -ForegroundColor White
Write-Host "  3. Learn more: https://starship.rs/config/" -ForegroundColor White

if ('PowerShell' -in $shellsToConfig) {
    Write-Host "`nPowerShell Commands:" -ForegroundColor Cyan
    Write-Host "  Get-StarshipStatus         - View plugin status" -ForegroundColor White
    Write-Host "  Update-StarshipConfig      - Apply themes" -ForegroundColor White
    Write-Host "  Disable-StarshipPrompt     - Disable (restore default)" -ForegroundColor White
}

Write-Host ""

