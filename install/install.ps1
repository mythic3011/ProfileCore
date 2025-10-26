<#
.SYNOPSIS
    ProfileCore v5.1.1 Installer - Windows Edition
.DESCRIPTION
    Installs ProfileCore PowerShell module with dependency injection architecture,
    optional Rust binary module for 10x performance improvements, comprehensive
    error handling, and antivirus compatibility support.
.PARAMETER Force
    Force reinstallation even if ProfileCore is already installed
.PARAMETER SkipBackup
    Skip creating backups of existing files
.PARAMETER SkipDependencies
    Skip installing Pester, PSScriptAnalyzer, and Starship
.PARAMETER SkipAntivirusPrompt
    Skip the antivirus exclusion prompt (for automated installations)
.PARAMETER Quiet
    Minimal output mode for automated installations
.PARAMETER Validate
    Validate installation without making changes
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -Force -SkipBackup
.EXAMPLE
    .\install.ps1 -Validate
.EXAMPLE
    .\install.ps1 -SkipAntivirusPrompt -Quiet
.NOTES
    Author: Mythic3011
    Version: 6.1.0
    Features: DI architecture, Rust binary module (optional), antivirus support
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipBackup,
    [switch]$SkipDependencies,
    [switch]$SkipAntivirusPrompt,
    [switch]$Quiet,
    [switch]$Validate
)

# Performance optimization
$global:ProgressPreference = 'SilentlyContinue'
$script:StartTime = Get-Date

# Import ProfileCore.Common module for shared utilities
$commonModulePath = Join-Path $PSScriptRoot "..\..\modules\ProfileCore.Common"
if (Test-Path $commonModulePath) {
    Import-Module $commonModulePath -DisableNameChecking -ErrorAction Stop
} else {
    Write-Error "ProfileCore.Common module not found at: $commonModulePath"
    exit 1
}

# Rollback actions stack
$script:RollbackActions = @()

function Add-RollbackAction {
    param([scriptblock]$Action)
    $script:RollbackActions += $Action
}

function Invoke-Rollback {
    if ($script:RollbackActions.Count -eq 0) { return }
    
    Write-Host "`n[WARN] Installation failed. Rolling back changes..." -ForegroundColor Yellow
    $script:RollbackActions.Reverse()
    foreach ($action in $script:RollbackActions) {
        try {
            & $action
        } catch {
            Write-Warning "Rollback action failed: $_"
        }
    }
    Write-Host "[OK] Rollback complete" -ForegroundColor Green
}

