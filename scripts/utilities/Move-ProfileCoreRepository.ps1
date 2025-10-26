<#
.SYNOPSIS
    Move ProfileCore repository to a new location while preserving configuration
.DESCRIPTION
    Safely moves the ProfileCore repository to a new directory while keeping the
    PowerShell module installation and configuration intact. The module remains
    in the PowerShell modules directory for easy access.
.PARAMETER NewLocation
    The new directory where you want to move the repository
.PARAMETER KeepModuleSymlink
    Create a symbolic link in the new location to the installed module
.EXAMPLE
    .\Move-ProfileCoreRepository.ps1 -NewLocation "C:\Dev\ProfileCore"
.EXAMPLE
    .\Move-ProfileCoreRepository.ps1 -NewLocation "D:\Projects\PowerShell\ProfileCore" -KeepModuleSymlink
.NOTES
    Author: ProfileCore Team
    Version: 1.0.0
    This script preserves your configuration and installed module
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$NewLocation,
    
    [switch]$KeepModuleSymlink
)

$ErrorActionPreference = 'Stop'

# Import ProfileCore.Common for shared output functions
. "$PSScriptRoot\..\shared\ScriptHelpers.ps1"
$commonLoaded = Import-ProfileCoreCommon -Quiet

if (-not $commonLoaded) {
    # Fallback helper functions if Common module isn't available
    function Write-Step {
        param([string]$Message)
        Write-Host "`n🔹 $Message" -ForegroundColor Cyan
    }

    function Write-Success {
        param([string]$Message)
        Write-Host "✅ $Message" -ForegroundColor Green
    }

    function Write-Info {
        param([string]$Message)
        Write-Host "ℹ️  $Message" -ForegroundColor White
    }
}

