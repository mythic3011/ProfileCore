# CacheProvider.Tests.ps1
# Unit tests for Cache system

BeforeAll {
    $modulePath = Resolve-Path (Join-Path $PSScriptRoot "..\..\modules\ProfileCore")
    Import-Module $modulePath -Force -ErrorAction Stop
    
    # Ensure classes are loaded by accessing the global ProfileCore object
    if (-not $global:ProfileCore.Cache) {
        throw "ProfileCore Cache system not initialized"
    }
}

Describe "CacheProvider" {
    
    Context "CacheManager" {
        BeforeEach {
            # Clear cache before each test
            $global:ProfileCore.Cache.Clear()
        }
        
        It "Should have cache manager initialized" {
            $global:ProfileCore.Cache | Should -Not -BeNullOrEmpty
            $global:ProfileCore.Cache.Enabled | Should -Be $true
        }
        
        It "Should cache and retrieve values" {
            $global:ProfileCore.Cache.Set("test-key", "test-value", 60)
            
            $value = $global:ProfileCore.Cache.Get("test-key")
            $value | Should -Be "test-value"
        }
        
        It "Should return null for missing keys" {
            $value = $global:ProfileCore.Cache.Get("non-existent")
            $value | Should -BeNullOrEmpty
        }
        
        It "Should expire old entries" {
            $global:ProfileCore.Cache.Set("test-key", "test-value", 0)  # Expires immediately
            Start-Sleep -Milliseconds 100
            
            $value = $global:ProfileCore.Cache.Get("test-key")
            $value | Should -BeNullOrEmpty
        }
        
        It "Should check key existence" {
            $global:ProfileCore.Cache.Set("exists", "value", 60)
            
            $global:ProfileCore.Cache.Has("exists") | Should -Be $true
            $global:ProfileCore.Cache.Has("not-exists") | Should -Be $false
        }
        
        It "Should remove entries" {
            $global:ProfileCore.Cache.Set("remove-me", "value", 60)
            $global:ProfileCore.Cache.Remove("remove-me")
            
            $global:ProfileCore.Cache.Has("remove-me") | Should -Be $false
        }
        
        It "Should clear all entries" {
            $global:ProfileCore.Cache.Set("key1", "value1", 60)
            $global:ProfileCore.Cache.Set("key2", "value2", 60)
            $global:ProfileCore.Cache.Clear()
            
            $global:ProfileCore.Cache.MemoryCache.Count | Should -Be 0
        }
        
        It "Should get cache statistics" {
            $global:ProfileCore.Cache.Set("stat-key", "value", 60)
            
            $stats = $global:ProfileCore.Cache.GetStatistics()
            $stats.MemoryItems | Should -BeGreaterThan 0
        }
    }
    
    Context "Public Functions" {
        It "Get-ProfileCoreCache should work" {
            { Get-ProfileCoreCache -Statistics } | Should -Not -Throw
        }
        
        It "Clear-ProfileCoreCache should work" {
            { Clear-ProfileCoreCache -Confirm:$false } | Should -Not -Throw
        }
    }
}

