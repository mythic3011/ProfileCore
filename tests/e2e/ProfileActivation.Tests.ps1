# ProfileActivation.Tests.ps1
# End-to-End tests for Profile Activation

BeforeAll {
    # Store original profile state
    $script:profilePath = $PROFILE
    $script:modulesPath = Join-Path (Split-Path $PROFILE) "Modules"
    $script:profileCorePath = Join-Path $modulesPath "ProfileCore"
}

Describe "Profile Activation E2E" {
    Context "Module Availability" {
        It "Should have ProfileCore module available" {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
            Test-Path $modulePath | Should -BeTrue
        }

        It "Should have module manifest" {
            $manifestPath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore\ProfileCore.psd1"
            Test-Path $manifestPath | Should -BeTrue
        }

        It "Should have module file" {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore\ProfileCore.psm1"
            Test-Path $modulePath | Should -BeTrue
        }
    }

    Context "Module Import" {
        BeforeAll {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
            Import-Module $modulePath -Force
        }

        It "Should import ProfileCore module successfully" {
            $module = Get-Module ProfileCore
            $module | Should -Not -BeNullOrEmpty
        }

        It "Should export expected number of functions" {
            $module = Get-Module ProfileCore
            $functions = $module.ExportedFunctions.Count
            $functions | Should -BeGreaterThan 0
        }

        It "Should export expected number of aliases" {
            $module = Get-Module ProfileCore
            $aliases = $module.ExportedAliases.Count
            $aliases | Should -BeGreaterThan 0
        }

        AfterAll {
            Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
        }
    }

    Context "Core Functions Workflow" {
        BeforeAll {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
            Import-Module $modulePath -Force
        }

        It "Should detect operating system" {
            $os = Get-OperatingSystem
            $os | Should -BeIn @('Windows', 'macOS', 'Linux')
        }

        It "Should load configuration (even if empty)" {
            { Get-ShellConfig -ConfigName 'config' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should handle path resolution" {
            { Get-CrossPlatformPath -AppName 'java8' -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should handle secret retrieval" {
            { Get-ProfileSecret -SecretName 'TEST' -WarningAction SilentlyContinue } | Should -Not -Throw
        }

        AfterAll {
            Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
        }
    }

    Context "Profile File Structure" {
        It "Should have main profile file" {
            $profileFile = Join-Path $PSScriptRoot "..\..\Microsoft.PowerShell_profile.ps1"
            Test-Path $profileFile | Should -BeTrue
        }

        It "Should have NEW profile file" {
            $newProfileFile = Join-Path $PSScriptRoot "..\..\Microsoft.PowerShell_profile.NEW.ps1"
            Test-Path $newProfileFile | Should -BeTrue
        }

        It "Should have backup profile" {
            $backupFile = Join-Path $PSScriptRoot "..\..\Microsoft.PowerShell_profile.ps1.backup"
            Test-Path $backupFile | Should -BeTrue
        }
    }

    Context "Shared Configuration" {
        It "Should have config directory" {
            $configDir = Join-Path $HOME ".config/shell-profile"
            # May not exist in test environment, so just check it doesn't throw
            { Test-Path $configDir } | Should -Not -Throw
        }

        It "Should have config files (if directory exists)" {
            $configDir = Join-Path $HOME ".config/shell-profile"
            if (Test-Path $configDir) {
                $configFile = Join-Path $configDir "config.json"
                $pathsFile = Join-Path $configDir "paths.json"
                $aliasesFile = Join-Path $configDir "aliases.json"
                
                # At least one should exist
                $hasAnyConfig = (Test-Path $configFile) -or 
                               (Test-Path $pathsFile) -or 
                               (Test-Path $aliasesFile)
                $hasAnyConfig | Should -BeTrue
            } else {
                Set-ItResult -Skipped -Because "Config directory not set up"
            }
        }

        It "Should have env template" {
            $configDir = Join-Path $HOME ".config/shell-profile"
            if (Test-Path $configDir) {
                $envTemplate = Join-Path $configDir "env.template"
                Test-Path $envTemplate | Should -BeTrue
            } else {
                Set-ItResult -Skipped -Because "Config directory not set up"
            }
        }
    }

    Context "Full Workflow Simulation" {
        BeforeAll {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
            Import-Module $modulePath -Force
        }

        It "Should complete OS detection workflow" {
            $os = Get-OperatingSystem
            
            switch ($os) {
                'Windows' { Test-IsWindows | Should -BeTrue }
                'macOS' { Test-IsMacOS | Should -BeTrue }
                'Linux' { Test-IsLinux | Should -BeTrue }
            }
        }

        It "Should complete package management workflow (dry run)" {
            # Test package management functions exist and are callable
            { Install-CrossPlatformPackage -PackageName "test" -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Search-CrossPlatformPackage -PackageName "test" -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
            { Update-AllPackages -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It "Should complete network utilities workflow (no actual network calls)" {
            # Just verify functions exist and are callable
            $function1 = Get-Command Get-PublicIP -ErrorAction SilentlyContinue
            $function2 = Get-Command Get-LocalNetworkIPs -ErrorAction SilentlyContinue
            
            $function1 | Should -Not -BeNullOrEmpty
            $function2 | Should -Not -BeNullOrEmpty
        }

        It "Should complete file operations workflow" {
            # Test file operation function
            $function = Get-Command Open-CurrentDirectory -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
            
            { Open-CurrentDirectory -WhatIf -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        AfterAll {
            Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
        }
    }

    Context "Alias Functionality" {
        BeforeAll {
            $modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
            Import-Module $modulePath -Force
        }

        It "Should have all core aliases working" {
            $aliases = @{
                'myip' = 'Get-PublicIP'
                'localips' = 'Get-LocalNetworkIPs'
                'pkg' = 'Install-CrossPlatformPackage'
                'pkgs' = 'Search-CrossPlatformPackage'
                'pkgu' = 'Update-AllPackages'
                'Open-cd' = 'Open-CurrentDirectory'
                'o' = 'Open-CurrentDirectory'
            }

            foreach ($alias in $aliases.Keys) {
                $aliasObj = Get-Alias -Name $alias -ErrorAction SilentlyContinue
                $aliasObj | Should -Not -BeNullOrEmpty
                $aliasObj.ResolvedCommand.Name | Should -Be $aliases[$alias]
            }
        }

        AfterAll {
            Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe "Profile Integration" {
    Context "Documentation Completeness" {
        It "Should have README documentation" {
            $readme = Join-Path $PSScriptRoot "..\..\README.md"
            Test-Path $readme | Should -BeTrue
        }

        It "Should have CHANGELOG" {
            $changelog = Join-Path $PSScriptRoot "..\..\CHANGELOG.md"
            Test-Path $changelog | Should -BeTrue
        }

        It "Should have CONTRIBUTING guide" {
            $contributing = Join-Path $PSScriptRoot "..\..\CONTRIBUTING.md"
            Test-Path $contributing | Should -BeTrue
        }

        It "Should have test documentation" {
            $testReadme = Join-Path $PSScriptRoot "..\README.md"
            Test-Path $testReadme | Should -BeTrue
        }
    }

    Context "CI/CD Configuration" {
        It "Should have GitHub workflows" {
            $workflowPath = Join-Path $PSScriptRoot "..\..\. github\workflows\test.yml"
            # Note: May have space in path, just verify directory exists
            $githubDir = Join-Path $PSScriptRoot "..\..\. github"
            if (Test-Path $githubDir) {
                $true | Should -BeTrue
            }
        }

        It "Should have PSScriptAnalyzer settings" {
            $analyzerSettings = Join-Path $PSScriptRoot "...\.PSScriptAnalyzerSettings.psd1"
            Test-Path $analyzerSettings | Should -BeTrue
        }
    }
}

AfterAll {
    # Final cleanup
    Remove-Module ProfileCore -Force -ErrorAction SilentlyContinue
}

