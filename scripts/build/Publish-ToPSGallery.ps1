<#
.SYNOPSIS
    Publishes ProfileCore module to PowerShell Gallery.

.DESCRIPTION
    This script performs comprehensive validation and publishes the ProfileCore module
    to the PowerShell Gallery. It includes pre-publish checks, package creation,
    and optional dry-run mode for testing.

.PARAMETER ApiKey
    PowerShell Gallery API key. Can also be provided via $env:PSGALLERY_API_KEY.

.PARAMETER DryRun
    Performs all validation and package creation without actually publishing.

.PARAMETER SkipTests
    Skips running the test suite before publishing.

.PARAMETER Force
    Bypasses confirmation prompts.

.EXAMPLE
    .\Publish-ToPSGallery.ps1 -DryRun
    Validates and creates package without publishing.

.EXAMPLE
    .\Publish-ToPSGallery.ps1 -ApiKey "your-api-key"
    Publishes to PowerShell Gallery after validation.

.EXAMPLE
    $env:PSGALLERY_API_KEY = "your-api-key"
    .\Publish-ToPSGallery.ps1 -Force
    Publishes without prompts using environment variable.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$ApiKey = $env:PSGALLERY_API_KEY,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$SkipTests,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Configuration
$ModuleName = 'ProfileCore'
$ModulePath = Join-Path $PSScriptRoot "..\..\modules\$ModuleName"
$ManifestPath = Join-Path $ModulePath "$ModuleName.psd1"
$OutputPath = Join-Path $PSScriptRoot "..\..\build"

# Color output functions
function Write-StatusMessage {
    param([string]$Message, [string]$Type = 'Info')
    
    $color = switch ($Type) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Info' { 'Cyan' }
        default { 'White' }
    }
    
    $icon = switch ($Type) {
        'Success' { '✅' }
        'Warning' { '⚠️' }
        'Error' { '❌' }
        'Info' { 'ℹ️' }
        default { '•' }
    }
    
    Write-Host "$icon $Message" -ForegroundColor $color
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Start
Write-SectionHeader "ProfileCore - PowerShell Gallery Publisher"

if ($DryRun) {
    Write-StatusMessage "Running in DRY-RUN mode (no actual publishing)" "Warning"
}

# Step 1: Validate Module Manifest
Write-SectionHeader "Step 1: Validating Module Manifest"

try {
    Write-StatusMessage "Testing manifest: $ManifestPath" "Info"
    $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    
    Write-StatusMessage "Module Name: $($manifest.Name)" "Success"
    Write-StatusMessage "Version: $($manifest.Version)" "Success"
    Write-StatusMessage "Author: $($manifest.Author)" "Success"
    Write-StatusMessage "Functions: $($manifest.ExportedFunctions.Count)" "Success"
    Write-StatusMessage "Aliases: $($manifest.ExportedAliases.Count)" "Success"
    
    # Validate required fields for PSGallery
    $requiredFields = @{
        'Author' = $manifest.Author
        'Description' = $manifest.Description
        'ProjectUri' = $manifest.PrivateData.PSData.ProjectUri
        'LicenseUri' = $manifest.PrivateData.PSData.LicenseUri
    }
    
    $missingFields = @()
    foreach ($field in $requiredFields.GetEnumerator()) {
        if ([string]::IsNullOrWhiteSpace($field.Value)) {
            $missingFields += $field.Key
        }
    }
    
    if ($missingFields.Count -gt 0) {
        Write-StatusMessage "Missing required fields: $($missingFields -join ', ')" "Error"
        throw "Module manifest is missing required PSGallery fields"
    }
    
    Write-StatusMessage "All required PSGallery fields present" "Success"
    
} catch {
    Write-StatusMessage "Manifest validation failed: $_" "Error"
    exit 1
}

# Step 2: Run PSScriptAnalyzer
Write-SectionHeader "Step 2: Running PSScriptAnalyzer"

