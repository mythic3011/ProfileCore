# ProfileCore Developer Guide

Welcome to the ProfileCore developer documentation! This guide will help you contribute to and extend ProfileCore.

## Quick Navigation

### Getting Started

- **[Contributing Guide](contributing.md)** - How to contribute to ProfileCore
- **[Build System](build-system.md)** - Building, testing, and packaging
- **[Architecture Principles](architecture-principles.md)** - SOLID principles and design philosophy
- **[Repository Migration](repository-migration.md)** - Moving the repository

### Architecture & Design

- **[Architecture Review](../architecture/architecture-review.md)** - Complete architecture analysis (45 pages)
- **[Global Variables](../architecture/global-variables.md)** - All global variables documented
- **[Project Status](../architecture/project-status.md)** - Current project state and metrics

### Development

- **[Testing Guide](testing.md)** - How to write and run tests
- **Build Scripts** - Located in `/scripts/build/`
- **Utilities** - Helper scripts in `/scripts/utilities/`

## Architecture Overview

ProfileCore v5.0 is built on a solid foundation:

- **67 Classes** organized across 15 modules
- **14 Design Patterns** correctly implemented
- **90% SOLID Compliance** - Production-grade design
- **94% Quality Score** - Exceeds industry standards

### Key Design Patterns

1. **Factory Pattern** - OS abstraction (`OSProviderFactory`)
2. **Strategy Pattern** - Package managers, config providers
3. **Dependency Injection** - Service container
4. **Chain of Responsibility** - Middleware pipeline
5. **Singleton** - Service locator
6. **Registry** - Package/update provider management
7. **Template Method** - OSProvider base class
8. **Plugin Architecture** - Extensibility system
9. **Observer** - Metrics tracking
10. **Builder** - Service registration
11. **Proxy** - Lazy loading framework
12. **Cache** - Performance optimization
13. **Manager** - Component orchestration
14. **Provider** - Abstraction layers

## Development Workflow

### 1. Clone and Setup

```powershell
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore
.\scripts\setup-dev-environment.ps1
```

### 2. Make Changes

- Follow SOLID principles
- Add tests for new features
- Update documentation
- Run PSScriptAnalyzer

### 3. Test

```powershell
# Run all tests
Invoke-Pester

# Run specific test
Invoke-Pester tests/unit/YourFeature.Tests.ps1

# Check test coverage
Invoke-Pester -CodeCoverage
```

### 4. Build

```powershell
.\scripts\build\build.ps1
```

### 5. Submit PR

- Create feature branch
- Write clear commit messages
- Reference issues in PR
- Await code review

## Code Standards

### PowerShell Best Practices

- Use `Write-Information`, `Write-Warning`, `Write-Error` (not `Write-Host`)
- Add `[CmdletBinding()]` to all functions
- Support `ShouldProcess` for destructive operations
- Use approved verbs (`Get-`, `Set-`, `New-`, etc.)
- Add comprehensive help comments
- Follow PSScriptAnalyzer recommendations

### Architecture Principles (SOLID)

- **Single Responsibility** - One class, one purpose
- **Open/Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Derived classes fully substitutable
- **Interface Segregation** - Small, focused interfaces
- **Dependency Inversion** - Depend on abstractions, not concretions

### Testing

- Unit tests for all public functions
- Integration tests for workflows
- E2E tests for user scenarios
- Mock external dependencies
- Aim for 80%+ code coverage

## Project Structure

```
ProfileCore/
├── modules/ProfileCore/         # Main module
│   ├── private/                 # Private functions (18 files)
│   └── public/                  # Public functions (25 files)
├── scripts/                     # Build and utility scripts
├── tests/                       # Test suite
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── e2e/                     # End-to-end tests
├── docs/                        # Documentation
│   ├── user-guide/              # User documentation
│   ├── developer/               # Developer documentation
│   ├── architecture/            # Architecture docs
│   ├── archive/                 # Historical docs
│   └── planning/                # Roadmap and planning
├── examples/                    # Example plugins and configs
└── shells/                      # Bash, Zsh, Fish support
```

## Key Technologies

- **PowerShell 7+** - Core language
- **Pester 5.x** - Testing framework
- **PSScriptAnalyzer** - Code quality
- **Git** - Version control
- **GitHub Actions** - CI/CD (planned)

## Performance Considerations

### Caching Strategy

- TTL-based expiration
- User-controllable with `-NoCache`
- 97% reduction in redundant operations
- Implemented in 6 high-impact functions

### Module Loading

- Current load time: 16-86ms
- Lazy loading for heavy components
- Efficient import ordering
- Minimal startup overhead

## Release Process

1. Update version in `ProfileCore.psd1`
2. Update `CHANGELOG.md`
3. Run full test suite
4. Build and test package
5. Create GitHub release
6. Tag version
7. Publish to PowerShell Gallery (if applicable)

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/mythic3011/ProfileCore/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mythic3011/ProfileCore/discussions)
- **Email**: Contact @mythic3011

## Additional Resources

- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [Pester Documentation](https://pester.dev/)
- [PSScriptAnalyzer Rules](https://github.com/PowerShell/PSScriptAnalyzer)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

---

**ProfileCore v5.0** - Production-grade PowerShell ecosystem  
[Back to Main README](../../README.md)
