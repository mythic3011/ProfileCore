#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Profiles the main PowerShell profile script to identify performance bottlenecks.

.DESCRIPTION
    This script measures the load time of each initialization phase in Microsoft.PowerShell_profile.ps1
    to identify which components are slowest and should be optimized.

.EXAMPLE
    .\Profile-MainScript.ps1

.NOTES
    ProfileCore Performance Optimization
#>

[CmdletBinding()]
param(
    [int]$Iterations = 10
)

Write-Host "`n🔍 Main Profile Script Performance Profiler" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray

# Results storage
$allResults = [System.Collections.Generic.List[object]]::new()

Write-Host "`n📊 Running $Iterations profiling iterations..." -ForegroundColor Yellow
Write-Host ""

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Progress -Activity "Profiling Profile Script" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
    
    # Start a new PowerShell process with profiling
    $profileScript = @'
$global:ProfileLoadStart = Get-Date
$global:ProgressPreference = 'SilentlyContinue'

# Measure each phase
$phases = @{}

# Phase 1: Environment & Configuration
$phases['Environment'] = Measure-Command {
    $envFile = Join-Path $HOME ".config/shell-profile/.env"
    if (Test-Path $envFile) {
        Get-Content $envFile -ReadCount 0 | 
            Where-Object { $_ -match '^([^=]+)=(.*)$' -and -not $_.StartsWith('#') } | 
            ForEach-Object {
                [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
            }
    }
    
    $configFile = Join-Path $HOME ".config/shell-profile/config.json"
    if (Test-Path $configFile) {
        $global:ProfileConfig = Get-Content $configFile -Raw | ConvertFrom-Json
    }
}

# Phase 2: Module Import
$phases['ModuleImport'] = Measure-Command {
    Import-Module ProfileCore -ErrorAction SilentlyContinue -DisableNameChecking
}

# Phase 3: Performance Features
$phases['PerformanceFeatures'] = Measure-Command {
    if (Get-Command Enable-ConfigCache -ErrorAction SilentlyContinue) {
        Enable-ConfigCache -TimeoutSeconds 600
    }
    if (Get-Command Enable-LazyLoading -ErrorAction SilentlyContinue) {
        Enable-LazyLoading
    }
}

# Phase 4: Command Registry
$global:ProfileCommands = @{
    Categories = [ordered]@{}
    Metadata = @{
        Version = "5.0.0"
        LoadTime = 0
        LastUpdate = (Get-Date).ToString("yyyy-MM-dd")
    }
}

$phases['CommandRegistry'] = Measure-Command {
    # Simulate command registration
    $commands = @(
        'pkg', 'pkg-search', 'pkg-info', 'pkgu',
        'scan-port', 'check-ssl', 'dns-lookup', 'whois-lookup',
        'gen-password', 'check-password', 'check-headers',
        'gqc', 'git-status', 'git-cleanup', 'new-branch',
        'docker-status', 'dc-up', 'dc-down', 'init-project',
        'sysinfo', 'pinfo', 'diskinfo', 'killp', 'connections',
        'myip', 'localips', 'reverse-dns', 'dns-propagation',
        'Open-cd', 'perf', 'optimize', 'clear-cache'
    )
    
    # Check if commands exist (simulates registration overhead)
    foreach ($cmd in $commands) {
        $null = Get-Command "*$cmd*" -ErrorAction SilentlyContinue
    }
}

# Phase 5: Plugin Discovery
$phases['PluginDiscovery'] = Measure-Command {
    $pluginPath = Join-Path $HOME ".config/shell-profile/plugins"
    if (Test-Path $pluginPath) {
        $null = Get-ChildItem -Path $pluginPath -Filter "*.ps1" -ErrorAction SilentlyContinue
    }
}

# Phase 6: PSReadLine
$phases['PSReadLine'] = Measure-Command {
    if (Get-Module -Name PSReadLine) {
        Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -MaximumHistoryCount 5000 -ErrorAction SilentlyContinue
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
    }
}

# Phase 7: Prompt Initialization
$phases['Prompt'] = Measure-Command {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
    }
}

# Total time
$totalTime = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds

# Output results as JSON
$results = @{
    TotalMs = $totalTime
    Phases = @{}
}

foreach ($phase in $phases.Keys) {
    $results.Phases[$phase] = [Math]::Round($phases[$phase].TotalMilliseconds, 2)
}

$results | ConvertTo-Json -Compress
'@

    # Run in clean PowerShell process
    $result = pwsh -NoProfile -Command $profileScript 2>$null | ConvertFrom-Json
    
    if ($result) {
        $allResults.Add($result)
        Write-Host "  Iteration $i`: $([Math]::Round($result.TotalMs, 0))ms" -ForegroundColor Gray
    }
}

Write-Progress -Activity "Profiling Profile Script" -Completed

# Calculate statistics
Write-Host "`n" + ("=" * 70) -ForegroundColor Gray
Write-Host "📊 PROFILING RESULTS" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Gray

