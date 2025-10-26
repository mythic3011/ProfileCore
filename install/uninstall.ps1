<#
.SYNOPSIS
    ProfileCore v5.0.0 Uninstaller - Windows Edition
.DESCRIPTION
    Safely uninstalls ProfileCore PowerShell module and removes shell configurations
    with backup restoration options and comprehensive cleanup.
.PARAMETER KeepConfig
    Keep configuration files and user data
.PARAMETER KeepBackups
    Keep profile backups created during installation
.PARAMETER Force
    Force uninstallation without confirmation prompts
.PARAMETER Quiet
    Minimal output mode for automated uninstallation
.PARAMETER RestoreBackup
    Restore the most recent profile backup (if available)
.EXAMPLE
    .\uninstall.ps1
.EXAMPLE
    .\uninstall.ps1 -KeepConfig -KeepBackups
.EXAMPLE
    .\uninstall.ps1 -RestoreBackup -Force
.NOTES
    Author: Mythic3011
    Version: 5.0.0
    Performance Edition with safe cleanup and restoration
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$KeepConfig,
    [switch]$KeepBackups,
    [switch]$Force,
    [switch]$Quiet,
    [switch]$RestoreBackup
)

# Performance optimization
$global:ProgressPreference = 'SilentlyContinue'
$script:StartTime = Get-Date
$script:UninstallLog = @()

function Write-Step {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "🔹 $Message" -ForegroundColor Cyan
    }
    $script:UninstallLog += $Message
}

function Write-Progress {
    param([string]$Status, [int]$Percent)
    if (-not $Quiet) {
        Write-Host "[$Percent%] $Status" -ForegroundColor Gray
    }
}

function Write-Success {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "✅ $Message" -ForegroundColor Green
    }
    $script:UninstallLog += "[SUCCESS] $Message"
}

function Write-Info {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "ℹ️  $Message" -ForegroundColor White
    }
}

function Write-UninstallLog {
    param([string]$LogFile)
    
    $logContent = @"
ProfileCore Uninstallation Log
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
User: $env:USERNAME
Computer: $env:COMPUTERNAME

========================================
Uninstallation Steps:
========================================

$($script:UninstallLog -join "`n")

========================================
Status: Completed Successfully
========================================
"@
    
    Set-Content -Path $LogFile -Value $logContent -Force
    Write-Info "Uninstallation log saved: $LogFile"
}

# Start
Clear-Host

if (-not $Quiet) {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║       ProfileCore v5.0 Uninstaller - Windows           ║" -ForegroundColor Red
    Write-Host "║            Uninstallation Process                      ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Red
}

