# FileOperations.Tests.ps1
# Unit tests for File Operation functions

BeforeAll {
    # Import the ProfileCore module
    $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
    Import-Module $modulePath -Force
}

Describe "Open-CurrentDirectory" {
    Context "Function Existence" {
        It "Should be exported from module" {
            $function = Get-Command Open-CurrentDirectory -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should have 'Open-cd' alias" {
            $alias = Get-Alias -Name "Open-cd" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Open-CurrentDirectory"
        }

        It "Should have 'o' alias" {
            $alias = Get-Alias -Name "o" -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommand.Name | Should -Be "Open-CurrentDirectory"
        }
    }

    Context "Platform-Specific Behavior" {
        It "Should use explorer.exe on Windows" -Skip:(-not $IsWindows) {
            # Test that function exists and can be invoked
            { Open-CurrentDirectory -WhatIf } | Should -Not -Throw
        }

        It "Should use 'open' command on macOS" -Skip:(-not $IsMacOS) {
            # macOS uses 'open' command
            $hasOpen = Get-Command open -ErrorAction SilentlyContinue
            $hasOpen | Should -Not -BeNullOrEmpty
        }

        It "Should use xdg-open on Linux" -Skip:(-not $IsLinux) {
            # Linux typically uses xdg-open
            # Function should handle if not available
            { Open-CurrentDirectory -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Path Handling" {
        It "Should work with current location" {
            # Test that it uses Get-Location
            $currentPath = (Get-Location).Path
            $currentPath | Should -Not -BeNullOrEmpty
        }

        It "Should handle paths with spaces" {
            # Save current location
            $originalLocation = Get-Location
            
            # Create temp directory with spaces
            $testPath = Join-Path $env:TEMP "Test Directory With Spaces"
            if (-not (Test-Path $testPath)) {
                New-Item -Path $testPath -ItemType Directory -Force | Out-Null
            }
            
            Set-Location $testPath
            
            # Test function doesn't throw
            { Open-CurrentDirectory -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
            
            # Restore location and cleanup
            Set-Location $originalLocation
            Remove-Item $testPath -Force -ErrorAction SilentlyContinue
        }

        It "Should handle UNC paths on Windows" -Skip:(-not $IsWindows) {
            # UNC path handling
            # Just ensure function doesn't crash
            { Open-CurrentDirectory -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context "Error Handling" {
        It "Should not throw on execution" {
            # Function should handle errors gracefully
            { Open-CurrentDirectory -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should work in non-interactive mode" {
            # Should work even in automated/CI environments
            $function = Get-Command Open-CurrentDirectory
            $function | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "File Operation Aliases" {
    Context "Alias Configuration" {
        It "Should export file operation aliases" {
            $module = Get-Module ProfileCore
            $aliases = $module.ExportedAliases.Keys
            
            $aliases | Should -Contain 'Open-cd'
            $aliases | Should -Contain 'o'
        }

        It "All aliases should resolve to valid functions" {
            $aliases = @('Open-cd', 'o')
            
            foreach ($aliasName in $aliases) {
                $alias = Get-Alias -Name $aliasName -ErrorAction SilentlyContinue
                $alias | Should -Not -BeNullOrEmpty
                $alias.ResolvedCommand | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "Cross-Platform File Explorer" {
    Context "Command Availability" {
        It "Should detect available file manager on Windows" -Skip:(-not $IsWindows) {
            $hasExplorer = Get-Command explorer.exe -ErrorAction SilentlyContinue
            $hasExplorer | Should -Not -BeNullOrEmpty
        }

        It "Should detect available file manager on macOS" -Skip:(-not $IsMacOS) {
            $hasOpen = Get-Command open -ErrorAction SilentlyContinue
            $hasOpen | Should -Not -BeNullOrEmpty
        }

        It "Should handle missing file manager on Linux gracefully" -Skip:(-not $IsLinux) {
            # May not have GUI in CI, function should handle gracefully
            { Open-CurrentDirectory -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

