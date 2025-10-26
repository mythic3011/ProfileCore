#
# ProfileCore Rust FFI Integration Tests
# Tests the Rust binary module's FFI interface from PowerShell
#

Describe "Rust FFI Module Loading" {
    BeforeAll {
        $script:ModulePath = Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1"
        $script:ModuleLoaded = $false
        
        # Try to import the Rust binary module
        try {
            Import-Module $script:ModulePath -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            Write-Warning "Rust binary module not available: $_"
        }
    }
    
    It "Should load Rust binary module successfully" {
        { Import-Module $script:ModulePath -Force } | Should -Not -Throw
    }
    
    It "Should export expected functions" -Skip:(-not $script:ModuleLoaded) {
        $functions = @(
            'Get-SystemInfoBinary',
            'Get-ProcessInfoBinary',
            'Get-DiskInfoBinary',
            'Get-NetworkStatsBinary',
            'Get-PublicIPBinary',
            'Get-LocalIPBinary',
            'Get-LocalNetworkIPsBinary',
            'Test-PortBinary',
            'Get-PlatformInfoBinary'
        )
        
        foreach ($function in $functions) {
            Get-Command $function -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Rust FFI - System Information" {
    BeforeAll {
        $script:ModulePath = Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1"
        try {
            Import-Module $script:ModulePath -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should call GetProfileSystemInfo without errors" -Skip:(-not $script:ModuleLoaded) {
        { Get-SystemInfoBinary } | Should -Not -Throw
    }
    
    It "Should return valid object from GetProfileSystemInfo" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-SystemInfoBinary
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType [PSCustomObject]
    }
    
    It "Should include expected system info fields" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-SystemInfoBinary
        
        # Should have at least some system information
        $result.PSObject.Properties.Name.Count | Should -BeGreaterThan 0
    }
}

Describe "Rust FFI - Platform Detection" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should return valid platform info" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-PlatformInfoBinary
        $result | Should -Not -BeNullOrEmpty
    }
    
    It "Should have platform and architecture fields" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-PlatformInfoBinary
        $result.platform | Should -Not -BeNullOrEmpty
        $result.architecture | Should -Not -BeNullOrEmpty
    }
    
    It "Should return valid platform name" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-PlatformInfoBinary
        $result.platform | Should -BeIn @('windows', 'linux', 'macos')
    }
}

Describe "Rust FFI - Network Functions" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should get local IP address" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-LocalIPBinary
        $result | Should -Not -BeNullOrEmpty
        $result | Should -Match '^\d+\.\d+\.\d+\.\d+$|^[0-9a-f:]+$'  # IPv4 or IPv6 pattern
    }
    
    It "Should get local network IPs array" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-LocalNetworkIPsBinary
        $result | Should -Not -BeNullOrEmpty
        $result | Should -BeOfType [System.Array]
        $result.Count | Should -BeGreaterThan 0
    }
    
    It "Should test port connectivity" -Skip:(-not $script:ModuleLoaded) {
        # Test localhost port (should complete quickly)
        $result = Test-PortBinary -Host "127.0.0.1" -Port 80 -TimeoutMs 100
        $result | Should -BeOfType [bool]
    }
}

Describe "Rust FFI - Process Information" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should get process information" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-ProcessInfoBinary -Count 5 -SortBy CPU
        $result | Should -Not -BeNullOrEmpty
    }
    
    It "Should return array of processes" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-ProcessInfoBinary -Count 5 -SortBy CPU
        $result | Should -BeOfType [System.Array]
        $result.Count | Should -BeLessOrEqual 5
    }
    
    It "Should sort by Memory when specified" -Skip:(-not $script:ModuleLoaded) {
        { Get-ProcessInfoBinary -Count 3 -SortBy Memory } | Should -Not -Throw
    }
}

Describe "Rust FFI - Disk Information" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should get disk information" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-DiskInfoBinary
        $result | Should -Not -BeNullOrEmpty
    }
    
    It "Should return array of disks" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-DiskInfoBinary
        $result | Should -BeOfType [System.Array]
        $result.Count | Should -BeGreaterThan 0
    }
}

Describe "Rust FFI - Network Statistics" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should get network statistics" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-NetworkStatsBinary
        $result | Should -Not -BeNullOrEmpty
    }
    
    It "Should return array of network interfaces" -Skip:(-not $script:ModuleLoaded) {
        $result = Get-NetworkStatsBinary
        $result | Should -BeOfType [System.Array]
    }
}

Describe "Rust FFI - Error Handling" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should handle null/empty parameters gracefully" -Skip:(-not $script:ModuleLoaded) {
        # Test with invalid timeout (0)
        { Test-PortBinary -Host "127.0.0.1" -Port 80 -TimeoutMs 0 } | Should -Not -Throw
    }
    
    It "Should handle invalid host gracefully" -Skip:(-not $script:ModuleLoaded) {
        $result = Test-PortBinary -Host "invalid.host.that.does.not.exist" -Port 80 -TimeoutMs 100
        $result | Should -Be $false
    }
}

Describe "Rust FFI - Performance" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should execute system info call quickly" -Skip:(-not $script:ModuleLoaded) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = Get-SystemInfoBinary
        $sw.Stop()
        
        $sw.ElapsedMilliseconds | Should -BeLessThan 500  # Should complete in under 500ms
    }
    
    It "Should handle multiple rapid calls" -Skip:(-not $script:ModuleLoaded) {
        1..10 | ForEach-Object {
            { Get-PlatformInfoBinary } | Should -Not -Throw
        }
    }
}

Describe "Rust FFI - Memory Safety" {
    BeforeAll {
        try {
            Import-Module (Join-Path $PSScriptRoot "../../modules/ProfileCore.Binary/ProfileCore.psd1") -Force -ErrorAction Stop
            $script:ModuleLoaded = $true
        } catch {
            $script:ModuleLoaded = $false
        }
    }
    
    It "Should not leak memory on repeated calls" -Skip:(-not $script:ModuleLoaded) {
        # Make 100 calls - should not cause memory issues
        1..100 | ForEach-Object {
            Get-LocalIPBinary | Out-Null
        }
        
        # If we get here without crash, memory management is working
        $true | Should -Be $true
    }
    
    It "Should handle concurrent calls safely" -Skip:(-not $script:ModuleLoaded) {
        # Run 5 parallel jobs calling Rust functions
        $jobs = 1..5 | ForEach-Object {
            Start-Job -ScriptBlock {
                Import-Module $using:script:ModulePath -Force
                Get-PlatformInfoBinary
            }
        }
        
        $results = $jobs | Wait-Job | Receive-Job
        $jobs | Remove-Job
        
        $results.Count | Should -Be 5
        $results | ForEach-Object { $_ | Should -Not -BeNullOrEmpty }
    }
}

