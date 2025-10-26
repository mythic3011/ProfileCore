#!/usr/bin/env pwsh
<#
.SYNOPSIS
    ProfileCore Performance Benchmarking Tool
.DESCRIPTION
    Measures startup times and performance metrics across different shells
.PARAMETER Shell
    Which shell to benchmark (Zsh, Bash, Fish, All)
.PARAMETER Iterations
    Number of iterations to run (default: 10)
.PARAMETER Detailed
    Show detailed per-iteration results
.EXAMPLE
    .\benchmark-performance.ps1 -Shell Zsh
.EXAMPLE
    .\benchmark-performance.ps1 -Shell All -Iterations 20 -Detailed
#>

param(
    [ValidateSet('Zsh', 'Bash', 'Fish', 'PowerShell', 'All')]
    [string]$Shell = 'All',
    [int]$Iterations = 10,
    [switch]$Detailed
)

# ═════════════════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ═════════════════════════════════════════════════════════════════

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Result {
    param(
        [string]$Label,
        [double]$Average,
        [double]$Min,
        [double]$Max,
        [double]$StdDev
    )
    
    Write-Host ""
    Write-Host "  $Label" -ForegroundColor Yellow
    Write-Host "  ├─ Average: $($Average.ToString('F2'))ms" -ForegroundColor White
    Write-Host "  ├─ Min:     $($Min.ToString('F2'))ms" -ForegroundColor Green
    Write-Host "  ├─ Max:     $($Max.ToString('F2'))ms" -ForegroundColor Red
    Write-Host "  └─ StdDev:  $($StdDev.ToString('F2'))ms" -ForegroundColor Gray
}

function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Measure-Statistics {
    param([double[]]$Values)
    
    $avg = ($Values | Measure-Object -Average).Average
    $min = ($Values | Measure-Object -Minimum).Minimum
    $max = ($Values | Measure-Object -Maximum).Maximum
    
    # Calculate standard deviation
    $variance = ($Values | ForEach-Object { [math]::Pow($_ - $avg, 2) } | Measure-Object -Average).Average
    $stdDev = [math]::Sqrt($variance)
    
    return @{
        Average = $avg
        Min = $min
        Max = $max
        StdDev = $stdDev
    }
}

# ═════════════════════════════════════════════════════════════════
#  BENCHMARK FUNCTIONS
# ═════════════════════════════════════════════════════════════════

function Benchmark-Zsh {
    param([int]$Iterations)
    
    if (-not (Test-Command 'zsh')) {
        Write-Host "  ⚠️  Zsh not found - skipping" -ForegroundColor Yellow
        return $null
    }
    
    Write-Host "  🔍 Testing Zsh..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Progress -Activity "Benchmarking Zsh" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
        
        $result = Measure-Command {
            zsh -i -c 'exit' 2>$null
        }
        
        $ms = $result.TotalMilliseconds
        $times += $ms
        
        if ($Detailed) {
            Write-Host "    Iteration $i: $($ms.ToString('F2'))ms" -ForegroundColor Gray
        }
    }
    
    Write-Progress -Activity "Benchmarking Zsh" -Completed
    
    return Measure-Statistics -Values $times
}

function Benchmark-Bash {
    param([int]$Iterations)
    
    if (-not (Test-Command 'bash')) {
        Write-Host "  ⚠️  Bash not found - skipping" -ForegroundColor Yellow
        return $null
    }
    
    Write-Host "  🔍 Testing Bash..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Progress -Activity "Benchmarking Bash" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
        
        $result = Measure-Command {
            bash -i -c 'exit' 2>$null
        }
        
        $ms = $result.TotalMilliseconds
        $times += $ms
        
        if ($Detailed) {
            Write-Host "    Iteration $i: $($ms.ToString('F2'))ms" -ForegroundColor Gray
        }
    }
    
    Write-Progress -Activity "Benchmarking Bash" -Completed
    
    return Measure-Statistics -Values $times
}

