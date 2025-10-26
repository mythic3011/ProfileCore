# LoggingProvider.Tests.ps1
# Unit tests for Logging system

BeforeAll {
    $modulePath = Resolve-Path (Join-Path $PSScriptRoot "..\..\modules\ProfileCore")
    Import-Module $modulePath -Force -ErrorAction Stop
    
    # Ensure logger is initialized
    if (-not $global:ProfileCore.Logger) {
        Write-Warning "Logger system not initialized"
    }
}

Describe "LoggingProvider" {
    
    Context "LogManager" -Skip {
        # These tests require direct class access which isn't available in module tests
        # Classes are internal implementation details
        # Public functions are tested in "Public Functions" context
        
        It "Should create log manager" -Skip {
            Set-ItResult -Skipped -Because "Class testing not supported"
        }
    }
    
    Context "ConsoleLogger" -Skip {
        # These tests require direct class access which isn't available in module tests
        # Classes are internal implementation details
        
        It "Should create console logger" -Skip {
            Set-ItResult -Skipped -Because "Class testing not supported"
        }
    }
    
    Context "FileLogger" -Skip {
        # These tests require direct class access which isn't available in module tests
        # Classes are internal implementation details
        
        It "Should create file logger" -Skip {
            Set-ItResult -Skipped -Because "Class testing not supported"
        }
    }
    
    Context "Public Functions" {
        It "Set-ProfileCoreLogLevel should be exported" {
            $command = Get-Command Set-ProfileCoreLogLevel -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Enable-ProfileCoreDebugLogging should be exported" {
            $command = Get-Command Enable-ProfileCoreDebugLogging -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Get-ProfileCoreLogs should be exported" {
            $command = Get-Command Get-ProfileCoreLogs -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Clear-ProfileCoreLogs should be exported" {
            $command = Get-Command Clear-ProfileCoreLogs -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Add-ProfileCoreFileLogger should be exported" {
            $command = Get-Command Add-ProfileCoreFileLogger -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Enable-ProfileCoreDebugLogging should work" {
            { Enable-ProfileCoreDebugLogging -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

