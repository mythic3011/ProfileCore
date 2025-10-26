# OSDetection.Tests.ps1
# Unit tests for OS Detection functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
}

Describe "Get-OperatingSystem" {
    Context "OS Detection" {
        It "Should return a valid operating system" {
            $os = Get-OperatingSystem
            $os | Should -BeIn @('Windows', 'macOS', 'Linux', 'Unknown')
        }

        It "Should not return null or empty" {
            $os = Get-OperatingSystem
            $os | Should -Not -BeNullOrEmpty
        }

        It "Should return consistent results" {
            $os1 = Get-OperatingSystem
            $os2 = Get-OperatingSystem
            $os1 | Should -Be $os2
        }
    }
}

Describe "Test-IsWindows" {
    Context "Windows Detection" {
        It "Should return a boolean" {
            $result = Test-IsWindows
            $result | Should -BeOfType [bool]
        }

        It "Should be true on Windows" -Skip:(-not $IsWindows) {
            Test-IsWindows | Should -Be $true
        }

        It "Should be false on non-Windows" -Skip:$IsWindows {
            Test-IsWindows | Should -Be $false
        }
    }
}

Describe "Test-IsMacOS" {
    Context "macOS Detection" {
        It "Should return a boolean" {
            $result = Test-IsMacOS
            $result | Should -BeOfType [bool]
        }

        It "Should be true on macOS" -Skip:(-not $IsMacOS) {
            Test-IsMacOS | Should -Be $true
        }

        It "Should be false on non-macOS" -Skip:$IsMacOS {
            Test-IsMacOS | Should -Be $false
        }
    }
}

Describe "Test-IsLinux" {
    Context "Linux Detection" {
        It "Should return a boolean" {
            $result = Test-IsLinux
            $result | Should -BeOfType [bool]
        }

        It "Should be true on Linux" -Skip:(-not $IsLinux) {
            Test-IsLinux | Should -Be $true
        }

        It "Should be false on non-Linux" -Skip:$IsLinux {
            Test-IsLinux | Should -Be $false
        }
    }
}

AfterAll {
    # Cleanup if needed
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

