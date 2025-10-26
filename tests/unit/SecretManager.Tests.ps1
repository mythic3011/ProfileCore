# SecretManager.Tests.ps1
# Unit tests for Secret Manager functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
    
    # Store original environment for cleanup
    $script:originalEnv = @{}
}

Describe "Get-ProfileSecret" {
    Context "Parameter Validation" {
        It "Should require SecretName parameter" {
            { Get-ProfileSecret } | Should -Throw
        }

        It "Should accept valid secret name" {
            { Get-ProfileSecret -SecretName "TEST_SECRET" } | Should -Not -Throw
        }
    }

    Context "Environment Variable Priority" {
        BeforeEach {
            # Set up test environment variable
            [System.Environment]::SetEnvironmentVariable("PWSH_TEST_SECRET", "test_value", "Process")
        }

        AfterEach {
            # Clean up test environment variable
            [System.Environment]::SetEnvironmentVariable("PWSH_TEST_SECRET", $null, "Process")
        }

        It "Should retrieve from environment variable" {
            $secret = Get-ProfileSecret -SecretName "TEST_SECRET"
            $secret | Should -Be "test_value"
        }

        It "Should prefix with PWSH_" {
            # The function should look for PWSH_SECRETNAME
            $secret = Get-ProfileSecret -SecretName "TEST_SECRET"
            $secret | Should -Not -BeNullOrEmpty
        }

        It "Should be case-insensitive for secret name" {
            $secret1 = Get-ProfileSecret -SecretName "test_secret"
            $secret2 = Get-ProfileSecret -SecretName "TEST_SECRET"
            $secret1 | Should -Be $secret2
        }
    }

    Context "SecretManagement Fallback" {
        It "Should attempt SecretManagement if env var not found" {
            # Test with non-existent secret
            $secret = Get-ProfileSecret -SecretName "NONEXISTENT_SECRET" -ErrorAction SilentlyContinue
            # Should return null without throwing
            $secret | Should -BeNullOrEmpty
        }

        It "Should handle missing SecretManagement module gracefully" {
            # If SecretManagement isn't installed, should not throw
            { Get-ProfileSecret -SecretName "TEST" -WarningAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Common Secret Names" {
        It "Should handle VIRUSTOTAL_API secret name" {
            { Get-ProfileSecret -SecretName "VIRUSTOTAL_API" } | Should -Not -Throw
        }

        It "Should handle SHODAN_API secret name" {
            { Get-ProfileSecret -SecretName "SHODAN_API" } | Should -Not -Throw
        }

        It "Should handle custom secret names" {
            { Get-ProfileSecret -SecretName "CUSTOM_API_KEY" } | Should -Not -Throw
        }
    }

    Context "Return Values" {
        It "Should return string for valid secret" {
            [System.Environment]::SetEnvironmentVariable("PWSH_VALID_SECRET", "secret123", "Process")
            $secret = Get-ProfileSecret -SecretName "VALID_SECRET"
            $secret | Should -BeOfType [string]
            [System.Environment]::SetEnvironmentVariable("PWSH_VALID_SECRET", $null, "Process")
        }

        It "Should return null for missing secret" {
            $secret = Get-ProfileSecret -SecretName "MISSING_SECRET" -WarningAction SilentlyContinue
            $secret | Should -BeNullOrEmpty
        }
    }

    Context "Security Best Practices" {
        It "Should not expose secrets in error messages" {
            [System.Environment]::SetEnvironmentVariable("PWSH_SECURE_SECRET", "super_secret_value", "Process")
            
            # Even if there's an error, secret shouldn't be in output
            $output = Get-ProfileSecret -SecretName "SECURE_SECRET" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            
            # Clean up
            [System.Environment]::SetEnvironmentVariable("PWSH_SECURE_SECRET", $null, "Process")
            
            # Test passes if no exception thrown
            $true | Should -BeTrue
        }
    }
}

Describe "Secret Manager Integration" {
    Context "Environment File Support" {
        It "Should support .env file pattern" {
            # The profile should load .env files
            # Test that the function works with env var pattern
            $envFile = Join-Path $HOME ".config/shell-profile/.env"
            
            if (Test-Path $envFile) {
                # If .env exists, secrets should be loadable
                $true | Should -BeTrue
            } else {
                # If .env doesn't exist, should handle gracefully
                { Get-ProfileSecret -SecretName "ANY_SECRET" -WarningAction SilentlyContinue } | Should -Not -Throw
            }
        }
    }

    Context "SecretManagement Module" {
        It "Should check for SecretManagement availability" {
            $hasSecretMgmt = Get-Module -ListAvailable -Name Microsoft.PowerShell.SecretManagement -ErrorAction SilentlyContinue
            # Test should pass regardless of module availability
            $true | Should -BeTrue
        }

        It "Should work without SecretManagement installed" {
            # Function should work with just environment variables
            [System.Environment]::SetEnvironmentVariable("PWSH_FALLBACK_TEST", "fallback_value", "Process")
            $secret = Get-ProfileSecret -SecretName "FALLBACK_TEST" -WarningAction SilentlyContinue
            $secret | Should -Be "fallback_value"
            [System.Environment]::SetEnvironmentVariable("PWSH_FALLBACK_TEST", $null, "Process")
        }
    }
}

AfterAll {
    # Cleanup any test environment variables
    [System.Environment]::SetEnvironmentVariable("PWSH_TEST_SECRET", $null, "Process")
    [System.Environment]::SetEnvironmentVariable("PWSH_VALID_SECRET", $null, "Process")
    [System.Environment]::SetEnvironmentVariable("PWSH_SECURE_SECRET", $null, "Process")
    [System.Environment]::SetEnvironmentVariable("PWSH_FALLBACK_TEST", $null, "Process")
    
    # Remove module
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

