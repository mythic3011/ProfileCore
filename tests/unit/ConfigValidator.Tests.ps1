# ConfigValidator.Tests.ps1
# Unit tests for Configuration Validation system

BeforeAll {
    $modulePath = Resolve-Path (Join-Path $PSScriptRoot "..\..\modules\ProfileCore")
    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe "ConfigValidator" {
    
    Context "ValidationRule" -Skip {
        # These tests require direct class access which isn't available in module tests
        # Classes are internal implementation details
        # Public functions are tested in "Public Functions" context
        
        It "Should create validation rule" -Skip {
            Set-ItResult -Skipped -Because "Class testing not supported"
        }
    }
    
    Context "ConfigValidator" -Skip {
        # These tests require direct class access which isn't available in module tests
        # Classes are internal implementation details
        # Public functions are tested in "Public Functions" context
        
        It "Should create config validator" -Skip {
            Set-ItResult -Skipped -Because "Class testing not supported"
        }
    }
    
    Context "Public Functions" {
        It "Test-ProfileCoreConfig should accept valid config" {
            $config = @{
                Update = @{
                    AutoUpdate = $true
                    Schedule = "Weekly"
                }
            }
            
            # Should not throw with valid config
            { Test-ProfileCoreConfig -Config $config } | Should -Not -Throw
        }
        
        It "Test-ProfileCoreConfig should be exported" {
            $command = Get-Command Test-ProfileCoreConfig -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
        
        It "Repair-ProfileCoreConfig should be exported" {
            $command = Get-Command Repair-ProfileCoreConfig -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }
}

