#
# Rust-vs-PowerShell.ps1
# Performance comparison between Rust FFI and PowerShell implementations
#

[CmdletBinding()]
param(
    [int]$Iterations = 1000,
    [switch]$Verbose,
    [switch]$ExportResults
)

$ErrorActionPreference = 'Stop'

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host   "║  Rust vs PowerShell Performance Benchmark          ║" -ForegroundColor Cyan
Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Import required modules
$modulePath = Join-Path $PSScriptRoot "../../modules/ProfileCore"
if (Test-Path "$modulePath/ProfileCore-v6.psm1") {
    Import-Module "$modulePath/ProfileCore-v6.psm1" -Force
} else {
    throw "ProfileCore v6 module not found at: $modulePath"
}

# Check if system info service is available
try {
    $systemInfo = Resolve-Service 'ISystemInfo'
    $rustAvailable = $systemInfo.IsRustAvailable()
} catch {
    Write-Error "Failed to resolve ISystemInfo service: $_"
    exit 1
}

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Iterations:     $Iterations" -ForegroundColor White
Write-Host "  Rust Available: $(if ($rustAvailable) { '✅ Yes' } else { '⚠️  No' })" -ForegroundColor $(if ($rustAvailable) { 'Green' } else { 'Yellow' })
Write-Host ""

if (-not $rustAvailable) {
    Write-Warning "Rust binary not available. Install ProfileCore.Binary module to run full benchmarks."
    Write-Warning "Proceeding with PowerShell-only benchmarks..."
}

# Benchmark results storage
$results = @{
    Timestamp = Get-Date
    Iterations = $Iterations
    RustAvailable = $rustAvailable
    Tests = @()
}

# ===========================================================================
# Test 1: System Information Gathering
# ===========================================================================

Write-Host "`n━━━ Test 1: System Information ━━━" -ForegroundColor Yellow

if ($rustAvailable) {
    # Rust implementation
    Write-Host "  Benchmarking Rust implementation..." -ForegroundColor Gray
    $rustTime = Measure-Command {
        1..$Iterations | ForEach-Object {
            $null = $systemInfo.GetSystemInfo()
        }
    }
    
    $rustAvgMs = [Math]::Round($rustTime.TotalMilliseconds / $Iterations, 4)
    Write-Host "  Rust:       $($rustTime.TotalMilliseconds)ms total, ${rustAvgMs}ms avg" -ForegroundColor Green
}

# PowerShell fallback
Write-Host "  Benchmarking PowerShell implementation..." -ForegroundColor Gray
$psTime = Measure-Command {
    1..$Iterations | ForEach-Object {
        $null = $systemInfo.GetFallbackSystemInfo()
    }
}

$psAvgMs = [Math]::Round($psTime.TotalMilliseconds / $Iterations, 4)
Write-Host "  PowerShell: $($psTime.TotalMilliseconds)ms total, ${psAvgMs}ms avg" -ForegroundColor Cyan

if ($rustAvailable) {
    $speedup = [Math]::Round($psTime.TotalMilliseconds / $rustTime.TotalMilliseconds, 2)
    $improvement = [Math]::Round((($psTime.TotalMilliseconds - $rustTime.TotalMilliseconds) / $psTime.TotalMilliseconds) * 100, 1)
    Write-Host "  Speedup:    ${speedup}x faster ($improvement% improvement)" -ForegroundColor Green
    
    $results.Tests += @{
        Name = 'System Information'
        RustMs = $rustTime.TotalMilliseconds
        PowerShellMs = $psTime.TotalMilliseconds
        Speedup = $speedup
        ImprovementPercent = $improvement
    }
} else {
    Write-Host "  Speedup:    (Rust unavailable)" -ForegroundColor Yellow
}

# ===========================================================================
# Test 2: Platform Detection
# ===========================================================================

Write-Host "`n━━━ Test 2: Platform Detection ━━━" -ForegroundColor Yellow

