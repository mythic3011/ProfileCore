# ProfileCore Tests

This directory contains automated tests for the ProfileCore module.

## 📁 Test Structure

```
Tests/
├── Unit/                           # Unit tests for individual functions
│   ├── OSDetection.Tests.ps1       # OS detection tests
│   ├── ConfigLoader.Tests.ps1      # Configuration loader tests
│   ├── PackageManager.Tests.ps1    # Package management tests (TODO)
│   └── NetworkUtilities.Tests.ps1  # Network utility tests (TODO)
├── Integration/                    # Integration tests
│   ├── ProfileCore.Integration.Tests.ps1  # Module integration tests
│   └── DualShell.Integration.Tests.ps1    # Dual-shell tests (TODO)
├── E2E/                           # End-to-end tests
│   └── ProfileActivation.Tests.ps1 # Profile activation tests (TODO)
└── README.md                       # This file
```

## 🧪 Running Tests

### Run All Tests

```powershell
# Run all tests
Invoke-Pester

# Run tests with detailed output
Invoke-Pester -Output Detailed
```

### Run Specific Test Categories

```powershell
# Run only unit tests
Invoke-Pester -Path ./Tests/Unit

# Run only integration tests
Invoke-Pester -Path ./Tests/Integration

# Run specific test file
Invoke-Pester -Path ./Tests/Unit/OSDetection.Tests.ps1
```

### Generate Coverage Report

```powershell
# Run tests with code coverage
Invoke-Pester -CodeCoverage ./Modules/ProfileCore/**/*.ps1

# Generate HTML coverage report
Invoke-Pester -CodeCoverage ./Modules/ProfileCore/**/*.ps1 -CodeCoverageOutputFile ./coverage.xml
```

## 📊 Test Coverage Goals

| Category              | Current        | Target  |
| --------------------- | -------------- | ------- |
| **Unit Tests**        | 🔨 Building    | 90%     |
| **Integration Tests** | 🔨 Building    | 80%     |
| **E2E Tests**         | 📝 Planned     | 70%     |
| **Overall**           | 🚧 In Progress | **90%** |

## ✅ Current Test Status

### Completed ✅

- [x] OS Detection unit tests
- [x] Config Loader unit tests (basic)
- [x] Module integration tests

### In Progress 🔨

- [ ] Package Manager tests
- [ ] Network Utilities tests
- [ ] Secret Manager tests

### Planned 📝

- [ ] File Operations tests
- [ ] Dual-shell integration tests
- [ ] End-to-end profile activation tests
- [ ] Cross-platform tests on CI/CD

## 🛠️ Test Development Guidelines

### Writing Unit Tests

```powershell
# Template for unit tests
BeforeAll {
    Import-Module $modulePath -Force
}

Describe "FunctionName" {
    Context "When condition A" {
        It "Should do expected behavior" {
            $result = FunctionName -Parameter "value"
            $result | Should -Be "expected"
        }
    }

    Context "Error Handling" {
        It "Should throw on invalid input" {
            { FunctionName -Parameter $null } | Should -Throw
        }
    }
}

AfterAll {
    Remove-Module ProfileCore -Force
}
```

### Writing Integration Tests

```powershell
# Test that multiple components work together
Describe "Feature Integration" {
    Context "End-to-end workflow" {
        It "Should complete full workflow" {
            $step1 = Function1
            $step2 = Function2 $step1
            $step2 | Should -Not -BeNullOrEmpty
        }
    }
}
```

## 🔍 Test Requirements

### Prerequisites

```powershell
# Install Pester
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify Pester version (5.0+)
Get-Module -Name Pester -ListAvailable
```

### Test Environment

- **PowerShell 5.1+** or **PowerShell Core 7+**
- **Pester 5.x** (latest version)
- **PSScriptAnalyzer** (for linting)

## 🎯 Testing Best Practices

### Do's ✅

- **Test one thing** per test
- **Use descriptive names** for tests
- **Test edge cases** and error conditions
- **Clean up** after tests (use AfterEach/AfterAll)
- **Mock external dependencies** when possible
- **Skip tests** that require specific OS (`-Skip:(-not $IsWindows)`)

### Don'ts ❌

- **Don't rely on external state** (network, files)
- **Don't test implementation** details
- **Don't ignore failing** tests
- **Don't skip cleanup**
- **Don't make tests dependent** on each other

## 📈 Continuous Integration

### GitHub Actions Workflow (Planned)

```yaml
name: ProfileCore Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest, macos-latest]
    steps:
      - uses: actions/checkout@v3
      - name: Run Pester Tests
        run: Invoke-Pester -CI
```

## 🐛 Debugging Tests

### Run Tests in Debug Mode

```powershell
# Run with verbose output
Invoke-Pester -Output Detailed -Verbose

# Debug specific test
Invoke-Pester -Path ./Tests/Unit/OSDetection.Tests.ps1 -Output Diagnostic
```

### Troubleshooting

**Issue:** Tests fail with "Module not found"

```powershell
# Solution: Ensure module path is correct
$modulePath = Join-Path $PSScriptRoot "..\..\Modules\ProfileCore"
Import-Module $modulePath -Force
```

**Issue:** Tests fail on different OS

```powershell
# Solution: Use OS-specific skipping
It "Should work on Windows" -Skip:(-not $IsWindows) {
    # Windows-specific test
}
```

## 📚 Additional Resources

- [Pester Documentation](https://pester.dev/docs/quick-start)
- [PowerShell Testing Best Practices](https://docs.microsoft.com/powershell/scripting/developer/testing/overview)
- [Pester Examples](https://github.com/pester/Pester/tree/main/tst)

## 🤝 Contributing Tests

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on contributing tests.

**All contributions welcome!** 🎉

---

**Last Updated:** October 7, 2025  
**Test Framework:** Pester 5.x  
**Target Coverage:** 90%