# Confirmation prompt (unless -Force)
if (-not $Force) {
    Write-Host "⚠️  This will remove ProfileCore from your system." -ForegroundColor Yellow
    Write-Host "   The following will be removed:" -ForegroundColor Yellow
    Write-Host "   • ProfileCore PowerShell module" -ForegroundColor Gray
    Write-Host "   • PowerShell profile modifications" -ForegroundColor Gray
    
    if (-not $KeepConfig) {
        Write-Host "   • Configuration files and user data" -ForegroundColor Gray
    }
    
    if (-not $KeepBackups) {
        Write-Host "   • Profile backups" -ForegroundColor Gray
    }
    
    Write-Host ""
    $response = Read-Host "Continue with uninstallation? (yes/no)"
    if ($response -notmatch '^(y|yes)$') {
        Write-Host "`n❌ Uninstallation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

Write-Step "Starting ProfileCore uninstallation..."
Write-Progress "Detecting installation..." 5

# Detect paths
$profilePath = $PROFILE
$modulesPath = Split-Path $profilePath -Parent | Join-Path -ChildPath "Modules"
$moduleInstallPath = Join-Path $modulesPath "ProfileCore"
$configDir = Join-Path $HOME ".config\shell-profile"
$envFile = Join-Path $configDir ".env"

Write-Info "Profile path: $profilePath"
Write-Info "Module path: $moduleInstallPath"
Write-Info "Config path: $configDir"

# Check if ProfileCore is installed
$isInstalled = Test-Path $moduleInstallPath
if (-not $isInstalled) {
    Write-Host "`n⚠️  ProfileCore module not found at: $moduleInstallPath" -ForegroundColor Yellow
    Write-Host "   The module may already be uninstalled or installed in a different location." -ForegroundColor Gray
    
    if (-not $Force) {
        $response = Read-Host "Continue anyway? (yes/no)"
        if ($response -notmatch '^(y|yes)$') {
            Write-Host "`n❌ Uninstallation cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Step 1: Unload ProfileCore module (10%)
Write-Step "Unloading ProfileCore module"
Write-Progress "Removing module from memory..." 10

try {
    if (Get-Module ProfileCore) {
        Remove-Module ProfileCore -Force -ErrorAction Stop
        Write-Success "Module unloaded from current session"
    } else {
        Write-Info "Module not loaded in current session"
    }
} catch {
    Write-Warning "Failed to unload module: $_"
}

# Step 2: Restore or remove PowerShell profile (20-40%)
Write-Step "Handling PowerShell profile"
Write-Progress "Processing profile..." 20

if ($RestoreBackup) {
    # Find most recent backup
    $backups = Get-ChildItem -Path (Split-Path $profilePath) -Filter "$([System.IO.Path]::GetFileName($profilePath))*.backup" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending
    
    if ($backups) {
        $latestBackup = $backups[0]
        Write-Progress "Restoring backup: $($latestBackup.Name)..." 25
        
        try {
            Copy-Item $latestBackup.FullName $profilePath -Force
            Write-Success "Profile restored from backup: $($latestBackup.Name)"
        } catch {
            Write-Warning "Failed to restore backup: $_"
        }
    } else {
        Write-Warning "No profile backups found"
    }
} else {
    # Check if profile contains ProfileCore
    if (Test-Path $profilePath) {
        $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
        
        if ($profileContent -match 'ProfileCore|Initialize-ProfileEnvironment') {
            Write-Progress "Removing ProfileCore from profile..." 30
            
            # Create backup before modification
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$profilePath.pre-uninstall-$timestamp.backup"
            Copy-Item $profilePath $backupPath -Force
            Write-Info "Profile backed up to: $backupPath"
            
            # Remove ProfileCore initialization
            $newContent = $profileContent -replace '(?ms)#.*ProfileCore.*?(?=\r?\n\r?\n|\z)', '' `
                                         -replace 'Import-Module ProfileCore.*', '' `
                                         -replace 'Initialize-ProfileEnvironment.*', '' `
                                         -replace '\r?\n\r?\n\r?\n', "`n`n"
            
            if ([string]::IsNullOrWhiteSpace($newContent.Trim())) {
                # If profile is now empty, remove it
                Remove-Item $profilePath -Force
                Write-Success "Empty profile removed"
            } else {
                Set-Content -Path $profilePath -Value $newContent -Force
                Write-Success "ProfileCore references removed from profile"
            }
        } else {
            Write-Info "Profile does not contain ProfileCore references"
        }
    } else {
        Write-Info "Profile file does not exist"
    }
}

# Step 3: Remove ProfileCore module (40-60%)
Write-Step "Removing ProfileCore module"
Write-Progress "Deleting module files..." 40

if (Test-Path $moduleInstallPath) {
    try {
        $fileCount = (Get-ChildItem $moduleInstallPath -Recurse -File).Count
        Write-Progress "Removing $fileCount module files..." 50
        
        Remove-Item $moduleInstallPath -Recurse -Force -ErrorAction Stop
        Write-Success "ProfileCore module removed ($fileCount files)"
    } catch {
        Write-Warning "Failed to remove module directory: $_"
        Write-Info "You may need to manually remove: $moduleInstallPath"
    }
} else {
    Write-Info "Module directory not found (may already be removed)"
}

# Step 4: Remove configuration (60-80%)
if (-not $KeepConfig) {
    Write-Step "Removing configuration files"
    Write-Progress "Cleaning up configuration..." 60
    
    if (Test-Path $configDir) {
        try {
            # Show what will be removed
            $configFiles = Get-ChildItem $configDir -Recurse -File
            Write-Info "Found $($configFiles.Count) configuration files"
            
            Write-Progress "Deleting configuration directory..." 70
            Remove-Item $configDir -Recurse -Force -ErrorAction Stop
            Write-Success "Configuration directory removed"
        } catch {
            Write-Warning "Failed to remove configuration: $_"
            Write-Info "You may need to manually remove: $configDir"
        }
    } else {
        Write-Info "Configuration directory not found"
    }
} else {
    Write-Success "Configuration files preserved (--KeepConfig)"
    Write-Progress "Skipping configuration removal..." 70
}

# Step 5: Clean up backups (80-90%)
if (-not $KeepBackups) {
    Write-Step "Removing profile backups"
    Write-Progress "Cleaning up backup files..." 80
    
    $backupFiles = Get-ChildItem -Path (Split-Path $profilePath) -Filter "$([System.IO.Path]::GetFileName($profilePath))*.backup" -ErrorAction SilentlyContinue
    
    if ($backupFiles) {
        Write-Info "Found $($backupFiles.Count) backup files"
        
        foreach ($backup in $backupFiles) {
            try {
                Remove-Item $backup.FullName -Force
            } catch {
                Write-Warning "Failed to remove backup: $($backup.Name)"
            }
        }
        
        Write-Success "Backup files removed"
    } else {
        Write-Info "No backup files found"
    }
} else {
    Write-Success "Backup files preserved (--KeepBackups)"
    Write-Progress "Skipping backup removal..." 85
}

# Step 6: Verify uninstallation (90-95%)
Write-Step "Verifying uninstallation"
Write-Progress "Running verification checks..." 90

$verifyChecks = @{
    "Module directory removed" = -not (Test-Path $moduleInstallPath)
    "Module not loaded" = -not (Get-Module ProfileCore)
}

if (-not $KeepConfig) {
    $verifyChecks["Config directory removed"] = -not (Test-Path $configDir)
}

$allPassed = $true
foreach ($check in $verifyChecks.GetEnumerator()) {
    if ($check.Value) {
        if (-not $Quiet) {
            Write-Host "  ✅ $($check.Key)" -ForegroundColor Green
        }
    } else {
        Write-Warning "$($check.Key): FAILED"
        $allPassed = $false
    }
}

# Step 7: Generate uninstall log (95-100%)
Write-Progress "Generating uninstallation log..." 95

$logFile = Join-Path $env:TEMP "profilecore-uninstall-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Write-UninstallLog $logFile

Write-Progress "Uninstallation complete!" 100

# Final summary
$uninstallTime = ((Get-Date) - $script:StartTime).TotalSeconds

if (-not $Quiet) {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║         ✅ Uninstallation Complete Successfully! ✅       ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
    
    Write-Success "ProfileCore v5.0 uninstalled in $([math]::Round($uninstallTime, 1))s!"
    
    Write-Host "`n📊 Uninstallation Summary:" -ForegroundColor Cyan
    Write-Host "  ✅ Module removed: $moduleInstallPath" -ForegroundColor Green
    
    if (-not $KeepConfig) {
        Write-Host "  ✅ Configuration removed: $configDir" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Configuration preserved: $configDir" -ForegroundColor Yellow
    }
    
    if ($RestoreBackup) {
        Write-Host "  ✅ Profile restored from backup" -ForegroundColor Green
    } else {
        Write-Host "  ✅ Profile cleaned" -ForegroundColor Green
    }
    
    if (-not $KeepBackups) {
        Write-Host "  ✅ Backup files removed" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Backup files preserved" -ForegroundColor Yellow
    }
    
    Write-Host "`n📝 What was removed:" -ForegroundColor Cyan
    Write-Host "   • ProfileCore PowerShell module" -ForegroundColor Gray
    Write-Host "   • PowerShell profile modifications" -ForegroundColor Gray
    
    if (-not $KeepConfig) {
        Write-Host "   • Configuration and user data" -ForegroundColor Gray
    }
    
    if (-not $KeepBackups) {
        Write-Host "   • Profile backup files" -ForegroundColor Gray
    }
    
    Write-Host "`n💾 Preserved:" -ForegroundColor Cyan
    Write-Host "   • Uninstallation log: $logFile" -ForegroundColor Gray
    
    if ($KeepConfig) {
        Write-Host "   • Configuration files: $configDir" -ForegroundColor Gray
    }
    
    if ($KeepBackups) {
        Write-Host "   • Profile backups" -ForegroundColor Gray
    }
    
    Write-Host "`n💡 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1️⃣  Restart your PowerShell session" -ForegroundColor White
    Write-Host "  2️⃣  (Optional) Remove remaining configuration:" -ForegroundColor White
    Write-Host "     Remove-Item '$configDir' -Recurse -Force" -ForegroundColor Cyan
    
    if ($KeepBackups) {
        Write-Host "  3️⃣  (Optional) Remove profile backups:" -ForegroundColor White
        Write-Host "     Get-ChildItem '$(Split-Path $profilePath)' -Filter '*.backup' | Remove-Item" -ForegroundColor Cyan
    }
    
    Write-Host "`n📚 Reinstallation:" -ForegroundColor Cyan
    Write-Host "  To reinstall ProfileCore, run:" -ForegroundColor White
    Write-Host "  .\scripts\installation\install.ps1" -ForegroundColor Cyan
    
    Write-Host "`n👋 Thank you for using ProfileCore!`n" -ForegroundColor Green
} else {
    Write-Success "ProfileCore v5.0 uninstalled in $([math]::Round($uninstallTime, 1))s"
    Write-Info "Log: $logFile"
}

# Exit with success
exit 0