try {
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Write-StatusMessage "PSScriptAnalyzer not found, skipping..." "Warning"
    } else {
        Write-StatusMessage "Analyzing module code..." "Info"
        
        $analysisResults = Invoke-ScriptAnalyzer -Path $ModulePath -Recurse -Settings (Join-Path $PSScriptRoot "..\..\config\analyzer-settings.psd1")
        
        $errors = $analysisResults | Where-Object Severity -eq 'Error'
        $warnings = $analysisResults | Where-Object Severity -eq 'Warning'
        
        if ($errors.Count -gt 0) {
            Write-StatusMessage "Found $($errors.Count) errors" "Error"
            $errors | Format-Table -AutoSize | Out-String | Write-Host
            throw "PSScriptAnalyzer found errors that must be fixed"
        }
        
        Write-StatusMessage "Errors: 0" "Success"
        Write-StatusMessage "Warnings: $($warnings.Count)" "Info"
        
        if ($warnings.Count -gt 0 -and $warnings.Count -lt 10) {
            $warnings | Format-Table -Property Severity, RuleName, Message, Line -AutoSize
        }
    }
} catch {
    Write-StatusMessage "PSScriptAnalyzer check failed: $_" "Error"
    exit 1
}

# Step 3: Run Tests
if (-not $SkipTests) {
    Write-SectionHeader "Step 3: Running Test Suite"
    
    try {
        if (-not (Get-Module -ListAvailable -Name Pester)) {
            Write-StatusMessage "Pester not found, skipping tests..." "Warning"
        } else {
            Write-StatusMessage "Running Pester tests..." "Info"
            
            $testsPath = Join-Path $PSScriptRoot "..\..\tests"
            $pesterConfig = New-PesterConfiguration
            $pesterConfig.Run.Path = $testsPath
            $pesterConfig.Run.PassThru = $true
            $pesterConfig.Output.Verbosity = 'Minimal'
            $pesterConfig.CodeCoverage.Enabled = $false
            
            $testResults = Invoke-Pester -Configuration $pesterConfig
            
            if ($testResults.FailedCount -gt 0) {
                Write-StatusMessage "Tests failed: $($testResults.FailedCount) failures" "Error"
                throw "Test suite must pass before publishing"
            }
            
            Write-StatusMessage "All tests passed ($($testResults.PassedCount) passed)" "Success"
        }
    } catch {
        Write-StatusMessage "Test execution failed: $_" "Error"
        exit 1
    }
} else {
    Write-StatusMessage "Skipping tests (use -SkipTests)" "Warning"
}

# Step 4: Check for Existing Version
Write-SectionHeader "Step 4: Checking PowerShell Gallery"

try {
    Write-StatusMessage "Checking if version $($manifest.Version) already exists..." "Info"
    
    $existingModule = Find-Module -Name $ModuleName -ErrorAction SilentlyContinue
    
    if ($existingModule) {
        Write-StatusMessage "Current PSGallery version: $($existingModule.Version)" "Info"
        
        if ($existingModule.Version -ge $manifest.Version) {
            Write-StatusMessage "Version $($manifest.Version) already exists or is older" "Error"
            Write-StatusMessage "Please update ModuleVersion in the manifest" "Error"
            exit 1
        }
        
        Write-StatusMessage "New version $($manifest.Version) > $($existingModule.Version)" "Success"
    } else {
        Write-StatusMessage "This will be the first publication" "Info"
    }
} catch {
    Write-StatusMessage "Could not check PSGallery (may be first publish): $_" "Warning"
}

# Step 5: Create Package
Write-SectionHeader "Step 5: Creating Module Package"

