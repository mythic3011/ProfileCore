# ProfileCore Modules

This directory contains all ProfileCore PowerShell modules organized by functionality.

## 📁 Directory Structure

```
modules/
├── ProfileCore/              # Main ProfileCore module (v5.2.0)
│   ├── ProfileCore.psd1     # Module manifest
│   ├── ProfileCore.psm1     # Main module script (v6 bootstrap)
│   ├── public/              # Exported functions
│   ├── private/             # Legacy v5 private functions
│   ├── private-v6/          # New v6 DI architecture
│   └── rust-binary/         # Integrated Rust binary component
│
├── ProfileCore.Common/       # Shared utility library (v1.0.0)
│   ├── public/
│   │   ├── OutputHelpers.ps1    # Write-BoxHeader, Write-Step, etc.
│   │   └── InstallHelpers.ps1   # Installation utilities
│   └── ProfileCore.Common.psd1
│
├── ProfileCore-rs/          # Rust source code
│   ├── src/                 # Rust source files
│   ├── Cargo.toml           # Rust project manifest
│   └── target/              # Build artifacts (gitignored)
│
├── ProfileCore.CloudSync/   # Cloud synchronization module
├── ProfileCore.Security/    # Security tools module
│
└── deprecated-v5.2/         # Archived modules (deprecated in v5.2.0)
    ├── ProfileCore.Binary/
    ├── ProfileCore.Performance/
    └── ProfileCore.PackageManagement/
```

## 🎯 Active Modules

### ProfileCore (Main Module)

**Version:** 5.2.0  
**Architecture:** v6 DI-based with v5 fallback compatibility  
**Location:** `modules/ProfileCore/`

The core ProfileCore module with:

- 70+ PowerShell commands for development workflows
- Dependency injection architecture (v6)
- Integrated Rust binary for high-performance operations
- Lazy loading for optimal startup time

**Key Files:**

- `ProfileCore.psm1` - Bootstrap and module loader
- `ProfileCore.psd1` - Module manifest with exports
- `private-v6/` - Modern DI-based architecture
- `rust-binary/` - Native binary component

### ProfileCore.Common (Shared Library)

**Version:** 1.0.0  
**Location:** `modules/ProfileCore.Common/`

Shared utility functions used across ProfileCore scripts and modules:

- Output helpers: `Write-BoxHeader`, `Write-Step`, `Write-Success`, etc.
- Installation helpers: `Test-Prerequisites`, `Get-UserConfirmation`, etc.

**Usage:**

```powershell
Import-Module ProfileCore.Common
Write-BoxHeader "My Header"
```

### ProfileCore-rs (Rust Binary Source)

**Version:** 5.1.0  
**Location:** `modules/ProfileCore-rs/`

Rust source code for high-performance native implementations:

- System information gathering
- Network utilities and port scanning
- Cross-platform OS detection
- FFI exports for PowerShell

**Build:**

```powershell
.\scripts\build\build-rust-all.ps1 -Release -CopyToModule
```

**Note:** The `target/` directory contains build artifacts and is gitignored. It's automatically created during builds.

### ProfileCore.CloudSync

**Location:** `modules/ProfileCore.CloudSync/`

Cloud storage synchronization for ProfileCore configurations (Azure Blob, AWS S3, Google Cloud).

### ProfileCore.Security

**Location:** `modules/ProfileCore.Security/`

Security and cryptography utilities for password generation, hashing, and secret management.

## 🗄️ Deprecated Modules

### deprecated-v5.2/

**Location:** `modules/deprecated-v5.2/`

Contains modules deprecated in ProfileCore v5.2.0:

- **ProfileCore.Binary** - Integrated into `ProfileCore/rust-binary/`
- **ProfileCore.Performance** - Functions merged into main ProfileCore module
- **ProfileCore.PackageManagement** - Functions merged into main ProfileCore module

These modules are kept for reference and backward compatibility during migration. They will be removed in v6.0.0.

See `deprecated-v5.2/README.md` for migration instructions.

## 🔄 Module Dependencies

```
ProfileCore ──┬──> ProfileCore.Common (shared utilities)
              └──> ProfileCore-rs (Rust binary, optional)

ProfileCore.CloudSync ──> (independent)
ProfileCore.Security ──> (independent)
```

## 📦 Import Order

For optimal loading, import in this order:

```powershell
# 1. Common utilities (if needed standalone)
Import-Module ProfileCore.Common

# 2. Main module (auto-imports Common)
Import-Module ProfileCore

# 3. Optional modules
Import-Module ProfileCore.CloudSync
Import-Module ProfileCore.Security
```

## 🏗️ Development

### Building the Rust Component

```powershell
# Build for current platform
cd modules/ProfileCore-rs
cargo build --release

# Or use the build script
.\scripts\build\build-rust-all.ps1 -Targets @('windows') -Release -CopyToModule
```

### Testing

```powershell
# Test ProfileCore module
Invoke-Pester tests/unit/ProfileCore*.Tests.ps1

# Test Rust component
cd modules/ProfileCore-rs
cargo test --release
```

### Module Structure Best Practices

- **public/** - Exported functions (FunctionsToExport in .psd1)
- **private/** - Internal helper functions
- **classes/** - PowerShell classes (if any)
- **bin/** - Binary dependencies
- **en-US/** - Help files

## 📚 Documentation

- **Main Docs:** `docs/`
- **Developer Guide:** `docs/developer/`
- **Architecture:** `docs/architecture/`
- **User Guide:** `docs/user-guide/`

## 🔗 Related Files

- `scripts/build/build.ps1` - Main build script
- `scripts/build/build-rust-all.ps1` - Rust build script
- `.gitignore` - Excludes build artifacts

---

**ProfileCore v5.2.0** | Architecture: v6 DI | [Documentation](../docs/) | [GitHub](https://github.com/Mythic3011/ProfileCore)
