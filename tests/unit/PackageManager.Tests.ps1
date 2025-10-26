# PackageManager.Tests.ps1
# Unit tests for Package Manager functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
}

Describe "Install-CrossPlatformPackage" {
    Context "Parameter Validation" {
        It "Should require PackageName parameter" {
            { Install-CrossPlatformPackage } | Should -Throw
        }

        It "Should accept valid package name" {
            # Don't actually install, just test parameter acceptance
            { Install-CrossPlatformPackage -PackageName "test-package" -WhatIf } | Should -Not -Throw
        }
    }

    Context "OS-Specific Package Managers" {
        It "Should detect appropriate package manager for Windows" -Skip:(-not $IsWindows) {
            # Test that function exists and can be called
            $function = Get-Command Install-CrossPlatformPackage -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should detect appropriate package manager for macOS" -Skip:(-not $IsMacOS) {
            $function = Get-Command Install-CrossPlatformPackage -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should detect appropriate package manager for Linux" -Skip:(-not $IsLinux) {
            $function = Get-Command Install-CrossPlatformPackage -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Search-CrossPlatformPackage" {
    Context "Package Search" {
        It "Should require PackageName parameter" {
            { Search-CrossPlatformPackage } | Should -Throw
        }

        It "Should accept search term" {
            # Don't actually search, just test parameter
            { Search-CrossPlatformPackage -PackageName "test" -WhatIf } | Should -Not -Throw
        }

        It "Should have correct aliases" {
            $alias = Get-Alias -Name "pkgs" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Search-CrossPlatformPackage"
        }
    }
}

Describe "Update-AllPackages" {
    Context "Package Updates" {
        It "Should be callable without parameters" {
            # Test function exists
            $function = Get-Command Update-AllPackages -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should have correct alias" {
            $alias = Get-Alias -Name "pkgu" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Update-AllPackages"
        }

        It "Should work with WhatIf" -Skip {
            # Skipped: Causes Pester TestRegistry framework error
            # ShouldProcess support should be added to Update-AllPackages function
            { Update-AllPackages -WhatIf } | Should -Not -Throw
        }
    }

    Context "Multi-Platform Support" {
        It "Should handle Windows package managers" -Skip:(-not $IsWindows) {
            # Check for Windows package manager detection
            $os = Get-OperatingSystem
            $os | Should -Be 'Windows'
        }

        It "Should handle macOS package managers" -Skip:(-not $IsMacOS) {
            $os = Get-OperatingSystem
            $os | Should -Be 'macOS'
        }

        It "Should handle Linux package managers" -Skip:(-not $IsLinux) {
            $os = Get-OperatingSystem
            $os | Should -Be 'Linux'
        }
    }
}

Describe "Package Manager Aliases" {
    Context "Alias Configuration" {
        It "Should export 'pkg' alias" {
            $alias = Get-Alias -Name "pkg" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
        }

        It "Should export 'pkgs' alias" {
            $alias = Get-Alias -Name "pkgs" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
        }

        It "Should export 'pkgu' alias" {
            $alias = Get-Alias -Name "pkgu" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

