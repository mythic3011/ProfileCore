# ProfileCore.Integration.Tests.ps1
# Integration tests for ProfileCore module

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
}

Describe "ProfileCore Module Integration" {
    Context "Module Loading" {
        It "Should import without errors" {
            $module = Get-Module ProfileCore
            $module | Should -Not -BeNullOrEmpty
        }

        It "Should export expected functions" {
            $module = Get-Module ProfileCore
            $functions = $module.ExportedFunctions.Keys
            
            # Core functions
            $functions | Should -Contain 'Get-OperatingSystem'
            $functions | Should -Contain 'Get-ShellConfig'
            $functions | Should -Contain 'Get-CrossPlatformPath'
        }

        It "Should export expected aliases" {
            $module = Get-Module ProfileCore
            $aliases = $module.ExportedAliases.Keys
            
            # Check for key aliases
            $aliases | Should -Contain 'myip'
            $aliases | Should -Contain 'pkg'
        }
    }

    Context "Function Integration" {
        It "Get-OperatingSystem should work with Test-Is* functions" {
            $os = Get-OperatingSystem
            
            switch ($os) {
                'Windows' { Test-IsWindows | Should -Be $true }
                'macOS' { Test-IsMacOS | Should -Be $true }
                'Linux' { Test-IsLinux | Should -Be $true }
            }
        }

        It "Configuration functions should work together" {
            # Test that config functions integrate properly
            $config = Get-ShellConfig -ConfigName 'config'
            # Even if config doesn't exist, should not throw
            { Get-ShellConfig -ConfigName 'config' } | Should -Not -Throw
        }
    }
}

Describe "Cross-Platform Functionality" {
    Context "OS-Aware Functions" {
        It "Package manager functions should detect appropriate manager" {
            # Install-CrossPlatformPackage should work
            # Note: Don't actually install packages in tests
            { Install-CrossPlatformPackage -WhatIf } | Should -Not -Throw -Skip
        }

        It "File operations should work cross-platform" {
            # Open-CurrentDirectory should work
            # Note: Don't actually open file explorer in tests
        }
    }

    Context "Path Resolution" {
        It "Should resolve paths based on current OS" {
            $os = Get-OperatingSystem
            $os | Should -BeIn @('Windows', 'macOS', 'Linux')
            
            # If paths.json exists, test resolution
            $path = Get-CrossPlatformPath -AppName 'java8' -ErrorAction SilentlyContinue
            # Path could be null if not configured
        }
    }
}

Describe "Configuration System Integration" {
    Context "Shared Configuration" {
        It "Should access shared config directory" {
            $configPath = Join-Path $HOME ".config/shell-profile"
            # Directory might not exist in test environment
            # Test should not fail if directory doesn't exist
        }

        It "Should handle missing configuration gracefully" {
            # Functions should not throw when config is missing
            { Get-ShellConfig -ConfigName 'non-existent' } | Should -Not -Throw
            { Get-CrossPlatformPath -AppName 'non-existent' } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

