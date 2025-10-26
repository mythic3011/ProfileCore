<#
.SYNOPSIS
    Validates ProfileCore module readiness for PowerShell Gallery publication.

.DESCRIPTION
    Performs comprehensive validation checks to ensure the module meets all
    PowerShell Gallery requirements and best practices.

.EXAMPLE
    .\Test-PSGalleryReadiness.ps1
    Runs all validation checks and displays a detailed report.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Configuration
$ModuleName = 'ProfileCore'
$ModulePath = Join-Path $PSScriptRoot "..\..\modules\$ModuleName"
$ManifestPath = Join-Path $ModulePath "$ModuleName.psd1"

# Results tracking
$script:PassedChecks = 0
$script:FailedChecks = 0
$script:WarningChecks = 0
$script:TotalChecks = 0

function Write-CheckResult {
    param(
        [string]$CheckName,
        [bool]$Passed,
        [string]$Message,
        [bool]$IsWarning = $false
    )
    
    $script:TotalChecks++
    
    if ($Passed) {
        $script:PassedChecks++
        Write-Host "✅ " -ForegroundColor Green -NoNewline
        Write-Host "$CheckName" -ForegroundColor White
        if ($Message) {
            Write-Host "   $Message" -ForegroundColor Gray
        }
    } elseif ($IsWarning) {
        $script:WarningChecks++
        Write-Host "⚠️  " -ForegroundColor Yellow -NoNewline
        Write-Host "$CheckName" -ForegroundColor White
        Write-Host "   $Message" -ForegroundColor Yellow
    } else {
        $script:FailedChecks++
        Write-Host "❌ " -ForegroundColor Red -NoNewline
        Write-Host "$CheckName" -ForegroundColor White
        Write-Host "   $Message" -ForegroundColor Red
    }
}

