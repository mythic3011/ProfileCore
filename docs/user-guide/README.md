# ProfileCore User Guide

Welcome to the ProfileCore user documentation! This guide will help you get the most out of ProfileCore.

## Quick Navigation

### Getting Started

- **[Quick Start Guide](quick-start.md)** - Get up and running in 5 minutes
- **[Installation Guide](installation.md)** - Detailed installation instructions
- **[Installation (Advanced)](installation-advanced.md)** - Advanced installation scenarios
- **[Migration Guide (v5)](migration-v5.md)** - Upgrading from v4.x to v5.0

### Features & Tools

- **[Package Management](package-management.md)** - Universal package operations across platforms
- **[Security Tools](security-tools.md)** - Port scanning, SSL checking, password generation
- **[Update System](update-system.md)** - Enterprise-grade automatic updates
- **[Command Reference](command-reference.md)** - Complete command and alias reference
- **[Optimization Reference](optimization-reference.md)** - Performance tips and best practices

### Maintenance

- **[Uninstallation](uninstallation.md)** - How to cleanly remove ProfileCore

## What's New in v5.0

### ⚡ Intelligent Caching

- DNS lookups: **38x faster** when cached
- Package searches: **34x faster** when cached
- Automatic TTL-based expiration
- `-NoCache` parameter for fresh data

### 🛡️ Enhanced Safety

- `ShouldProcess` support on 10 critical functions
- `-WhatIf` to preview changes
- `-Confirm` for interactive confirmation
- Zero accidental modifications

### 📊 Production Excellence

- 94% overall quality score
- 90% SOLID compliance
- 14 design patterns implemented
- 67 well-architected classes

## Getting Help

- **[GitHub Issues](https://github.com/mythic3011/ProfileCore/issues)** - Report bugs or request features
- **[Contributing Guide](../developer/contributing.md)** - Help improve ProfileCore
- **[Architecture Review](../architecture/architecture-review.md)** - Understand the design

## Examples

### Basic Package Management

```powershell
# Install a package
pkg install neovim

# Search for packages
pkgs python

# Update all packages (with safety check)
pkgu -WhatIf    # Preview what would be updated
pkgu            # Actually update
```

### Cached Operations

```powershell
# First DNS lookup - regular speed
Get-DNSInfo github.com

# Second lookup - instant (38x faster!)
Get-DNSInfo github.com

# Force fresh lookup
Get-DNSInfo github.com -NoCache
```

### Safety Features

```powershell
# Preview package installations
Install-Package docker -WhatIf

# Confirm before updating
Update-AllPackages -Confirm
```

---

**ProfileCore v5.0** - Production-grade excellence for power users  
[Back to Main README](../../README.md)
