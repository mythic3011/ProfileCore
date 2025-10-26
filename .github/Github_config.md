# ProfileCore GitHub Configuration 🔧

**GitHub-specific configuration and automation for ProfileCore**

---

## 📁 Directory Structure

```
.github/
├── workflows/           # GitHub Actions workflows
│   ├── test.yml        # CI/CD test automation
│   └── README.md       # Workflow documentation
└── README.md           # This file
```

---

## 🔄 Workflows

### test.yml - Automated Testing

**Purpose:** Run comprehensive tests on every push and pull request

**Platforms:**

- ✅ Windows (windows-latest)
- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)

**Tests:**

- Unit Tests
- Integration Tests
- E2E Tests
- PSScriptAnalyzer (code quality)

**Learn More:** [workflows/README.md](workflows/README.md)

---

## 🚀 Quick Links

### For Contributors

- **[Test Workflow](workflows/test.yml)** - Automated test suite
- **[Workflow Docs](workflows/README.md)** - CI/CD documentation
- **[Contributing Guide](../docs/development/contributing.md)** - How to contribute

### For Users

- **[Main README](../README.md)** - Project overview
- **[Installation](../INSTALL.md)** - How to install
- **[Quick Start](../QUICK_START.md)** - Get started quickly

---

## 📊 CI/CD Status

### Current Workflows

| Workflow   | Status    | Purpose                |
| ---------- | --------- | ---------------------- |
| Test Suite | ✅ Active | Multi-platform testing |

### Planned Workflows

| Workflow  | Status     | Purpose                  |
| --------- | ---------- | ------------------------ |
| Release   | 📋 Planned | Automated releases       |
| Lint      | 📋 Planned | Dedicated linting        |
| Docs      | 📋 Planned | Documentation generation |
| Benchmark | 📋 Planned | Performance tracking     |
| Security  | 📋 Planned | Security scanning        |

---

## 🛠️ Local Testing

Before pushing changes, run tests locally:

```powershell
# Install dependencies
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force
Install-Module -Name PSScriptAnalyzer -Force

# Run all tests
Invoke-Pester

# Run PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path ./modules/ProfileCore -Recurse -Settings ./config/analyzer-settings.psd1
```

---

## 📝 Adding New Workflows

### 1. Create Workflow File

Create `.github/workflows/your-workflow.yml`:

```yaml
name: Your Workflow

on:
  push:
    branches: [main]

jobs:
  your-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Your Step
        run: echo "Hello!"
```

### 2. Test Locally

```powershell
# Install act (GitHub Actions local runner)
# https://github.com/nektos/act

# Test workflow locally
act -j your-job
```

### 3. Push and Verify

```bash
git add .github/workflows/your-workflow.yml
git commit -m "Add new workflow"
git push
```

---

## 🔍 Debugging Workflows

### View Logs

1. Go to **GitHub Actions** tab
2. Click on workflow run
3. Select failed job
4. Expand failed step
5. Review error messages

### Download Artifacts

```powershell
# Via GitHub UI:
# Actions → Workflow Run → Artifacts → Download

# View test results
$xml = [xml](Get-Content test-results.xml)
$xml.testsuites.testsuite | Format-Table
```

### Re-run Failed Jobs

1. Go to failed workflow run
2. Click "Re-run failed jobs"
3. Or "Re-run all jobs"

---

## 📈 Status Badges

Add workflow status badges to README:

```markdown
![Test Suite](https://github.com/YOUR_USERNAME/ProfileCore/workflows/Test%20ProfileCore/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)
```

---

## 🔒 Security

### Secrets Management

Store sensitive data in GitHub Secrets:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click "New repository secret"
3. Add secret name and value
4. Access in workflow:

```yaml
- name: Use Secret
  env:
    MY_SECRET: ${{ secrets.MY_SECRET }}
  run: echo "Secret is set"
```

### Common Secrets

- `GITHUB_TOKEN` - Automatic (no setup needed)
- `CODECOV_TOKEN` - For coverage reporting
- `NPM_TOKEN` - For package publishing

---

## 🏷️ Issue & PR Templates

### Future Additions

**Issue Templates:**

- Bug report
- Feature request
- Documentation improvement

**PR Template:**

- Description
- Related issues
- Checklist (tests, docs, changelog)

**Location:**

```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
└── pull_request_template.md
```

---

## 🤖 GitHub Apps & Integrations

### Recommended Apps

- **Codecov** - Code coverage
- **Dependabot** - Dependency updates
- **CodeQL** - Security analysis
- **Semantic Release** - Automated releases

### Setup

1. Install app from GitHub Marketplace
2. Grant repository access
3. Configure in workflow or settings

---

## 📚 Resources

### GitHub Actions

- **[GitHub Actions Docs](https://docs.github.com/actions)** - Official documentation
- **[Actions Marketplace](https://github.com/marketplace?type=actions)** - Reusable actions
- **[Workflow Syntax](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions)** - Complete reference

### PowerShell CI/CD

- **[Pester Docs](https://pester.dev)** - Testing framework
- **[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)** - Code analysis
- **[PowerShell Gallery](https://www.powershellgallery.com)** - Module publishing

---

<div align="center">

**ProfileCore GitHub Configuration** - _Automated Quality & CI/CD_

**[🔄 Workflows](workflows/)** • **[📖 Main Docs](../README.md)** • **[🧪 Tests](../tests/README.md)**

</div>