if ($rustAvailable) {
    Write-Host "  Benchmarking Rust implementation..." -ForegroundColor Gray
    $rustTime = Measure-Command {
        1..$Iterations | ForEach-Object {
            $null = $systemInfo.GetPlatformInfo()
        }
    }
    
    $rustAvgMs = [Math]::Round($rustTime.TotalMilliseconds / $Iterations, 4)
    Write-Host "  Rust:       $($rustTime.TotalMilliseconds)ms total, ${rustAvgMs}ms avg" -ForegroundColor Green
}

Write-Host "  Benchmarking PowerShell implementation..." -ForegroundColor Gray
$psTime = Measure-Command {
    1..$Iterations | ForEach-Object {
        $null = $systemInfo.GetFallbackPlatformInfo()
    }
}

$psAvgMs = [Math]::Round($psTime.TotalMilliseconds / $Iterations, 4)
Write-Host "  PowerShell: $($psTime.TotalMilliseconds)ms total, ${psAvgMs}ms avg" -ForegroundColor Cyan

if ($rustAvailable) {
    $speedup = [Math]::Round($psTime.TotalMilliseconds / $rustTime.TotalMilliseconds, 2)
    $improvement = [Math]::Round((($psTime.TotalMilliseconds - $rustTime.TotalMilliseconds) / $psTime.TotalMilliseconds) * 100, 1)
    Write-Host "  Speedup:    ${speedup}x faster ($improvement% improvement)" -ForegroundColor Green
    
    $results.Tests += @{
        Name = 'Platform Detection'
        RustMs = $rustTime.TotalMilliseconds
        PowerShellMs = $psTime.TotalMilliseconds
        Speedup = $speedup
        ImprovementPercent = $improvement
    }
}

# ===========================================================================
# Test 3: Local IP Address
# ===========================================================================

Write-Host "`n━━━ Test 3: Local IP Address ━━━" -ForegroundColor Yellow

if ($rustAvailable) {
    Write-Host "  Benchmarking Rust implementation..." -ForegroundColor Gray
    $rustTime = Measure-Command {
        1..$Iterations | ForEach-Object {
            $null = $systemInfo.GetLocalIP()
        }
    }
    
    $rustAvgMs = [Math]::Round($rustTime.TotalMilliseconds / $Iterations, 4)
    Write-Host "  Rust:       $($rustTime.TotalMilliseconds)ms total, ${rustAvgMs}ms avg" -ForegroundColor Green
}

Write-Host "  Benchmarking PowerShell implementation..." -ForegroundColor Gray
$psTime = Measure-Command {
    1..$Iterations | ForEach-Object {
        $null = $systemInfo.GetFallbackLocalIP()
    }
}

$psAvgMs = [Math]::Round($psTime.TotalMilliseconds / $Iterations, 4)
Write-Host "  PowerShell: $($psTime.TotalMilliseconds)ms total, ${psAvgMs}ms avg" -ForegroundColor Cyan

if ($rustAvailable) {
    $speedup = [Math]::Round($psTime.TotalMilliseconds / $rustTime.TotalMilliseconds, 2)
    $improvement = [Math]::Round((($psTime.TotalMilliseconds - $rustTime.TotalMilliseconds) / $psTime.TotalMilliseconds) * 100, 1)
    Write-Host "  Speedup:    ${speedup}x faster ($improvement% improvement)" -ForegroundColor Green
    
    $results.Tests += @{
        Name = 'Local IP Address'
        RustMs = $rustTime.TotalMilliseconds
        PowerShellMs = $psTime.TotalMilliseconds
        Speedup = $speedup
        ImprovementPercent = $improvement
    }
}

# ===========================================================================
# Test 4: Port Testing (Network I/O)
# ===========================================================================

Write-Host "`n━━━ Test 4: Port Testing (10 iterations) ━━━" -ForegroundColor Yellow
$portIterations = 10  # Fewer iterations for network I/O

