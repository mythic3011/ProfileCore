# PerformanceMetrics.Tests.ps1
# Unit tests for Performance Metrics system

Describe "PerformanceMetrics" {
    BeforeAll {
        # Import ProfileCore module
        $modulePath = Join-Path $PSScriptRoot "..\..\modules\ProfileCore"
        Import-Module $modulePath -Force
    }
    
    Context "PerformanceMetricsManager" {
        It "Should initialize metrics manager" {
            $metrics = [PerformanceMetricsManager]::new()
            $metrics | Should -Not -BeNullOrEmpty
            $metrics.Enabled | Should -Be $true
        }
        
        It "Should record command execution" {
            $metrics = [PerformanceMetricsManager]::new()
            $metrics.RecordCommandExecution("TestCommand", 100.5)
            
            $metrics.CommandStats.ContainsKey("TestCommand") | Should -Be $true
            $metrics.CommandStats["TestCommand"].ExecutionCount | Should -Be 1
            $metrics.CommandStats["TestCommand"].TotalDuration | Should -Be 100.5
        }
        
        It "Should track cache hits and misses" {
            $metrics = [PerformanceMetricsManager]::new()
            $metrics.RecordCacheHit()
            $metrics.RecordCacheHit()
            $metrics.RecordCacheMiss()
            
            $metrics.CacheHits | Should -Be 2
            $metrics.CacheMisses | Should -Be 1
            $metrics.GetCacheHitRate() | Should -Be 66.67
        }
        
        It "Should increment counters" {
            $metrics = [PerformanceMetricsManager]::new()
            $metrics.IncrementCounter("TestCounter")
            $metrics.IncrementCounter("TestCounter")
            
            $metrics.Counters["TestCounter"] | Should -Be 2
        }
        
        It "Should generate summary" {
            $metrics = [PerformanceMetricsManager]::new()
            $metrics.RecordCommandExecution("Cmd1", 50)
            $metrics.RecordCommandExecution("Cmd2", 75)
            
            $summary = $metrics.GetSummary()
            $summary.TotalCommands | Should -Be 2
            $summary.TotalExecutions | Should -Be 2
        }
    }
    
    Context "Public Functions" {
        It "Get-ProfileCoreMetrics should work" {
            { Get-ProfileCoreMetrics } | Should -Not -Throw
        }
        
        It "Reset-ProfileCoreMetrics should reset counters" {
            if ($global:ProfileCore -and $global:ProfileCore.Metrics) {
                $global:ProfileCore.Metrics.IncrementCounter("Test")
                Reset-ProfileCoreMetrics -Confirm:$false
                $global:ProfileCore.Metrics.Counters["Test"] | Should -Be 0
            }
        }
    }
}