function Benchmark-Fish {
    param([int]$Iterations)
    
    if (-not (Test-Command 'fish')) {
        Write-Host "  ⚠️  Fish not found - skipping" -ForegroundColor Yellow
        return $null
    }
    
    Write-Host "  🔍 Testing Fish..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Progress -Activity "Benchmarking Fish" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
        
        $result = Measure-Command {
            fish -i -c 'exit' 2>$null
        }
        
        $ms = $result.TotalMilliseconds
        $times += $ms
        
        if ($Detailed) {
            Write-Host "    Iteration $i: $($ms.ToString('F2'))ms" -ForegroundColor Gray
        }
    }
    
    Write-Progress -Activity "Benchmarking Fish" -Completed
    
    return Measure-Statistics -Values $times
}

function Benchmark-PowerShell {
    param([int]$Iterations)
    
    Write-Host "  🔍 Testing PowerShell..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Progress -Activity "Benchmarking PowerShell" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
        
        $result = Measure-Command {
            pwsh -NoProfile -Command 'exit' 2>$null
        }
        
        $ms = $result.TotalMilliseconds
        $times += $ms
        
        if ($Detailed) {
            Write-Host "    Iteration $i: $($ms.ToString('F2'))ms" -ForegroundColor Gray
        }
    }
    
    Write-Progress -Activity "Benchmarking PowerShell" -Completed
    
    return Measure-Statistics -Values $times
}

# ═════════════════════════════════════════════════════════════════
#  MAIN EXECUTION
# ═════════════════════════════════════════════════════════════════

Write-Header "ProfileCore Performance Benchmark"

Write-Host ""
Write-Host "  Configuration:" -ForegroundColor Yellow
Write-Host "  ├─ Shell(s):    $Shell" -ForegroundColor White
Write-Host "  ├─ Iterations:  $Iterations" -ForegroundColor White
Write-Host "  └─ Detailed:    $Detailed" -ForegroundColor White
Write-Host ""

$results = @{}

# Run benchmarks based on selection
if ($Shell -eq 'All' -or $Shell -eq 'Zsh') {
    $results['Zsh'] = Benchmark-Zsh -Iterations $Iterations
}

if ($Shell -eq 'All' -or $Shell -eq 'Bash') {
    $results['Bash'] = Benchmark-Bash -Iterations $Iterations
}

if ($Shell -eq 'All' -or $Shell -eq 'Fish') {
    $results['Fish'] = Benchmark-Fish -Iterations $Iterations
}

if ($Shell -eq 'All' -or $Shell -eq 'PowerShell') {
    $results['PowerShell'] = Benchmark-PowerShell -Iterations $Iterations
}

# ═════════════════════════════════════════════════════════════════
#  DISPLAY RESULTS
# ═════════════════════════════════════════════════════════════════

Write-Header "Benchmark Results"

foreach ($shellName in $results.Keys | Sort-Object) {
    $stats = $results[$shellName]
    
    if ($null -ne $stats) {
        Write-Result -Label $shellName `
            -Average $stats.Average `
            -Min $stats.Min `
            -Max $stats.Max `
            -StdDev $stats.StdDev
    }
}

# ═════════════════════════════════════════════════════════════════
#  SUMMARY TABLE
# ═════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Summary Table" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$table = @()
foreach ($shellName in $results.Keys | Sort-Object) {
    $stats = $results[$shellName]
    if ($null -ne $stats) {
        $table += [PSCustomObject]@{
            Shell = $shellName
            'Average (ms)' = [math]::Round($stats.Average, 2)
            'Min (ms)' = [math]::Round($stats.Min, 2)
            'Max (ms)' = [math]::Round($stats.Max, 2)
            'StdDev (ms)' = [math]::Round($stats.StdDev, 2)
        }
    }
}

$table | Format-Table -AutoSize

# ═════════════════════════════════════════════════════════════════
#  PERFORMANCE RATING
# ═════════════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Performance Rating" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

foreach ($shellName in $results.Keys | Sort-Object) {
    $stats = $results[$shellName]
    if ($null -ne $stats) {
        $avg = $stats.Average
        
        $rating = if ($avg -lt 50) {
            "⚡ Excellent"
            $color = "Green"
        } elseif ($avg -lt 100) {
            "✅ Good"
            $color = "Green"
        } elseif ($avg -lt 200) {
            "⚠️  Fair"
            $color = "Yellow"
        } else {
            "❌ Slow"
            $color = "Red"
        }
        
        Write-Host "  $shellName: $rating ($($avg.ToString('F2'))ms)" -ForegroundColor $color
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Benchmark Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