if ($rustAvailable) {
    Write-Host "  Benchmarking Rust implementation..." -ForegroundColor Gray
    $rustTime = Measure-Command {
        1..$portIterations | ForEach-Object {
            $null = $systemInfo.TestPort('127.0.0.1', 80, 100)
        }
    }
    
    $rustAvgMs = [Math]::Round($rustTime.TotalMilliseconds / $portIterations, 4)
    Write-Host "  Rust:       $($rustTime.TotalMilliseconds)ms total, ${rustAvgMs}ms avg" -ForegroundColor Green
}

Write-Host "  Benchmarking PowerShell implementation..." -ForegroundColor Gray
$psTime = Measure-Command {
    1..$portIterations | ForEach-Object {
        $null = $systemInfo.FallbackTestPort('127.0.0.1', 80, 100)
    }
}

$psAvgMs = [Math]::Round($psTime.TotalMilliseconds / $portIterations, 4)
Write-Host "  PowerShell: $($psTime.TotalMilliseconds)ms total, ${psAvgMs}ms avg" -ForegroundColor Cyan

if ($rustAvailable) {
    $speedup = [Math]::Round($psTime.TotalMilliseconds / $rustTime.TotalMilliseconds, 2)
    $improvement = [Math]::Round((($psTime.TotalMilliseconds - $rustTime.TotalMilliseconds) / $psTime.TotalMilliseconds) * 100, 1)
    Write-Host "  Speedup:    ${speedup}x faster ($improvement% improvement)" -ForegroundColor Green
    
    $results.Tests += @{
        Name = 'Port Testing'
        RustMs = $rustTime.TotalMilliseconds
        PowerShellMs = $psTime.TotalMilliseconds
        Speedup = $speedup
        ImprovementPercent = $improvement
    }
}

# ===========================================================================
# Summary
# ===========================================================================

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host   "║  Benchmark Complete!                               ║" -ForegroundColor Green
Write-Host   "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Green

if ($rustAvailable -and $results.Tests.Count -gt 0) {
    # Calculate overall statistics
    $avgSpeedup = [Math]::Round(($results.Tests | Measure-Object -Property Speedup -Average).Average, 2)
    $avgImprovement = [Math]::Round(($results.Tests | Measure-Object -Property ImprovementPercent -Average).Average, 1)
    $maxSpeedup = [Math]::Round(($results.Tests | Measure-Object -Property Speedup -Maximum).Maximum, 2)
    $minSpeedup = [Math]::Round(($results.Tests | Measure-Object -Property Speedup -Minimum).Minimum, 2)
    
    Write-Host "Overall Results:" -ForegroundColor Cyan
    Write-Host "  Average Speedup:  ${avgSpeedup}x" -ForegroundColor Green
    Write-Host "  Average Improvement: $avgImprovement%" -ForegroundColor Green
    Write-Host "  Best Speedup:     ${maxSpeedup}x" -ForegroundColor White
    Write-Host "  Worst Speedup:    ${minSpeedup}x" -ForegroundColor White
    
    # Add summary to results
    $results.Summary = @{
        AverageSpeedup = $avgSpeedup
        AverageImprovement = $avgImprovement
        MaxSpeedup = $maxSpeedup
        MinSpeedup = $minSpeedup
    }
    
    Write-Host "`nConclusion:" -ForegroundColor Cyan
    if ($avgSpeedup -ge 5) {
        Write-Host "  🚀 Rust provides exceptional performance gains!" -ForegroundColor Green
    } elseif ($avgSpeedup -ge 2) {
        Write-Host "  ✅ Rust provides significant performance improvements" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Rust provides modest performance improvements" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "Rust benchmarks not available." -ForegroundColor Yellow
    Write-Host "Install ProfileCore.Binary module to measure Rust performance." -ForegroundColor Gray
}

# Export results if requested
if ($ExportResults) {
    $outputPath = Join-Path $PSScriptRoot "benchmark-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $results | ConvertTo-Json -Depth 10 | Out-File $outputPath -Encoding UTF8
    Write-Host "`nResults exported to: $outputPath" -ForegroundColor Cyan
}

Write-Host ""