try {
    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }
    
    Write-StatusMessage "Output directory: $OutputPath" "Info"
    
    # Create a clean copy of the module
    $stagingPath = Join-Path $OutputPath "staging\$ModuleName"
    if (Test-Path $stagingPath) {
        Remove-Item -Path $stagingPath -Recurse -Force
    }
    
    Write-StatusMessage "Creating staging directory..." "Info"
    New-Item -Path $stagingPath -ItemType Directory -Force | Out-Null
    
    # Copy module files
    Write-StatusMessage "Copying module files..." "Info"
    Copy-Item -Path "$ModulePath\*" -Destination $stagingPath -Recurse -Force
    
    # Remove any unnecessary files
    $excludePatterns = @('*.Tests.ps1', '*.test.ps1', '.git*', 'test*', 'Test*')
    foreach ($pattern in $excludePatterns) {
        Get-ChildItem -Path $stagingPath -Filter $pattern -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    
    Write-StatusMessage "Package created in staging directory" "Success"
    Write-StatusMessage "Package size: $([math]::Round((Get-ChildItem $stagingPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1KB, 2)) KB" "Info"
    
} catch {
    Write-StatusMessage "Package creation failed: $_" "Error"
    exit 1
}

# Step 6: Publish to PSGallery
Write-SectionHeader "Step 6: Publishing to PowerShell Gallery"

if ($DryRun) {
    Write-StatusMessage "DRY-RUN: Skipping actual publish" "Warning"
    Write-StatusMessage "Package is ready at: $stagingPath" "Info"
    Write-StatusMessage "To publish, run without -DryRun flag" "Info"
} else {
    # Validate API key
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        Write-StatusMessage "API Key required for publishing" "Error"
        Write-StatusMessage "Provide via -ApiKey parameter or `$env:PSGALLERY_API_KEY" "Error"
        exit 1
    }
    
    # Confirm publish
    if (-not $Force) {
        Write-Host "`nReady to publish ProfileCore v$($manifest.Version) to PowerShell Gallery" -ForegroundColor Yellow
        Write-Host "This action cannot be undone. Continue? (Y/N): " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host
        
        if ($confirmation -ne 'Y') {
            Write-StatusMessage "Publish cancelled by user" "Warning"
            exit 0
        }
    }
    
    try {
        Write-StatusMessage "Publishing to PowerShell Gallery..." "Info"
        
        Publish-Module -Path $stagingPath -NuGetApiKey $ApiKey -Verbose -ErrorAction Stop
        
        Write-StatusMessage "Successfully published to PowerShell Gallery!" "Success"
        Write-StatusMessage "Module will be available at: https://www.powershellgallery.com/packages/$ModuleName" "Info"
        Write-StatusMessage "Installation: Install-Module -Name $ModuleName" "Info"
        
    } catch {
        Write-StatusMessage "Publish failed: $_" "Error"
        exit 1
    }
}

# Step 7: Cleanup
Write-SectionHeader "Step 7: Cleanup"

if (-not $DryRun) {
    try {
        Write-StatusMessage "Cleaning up staging directory..." "Info"
        Remove-Item -Path (Join-Path $OutputPath "staging") -Recurse -Force -ErrorAction SilentlyContinue
        Write-StatusMessage "Cleanup complete" "Success"
    } catch {
        Write-StatusMessage "Cleanup warning: $_" "Warning"
    }
}

# Summary
Write-SectionHeader "Publication Summary"

Write-Host "Module Name:    " -NoNewline; Write-Host $ModuleName -ForegroundColor Green
Write-Host "Version:        " -NoNewline; Write-Host $manifest.Version -ForegroundColor Green
Write-Host "Functions:      " -NoNewline; Write-Host $manifest.ExportedFunctions.Count -ForegroundColor Green
Write-Host "Aliases:        " -NoNewline; Write-Host $manifest.ExportedAliases.Count -ForegroundColor Green

if ($DryRun) {
    Write-Host "Status:         " -NoNewline; Write-Host "DRY-RUN (not published)" -ForegroundColor Yellow
} else {
    Write-Host "Status:         " -NoNewline; Write-Host "PUBLISHED ✅" -ForegroundColor Green
}

Write-Host "`n═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

if (-not $DryRun) {
    Write-Host "🎉 ProfileCore v$($manifest.Version) is now live on PowerShell Gallery!" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Create GitHub release with tag v$($manifest.Version)" -ForegroundColor White
    Write-Host "  2. Update CHANGELOG.md with release notes" -ForegroundColor White
    Write-Host "  3. Announce on social media / community" -ForegroundColor White
    Write-Host "  4. Monitor for issues and feedback" -ForegroundColor White
}


