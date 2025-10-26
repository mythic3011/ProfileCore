#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Profiles ProfileCore module loading to identify performance bottlenecks.

.DESCRIPTION
    This script measures the load time of each file and initialization system
    to identify which components are slowest and should be optimized.

.EXAMPLE
    .\Profile-ModuleLoad.ps1

.NOTES
    Part of Phase 3 - Performance Optimization
#>

[CmdletBinding()]
param()

Write-Host "`n🔍 ProfileCore Load Time Profiler" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Gray

# Remove module if already loaded
if (Get-Module ProfileCore) {
    Remove-Module ProfileCore -Force
}

$script:ModuleRoot = Join-Path $PSScriptRoot "..\..\modules\ProfileCore"

# Results storage
$results = [System.Collections.Generic.List[object]]::new()

# Function to measure file load time
function Measure-FileLoad {
    param(
        [string]$FilePath,
        [string]$Category
    )
    
    $fileName = Split-Path $FilePath -Leaf
    $time = Measure-Command {
        . $FilePath
    }
    
    [PSCustomObject]@{
        Category = $Category
        FileName = $fileName
        TimeMs = [Math]::Round($time.TotalMilliseconds, 2)
        Path = $FilePath
    }
}

Write-Host "`n📦 Phase 1: Measuring Private Files..." -ForegroundColor Yellow

# Measure private files in order
$privatePath = Join-Path $ModuleRoot "private"
$privateImportOrder = @(
    'OSDetection.ps1',
    'SecretManager.ps1',
    'OSAbstraction.ps1',
    'ServiceContainer.ps1',
    'PerformanceMetrics.ps1',
    'CacheProvider.ps1',
    'LoggingProvider.ps1',
    'ConfigValidator.ps1',
    'PackageManagerProvider.ps1',
    'ConfigurationProvider.ps1',
    'UpdateProvider.ps1',
    'UpdateManager.ps1',
    'ConfigLoader.ps1',
    'CommandHandler.ps1',
    'PluginFramework.ps1',
    'PluginFrameworkV2.ps1',
    'CloudSync.ps1',
    'AdvancedPerformance.ps1'
)

foreach ($fileName in $privateImportOrder) {
    $filePath = Join-Path $privatePath $fileName
    if (Test-Path $filePath) {
        $result = Measure-FileLoad -FilePath $filePath -Category "Private"
        $results.Add($result)
        Write-Host "  ✓ $fileName`: $($result.TimeMs)ms" -ForegroundColor Gray
    }
}

Write-Host "`n📦 Phase 2: Measuring Public Files..." -ForegroundColor Yellow

# Measure public files
$publicPath = Join-Path $ModuleRoot "public"
$publicFiles = Get-ChildItem -Path "$publicPath/*.ps1" -ErrorAction SilentlyContinue

foreach ($file in $publicFiles) {
    $result = Measure-FileLoad -FilePath $file.FullName -Category "Public"
    $results.Add($result)
    Write-Host "  ✓ $($file.Name)`: $($result.TimeMs)ms" -ForegroundColor Gray
}

Write-Host "`n📦 Phase 3: Measuring Full Module Load..." -ForegroundColor Yellow

# Measure full module import (with initialization)
Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
$fullLoadTime = Measure-Command {
    Import-Module "$ModuleRoot\ProfileCore.psd1" -Force -ErrorAction Stop
}

$fullLoadMs = [Math]::Round($fullLoadTime.TotalMilliseconds, 2)
Write-Host "  ✓ Full module load: $fullLoadMs`ms" -ForegroundColor Green

# Calculate totals and overhead
$privateTotal = ($results | Where-Object Category -eq 'Private' | Measure-Object TimeMs -Sum).Sum
$publicTotal = ($results | Where-Object Category -eq 'Public' | Measure-Object TimeMs -Sum).Sum
$filesTotal = $privateTotal + $publicTotal
$initOverhead = $fullLoadMs - $filesTotal

# Summary Statistics
Write-Host "`n" + ("=" * 60) -ForegroundColor Gray
Write-Host "📊 PERFORMANCE SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

Write-Host "`n⏱️  Load Time Breakdown:" -ForegroundColor White
Write-Host "  Private files:        $([Math]::Round($privateTotal, 2))ms ($([Math]::Round($privateTotal/$fullLoadMs*100, 1))%)" -ForegroundColor Gray
Write-Host "  Public files:         $([Math]::Round($publicTotal, 2))ms ($([Math]::Round($publicTotal/$fullLoadMs*100, 1))%)" -ForegroundColor Gray
Write-Host "  Initialization:       $([Math]::Round($initOverhead, 2))ms ($([Math]::Round($initOverhead/$fullLoadMs*100, 1))%)" -ForegroundColor Gray
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
Write-Host "  TOTAL:                $fullLoadMs`ms" -ForegroundColor Cyan

