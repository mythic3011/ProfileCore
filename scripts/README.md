# ProfileCore Scripts Directory

Organized collection of scripts for installation, building, and maintaining ProfileCore.

---

## 📁 Directory Structure

```
scripts/
├── shared/                    # Shared utilities for all scripts
│   ├── ScriptHelpers.ps1      # Common module import wrapper
│   └── README.md
├── installation/              # Installation and setup scripts
│   ├── install.ps1            # Full installation (PowerShell)
│   ├── install.sh             # Full installation (Bash)
│   ├── install-v6.ps1         # Zero-prerequisite installer
│   ├── uninstall.ps1          # Uninstallation (PowerShell)
│   └── uninstall.sh           # Uninstallation (Bash)
├── build/                     # Build and release scripts
│   ├── build.ps1              # Main build script
│   ├── build.sh               # Build script (Bash)
│   ├── build-rust-all.ps1     # Rust binary builder
│   ├── Publish-ToPSGallery.ps1
│   └── Test-PSGalleryReadiness.ps1
├── utilities/                 # Utility and development scripts
│   ├── benchmark-performance.ps1
│   ├── setup-dev-environment.ps1
│   ├── Move-ProfileCoreRepository.ps1
│   └── Profile-*.ps1          # Profiling utilities
├── configuration/             # Configuration helpers
│   └── README.md
├── quick-install.ps1          # Quick installer (Windows)
├── quick-install.sh           # Quick installer (Unix)
└── README.md                  # This file
```

---

## 🚀 Quick Start Scripts (Root Level)

### quick-install.ps1 / quick-install.sh

**Purpose:** Fast, simple installation for end users

**Features:**

- Auto-installs prerequisites (Git)
- Clones/updates repository
- Runs full installation
- Non-interactive mode available

**Usage:**

```powershell
# Windows
.\scripts\quick-install.ps1

# Unix/macOS
./scripts/quick-install.sh
```

---

## 📦 Installation Scripts

### install.ps1 / install.sh

**Purpose:** Complete installation with all features

**Features:**

- Full system prerequisites check
- Module installation
- Configuration setup
- Rust binary support
- Rollback on failure

**Usage:**

```powershell
# PowerShell
.\scripts\installation\install.ps1 [-Force] [-SkipBackup] [-Quiet]

# Bash
./scripts/installation/install.sh [--force] [--skip-backup] [--quiet]
```

### install-v6.ps1

**Purpose:** Zero-prerequisite installer for v6

**Features:**

- Downloads from GitHub releases
- No Git required
- Pre-built binaries included
- Offline installation support

**Usage:**

```powershell
.\scripts\installation\install-v6.ps1 [-Version latest] [-Offline] [-Quiet]
```

### uninstall.ps1 / uninstall.sh

**Purpose:** Clean uninstallation

**Features:**

- Removes all ProfileCore files
- Backs up configurations
- Cleans module paths
- Removes environment variables

**Usage:**

```powershell
# PowerShell
.\scripts\installation\uninstall.ps1 [-KeepConfig]

# Bash
./scripts/installation/uninstall.sh [--keep-config]
```

---

## 🛠️ Build Scripts

### build.ps1

**Purpose:** Build release packages

**Features:**

- Code minification
- Cross-platform packaging
- Checksum generation
- Release notes creation

**Usage:**

```powershell
.\scripts\build\build.ps1 -Version "5.2.0" [-Configuration Release]
```

### build-rust-all.ps1

**Purpose:** Build Rust binaries for all platforms

**Features:**

- Builds for Windows, Linux, macOS
- x64 and ARM64 architectures
- Automatic cross-compilation

**Usage:**

```powershell
.\scripts\build\build-rust-all.ps1
```

### Publish-ToPSGallery.ps1

**Purpose:** Publish module to PowerShell Gallery

**Usage:**

```powershell
.\scripts\build\Publish-ToPSGallery.ps1 -ApiKey $key -Version "5.2.0"
```

---

## 🔧 Utility Scripts

### setup-dev-environment.ps1

**Purpose:** Set up development environment

**Features:**

- Installs required modules (Pester, PSScriptAnalyzer)
- Configures shell environments
- Sets up development tools

**Usage:**

```powershell
.\scripts\utilities\setup-dev-environment.ps1 [-InstallTools] [-SetupShells]
```

### benchmark-performance.ps1

**Purpose:** Performance benchmarking

**Features:**

- Measures load times
- Function performance testing
- Comparison with previous versions

**Usage:**

```powershell
.\scripts\utilities\benchmark-performance.ps1
```

### Move-ProfileCoreRepository.ps1

**Purpose:** Relocate ProfileCore installation

**Features:**

- Moves repository safely
- Updates symbolic links
- Preserves configurations

**Usage:**

```powershell
.\scripts\utilities\Move-ProfileCoreRepository.ps1 -NewLocation "C:\Dev\ProfileCore"
```

---

## 📚 Shared Library

### scripts/shared/

**Purpose:** Common utilities for all scripts

**Key Components:**

- `ScriptHelpers.ps1` - Imports ProfileCore.Common module
- Provides consistent output functions
- Path resolution utilities

**Usage in Your Script:**

```powershell
# Import shared helpers
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"
Import-ProfileCoreCommon

# Use ProfileCore.Common functions
Write-BoxHeader "My Script Title"
Write-Step "Processing..."
Write-Success "Complete!"
```

**See:** `scripts/shared/README.md` for detailed usage

---

## 🎯 Best Practices

### For Script Developers

1. **Use Shared Library**: Import `ScriptHelpers.ps1` to access ProfileCore.Common
2. **Consistent Output**: Use `Write-*` functions for uniform UX
3. **Error Handling**: Implement proper try-catch with rollback
4. **Documentation**: Add help comments and examples
5. **Cross-Platform**: Test on Windows, Linux, and macOS

### Example Script Template

```powershell
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description
.PARAMETER ParamName
    Parameter description
.EXAMPLE
    .\script.ps1
#>

param(
    [Parameter(Mandatory)]
    [string]$ParamName
)

# Import shared utilities
. "$PSScriptRoot/../shared/ScriptHelpers.ps1"
Import-ProfileCoreCommon

$ErrorActionPreference = 'Stop'

try {
    Write-BoxHeader "Script Title"

    Write-Step "Step 1: Doing something..."
    # Your code here

    Write-Success "Complete!"

} catch {
    Write-Fail "Error: $_"
    exit 1
}
```

---

## 🔗 Related Documentation

- **Shared Libraries**: `docs/architecture/shared-libraries.md`
- **Build System**: `scripts/build/README.md`
- **Contributing**: `docs/developer/contributing.md`
- **ProfileCore.Common**: `modules/ProfileCore.Common/`

---

## 📊 Scripts Summary

| Category         | Scripts | Purpose                          |
| ---------------- | ------- | -------------------------------- |
| **Quick Start**  | 2       | Fast installation entry points   |
| **Installation** | 5       | Full installation/uninstallation |
| **Build**        | 7       | Building and publishing          |
| **Utilities**    | 7+      | Development and maintenance      |
| **Shared**       | 2       | Common utilities                 |

**Total:** 20+ scripts, organized for clarity and maintainability

---

**ProfileCore Scripts** - Organized, maintainable, and easy to use! 🚀
