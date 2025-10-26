# Contributing to ProfileCore

First off, thank you for considering contributing to ProfileCore! It's people like you that make ProfileCore such a great tool.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)

---

## 🤝 Code of Conduct

### Our Pledge

We pledge to make participation in ProfileCore a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behavior includes:**

- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**

- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## 🚀 How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**

- Check the [existing issues](../../issues) to avoid duplicates
- Collect information about the bug:
  - OS and version (Windows, macOS, Linux)
  - Shell and version (PowerShell, Zsh, etc.)
  - ProfileCore version
  - Steps to reproduce
  - Expected vs actual behavior

**Bug Report Template:**

```markdown
## Bug Description

[Clear description of the bug]

## Environment

- OS: Windows 11 / macOS 14 / Ubuntu 22.04
- Shell: PowerShell 7.4 / Zsh 5.9
- ProfileCore Version: 2.0.0

## Steps to Reproduce

1. Step one
2. Step two
3. Step three

## Expected Behavior

[What should happen]

## Actual Behavior

[What actually happens]

## Additional Context

[Screenshots, error messages, etc.]
```

### Suggesting Enhancements

We love feature suggestions! To suggest an enhancement:

1. **Check existing feature requests** in [issues](../../issues)
2. **Open a new issue** with the `enhancement` label
3. **Describe the feature** clearly
4. **Explain why it's useful** to ProfileCore users
5. **Provide examples** of how it would work

**Feature Request Template:**

```markdown
## Feature Description

[Clear description of the feature]

## Use Case

[Why is this feature needed?]

## Proposed Solution

[How should this feature work?]

## Alternatives Considered

[Other approaches you've thought about]

## Additional Context

[Mockups, examples, related features]
```

### Your First Code Contribution

Unsure where to start? Look for issues labeled:

- `good first issue` - Simple issues perfect for beginners
- `help wanted` - Issues where we need community help
- `documentation` - Documentation improvements

---

## 🛠️ Development Setup

### Prerequisites

**PowerShell Development:**

- PowerShell 5.1+ or PowerShell Core 7+
- Pester module (for testing)
- PSScriptAnalyzer (for linting)

**Zsh Development:**

- Zsh 5.0+
- jq (for JSON parsing)
- shunit2 (for testing)

### Setup Steps

1. **Fork the Repository**

   ```bash
   # Fork via GitHub UI, then clone
   git clone https://github.com/YOUR_USERNAME/ProfileCore.git
   cd ProfileCore
   ```

2. **Create Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install Development Dependencies**

   ```powershell
   # PowerShell
   Install-Module Pester -Force
   Install-Module PSScriptAnalyzer -Force
   ```

   ```bash
   # macOS/Linux
   brew install jq shunit2
   ```

4. **Set Up Development Environment**
   ```powershell
   # Load ProfileCore for testing
   Import-Module ./Modules/ProfileCore -Force
   ```

---

## 📝 Coding Standards

### PowerShell

**Follow PowerShell Best Practices:**

- Use approved verbs (`Get-`, `Set-`, `New-`, etc.)
- Include comment-based help for all functions
- Use proper error handling (`try/catch`, `-ErrorAction`)
- Follow naming conventions (PascalCase for functions)
- Add parameter validation

**Example Function:**

```powershell
function Get-Example {
    <#
    .SYNOPSIS
        Brief description
    .DESCRIPTION
        Detailed description
    .PARAMETER Name
        Parameter description
    .EXAMPLE
        Get-Example -Name "test"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    try {
        # Implementation
        Write-Verbose "Processing: $Name"

        # Return value
        return $result
    }
    catch {
        Write-Error "Failed to process: $_"
        throw
    }
}
```

### Zsh

**Follow Zsh Best Practices:**

- Use lowercase with underscores for functions
- Add usage comments for all functions
- Handle errors gracefully
- Use local variables in functions
- Check for required commands

**Example Function:**

```bash
#!/usr/bin/env zsh
# Description: Brief description of the function

function_name() {
    local param="$1"

    # Validate input
    if [[ -z "$param" ]]; then
        echo "Error: Parameter required"
        return 1
    fi

    # Check dependencies
    if ! command -v required_cmd &>/dev/null; then
        echo "Error: required_cmd not found"
        return 1
    fi

    # Implementation
    # ...

    return 0
}
```

### General Guidelines

- **Keep it simple** - Prefer clarity over cleverness
- **Comment complex logic** - Explain why, not what
- **Error handling** - Always handle errors gracefully
- **Cross-platform** - Test on Windows, macOS, and Linux
- **Performance** - Optimize for speed when possible

