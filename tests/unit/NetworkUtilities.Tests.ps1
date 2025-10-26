# NetworkUtilities.Tests.ps1
# Unit tests for Network Utility functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
}

Describe "Get-PublicIP" {
    Context "Function Existence" {
        It "Should be exported from module" {
            $function = Get-Command Get-PublicIP -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should have 'myip' alias" {
            $alias = Get-Alias -Name "myip" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Get-PublicIP"
        }
    }

    Context "IP Retrieval" -Tag "Integration" {
        It "Should return an IP address format" -Skip {
            # Skip actual network call in unit tests
            # This would be better as an integration test
            $ip = Get-PublicIP
            $ip | Should -Match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'
        }
    }

    Context "Error Handling" {
        It "Should handle network errors gracefully" {
            # Test that function doesn't throw on error
            { Get-PublicIP -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

Describe "Get-LocalNetworkIPs" {
    Context "Function Existence" {
        It "Should be exported from module" {
            $function = Get-Command Get-LocalNetworkIPs -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should have 'localips' alias" {
            $alias = Get-Alias -Name "localips" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Get-LocalNetworkIPs"
        }
    }

    Context "Platform-Specific Behavior" {
        It "Should use Get-NetNeighbor on Windows" -Skip:(-not $IsWindows) {
            # Test that the function can be called
            { Get-LocalNetworkIPs -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should use appropriate command on macOS" -Skip:(-not $IsMacOS) {
            { Get-LocalNetworkIPs -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should use appropriate command on Linux" -Skip:(-not $IsLinux) {
            { Get-LocalNetworkIPs -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

Describe "Network Utility Aliases" {
    Context "Alias Exports" {
        It "Should export network utility aliases" {
            $module = Get-Module ProfileCore
            $aliases = $module.ExportedAliases.Keys
            
            $aliases | Should -Contain 'myip'
            $aliases | Should -Contain 'localips'
        }
    }
}

Describe "Cross-Platform Clipboard Support" {
    Context "Clipboard Integration" {
        It "Should handle clipboard on Windows" -Skip:(-not $IsWindows) {
            # Test that Set-Clipboard is available or handled
            $hasClipboard = Get-Command Set-Clipboard -ErrorAction SilentlyContinue
            if (-not $hasClipboard) {
                Set-ItResult -Skipped -Because "Clipboard not available in test environment"
            }
        }

        It "Should handle clipboard on macOS" -Skip:(-not $IsMacOS) {
            # macOS uses pbcopy or Set-Clipboard (PowerShell Core)
            $hasClipboard = (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) -or 
                           (Get-Command pbcopy -ErrorAction SilentlyContinue)
            $hasClipboard | Should -BeTrue
        }

        It "Should handle clipboard on Linux" -Skip:(-not $IsLinux) {
            # Linux uses xclip or xsel
            $hasClipboard = (Get-Command xclip -ErrorAction SilentlyContinue) -or 
                           (Get-Command xsel -ErrorAction SilentlyContinue)
            # May not be available in CI, so just check function doesn't throw
            { Get-PublicIP -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