try {
    # Header
    if (-not $Quiet) {
        $mode = if ($Validate) { "Validation Mode" } else { "Installation" }
        Write-BoxHeader "ProfileCore v5.1.1 Installer - Windows" -Subtitle $mode -Color Magenta
    }

    # Get installation directory
    $installRoot = Split-Path (Split-Path $PSScriptRoot)  # Go up two levels from scripts/installation
    $modulesPath = Join-Path (Split-Path $PROFILE) "modules"
    $profilePath = $PROFILE
    $configDir = Join-Path $HOME ".config/shell-profile"
    
    # Detect existing installation
    $existingModule = Get-Module ProfileCore -ListAvailable | Select-Object -First 1
    $isUpgrade = $null -ne $existingModule
    $currentVersion = if ($isUpgrade) { $existingModule.Version.ToString() } else { "None" }
    $newVersion = "5.2.0"
    
    if ($isUpgrade -and -not $Quiet) {
        Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║              UPGRADE DETECTED                            ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "`n  Current Version: " -NoNewline -ForegroundColor White
        Write-Host $currentVersion -ForegroundColor Yellow
        Write-Host "  New Version:     " -NoNewline -ForegroundColor White
        Write-Host $newVersion -ForegroundColor Green
        Write-Host "`n  What's New in v$newVersion`:" -ForegroundColor Cyan
        Write-Host "    • v6 DI Architecture with 5 core services" -ForegroundColor Gray
        Write-Host "    • ProfileCore.Common shared library" -ForegroundColor Gray
        Write-Host "    • Enhanced Rust binary integration" -ForegroundColor Gray
        Write-Host "    • Improved error handling & stability" -ForegroundColor Gray
        Write-Host "    • Faster startup (~180ms load time)" -ForegroundColor Gray
        Write-Host "`n  Your configuration will be preserved ✓`n" -ForegroundColor Green
        
        if (-not $Force) {
            $continue = Read-Host "  Continue with upgrade? (Y/n)"
            if ($continue -eq 'n' -or $continue -eq 'N') {
                Write-Host "`n[INFO] Upgrade cancelled by user" -ForegroundColor Yellow
                exit 0
            }
        }
    }
    
    # Initialize Rust binary flag
    $hasRustBinary = $true  # Default to true, will be updated in antivirus prompt

    # Step 1: Prerequisites check (0-10%)
    Write-Step "Checking Prerequisites" -Quiet:$Quiet
    Write-Progress "Validating system requirements..." -Percent 5 -Quiet:$Quiet
    
    $psVersion = $PSVersionTable.PSVersion
    Write-Info "PowerShell Version: $psVersion" -Quiet:$Quiet
    Write-Info "Profile Path: $profilePath" -Quiet:$Quiet
    Write-Info "Install Root: $installRoot" -Quiet:$Quiet
    
    # Run comprehensive prerequisites check
    if (-not (Test-Prerequisites -ThrowOnError:(-not $Validate))) {
        if ($Validate) {
            Write-Warning "Prerequisites check failed (validation mode)"
        }
    }
    
    Write-Success "Prerequisites validated" -Quiet:$Quiet

    # Validation mode - just check and exit
    if ($Validate) {
        Write-Step "Validation Mode - Checking Installation" -Quiet:$Quiet
        
        $rustBinaryExists = Test-Path (Join-Path $modulesPath "ProfileCore.Binary\bin\ProfileCore.dll")
        
        $validationResults = @{
            "Module manifest exists" = Test-Path (Join-Path $modulesPath "ProfileCore\ProfileCore.psd1")
            "Module file exists" = Test-Path (Join-Path $modulesPath "ProfileCore\ProfileCore.psm1")
            "Profile file exists" = Test-Path $profilePath
            "Config directory exists" = Test-Path $configDir
            "Rust binary (optional)" = $rustBinaryExists
            "Module can be imported" = $false
        }
        
        # Try to import module
        try {
            Import-Module ProfileCore -ErrorAction Stop
            $validationResults["Module can be imported"] = $true
        } catch {
            Write-Warning "Module import failed: $_"
        }
        
        Write-Host "`nValidation Results:" -ForegroundColor Cyan
        foreach ($check in $validationResults.GetEnumerator()) {
            $isOptional = $check.Key -like "*optional*"
            if ($check.Value) {
                $status = "[PASS]"
                $color = "Green"
            } else {
                if ($isOptional) {
                    $status = "[SKIP]"
                    $color = "Yellow"
                } else {
                    $status = "[FAIL]"
                    $color = "Yellow"
                }
            }
            Write-Host "  $status - $($check.Key)" -ForegroundColor $color
        }
        
        # Count only non-optional checks for pass/fail
        $requiredChecks = $validationResults.GetEnumerator() | Where-Object { $_.Key -notlike "*optional*" }
        $passCount = ($requiredChecks | Where-Object { $_.Value }).Count
        $totalCount = $requiredChecks.Count
        
        Write-Host "`nValidation Score: $passCount/$totalCount (required)" -ForegroundColor $(if ($passCount -eq $totalCount) { "Green" } else { "Yellow" })
        if ($rustBinaryExists) {
            Write-Host "Rust Binary: Available" -ForegroundColor Green
        } else {
            Write-Host "Rust Binary: Not available (PowerShell fallback active)" -ForegroundColor Yellow
        }
        
        exit $(if ($passCount -eq $totalCount) { 0 } else { 1 })
    }

    # Check if already installed
    if ((Test-Path $modulesPath\ProfileCore) -and -not $Force) {
        Write-Host "[INFO] ProfileCore is already installed. Use --Force to reinstall." -ForegroundColor Yellow
        exit 0
    }

    # Step 2: Backup existing files (10-20%)
    if (-not $SkipBackup) {
        Write-Step "Creating Backup" -Quiet:$Quiet
        Write-Progress "Backing up existing files..." -Percent 15 -Quiet:$Quiet
        
        if (Test-Path $profilePath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$profilePath.$timestamp.backup"
            Copy-Item $profilePath $backupPath -Force
            Add-RollbackAction { Move-Item $backupPath $profilePath -Force }
            if (-not $Quiet) {
                Write-Host "[OK] Profile backed up to: $(Split-Path $backupPath -Leaf)" -ForegroundColor Green
            }
        }
    }

    # Step 3: Create directories (20-30%)
    Write-Step "Creating Directories" -Quiet:$Quiet
    Write-Progress "Creating directory structure..." -Percent 25 -Quiet:$Quiet

    $directories = @(
        $modulesPath,
        (Join-Path $modulesPath "ProfileCore"),
        (Join-Path $modulesPath "ProfileCore\public"),
        (Join-Path $modulesPath "ProfileCore\private"),
        $configDir
    )

    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Add-RollbackAction { if (Test-Path $dir) { Remove-Item $dir -Recurse -Force } }
        }
    }

    if (-not $Quiet) {
        Write-Host "[OK] Directory structure created" -ForegroundColor Green
    }

    # Step 3.5: Antivirus & Rust Binary Setup (25-30%)
    if (-not $SkipAntivirusPrompt -and -not $Quiet) {
        Write-Step "Rust Binary Module" -Quiet:$Quiet
        Write-Progress "Checking for Rust binary module..." -Percent 27 -Quiet:$Quiet
        
        $rustBinarySource = Join-Path $installRoot "modules\ProfileCore.Binary"
        $hasRustBinary = Test-Path (Join-Path $rustBinarySource "bin\ProfileCore.dll")
        
        if ($hasRustBinary) {
            Write-Host "`n[Rust] ProfileCore v5.1.1 includes an optional Rust binary module:" -ForegroundColor Cyan
            Write-Host "  [+] 10x faster system operations" -ForegroundColor Green
            Write-Host "  [+] Automatic fallback to PowerShell if unavailable" -ForegroundColor White
            Write-Host "  [!] Antivirus software may initially block unsigned DLLs" -ForegroundColor Yellow
            
            Write-Host "`n[WARN] ANTIVIRUS NOTICE:" -ForegroundColor Yellow
            Write-Host "  Some antivirus programs (Windows Defender, ESET, etc.) may block" -ForegroundColor Gray
            Write-Host "  the Rust DLL during or after installation. This is normal for" -ForegroundColor Gray
            Write-Host "  unsigned development binaries." -ForegroundColor Gray
            
            Write-Host "`n[*] SOLUTIONS:" -ForegroundColor Cyan
            Write-Host "  1. Add antivirus exclusion (recommended for development)" -ForegroundColor White
            Write-Host "  2. Use PowerShell fallback (works perfectly, just slower)" -ForegroundColor White
            Write-Host "  3. Wait for signed version (coming in v6.2.0)" -ForegroundColor White
            
            Write-Host "`n[*] For detailed guidance, see:" -ForegroundColor Cyan
            Write-Host "     docs/user-guide/antivirus-and-rust.md" -ForegroundColor White
            Write-Host "     ANTIVIRUS_QUICK_FIX.md (in root directory)" -ForegroundColor White
            
            Write-Host "`n[?] Would you like to:" -ForegroundColor Yellow
            Write-Host "  [Y] Continue with installation (recommended)" -ForegroundColor White
            Write-Host "  [N] Skip Rust binary (PowerShell only)" -ForegroundColor Gray
            Write-Host "  [?] Show antivirus exclusion command" -ForegroundColor Gray
            
            $response = Read-Host "`nYour choice [Y/n/?]"
            
            switch ($response.ToLower()) {
                "n" {
                    Write-Host "`n[OK] Rust binary will be skipped. Using PowerShell fallback." -ForegroundColor Green
                    $hasRustBinary = $false
                }
                "?" {
                    Write-Host "`n[*] TO ADD WINDOWS DEFENDER EXCLUSION:" -ForegroundColor Cyan
                    Write-Host "`nRun this command in PowerShell as Administrator:" -ForegroundColor White
                    Write-Host "`nAdd-MpPreference -ExclusionPath '$HOME\Documents\PowerShell\modules'" -ForegroundColor Yellow
                    Write-Host "`nPress Enter to continue with installation..." -ForegroundColor Gray
                    $null = Read-Host
                }
                default {
                    Write-Host "`n[OK] Continuing with Rust binary installation." -ForegroundColor Green
                    Write-Host "   If antivirus blocks it, ProfileCore will use PowerShell fallback." -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "[INFO] Rust binary not found - using PowerShell implementation (fully functional)" -ForegroundColor Yellow
        }
    }

    # Step 4: Install ProfileCore module (30-50%)
    Write-Step "Installing ProfileCore module" -Quiet:$Quiet
    Write-Progress "Checking module location..." -Percent 35 -Quiet:$Quiet

    $sourceModule = Join-Path $installRoot "modules\ProfileCore"
    $destModule = Join-Path $modulesPath "ProfileCore"

    # Check if installing from same location (in-place)
    $sourceModuleFull = (Resolve-Path $sourceModule).Path
    $destModuleFull = if (Test-Path $destModule) { (Resolve-Path $destModule).Path } else { "" }

    if ($sourceModuleFull -eq $destModuleFull) {
        if (-not $Quiet) {
            Write-Host "[INFO] Installing in-place (ProfileCore already in modules/)" -ForegroundColor Yellow
            Write-Host "[OK] Verifying module files..." -ForegroundColor Green
        }
    } else {
        if (-not $Quiet) {
            Write-Host "[INFO] Copying module files..." -ForegroundColor White
        }
        
        $moduleFiles = Get-ChildItem -Path $sourceModule -Recurse -File
        $totalFiles = $moduleFiles.Count
        $fileCounter = 0

        foreach ($file in $moduleFiles) {
            $relativePath = $file.FullName.Substring($sourceModule.Length)
            $destFile = Join-Path $destModule $relativePath
            $destFileDir = Split-Path $destFile -Parent
            
            if (-not (Test-Path $destFileDir)) {
                New-Item -Path $destFileDir -ItemType Directory -Force | Out-Null
            }
            
            Copy-Item $file.FullName $destFile -Force
            $fileCounter++
            
            # Progress every 5 files
            if ($fileCounter % 5 -eq 0 -or $fileCounter -eq $totalFiles) {
                $percent = 35 + [math]::Floor(($fileCounter / $totalFiles) * 15)
                Write-Progress "Copying module files ($fileCounter/$totalFiles)..." $percent
            }
        }

        if (-not $Quiet) {
            Write-Host "[OK] Module installation complete ($totalFiles files)" -ForegroundColor Green
        }
    }

    # Step 4.5: Install Rust Binary Module (50-55%)
    if ($hasRustBinary) {
        Write-Step "Installing Rust Binary Module" -Quiet:$Quiet
        Write-Progress "Deploying ProfileCore.Binary..." -Percent 52 -Quiet:$Quiet
        
        $rustBinarySource = Join-Path $installRoot "modules\ProfileCore.Binary"
        $rustBinaryDest = Join-Path $modulesPath "ProfileCore.Binary"
        
        if (Test-Path $rustBinarySource) {
            try {
                # Create destination directory
                if (-not (Test-Path $rustBinaryDest)) {
                    New-Item -Path $rustBinaryDest -ItemType Directory -Force | Out-Null
                }
                
                # Copy binary module files
                $rustFiles = Get-ChildItem -Path $rustBinarySource -Recurse -File
                foreach ($file in $rustFiles) {
                    $relativePath = $file.FullName.Substring($rustBinarySource.Length)
                    $destFile = Join-Path $rustBinaryDest $relativePath
                    $destFileDir = Split-Path $destFile -Parent
                    
                    if (-not (Test-Path $destFileDir)) {
                        New-Item -Path $destFileDir -ItemType Directory -Force | Out-Null
                    }
                    
                    Copy-Item $file.FullName $destFile -Force
                }
                
                # Verify DLL was copied successfully
                $dllPath = Join-Path $rustBinaryDest "bin\ProfileCore.dll"
                if (Test-Path $dllPath) {
                    $dllSize = (Get-Item $dllPath).Length / 1KB
                    if (-not $Quiet) {
                        Write-Host "  [OK] Rust binary deployed: $([math]::Round($dllSize, 0)) KB" -ForegroundColor Green
                    }
                } else {
                    Write-Warning "Rust DLL not found after copy - antivirus may have blocked it"
                    Write-Warning "ProfileCore will use PowerShell fallback (fully functional)"
                }
                
                if (-not $Quiet) {
                    Write-Host "[OK] Rust binary module installed" -ForegroundColor Green
                }
            } catch {
                Write-Warning "Failed to install Rust binary: $_"
                Write-Host "  [INFO] ProfileCore will use PowerShell fallback instead" -ForegroundColor Yellow
            }
        }
    }

    # Step 5: Setup configuration (50-60%)
    Write-Step "Configuring ProfileCore" -Quiet:$Quiet
    Write-Progress "Creating configuration files..." -Percent 55 -Quiet:$Quiet

    $configFile = Join-Path $configDir "config.json"
    if (-not (Test-Path $configFile)) {
        $config = @{
            version = "6.1.0"
            theme = "default"
            features = @{
                starship = $true
                psreadline = $true
                performance = $true
                rust_binary = $true
            }
        } | ConvertTo-Json -Depth 4
        
        $config | Out-File $configFile -Encoding UTF8
    }

    # Step 6: Setup .env file (60-65%)
    Write-Progress "Creating environment file..." -Percent 62 -Quiet:$Quiet

    $envFile = Join-Path $configDir ".env"
    if (-not (Test-Path $envFile)) {
        @"
# ProfileCore Environment Variables
# Add your API keys and secrets here

# Example:
# GITHUB_TOKEN=your_token_here
# OPENAI_API_KEY=your_key_here
"@ | Out-File $envFile -Encoding UTF8
    }

    if (-not $Quiet) {
        Write-Host "[OK] Configuration files created" -ForegroundColor Green
    }

    # Step 7: Install/Update profile (65-75%)
    Write-Step "Installing Profile" -Quiet:$Quiet
    Write-Progress "Updating PowerShell profile..." -Percent 70 -Quiet:$Quiet

    $sourceProfile = Join-Path $installRoot "Microsoft.PowerShell_profile.ps1"
    
    # Check if installing from same location
    $sourceProfileFull = if (Test-Path $sourceProfile) { (Resolve-Path $sourceProfile).Path } else { "" }
    $destProfileFull = if (Test-Path $profilePath) { (Resolve-Path $profilePath).Path } else { "" }

    if ($sourceProfileFull -eq $destProfileFull) {
        if (-not $Quiet) {
            Write-Host "[INFO] Profile already in correct location" -ForegroundColor Yellow
            Write-Host "[OK] Verifying profile file..." -ForegroundColor Green
        }
    } else {
        if (Test-Path $sourceProfile) {
            Copy-Item $sourceProfile $profilePath -Force
            if (-not $Quiet) {
                Write-Host "[OK] Profile installed" -ForegroundColor Green
            }
        } else {
            Write-Warning "Source profile not found. Skipping profile installation."
        }
    }

    # Step 8: Install dependencies (75-90%)
    if (-not $SkipDependencies) {
        Write-Step "Installing Dependencies" -Quiet:$Quiet
        Write-Progress "Installing PowerShell modules..." -Percent 77 -Quiet:$Quiet

        # Define required modules
        $requiredModules = @(
            @{ Name = "Pester"; MinVersion = "5.0.0"; Description = "Testing framework" }
            @{ Name = "PSScriptAnalyzer"; MinVersion = "1.20.0"; Description = "Code analyzer" }
        )
        
        $installedModules = @()
        $failedModules = @()
        
        foreach ($module in $requiredModules) {
            $moduleName = $module.Name
            $existing = Get-Module -ListAvailable -Name $moduleName | 
                Where-Object { $_.Version -ge [version]$module.MinVersion } |
                Select-Object -First 1
            
            if ($existing) {
                if (-not $Quiet) {
                    Write-Host "  [OK] $moduleName v$($existing.Version) already installed" -ForegroundColor Green
                }
                continue
            }
            
                if (-not $Quiet) {
                    Write-Host "  [*] Installing $moduleName ($($module.Description))..." -ForegroundColor Cyan
                }
            
            try {
                Invoke-WithRetry -Operation "$moduleName installation" -ScriptBlock {
                    Install-Module -Name $moduleName -MinimumVersion $module.MinVersion `
                        -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction Stop `
                        -Repository PSGallery -AllowClobber
                } -MaxAttempts 3 -DelaySeconds 3
                
                $installedModules += $moduleName
                if (-not $Quiet) {
                    Write-Host "  [OK] $moduleName installed successfully" -ForegroundColor Green
                }
            } catch {
                $failedModules += $moduleName
                if (-not $Quiet) {
                    Write-Host "  [WARN] Failed to install $moduleName`: $_" -ForegroundColor Yellow
                }
            }
        }

        Write-Progress "Checking optional dependencies..." -Percent 85 -Quiet:$Quiet
        
        # Check Starship (optional)
        $hasStarship = Get-Command starship -ErrorAction SilentlyContinue
        if (-not $Quiet) {
            if ($hasStarship) {
                $starshipVersion = (starship --version) -replace 'starship ',''
                Write-Host "  [OK] Starship $starshipVersion found" -ForegroundColor Green
            } else {
                Write-Host "  [INFO] Starship not found (optional prompt)" -ForegroundColor Yellow
                Write-Host "     Install with: scoop install starship" -ForegroundColor Gray
                Write-Host "     Or: winget install Starship.Starship" -ForegroundColor Gray
            }
        }
        
        # Check Windows Terminal (optional)
        if ($PSVersionTable.Platform -eq 'Win32NT' -or -not $PSVersionTable.Platform) {
            $hasWT = Get-Command wt -ErrorAction SilentlyContinue
            if (-not $Quiet) {
                if ($hasWT) {
                    Write-Host "  [OK] Windows Terminal found" -ForegroundColor Green
                } else {
                    Write-Host "  [INFO] Windows Terminal not found (recommended)" -ForegroundColor Yellow
                    Write-Host "     Install with: winget install Microsoft.WindowsTerminal" -ForegroundColor Gray
                }
            }
        }
        
        Write-Progress "Dependencies complete" -Percent 88 -Quiet:$Quiet

        if (-not $Quiet) {
            Write-Host "`n[*] Dependency Summary:" -ForegroundColor Cyan
            Write-Host "  Installed: $($installedModules.Count) modules" -ForegroundColor Green
            if ($failedModules.Count -gt 0) {
                Write-Host "  Failed: $($failedModules.Count) modules ($($failedModules -join ', '))" -ForegroundColor Yellow
            }
        }
    }

    # Step 9: Verify installation (90-100%)
    Write-Step "Verifying Installation" -Quiet:$Quiet
    Write-Progress "Running validation checks..." -Percent 92 -Quiet:$Quiet

    $verifyChecks = @{
        "ProfileCore module manifest" = Test-Path (Join-Path $modulesPath "ProfileCore\ProfileCore.psd1")
        "ProfileCore module file" = Test-Path (Join-Path $modulesPath "ProfileCore\ProfileCore.psm1")
        "public functions" = (Get-ChildItem (Join-Path $modulesPath "ProfileCore\public") -Filter "*.ps1" -ErrorAction SilentlyContinue).Count -ge 15
        "private functions" = (Test-Path (Join-Path $modulesPath "ProfileCore\private"))
        "Rust binary (optional)" = Test-Path (Join-Path $modulesPath "ProfileCore.Binary\bin\ProfileCore.dll")
        "Profile file" = Test-Path $profilePath
        "Config directory" = Test-Path $configDir
        "Config file" = Test-Path (Join-Path $configDir "config.json")
        ".env file" = Test-Path (Join-Path $configDir ".env")
    }

    $failedChecks = @()
    $passedChecks = @()
    $optionalChecks = @("Rust binary (optional)")
    
    foreach ($check in $verifyChecks.GetEnumerator()) {
        $isOptional = $optionalChecks -contains $check.Key
        
        if ($check.Value) {
            $passedChecks += $check.Key
            if (-not $Quiet) {
                Write-Host "  [OK] $($check.Key)" -ForegroundColor Green
            }
        } else {
            if ($isOptional) {
                if (-not $Quiet) {
                    Write-Host "  [WARN] $($check.Key) - not available (using fallback)" -ForegroundColor Yellow
                }
            } else {
                $failedChecks += $check.Key
                if (-not $Quiet) {
                    Write-Host "  [ERROR] $($check.Key)" -ForegroundColor Red
                }
            }
        }
    }

    if ($failedChecks.Count -gt 0) {
        throw "Verification failed for: $($failedChecks -join ', ')"
    }

    Write-Progress "Testing module import..." -Percent 95 -Quiet:$Quiet
    
    # Try importing the module
    try {
        Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
        Import-Module ProfileCore -Force -ErrorAction Stop
        
        # Get exported functions count
        $exportedFunctions = (Get-Command -Module ProfileCore).Count
        
        if (-not $Quiet) {
            Write-Host "  [OK] ProfileCore module loads successfully" -ForegroundColor Green
            Write-Host "  [OK] $exportedFunctions functions exported" -ForegroundColor Green
        }
        
        # Quick sanity test of core functions
        $coreFunctions = @('Get-OperatingSystem', 'Get-SystemInfo')
        foreach ($func in $coreFunctions) {
            if (Get-Command $func -ErrorAction SilentlyContinue) {
                if (-not $Quiet) {
                    Write-Host "  [OK] Core function '$func' available" -ForegroundColor Green
                }
            } else {
                Write-Warning "Core function '$func' not found"
            }
        }
        
    } catch {
        Write-Warning "Module import verification failed: $_"
        Write-Warning "You may need to restart your PowerShell session"
    }

    Write-Progress "Running health check..." -Percent 98 -Quiet:$Quiet
    
    # Health check
    $rustBinaryAvailable = Test-Path (Join-Path $modulesPath "ProfileCore.Binary\bin\ProfileCore.dll")
    $healthCheck = @{
        "PSVersion" = $PSVersionTable.PSVersion.ToString()
        "ProfileCoreVersion" = "6.1.0"
        "ProfileCoreLocation" = $modulesPath
        "FunctionsCount" = $exportedFunctions
        "RustBinary" = if ($rustBinaryAvailable) { "Available (10x faster)" } else { "Not available (PowerShell fallback)" }
        "ConfigExists" = Test-Path (Join-Path $configDir "config.json")
        "EnvFileExists" = Test-Path (Join-Path $configDir ".env")
    }
    
    if (-not $Quiet) {
        Write-Host "`n[*] Health Check:" -ForegroundColor Cyan
        foreach ($item in $healthCheck.GetEnumerator()) {
            $color = if ($item.Key -eq "RustBinary" -and -not $rustBinaryAvailable) { "Yellow" } else { "White" }
            Write-Host "  $($item.Key): $($item.Value)" -ForegroundColor $color
        }
    }

    Write-Progress "Validation complete" -Percent 100 -Quiet:$Quiet

    # Success message
    $installTime = ((Get-Date) - $script:StartTime).TotalSeconds
    
    # Check if Rust binary is available
    $rustAvailable = Test-Path (Join-Path $modulesPath "ProfileCore.Binary\bin\ProfileCore.dll")
    
    if (-not $Quiet) {
        Write-Host "`n================================================================" -ForegroundColor Green
        Write-Host "        Installation Complete Successfully!              " -ForegroundColor Green
        Write-Host "================================================================`n" -ForegroundColor Green
        
        Write-Success "ProfileCore v5.1.1 installed in $([math]::Round($installTime, 1))s!" -Quiet:$Quiet
        
        Write-Host "`n[*] Performance:" -ForegroundColor Yellow
        if ($rustAvailable) {
            Write-Host "  [Rust] Binary Available - 10x faster system operations" -ForegroundColor Green
        } else {
            Write-Host "  [PS] Rust binary not available (using PowerShell fallback)" -ForegroundColor Yellow
            Write-Host "       See docs/user-guide/antivirus-and-rust.md for details" -ForegroundColor Gray
        }
        Write-Host "  [DI] Fast service resolution" -ForegroundColor Green
        Write-Host "  [Lazy] Commands register on-demand" -ForegroundColor Green
        
        Write-Host "`n[*] Installation Summary:" -ForegroundColor Cyan
        Write-Host "  [OK] Module installed: $modulesPath\ProfileCore" -ForegroundColor Green
        Write-Host "  [OK] Functions exported: $exportedFunctions" -ForegroundColor Green
        Write-Host "  [OK] Profile updated: $profilePath" -ForegroundColor Green
        Write-Host "  [OK] Config directory: $configDir" -ForegroundColor Green
        
        Write-Host "`n[*] What's New in v6.1.0:" -ForegroundColor Cyan
        Write-Host "  - Rust Binary Module: Optional 10x performance boost" -ForegroundColor White
        Write-Host "  - Dependency Injection: Modern service architecture" -ForegroundColor White
        Write-Host "  - Automatic Fallback: Works perfectly with or without Rust" -ForegroundColor White
        Write-Host "  - Security Tools: Port scanning, SSL/TLS validation, DNS diagnostics" -ForegroundColor White
        Write-Host "  - Developer Tools: Git automation, Docker management, project scaffolding" -ForegroundColor White
        Write-Host "  - System Admin: Process monitoring, network diagnostics, disk management" -ForegroundColor White
        
        Write-Host "`n[*] Quick Start:" -ForegroundColor Yellow
        Write-Host "  1. Reload your profile:" -ForegroundColor White
        Write-Host "     . `$PROFILE" -ForegroundColor Cyan
        Write-Host "     # or restart your PowerShell session" -ForegroundColor Gray
        
        Write-Host "`n  2. Try some commands:" -ForegroundColor White
        Write-Host "     Get-SystemInfo               # System information dashboard" -ForegroundColor Cyan
        Write-Host "     Test-ProfileCoreRustAvailable # Check Rust status" -ForegroundColor Cyan
        Write-Host "     myip                         # Get your public IP" -ForegroundColor Cyan
        Write-Host "     scan-port 1-100              # Scan ports 1-100" -ForegroundColor Cyan
        
        Write-Host "`n  3. Explore features:" -ForegroundColor White
        Write-Host "     Get-Command -Module ProfileCore  # All commands" -ForegroundColor Cyan
        Write-Host "     Get-Helper                       # Interactive help" -ForegroundColor Cyan
        
        Write-Host "`n  4. Future updates:" -ForegroundColor White
        Write-Host "     Update-ProfileCore               # Quick reinstall from GitHub" -ForegroundColor Cyan
        Write-Host "     update-profile                   # Alias for quick update" -ForegroundColor Cyan
        Write-Host "     Update-ProfileCore -Force        # Force reinstall" -ForegroundColor Cyan
        
        Write-Host "`n  5. (Optional) Configure:" -ForegroundColor White
        Write-Host "     notepad `"$(Join-Path $configDir ".env")`"" -ForegroundColor Cyan
        Write-Host "     Initialize-ProfileCoreConfig" -ForegroundColor Cyan
        
        Write-Host "`n[*] Useful Commands:" -ForegroundColor Yellow
        Write-Host "  Validate:    .\scripts\installation\install.ps1 -Validate" -ForegroundColor Gray
        Write-Host "  Optimize:    Optimize-ProfileCore" -ForegroundColor Gray
        Write-Host "  Performance: Measure-ProfilePerformance" -ForegroundColor Gray
        Write-Host "  Update:      git pull && .\scripts\installation\install.ps1" -ForegroundColor Gray
        
        Write-Host "`n[*] Documentation:" -ForegroundColor Cyan
        Write-Host "  README:      https://github.com/mythic3011/ProfileCore" -ForegroundColor White
        Write-Host "  Local docs:  $(Join-Path $installRoot "README.md")" -ForegroundColor Gray
        if (-not $rustAvailable) {
            Write-Host "  Rust Guide:  $(Join-Path $installRoot "docs\user-guide\antivirus-and-rust.md")" -ForegroundColor Yellow
        }
        
        Write-Host "`nHappy scripting!`n" -ForegroundColor Green
    } else {
        $rustStatus = if ($rustAvailable) { "with Rust" } else { "PowerShell only" }
        Write-Success "ProfileCore v5.1.1 installed in $([math]::Round($installTime, 1))s - $exportedFunctions functions ($rustStatus)" -Quiet:$Quiet
    }

} catch {
    Invoke-Rollback
    Write-Host "`n[ERROR] Installation failed: $_" -ForegroundColor Red
    if ($_.ScriptStackTrace) {
        Write-Host "`nStack trace:" -ForegroundColor Gray
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    exit 1
} finally {
    $global:ProgressPreference = 'Continue'
}