---

## 📨 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(powershell): add plugin system support

- Add plugin discovery mechanism
- Implement auto-loading plugins
- Create sample Docker plugin

Closes #123
```

```bash
fix(zsh): resolve path resolution issue on macOS

The get_path function was failing on macOS when paths
contained spaces. Updated to properly escape paths.

Fixes #456
```

```bash
docs(readme): update installation instructions

- Add prerequisites section
- Include troubleshooting steps
- Update screenshots
```

---

## 🔄 Pull Request Process

### Before Submitting

1. **Test your changes**

   ```powershell
   # Run Pester tests
   Invoke-Pester -Path ./Tests

   # Run PSScriptAnalyzer
   Invoke-ScriptAnalyzer -Path ./Modules/ProfileCore
   ```

2. **Update documentation**

   - Update README.md if needed
   - Update CHANGELOG.md
   - Add/update function documentation

3. **Follow coding standards**
   - Run linters
   - Fix all warnings
   - Add comments

### Submitting PR

1. **Push to your fork**

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**

   - Use a clear title
   - Fill out the PR template
   - Link related issues
   - Add screenshots if applicable

3. **PR Template**

   ```markdown
   ## Description

   [What does this PR do?]

   ## Type of Change

   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing

   - [ ] Tested on Windows
   - [ ] Tested on macOS
   - [ ] Tested on Linux
   - [ ] Added/updated tests

   ## Checklist

   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No new warnings
   - [ ] Tests pass

   ## Related Issues

   Closes #123
   ```

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Requested changes** must be addressed
4. **Approval** required before merge
5. **Squash and merge** preferred

---

## 🧪 Testing Guidelines

### PowerShell Testing (Pester)

**Test Structure:**

```powershell
Describe "Get-Example" {
    Context "When parameter is valid" {
        It "Should return expected result" {
            $result = Get-Example -Name "test"
            $result | Should -Be "expected"
        }
    }

    Context "When parameter is invalid" {
        It "Should throw error" {
            { Get-Example -Name "" } | Should -Throw
        }
    }
}
```

**Running Tests:**

```powershell
# Run all tests
Invoke-Pester

# Run specific test file
Invoke-Pester -Path ./Tests/Unit/Example.Tests.ps1

# Generate coverage report
Invoke-Pester -CodeCoverage ./Modules/**/*.ps1
```

### Zsh Testing (shunit2)

**Test Structure:**

```bash
#!/usr/bin/env zsh

# Load function to test
source ./functions/example.zsh

# Test case
test_function_name() {
    result=$(function_name "test")
    assertEquals "expected" "$result"
}

# Run tests
. shunit2
```

### Test Coverage Goals

- **Unit Tests**: 90%+ coverage
- **Integration Tests**: All workflows
- **E2E Tests**: Critical paths
- **Cross-Platform**: Test on all supported OS

---

## 🎯 Development Workflow

### Typical Workflow

1. **Pick an issue** or create one
2. **Fork** and **clone** repository
3. **Create feature branch**
4. **Make changes** following guidelines
5. **Write/update tests**
6. **Run tests** and **linters**
7. **Update documentation**
8. **Commit** with proper message
9. **Push** and create **Pull Request**
10. **Address review** feedback
11. **Get approved** and **merged**

### Quick Reference Commands

```bash
# Development
git checkout -b feature/name
git add .
git commit -m "feat(scope): description"
git push origin feature/name

# Testing
Invoke-Pester
Invoke-ScriptAnalyzer ./Modules/ProfileCore

# Cleanup
git checkout main
git branch -d feature/name
```

---

## 📚 Additional Resources

### Documentation

- [PowerShell Best Practices](https://docs.microsoft.com/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)
- [Pester Documentation](https://pester.dev/docs/quick-start)
- [Zsh Guide](http://zsh.sourceforge.net/Guide/)

### Community

- [GitHub Discussions](../../discussions)
- [Issue Tracker](../../issues)
- [Enhancement Roadmap](Documentation/ENHANCEMENT_ROADMAP.md)

---

## 📞 Getting Help

**Need help?**

- 📖 Read the [Documentation](Documentation/README.md)
- 💬 Ask in [Discussions](../../discussions)
- 🐛 Report [Issues](../../issues)
- 📧 Contact maintainers

---

## 🙏 Thank You!

Your contributions make ProfileCore better for everyone. We appreciate your time and effort!

**Happy Coding!** 🚀

---

**Maintained by:** Mythic3011  
**Last Updated:** October 7, 2025
