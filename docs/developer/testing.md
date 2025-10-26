# ProfileCore Testing Guide

This guide covers how to test ProfileCore and contribute test coverage.

## Testing Framework

ProfileCore uses **Pester 5.x** for all testing. Pester is the industry-standard testing framework for PowerShell.

## Test Structure

```
tests/
├── unit/                    # Unit tests (isolated function testing)
│   ├── AsyncCommands.Tests.ps1
│   ├── CacheProvider.Tests.ps1
│   ├── ConfigLoader.Tests.ps1
│   ├── ... (11 test files)
│   └── SecretManager.Tests.ps1
├── integration/             # Integration tests (component interaction)
│   └── ProfileCore.Integration.Tests.ps1
└── e2e/                     # End-to-end tests (full scenarios)
    └── ProfileActivation.Tests.ps1
```

## Running Tests

### All Tests

```powershell
Invoke-Pester
```

### Specific Test File

```powershell
Invoke-Pester tests/unit/CacheProvider.Tests.ps1
```

### With Coverage

```powershell
Invoke-Pester -CodeCoverage 'modules/ProfileCore/**/*.ps1'
```

### Specific Test

```powershell
Invoke-Pester tests/unit/CacheProvider.Tests.ps1 -TestName "CacheManager"
```

## Writing Tests

### Test File Naming

- Unit tests: `{ModuleName}.Tests.ps1`
- Integration tests: `{Feature}.Integration.Tests.ps1`
- E2E tests: `{Scenario}.Tests.ps1`

### Basic Test Structure

```powershell
BeforeAll {
    # Import module
    Import-Module "$PSScriptRoot/../../modules/ProfileCore/ProfileCore.psd1" -Force
}

Describe "FunctionName" {
    Context "When doing something" {
        It "Should behave correctly" {
            # Arrange
            $input = "test"

            # Act
            $result = Invoke-Function -Input $input

            # Assert
            $result | Should -Be "expected"
        }
    }
}
```

### Mocking External Dependencies

```powershell
BeforeAll {
    # Mock external command
    Mock Invoke-RestMethod {
        return @{ data = "mocked" }
    }
}

It "Should use mocked API" {
    $result = Get-DataFromAPI
    $result.data | Should -Be "mocked"
}
```

### Testing ShouldProcess

```powershell
It "Should support WhatIf" {
    { Update-AllPackages -WhatIf } | Should -Not -Throw
}

It "Should not execute with WhatIf" {
    $result = Update-AllPackages -WhatIf
    # Verify no actual changes were made
}
```

## Test Coverage Goals

- **Unit Tests**: 80%+ coverage
- **Integration Tests**: All major workflows
- **E2E Tests**: Critical user scenarios

### Current Coverage

- Overall: **70%**
- Core Functions: **100%**
- Public Functions: **85%**
- Private Functions: **60%**

## Best Practices

### 1. Arrange-Act-Assert Pattern

```powershell
It "Should do something" {
    # Arrange - Set up test data
    $input = "test"

    # Act - Execute the function
    $result = Invoke-Function $input

    # Assert - Verify results
    $result | Should -Be "expected"
}
```

### 2. Test One Thing

```powershell
# Good - Tests one behavior
It "Should return true for valid input" {
    Test-Input "valid" | Should -Be $true
}

# Bad - Tests multiple behaviors
It "Should validate input and format output" {
    # Too much in one test
}
```

### 3. Use Descriptive Names

```powershell
# Good
It "Should cache DNS results for 15 minutes" {
    # ...
}

# Bad
It "Should work" {
    # ...
}
```

### 4. Isolate Tests

```powershell
BeforeEach {
    # Reset state before each test
    Clear-Cache
}

It "Should start with empty cache" {
    Get-CacheSize | Should -Be 0
}
```

### 5. Test Error Cases

```powershell
It "Should throw when input is null" {
    { Invoke-Function -Input $null } | Should -Throw
}

It "Should handle network errors gracefully" {
    Mock Invoke-RestMethod { throw "Network error" }
    { Get-DataFromAPI } | Should -Not -Throw
}
```

## Common Pester Assertions

```powershell
# Equality
$result | Should -Be $expected
$result | Should -Not -Be $unexpected

# Type checking
$result | Should -BeOfType [string]

# Null/Empty
$result | Should -Not -BeNullOrEmpty
$result | Should -BeNullOrEmpty

# Exceptions
{ Invoke-Function } | Should -Throw
{ Invoke-Function } | Should -Throw "specific error"

# Collections
$array | Should -Contain "item"
$array | Should -HaveCount 5

# File system
"file.txt" | Should -Exist
"file.txt" | Should -FileContentMatch "pattern"

# Mocking
Should -Invoke Invoke-RestMethod -Times 1
Should -Invoke Invoke-RestMethod -ParameterFilter { $Uri -eq "http://api.com" }
```

## Testing Performance

```powershell
Describe "Performance" {
    It "Should complete within 100ms" {
        $time = Measure-Command {
            Invoke-Function
        }
        $time.TotalMilliseconds | Should -BeLessThan 100
    }
}
```

## Testing Cached Operations

```powershell
Describe "Get-DNSInfo Caching" {
    It "Should cache results" {
        # First call
        $result1 = Get-DNSInfo github.com

        # Second call should be cached
        $time = Measure-Command {
            $result2 = Get-DNSInfo github.com
        }

        $time.TotalMilliseconds | Should -BeLessThan 10
        $result2 | Should -Be $result1
    }

    It "Should bypass cache with -NoCache" {
        Mock Resolve-DnsName { return "fresh" }
        $result = Get-DNSInfo github.com -NoCache
        Should -Invoke Resolve-DnsName -Times 1
    }
}
```

## Continuous Integration

Tests should run on:

- Every commit (local)
- Every pull request (CI/CD)
- Before releases (manual)

### Pre-commit Hook

```powershell
# .git/hooks/pre-commit
#!/usr/bin/env pwsh
Invoke-Pester -CI
if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed"
    exit 1
}
```

## Troubleshooting Tests

### Test Fails Locally

1. Ensure Pester 5.x installed: `Install-Module Pester -MinimumVersion 5.0`
2. Import module fresh: `Import-Module ./modules/ProfileCore -Force`
3. Check test isolation: Ensure no shared state
4. Verify mocks: Check mock setup

### Test Passes Locally, Fails in CI

1. Check environment differences
2. Verify external dependencies mocked
3. Check file paths (relative vs absolute)
4. Review timing issues

### Slow Tests

1. Mock external API calls
2. Use in-memory test data
3. Reduce test data size
4. Parallelize where possible

## Contributing Tests

When adding new features:

1. **Write tests first** (TDD approach)
2. **Test happy path** (normal operation)
3. **Test edge cases** (boundaries)
4. **Test error cases** (exceptions)
5. **Test performance** (if critical)

Example PR checklist:

- [ ] Unit tests for new functions
- [ ] Integration tests for workflows
- [ ] E2E tests for user scenarios
- [ ] All tests pass locally
- [ ] Code coverage maintained/improved

---

## Resources

- [Pester Documentation](https://pester.dev/)
- [Pester Quick Start](https://pester.dev/docs/quick-start)
- [PowerShell Testing Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations)

---

**ProfileCore v5.0** - Test-driven development for quality assurance  
[Back to Developer Guide](README.md)
