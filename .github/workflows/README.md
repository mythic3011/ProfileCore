# ProfileCore CI/CD Workflows 🔄

**Automated testing and quality assurance for ProfileCore**

---

## 📦 Workflows

### test.yml - Test Suite

**Triggers:**

- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual dispatch

**Platforms:**

- ✅ Windows (windows-latest)
- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)

**Test Coverage:**

- Unit Tests
- Integration Tests
- E2E Tests
- PSScriptAnalyzer linting

---

## 🔍 Test Jobs

### 1. test-windows

**Full test suite on Windows:**

```yaml
Steps: 1. Checkout repository
  2. Setup PowerShell modules (Pester, PSScriptAnalyzer)
  3. Display PowerShell version
  4. Import ProfileCore module
  5. Run PSScriptAnalyzer (code quality)
  6. Run Unit Tests
  7. Run Integration Tests
  8. Run E2E Tests
  9. Upload test results
```

**Special Features:**

- Runs PSScriptAnalyzer with custom settings
- Fails on any analyzer issues
- Generates NUnit XML test results

### 2. test-linux

**Cross-platform validation on Linux:**

```yaml
Steps: 1. Checkout repository
  2. Setup PowerShell modules
  3. Display PowerShell version
  4. Import ProfileCore module
  5. Run Unit Tests
  6. Upload test results
```

**Purpose:**

- Verify Linux compatibility
- Test cross-platform features
- Validate OS detection logic

### 3. test-macos

**Cross-platform validation on macOS:**

```yaml
Steps: 1. Checkout repository
  2. Setup PowerShell modules
  3. Display PowerShell version
  4. Import ProfileCore module
  5. Run Unit Tests
  6. Upload test results
```

**Purpose:**

- Verify macOS compatibility
- Test Zsh integration
- Validate shell detection

### 4. publish-results

**Aggregate and publish test results:**

```yaml
Dependencies: All test jobs
Steps: 1. Download all test results
  2. Publish unified test report
```

**Outputs:**

- Combined test report
- Pass/fail statistics
- Test coverage metrics

---

## 📊 Test Results

### Artifacts

All test jobs upload artifacts:

| Artifact               | Content                    | Retention |
| ---------------------- | -------------------------- | --------- |
| `test-results-windows` | Windows test results (XML) | 30 days   |
| `test-results-linux`   | Linux test results (XML)   | 30 days   |
| `test-results-macos`   | macOS test results (XML)   | 30 days   |

### Test Reports

Published using `EnricoMi/publish-unit-test-result-action@v2`:

- ✅ Detailed pass/fail statistics
- ✅ Test duration metrics
- ✅ Failure details
- ✅ Historical trends

---

## 🛠️ Local Testing

### Run Tests Locally

```powershell
# Install dependencies
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force
Install-Module -Name PSScriptAnalyzer -Force

# Run all tests
Invoke-Pester

# Run specific test suite
Invoke-Pester -Path ./tests/unit

# Run with code coverage
$config = New-PesterConfiguration
$config.Run.Path = './tests'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = './modules/ProfileCore'
Invoke-Pester -Configuration $config
```

### Run PSScriptAnalyzer

```powershell
# Analyze all code
Invoke-ScriptAnalyzer -Path ./modules/ProfileCore -Recurse -Settings ./config/analyzer-settings.psd1

# Fix auto-fixable issues
Invoke-ScriptAnalyzer -Path ./modules/ProfileCore -Recurse -Fix
```

---

## 🔧 Configuration

### Pester Configuration

```powershell
$config = New-PesterConfiguration
$config.Run.Path = './tests/unit'
$config.Run.Exit = $true
$config.Output.Verbosity = 'Detailed'
$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = './test-results.xml'
$config.TestResult.OutputFormat = 'NUnitXml'
```

### PSScriptAnalyzer Settings

Located in: `config/analyzer-settings.psd1`

**Rules:**

- PSAvoidUsingCmdletAliases
- PSAvoidUsingPositionalParameters
- PSUseDeclaredVarsMoreThanAssignments
- PSAvoidUsingConvertToSecureStringWithPlainText
- And more...

---

## 📈 Quality Gates

### Required Checks

All PRs must pass:

- ✅ All unit tests (Windows, Linux, macOS)
- ✅ All integration tests
- ✅ All E2E tests
- ✅ PSScriptAnalyzer (0 errors)
- ✅ Module imports successfully

### Performance Benchmarks

Tests include performance validation:

- Startup time < 1000ms
- Memory usage < 25MB
- Config load < 50ms

---

## 🚀 Adding New Workflows

### Create New Workflow

```yaml
name: My Workflow

on:
  push:
    branches: [main]

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: My Step
        run: echo "Hello!"
```

### Best Practices

1. **Always use `actions/checkout@v4`** (latest version)
2. **Set explicit PowerShell version** if needed
3. **Upload artifacts** for debugging
4. **Use matrix builds** for multiple versions
5. **Add `workflow_dispatch`** for manual runs
6. **Set appropriate timeouts**

---

## 🔍 Debugging Failed Tests

### Check Logs

1. Go to GitHub Actions tab
2. Click on failed workflow run
3. Select failed job
4. Expand failed step
5. Review error messages

### Download Artifacts

```powershell
# Via GitHub UI
Actions → Workflow Run → Artifacts → Download

# View test results
$xml = [xml](Get-Content test-results.xml)
$xml.testsuites.testsuite
```

### Run Locally

```powershell
# Replicate CI environment
$config = New-PesterConfiguration
$config.Run.Path = './tests/unit'
$config.Run.Exit = $true
$config.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $config
```

---

## 📋 Workflow Status

### Badges

Add to README.md:

```markdown
![Tests](https://github.com/YOUR_USERNAME/ProfileCore/workflows/Test%20ProfileCore/badge.svg)
```

### Status Checks

Required status checks for PRs:

- `test-windows`
- `test-linux`
- `test-macos`

---

## 🔮 Future Enhancements

### Planned Workflows

- **release.yml** - Automated releases
- **lint.yml** - Dedicated linting
- **docs.yml** - Documentation generation
- **benchmark.yml** - Performance tracking
- **security.yml** - Security scanning

### Improvements

- Add code coverage reporting
- Performance regression detection
- Automated changelog generation
- Dependency update automation
- Security vulnerability scanning

---

<div align="center">

**ProfileCore CI/CD** - _Automated Quality Assurance_

**[📖 Main Docs](../../README.md)** • **[🧪 Tests](../../tests/README.md)**

</div>