# Average times per phase
$avgTotal = ($allResults | ForEach-Object { $_.TotalMs } | Measure-Object -Average).Average
Write-Host "`n⏱️  Average Total Time: $([Math]::Round($avgTotal, 0))ms" -ForegroundColor Cyan

Write-Host "`n📈 Phase Breakdown (Average):" -ForegroundColor White

$phaseNames = $allResults[0].Phases.PSObject.Properties.Name
$phaseStats = @{}

foreach ($phase in $phaseNames) {
    $times = $allResults | ForEach-Object { $_.Phases.$phase }
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    $max = ($times | Measure-Object -Maximum).Maximum
    $percent = ($avg / $avgTotal) * 100
    
    $phaseStats[$phase] = @{
        Average = $avg
        Min = $min
        Max = $max
        Percent = $percent
    }
}

# Sort by average time descending
$sortedPhases = $phaseStats.GetEnumerator() | Sort-Object { $_.Value.Average } -Descending

foreach ($phase in $sortedPhases) {
    $name = $phase.Key
    $stats = $phase.Value
    $bar = "█" * [Math]::Min([Math]::Ceiling($stats.Average / 10), 50)
    
    $color = if ($stats.Average -gt 100) { 'Red' }
              elseif ($stats.Average -gt 50) { 'Yellow' }
              else { 'Green' }
    
    Write-Host ("  {0,-20} {1,7}ms ({2,4}%)  {3}" -f $name, 
        [Math]::Round($stats.Average, 1), 
        [Math]::Round($stats.Percent, 1),
        $bar) -ForegroundColor $color
}

# Top bottlenecks
Write-Host "`n🐌 Top Bottlenecks:" -ForegroundColor Red
$topBottlenecks = $sortedPhases | Select-Object -First 3
foreach ($phase in $topBottlenecks) {
    $name = $phase.Key
    $stats = $phase.Value
    Write-Host "  • $name`: $([Math]::Round($stats.Average, 0))ms" -ForegroundColor Yellow
}

# Optimization recommendations
Write-Host "`n💡 Optimization Recommendations:" -ForegroundColor Cyan

$slowPhases = $sortedPhases | Where-Object { $_.Value.Average -gt 50 }
if ($slowPhases.Count -gt 0) {
    Write-Host "  High-impact optimizations (>50ms):" -ForegroundColor White
    foreach ($phase in $slowPhases) {
        $name = $phase.Key
        $avg = [Math]::Round($phase.Value.Average, 0)
        
        $recommendation = switch ($name) {
            'ModuleImport' { 'Lazy load or use auto-loading' }
            'CommandRegistry' { 'Defer until first Get-Helper call' }
            'PluginDiscovery' { 'Lazy load plugins on first use' }
            'Prompt' { 'Use simpler prompt or defer Starship init' }
            'PSReadLine' { 'Defer configuration to background job' }
            'Environment' { 'Cache parsed config, optimize env loading' }
            'PerformanceFeatures' { 'Defer until needed' }
            default { 'Consider lazy loading or optimization' }
        }
        
        Write-Host "     • $name ($avg`ms): $recommendation" -ForegroundColor Gray
    }
}

# Calculate potential savings
$lazyLoadable = $sortedPhases | Where-Object { 
    $_.Key -in @('CommandRegistry', 'PluginDiscovery', 'PerformanceFeatures') 
}
$potentialSavings = ($lazyLoadable | ForEach-Object { $_.Value.Average } | Measure-Object -Sum).Sum
$targetTime = $avgTotal - $potentialSavings

Write-Host "`n💰 Potential Savings:" -ForegroundColor Green
Write-Host "  Lazy loadable phases: ~$([Math]::Round($potentialSavings, 0))ms" -ForegroundColor White
Write-Host "  Target load time: ~$([Math]::Round($targetTime, 0))ms (from $([Math]::Round($avgTotal, 0))ms)" -ForegroundColor Cyan

# Export detailed results
$reportData = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Iterations = $Iterations
    AverageTotalMs = [Math]::Round($avgTotal, 2)
    PhaseStats = $phaseStats
    Recommendations = @{
        SlowPhases = ($slowPhases | ForEach-Object { $_.Key })
        PotentialSavingsMs = [Math]::Round($potentialSavings, 0)
        TargetLoadTimeMs = [Math]::Round($targetTime, 0)
    }
    AllIterations = $allResults
}

$reportPath = Join-Path $PSScriptRoot "..\..\reports\PROFILE_SCRIPT_ANALYSIS.json"
$reportData | ConvertTo-Json -Depth 5 | Out-File $reportPath -Encoding UTF8
Write-Host "`n💾 Detailed report saved to: $reportPath" -ForegroundColor Green

Write-Host "`n" + ("=" * 70) -ForegroundColor Gray
Write-Host "✅ Profiling complete!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Gray
Write-Host ""

# Return summary
return [PSCustomObject]@{
    AverageTotalMs = $avgTotal
    PhaseStats = $phaseStats
    PotentialSavingsMs = $potentialSavings
    TargetLoadTimeMs = $targetTime
}