function Test-Section {
    param([string]$Title)
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

# Start
Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ProfileCore - PowerShell Gallery Readiness Check   ║" -ForegroundColor White
Write-Host "╚═══════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Section 1: File Structure
Test-Section "File Structure & Organization"

Write-CheckResult "Module directory exists" `
    (Test-Path $ModulePath) `
    "Path: $ModulePath"

Write-CheckResult "Module manifest exists" `
    (Test-Path $ManifestPath) `
    "Path: $ManifestPath"

Write-CheckResult "Module script file exists" `
    (Test-Path (Join-Path $ModulePath "$ModuleName.psm1")) `
    "RootModule present"

$licenseExists = Test-Path (Join-Path $PSScriptRoot "..\..\LICENSE")
Write-CheckResult "LICENSE file exists" `
    $licenseExists `
    "Required for PSGallery"

$readmeExists = Test-Path (Join-Path $PSScriptRoot "..\..\README.md")
Write-CheckResult "README.md exists" `
    $readmeExists `
    "Recommended for PSGallery"

# Section 2: Module Manifest Validation
Test-Section "Module Manifest Validation"

try {
    $manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    Write-CheckResult "Manifest is valid" $true "No syntax errors"
    
    # Check version format
    $versionValid = $manifest.Version -match '^\d+\.\d+\.\d+$'
    Write-CheckResult "Version format valid" `
        $versionValid `
        "Version: $($manifest.Version)"
    
    # Check GUID
    $guidValid = $manifest.Guid -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    Write-CheckResult "GUID format valid" `
        $guidValid `
        "GUID: $($manifest.Guid)"
    
    # Check PowerShell version
    $psVersionValid = $manifest.PowerShellVersion -ge [Version]'5.1'
    Write-CheckResult "PowerShell version requirement" `
        $psVersionValid `
        "Requires: $($manifest.PowerShellVersion)"
    
} catch {
    Write-CheckResult "Manifest validation" $false "Error: $_"
}

# Section 3: Required Metadata
Test-Section "Required PSGallery Metadata"

$authorValid = -not [string]::IsNullOrWhiteSpace($manifest.Author)
Write-CheckResult "Author specified" `
    $authorValid `
    "Author: $($manifest.Author)"

$descriptionValid = -not [string]::IsNullOrWhiteSpace($manifest.Description) -and $manifest.Description.Length -ge 10
Write-CheckResult "Description valid" `
    $descriptionValid `
    "Length: $($manifest.Description.Length) chars"

$projectUriValid = -not [string]::IsNullOrWhiteSpace($manifest.PrivateData.PSData.ProjectUri)
Write-CheckResult "ProjectUri specified" `
    $projectUriValid `
    "URI: $($manifest.PrivateData.PSData.ProjectUri)"

$licenseUriValid = -not [string]::IsNullOrWhiteSpace($manifest.PrivateData.PSData.LicenseUri)
Write-CheckResult "LicenseUri specified" `
    $licenseUriValid `
    "URI: $($manifest.PrivateData.PSData.LicenseUri)"

$tagsValid = $manifest.PrivateData.PSData.Tags.Count -ge 3
Write-CheckResult "Tags specified" `
    $tagsValid `
    "Count: $($manifest.PrivateData.PSData.Tags.Count) tags" `
    ($manifest.PrivateData.PSData.Tags.Count -lt 5)

$releaseNotesValid = -not [string]::IsNullOrWhiteSpace($manifest.PrivateData.PSData.ReleaseNotes)
Write-CheckResult "Release notes present" `
    $releaseNotesValid `
    "Length: $($manifest.PrivateData.PSData.ReleaseNotes.Length) chars"

# Section 4: Exports
Test-Section "Module Exports"

$functionsCount = $manifest.ExportedFunctions.Count
Write-CheckResult "Functions exported" `
    ($functionsCount -gt 0) `
    "Count: $functionsCount functions"

$aliasesCount = $manifest.ExportedAliases.Count
Write-CheckResult "Aliases exported" `
    ($aliasesCount -gt 0) `
    "Count: $aliasesCount aliases" `
    $true

# Check for explicit exports
$manifestContent = Get-Content $ManifestPath -Raw
$hasExplicitFunctions = $manifestContent -match 'FunctionsToExport\s*=\s*@\('
Write-CheckResult "Explicit function exports" `
    $hasExplicitFunctions `
    "Using explicit array (recommended)"

# Section 5: Code Quality
Test-Section "Code Quality Checks"

# Check for PSScriptAnalyzer
$hasAnalyzer = Get-Module -ListAvailable -Name PSScriptAnalyzer
if ($hasAnalyzer) {
    try {
        $analysisResults = Invoke-ScriptAnalyzer -Path $ModulePath -Recurse -Severity Error
        $noErrors = $analysisResults.Count -eq 0
        Write-CheckResult "PSScriptAnalyzer errors" `
            $noErrors `
            "Errors found: $($analysisResults.Count)"
        
        if ($analysisResults.Count -gt 0 -and $analysisResults.Count -le 5) {
            $analysisResults | ForEach-Object {
                Write-Host "      • $($_.RuleName): $($_.Message)" -ForegroundColor Red
            }
        }
    } catch {
        Write-CheckResult "PSScriptAnalyzer check" $false "Error running analysis: $_"
    }
} else {
    Write-CheckResult "PSScriptAnalyzer installed" $false "Install: Install-Module PSScriptAnalyzer" $true
}

# Check for help documentation
$publicFunctions = Get-ChildItem -Path (Join-Path $ModulePath "public") -Filter "*.ps1" -ErrorAction SilentlyContinue
if ($publicFunctions) {
    $functionsWithHelp = 0
    foreach ($file in $publicFunctions) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match '\.SYNOPSIS' -and $content -match '\.DESCRIPTION') {
            $functionsWithHelp++
        }
    }
    
    $helpCoverage = [math]::Round(($functionsWithHelp / $publicFunctions.Count) * 100, 0)
    Write-CheckResult "Function help documentation" `
        ($helpCoverage -ge 80) `
        "Coverage: $helpCoverage% ($functionsWithHelp/$($publicFunctions.Count))" `
        ($helpCoverage -lt 100)
}

# Section 6: Best Practices
Test-Section "Best Practices"

# Check for tests
$testsExist = Test-Path (Join-Path $PSScriptRoot "..\..\tests")
Write-CheckResult "Test directory exists" `
    $testsExist `
    "Path: tests/" `
    (-not $testsExist)

if ($testsExist) {
    $testFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "..\..\tests") -Filter "*.Tests.ps1" -Recurse
    Write-CheckResult "Test files present" `
        ($testFiles.Count -gt 0) `
        "Count: $($testFiles.Count) test files" `
        ($testFiles.Count -eq 0)
}

# Check for examples
$examplesExist = Test-Path (Join-Path $PSScriptRoot "..\..\examples")
Write-CheckResult "Examples directory exists" `
    $examplesExist `
    "Path: examples/" `
    $true