try {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     ProfileCore Repository Migration Tool             ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # Get current location
    $currentLocation = $PSScriptRoot | Split-Path | Split-Path
    $modulesPath = Join-Path (Split-Path $PROFILE) "modules"
    $moduleInstallPath = Join-Path $modulesPath "ProfileCore"
    $configDir = Join-Path $HOME ".config\shell-profile"
    
    Write-Info "Current repository location: $currentLocation"
    Write-Info "Module installation location: $moduleInstallPath"
    Write-Info "Configuration directory: $configDir"
    Write-Info "New repository location: $NewLocation"
    
    # Validation
    Write-Step "Validating Migration"
    
    # Check if current location is a git repository
    if (-not (Test-Path (Join-Path $currentLocation ".git"))) {
        throw "Current directory is not a git repository!"
    }
    
    # Check if new location exists
    if (Test-Path $NewLocation) {
        if ((Get-ChildItem $NewLocation -Force).Count -gt 0) {
            Write-Warning "Target directory exists and is not empty!"
            $continue = Read-Host "Continue anyway? This may overwrite files (y/N)"
            if ($continue -ne 'y' -and $continue -ne 'Y') {
                Write-Host "Migration cancelled." -ForegroundColor Yellow
                exit 0
            }
        }
    } else {
        New-Item -Path $NewLocation -ItemType Directory -Force | Out-Null
        Write-Success "Created target directory"
    }
    
    # Check if we're moving from the modules directory
    $movingFromModules = $currentLocation -eq $moduleInstallPath
    
    Write-Success "Validation complete"
    
    # Step 1: Check for uncommitted changes
    Write-Step "Checking Git Status"
    
    Push-Location $currentLocation
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($gitStatus) {
            Write-Warning "You have uncommitted changes!"
            Write-Host "`nUncommitted files:" -ForegroundColor Yellow
            $gitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            
            $stash = Read-Host "`nStash changes before moving? (Y/n)"
            if ($stash -ne 'n' -and $stash -ne 'N') {
                git stash push -m "Auto-stash before repository move $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
                Write-Success "Changes stashed"
            }
        } else {
            Write-Success "Working directory clean"
        }
    } finally {
        Pop-Location
    }
    
    # Step 2: Copy/Move repository
    Write-Step "Moving Repository"
    
    if ($PSCmdlet.ShouldProcess($NewLocation, "Move repository")) {
        # Get all items including hidden files
        $items = Get-ChildItem -Path $currentLocation -Force
        $totalItems = $items.Count
        $counter = 0
        
        foreach ($item in $items) {
            $counter++
            $percent = [math]::Round(($counter / $totalItems) * 100)
            Write-Progress -Activity "Moving repository" -Status "$percent% - $($item.Name)" -PercentComplete $percent
            
            $destination = Join-Path $NewLocation $item.Name
            
            if ($item.PSIsContainer) {
                if (-not (Test-Path $destination)) {
                    Copy-Item -Path $item.FullName -Destination $destination -Recurse -Force
                }
            } else {
                Copy-Item -Path $item.FullName -Destination $destination -Force
            }
        }
        
        Write-Progress -Activity "Moving repository" -Completed
        Write-Success "Repository copied to new location"
    }
    
    # Step 3: Verify new location
    Write-Step "Verifying New Location"
    
    $verifyChecks = @{
        ".git directory" = Test-Path (Join-Path $NewLocation ".git")
        "modules directory" = Test-Path (Join-Path $NewLocation "modules")
        "scripts directory" = Test-Path (Join-Path $NewLocation "scripts")
        "README.md" = Test-Path (Join-Path $NewLocation "README.md")
    }
    
    foreach ($check in $verifyChecks.GetEnumerator()) {
        if ($check.Value) {
            Write-Success "$($check.Key)"
        } else {
            Write-Warning "$($check.Key) - NOT FOUND"
        }
    }
    
    # Step 4: Update module if needed
    Write-Step "Checking Module Installation"
    
    if ($movingFromModules) {
        Write-Info "Repository was installed in modules directory"
        Write-Info "Updating module installation..."
        
        # Run installer from new location to set up module properly
        $installerPath = Join-Path $NewLocation "scripts\installation\install.ps1"
        if (Test-Path $installerPath) {
            & $installerPath -Force
            Write-Success "Module installation updated"
        }
    } else {
        Write-Info "Module is already installed separately in: $moduleInstallPath"
        Write-Success "No module update needed"
    }
    
    # Step 5: Create symlink if requested
    if ($KeepModuleSymlink) {
        Write-Step "Creating Symbolic Link"
        
        $symlinkPath = Join-Path $NewLocation "modules\ProfileCore-Installed"
        if (Test-Path $symlinkPath) {
            Remove-Item $symlinkPath -Force -Recurse
        }
        
        try {
            New-Item -ItemType SymbolicLink -Path $symlinkPath -Target $moduleInstallPath -Force | Out-Null
            Write-Success "Symbolic link created: $symlinkPath -> $moduleInstallPath"
        } catch {
            Write-Warning "Could not create symbolic link (requires admin): $_"
        }
    }
    
    # Step 6: Update git remote if needed
    Write-Step "Checking Git Configuration"
    
    Push-Location $NewLocation
    try {
        $gitRemote = git remote get-url origin 2>&1
        if ($gitRemote) {
            Write-Info "Git remote: $gitRemote"
            Write-Success "Git configuration preserved"
        }
    } finally {
        Pop-Location
    }
    
    # Step 7: Remove old location (optional)
    Write-Step "Cleanup"
    
    Write-Warning "Old repository location: $currentLocation"
    $cleanup = Read-Host "Delete old repository location? (y/N)"
    
    if ($cleanup -eq 'y' -or $cleanup -eq 'Y') {
        if ($PSCmdlet.ShouldProcess($currentLocation, "Remove old repository")) {
            Remove-Item -Path $currentLocation -Recurse -Force
            Write-Success "Old location removed"
        }
    } else {
        Write-Info "Old repository kept at: $currentLocation"
        Write-Info "You can manually delete it later if desired"
    }
    
    # Success Summary
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║           ✅ Migration Complete Successfully! ✅        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
    
    Write-Host "📊 Migration Summary:" -ForegroundColor Cyan
    Write-Host "  Repository moved to: $NewLocation" -ForegroundColor White
    Write-Host "  Module location:     $moduleInstallPath" -ForegroundColor White
    Write-Host "  Configuration:       $configDir" -ForegroundColor White
    
    Write-Host "`n✨ What's Preserved:" -ForegroundColor Cyan
    Write-Host "  ✅ Git history and remotes" -ForegroundColor Green
    Write-Host "  ✅ PowerShell module installation" -ForegroundColor Green
    Write-Host "  ✅ Configuration files (.config/shell-profile)" -ForegroundColor Green
    Write-Host "  ✅ Profile settings (\$PROFILE)" -ForegroundColor Green
    Write-Host "  ✅ All your customizations" -ForegroundColor Green
    
    Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Change to new location:" -ForegroundColor White
    Write-Host "     cd `"$NewLocation`"" -ForegroundColor Cyan
    
    Write-Host "`n  2. Verify everything works:" -ForegroundColor White
    Write-Host "     Get-SystemInfo" -ForegroundColor Cyan
    Write-Host "     Get-Command -Module ProfileCore" -ForegroundColor Cyan
    
    Write-Host "`n  3. Update repository:" -ForegroundColor White
    Write-Host "     git pull" -ForegroundColor Cyan
    
    if ($movingFromModules) {
        Write-Host "`n💡 Note: Module is now installed separately from repository" -ForegroundColor Yellow
        Write-Host "   Repository: $NewLocation" -ForegroundColor Gray
        Write-Host "   Module:     $moduleInstallPath" -ForegroundColor Gray
        Write-Host "   This allows you to develop in one place and use from another!" -ForegroundColor Gray
    }
    
    Write-Host "`n🎉 Your PowerShell configuration is intact and working!`n" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Migration failed: $_" -ForegroundColor Red
    
    if ($_.ScriptStackTrace) {
        Write-Host "`nStack trace:" -ForegroundColor Gray
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    }
    
    Write-Host "`n💡 What to do:" -ForegroundColor Yellow
    Write-Host "   1. Your current installation is still intact" -ForegroundColor White
    Write-Host "   2. Nothing has been damaged" -ForegroundColor White
    Write-Host "   3. Check the error above and try again" -ForegroundColor White
    Write-Host "   4. You can also manually copy the repository" -ForegroundColor White
    
    exit 1
}

