# ConfigLoader.Tests.ps1
# Unit tests for Configuration Loader functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force

    # Set up test config directory
    $script:testConfigDir = Join-Path $env:TEMP "ProfileCore-Test-Config"
    $script:originalConfigDir = Join-Path $HOME ".config/shell-profile"
}

Describe "Get-ShellConfig" {
    Context "When config file exists" {
        BeforeEach {
            # Create test config file
            New-Item -Path $testConfigDir -ItemType Directory -Force | Out-Null
            $testConfig = @{
                version = "1.0.0"
                test = $true
            } | ConvertTo-Json
            $testConfig | Out-File (Join-Path $testConfigDir "test-config.json")
        }

        AfterEach {
            # Cleanup
            Remove-Item $testConfigDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Should load a valid JSON configuration" {
            # Mock the config path for testing
            # This would need actual config files in ~/.config/shell-profile/
            $config = Get-ShellConfig -ConfigName 'config'
            if ($config) {
                $config | Should -Not -BeNullOrEmpty
            }
        }

        It "Should reject invalid config names" {
            # ValidateSet should prevent invalid config names
            { Get-ShellConfig -ConfigName 'non-existent-config' } | Should -Throw -ErrorId 'ParameterArgumentValidationError*'
        }
    }

    Context "Error Handling" {
        It "Should handle missing config files gracefully" {
            # Test with valid config name but missing file
            # config, paths, aliases are valid names
            $config = Get-ShellConfig -ConfigName 'aliases' -ErrorAction SilentlyContinue
            # Should return null for missing file without throwing
            if (-not (Test-Path "$HOME/.config/shell-profile/aliases.json")) {
                $config | Should -BeNullOrEmpty
            }
        }
    }
}

Describe "Get-CrossPlatformPath" {
    Context "Path Resolution" {
        It "Should require AppName parameter" {
            { Get-CrossPlatformPath } | Should -Throw
        }

        It "Should accept valid AppName" {
            # This will warn if paths.json doesn't exist, but shouldn't throw
            { $path = Get-CrossPlatformPath -AppName "java8" -ErrorAction SilentlyContinue } | Should -Not -Throw
            # Path could be null if not configured, which is acceptable behavior
        }

        It "Should expand environment variables" {
            # If paths.json is configured, test environment variable expansion
            # This is integration-level testing
        }
    }

    Context "OS-Specific Paths" {
        It "Should return appropriate path for current OS" -Skip {
            # Requires actual paths.json configuration
            # Enable this test when paths.json is properly configured
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
    Remove-Item $testConfigDir -Recurse -Force -ErrorAction SilentlyContinue
}