Write-Host "`n📈 File Statistics:" -ForegroundColor White
$privateCount = ($results | Where-Object Category -eq 'Private').Count
$publicCount = ($results | Where-Object Category -eq 'Public').Count
Write-Host "  Private files:        $privateCount files" -ForegroundColor Gray
Write-Host "  Public files:         $publicCount files" -ForegroundColor Gray
Write-Host "  Total files:          $($privateCount + $publicCount) files" -ForegroundColor Gray

# Top 10 slowest files
Write-Host "`n🐌 Top 10 Slowest Files:" -ForegroundColor Red
$slowest = $results | Sort-Object TimeMs -Descending | Select-Object -First 10
foreach ($item in $slowest) {
    $bar = "█" * [Math]::Min([Math]::Ceiling($item.TimeMs / 5), 30)
    Write-Host ("  {0,-30} {1,8}ms {2}" -f $item.FileName, $item.TimeMs, $bar) -ForegroundColor $(
        if ($item.TimeMs -gt 50) { 'Red' }
        elseif ($item.TimeMs -gt 20) { 'Yellow' }
        else { 'Gray' }
    )
}

# Top 10 fastest files
Write-Host "`n🚀 Top 10 Fastest Files:" -ForegroundColor Green
$fastest = $results | Sort-Object TimeMs | Select-Object -First 10
foreach ($item in $fastest) {
    Write-Host ("  {0,-30} {1,8}ms" -f $item.FileName, $item.TimeMs) -ForegroundColor Gray
}

# Optimization recommendations
Write-Host "`n💡 Optimization Recommendations:" -ForegroundColor Cyan

$slowFiles = $results | Where-Object TimeMs -gt 20
$slowFileCount = $slowFiles.Count

if ($slowFileCount -gt 0) {
    Write-Host "  ⚠️  Found $slowFileCount files taking >20ms each" -ForegroundColor Yellow
    Write-Host "  📝 Consider lazy loading for:" -ForegroundColor White
    
    $lazyLoadCandidates = $slowFiles | Sort-Object TimeMs -Descending | Select-Object -First 5
    foreach ($file in $lazyLoadCandidates) {
        Write-Host "     • $($file.FileName) ($($file.TimeMs)ms)" -ForegroundColor Gray
    }
}

$potentialSavings = ($slowFiles | Measure-Object TimeMs -Sum).Sum
if ($potentialSavings -gt 0) {
    Write-Host "`n  💰 Potential savings from lazy loading: ~$([Math]::Round($potentialSavings, 0))ms" -ForegroundColor Green
    $targetTime = $fullLoadMs - $potentialSavings
    Write-Host "  🎯 Target load time: ~$([Math]::Round($targetTime, 0))ms (from $fullLoadMs`ms)" -ForegroundColor Cyan
}

# Category breakdown
Write-Host "`n📊 Load Time by Category:" -ForegroundColor Cyan
$categoryStats = $results | Group-Object Category | ForEach-Object {
    $total = ($_.Group | Measure-Object TimeMs -Sum).Sum
    $avg = ($_.Group | Measure-Object TimeMs -Average).Average
    [PSCustomObject]@{
        Category = $_.Name
        Files = $_.Count
        TotalMs = [Math]::Round($total, 2)
        AvgMs = [Math]::Round($avg, 2)
        Percent = [Math]::Round($total / $fullLoadMs * 100, 1)
    }
} | Sort-Object TotalMs -Descending

$categoryStats | Format-Table -AutoSize

# Export detailed results
$reportPath = Join-Path $PSScriptRoot "..\..\reports\PHASE3_LOAD_PROFILE.json"
$reportData = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalLoadTimeMs = $fullLoadMs
    PrivateFilesMs = $privateTotal
    PublicFilesMs = $publicTotal
    InitializationMs = $initOverhead
    FileCount = $results.Count
    Files = $results | Sort-Object TimeMs -Descending
    CategoryStats = $categoryStats
    Recommendations = @{
        SlowFilesCount = $slowFileCount
        PotentialSavingsMs = [Math]::Round($potentialSavings, 0)
        TargetLoadTimeMs = [Math]::Round($fullLoadMs - $potentialSavings, 0)
        LazyLoadCandidates = ($slowFiles | Sort-Object TimeMs -Descending | Select-Object -First 10 | ForEach-Object { $_.FileName })
    }
}

$reportData | ConvertTo-Json -Depth 5 | Out-File $reportPath -Encoding UTF8
Write-Host "`n💾 Detailed report saved to: $reportPath" -ForegroundColor Green

Write-Host "`n" + ("=" * 60) -ForegroundColor Gray
Write-Host "✅ Profiling complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Gray

# Return summary object
return [PSCustomObject]@{
    TotalLoadTimeMs = $fullLoadMs
    FileResults = $results
    CategoryStats = $categoryStats
    Recommendations = $reportData.Recommendations
}