# Check for CHANGELOG
$changelogExists = Test-Path (Join-Path $PSScriptRoot "..\..\CHANGELOG.md")
Write-CheckResult "CHANGELOG.md exists" `
    $changelogExists `
    "Recommended for version tracking" `
    (-not $changelogExists)

# Check for .gitignore
$gitignoreExists = Test-Path (Join-Path $PSScriptRoot "...\.gitignore")
Write-CheckResult ".gitignore exists" `
    $gitignoreExists `
    "Prevents committing sensitive files" `
    $true

# Section 7: Module Size
Test-Section "Module Size & Performance"

$moduleSize = (Get-ChildItem -Path $ModulePath -Recurse | Measure-Object -Property Length -Sum).Sum
$moduleSizeMB = [math]::Round($moduleSize / 1MB, 2)
$sizeOk = $moduleSizeMB -lt 50

Write-CheckResult "Module size reasonable" `
    $sizeOk `
    "Size: $moduleSizeMB MB" `
    ($moduleSizeMB -gt 20)

# Check for large files
$largeFiles = Get-ChildItem -Path $ModulePath -Recurse -File | Where-Object { $_.Length -gt 1MB }
Write-CheckResult "No large files" `
    ($largeFiles.Count -eq 0) `
    "Files > 1MB: $($largeFiles.Count)" `
    ($largeFiles.Count -gt 0)

# Section 8: Security
Test-Section "Security Checks"

# Check for hardcoded secrets (basic check)
$suspiciousPatterns = @(
    'password\s*=\s*[''"]',
    'apikey\s*=\s*[''"]',
    'secret\s*=\s*[''"]',
    'token\s*=\s*[''"]'
)

$suspiciousFiles = @()
Get-ChildItem -Path $ModulePath -Filter "*.ps1" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    foreach ($pattern in $suspiciousPatterns) {
        if ($content -match $pattern) {
            $suspiciousFiles += $_.Name
            break
        }
    }
}

Write-CheckResult "No hardcoded secrets" `
    ($suspiciousFiles.Count -eq 0) `
    "Suspicious patterns found in: $($suspiciousFiles -join ', ')" `
    ($suspiciousFiles.Count -gt 0)

# Check for .env files in module
$envFiles = Get-ChildItem -Path $ModulePath -Filter ".env*" -Recurse
Write-CheckResult "No .env files in module" `
    ($envFiles.Count -eq 0) `
    ".env files should not be packaged"

# Final Summary
Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                  Validation Summary                  ║" -ForegroundColor White
Write-Host "╚═══════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Total Checks:    " -NoNewline
Write-Host $script:TotalChecks -ForegroundColor White

Write-Host "Passed:          " -NoNewline
Write-Host $script:PassedChecks -ForegroundColor Green

Write-Host "Failed:          " -NoNewline
Write-Host $script:FailedChecks -ForegroundColor $(if ($script:FailedChecks -eq 0) { 'Green' } else { 'Red' })

Write-Host "Warnings:        " -NoNewline
Write-Host $script:WarningChecks -ForegroundColor Yellow

$passRate = [math]::Round(($script:PassedChecks / $script:TotalChecks) * 100, 0)
Write-Host "`nPass Rate:       " -NoNewline
Write-Host "$passRate%" -ForegroundColor $(if ($passRate -ge 90) { 'Green' } elseif ($passRate -ge 75) { 'Yellow' } else { 'Red' })

Write-Host "`n" -NoNewline
if ($script:FailedChecks -eq 0) {
    Write-Host "✅ Module is ready for PowerShell Gallery publication!" -ForegroundColor Green
    Write-Host "`nNext step: Run .\Publish-ToPSGallery.ps1 -DryRun" -ForegroundColor Cyan
    exit 0
} elseif ($script:FailedChecks -le 3) {
    Write-Host "⚠️  Module has minor issues that should be addressed" -ForegroundColor Yellow
    Write-Host "`nReview failed checks above and fix before publishing" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "❌ Module is NOT ready for publication" -ForegroundColor Red
    Write-Host "`nPlease fix all failed checks before publishing" -ForegroundColor Red
    exit 1
}


