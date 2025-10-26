# AsyncCommands.Tests.ps1
# Unit tests for Async Commands system

Describe "AsyncCommands" {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot "..\..\modules\ProfileCore"
        Import-Module $modulePath -Force
    }
    
    AfterEach {
        # Clean up any test jobs
        Get-Job -Name "ProfileCore-*" -ErrorAction SilentlyContinue | Remove-Job -Force
    }
    
    Context "Start-ProfileCoreJob" {
        It "Should start a background job" {
            $job = Start-ProfileCoreJob -Name "TestJob" -ScriptBlock { Start-Sleep -Seconds 1; "Done" }
            
            $job | Should -Not -BeNullOrEmpty
            $job.Name | Should -Be "ProfileCore-TestJob"
            $job.State | Should -Be "Running"
        }
        
        It "Should pass arguments to job" {
            $job = Start-ProfileCoreJob -Name "ArgTest" -ScriptBlock {
                param($value)
                return "Value: $value"
            } -ArgumentList "TestValue"
            
            $job | Wait-Job | Out-Null
            $result = Receive-Job $job
            
            $result | Should -Be "Value: TestValue"
        }
    }
    
    Context "Get-ProfileCoreJob" {
        It "Should list ProfileCore jobs" {
            Start-ProfileCoreJob -Name "ListTest" -ScriptBlock { Start-Sleep -Seconds 2 }
            
            $jobs = Get-ProfileCoreJob
            $jobs | Should -Not -BeNullOrEmpty
        }
        
        It "Should get specific job by name" {
            Start-ProfileCoreJob -Name "SpecificTest" -ScriptBlock { Start-Sleep -Seconds 2 }
            
            $job = Get-ProfileCoreJob -Name "SpecificTest"
            $job.Name | Should -Be "ProfileCore-SpecificTest"
        }
    }
    
    Context "Receive-ProfileCoreJob" {
        It "Should receive job results" {
            $job = Start-ProfileCoreJob -Name "ResultTest" -ScriptBlock { "TestResult" }
            $job | Wait-Job | Out-Null
            
            $result = Receive-ProfileCoreJob -Name "ResultTest"
            $result | Should -Be "TestResult"
        }
        
        It "Should wait for job with -Wait" {
            Start-ProfileCoreJob -Name "WaitTest" -ScriptBlock { Start-Sleep -Seconds 1; "Done" }
            
            $result = Receive-ProfileCoreJob -Name "WaitTest" -Wait
            $result | Should -Be "Done"
        }
    }
    
    Context "Stop-ProfileCoreJob" {
        It "Should stop running job" {
            Start-ProfileCoreJob -Name "StopTest" -ScriptBlock { Start-Sleep -Seconds 10 }
            Start-Sleep -Seconds 1  # Let job start
            
            Stop-ProfileCoreJob -Name "StopTest" -Confirm:$false
            
            $job = Get-Job -Name "ProfileCore-StopTest"
            $job.State | Should -Be "Stopped"
        }
    }
    
    Context "Clear-ProfileCoreJobs" {
        It "Should clear completed jobs" {
            Start-ProfileCoreJob -Name "ClearTest1" -ScriptBlock { "Done" }
            Start-Sleep -Seconds 1
            
            Clear-ProfileCoreJobs -Confirm:$false
            
            $jobs = Get-Job -Name "ProfileCore-ClearTest*"
            $jobs | Should -BeNullOrEmpty
        }
    }
}

