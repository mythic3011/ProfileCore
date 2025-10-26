# ProfileCore Build System Documentation

## 🎯 Overview

Professional build system for creating optimized, production-ready releases of ProfileCore v5.0 with code minification, testing, and automated distribution.

---

## ✨ Features

### Code Optimization
- ✅ **Minification** - Removes comments, whitespace
- ✅ **PowerShell** - .ps1, .psm1, .psd1 files
- ✅ **Shell Scripts** - .zsh, .bash, .fish files
- ✅ **Size Reduction** - 30-50% smaller

### Build Process
- ✅ **Testing Integration** - Optional Pester tests
- ✅ **Multi-Platform** - Windows & Unix scripts
- ✅ **Archive Creation** - ZIP & TAR.GZ
- ✅ **Checksums** - MD5 & SHA256
- ✅ **Release Notes** - Auto-generated

### Automation
- ✅ **GitHub Actions** - CI/CD workflow
- ✅ **Version Management** - Semantic versioning
- ✅ **Artifact Upload** - Automated releases

---

## 🚀 Quick Start

### Build a Release

**Windows:**
```powershell
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Release
```

**Unix:**
```bash
./scripts/build/build.sh 5.0.0 Release
```

### Output

```
build/
├── output/
│   └── ProfileCore-v5.0.0/       # Extracted, optimized files
└── releases/
    ├── ProfileCore-v5.0.0-Release.zip
    ├── ProfileCore-v5.0.0-Release.tar.gz
    ├── ProfileCore-v5.0.0-checksums.txt
    └── RELEASE_NOTES_v5.0.0.md
```

---

## 📋 Build Parameters

### PowerShell (build.ps1)

```powershell
.\scripts\build\build.ps1 `
    -Version "5.0.0" `              # Required: Release version
    -Configuration Release `        # Release or Debug
    -SkipMinify `                   # Skip code minification
    -SkipTests `                    # Skip running tests
    -SkipArchive                    # Skip archive creation
```

### Bash (build.sh)

```bash
# Basic usage
./scripts/build/build.sh <version> [configuration]

# With environment variables
SKIP_MINIFY=true \
SKIP_TESTS=true \
SKIP_ARCHIVE=true \
./scripts/build/build.sh 5.0.0 Release
```

---

## 🔧 Build Process

### Step-by-Step

1. **Initialize**
   - Create build directories
   - Clean previous builds
   - Validate parameters

2. **Test** (optional)
   - Run Pester unit tests
   - Run integration tests
   - Fail build if tests fail

3. **Build PowerShell Module**
   - Optimize .ps1 files
   - Optimize .psm1 files
   - Copy .psd1 manifests
   - Process private/ and public/ directories

4. **Build Shell Functions**
   - Optimize Zsh scripts
   - Optimize Bash scripts
   - Optimize Fish scripts
   - Preserve executable permissions

5. **Build Profile Script**
   - Optimize Microsoft.PowerShell_profile.ps1
   - Remove comments
   - Reduce whitespace

6. **Build Plugins**
   - Package security-tools plugin
   - Package docker-enhanced plugin
   - Optimize plugin scripts

7. **Copy Documentation**
   - Copy README.md
   - Copy QUICK_START.md
   - Copy INSTALL.md
   - Copy LICENSE
   - Copy essential docs

8. **Build Installation Scripts**
   - Optimize install.ps1
   - Optimize install.sh

9. **Create Archives**
   - Create ZIP (Windows)
   - Create TAR.GZ (Unix)
   - Compress with maximum level

10. **Generate Checksums**
    - Calculate MD5
    - Calculate SHA256
    - Save to text file

11. **Create Release Notes**
    - Generate markdown
    - Include version info
    - Include installation instructions

---

## 🎨 Code Optimization

### PowerShell Minification

**Before:**
```powershell
# This is a comment
function Get-Data {
    <#
    .SYNOPSIS
        Get some data
    #>
    param([string]$Name)
    
    # Do something
    Write-Host "Processing $Name"
    
    return $result
}
```

**After (Release):**
```powershell
function Get-Data {
    param([string]$Name)
    Write-Host "Processing $Name"
    return $result
}
```

**Size Reduction:** ~40%

### Shell Script Minification

**Before:**
```bash
#!/bin/bash
# Core utilities for Bash

# Function to get OS
get_os() {
    # Detect operating system
    case "$(uname -s)" in
        Darwin*)
            echo "macOS"
            ;;
        Linux*)
            echo "Linux"
            ;;
    esac
}
```

**After (Release):**
```bash
#!/bin/bash
get_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macOS"
            ;;
        Linux*)
            echo "Linux"
            ;;
    esac
}
```

**Size Reduction:** ~30%

---

## 📦 Release Artifacts

### Files Generated

| File | Description | Size |
|------|-------------|------|
| `ProfileCore-v5.0.0-Release.zip` | Windows archive | ~2-3 MB |
| `ProfileCore-v5.0.0-Release.tar.gz` | Unix archive | ~2-3 MB |
| `ProfileCore-v5.0.0-checksums.txt` | Hash verification | ~1 KB |
| `RELEASE_NOTES_v5.0.0.md` | Release documentation | ~5 KB |

### Archive Contents

```
ProfileCore-v5.0.0/
├── modules/
│   └── ProfileCore/
│       ├── ProfileCore.psd1
│       ├── ProfileCore.psm1
│       ├── private/            (8 optimized files)
│       └── public/             (18 optimized files)
├── shells/
│   ├── zsh/
│   │   ├── lib/
│   │   │   ├── 00-core.zsh
│   │   │   └── 10-package-manager.zsh
│   │   └── profilecore.zsh
│   ├── bash/                   (same structure)
│   └── fish/                   (same structure)
├── examples/
│   └── plugins/
│       ├── security-tools/
│       └── example-docker-enhanced/
├── scripts/
│   └── installation/
│       ├── install.ps1
│       └── install.sh
├── docs/
│   ├── PROFILECORE_V5_SUMMARY.md
│   └── development/
│       ├── SOLID_ARCHITECTURE.md
│       ├── OPTIMIZATION_SUMMARY.md
│       └── contributing.md
├── README.md
├── QUICK_START.md
├── INSTALL.md
├── LICENSE
└── MIGRATION_V5.md
```

---

## 🤖 CI/CD Integration

### GitHub Actions Workflow

Automatically builds and releases when tags are pushed:

```bash
# Create and push tag
git tag -a v5.0.0 -m "Release version 5.0.0"
git push origin v5.0.0
```

**What Happens:**
1. Workflow triggers on tag push
2. Runs tests on Windows & Ubuntu
3. Builds release packages
4. Creates GitHub release
5. Uploads artifacts
6. Publishes release notes

### Manual Trigger

```yaml
# In GitHub Actions UI
Run workflow → Enter version → Run
```

---

## 🔍 Quality Assurance

### Pre-Build Checks

```powershell
# Run tests manually
Invoke-Pester

# Check for errors
Get-ChildItem -Recurse -Filter "*.ps1" | ForEach-Object {
    Test-ScriptFileInfo $_.FullName
}

# Verify module
Test-ModuleManifest .\modules\ProfileCore\ProfileCore.psd1
```

### Post-Build Verification

```powershell
# Extract and test
Expand-Archive build/releases/ProfileCore-v5.0.0-Release.zip -Destination C:\Test

# Import module
Import-Module C:\Test\ProfileCore-v5.0.0\modules\ProfileCore

# Run commands
Get-Command -Module ProfileCore
Install-Package git
```

---

## 📊 Performance

### Build Times

| Configuration | Windows | Linux | macOS |
|---------------|---------|-------|-------|
| Release | 10-15s | 8-12s | 8-12s |
| Debug | 5-10s | 4-8s | 4-8s |
| With Tests | +10-20s | +10-20s | +10-20s |

### Size Comparison

| Component | Original | Minified | Reduction |
|-----------|----------|----------|-----------|
| PowerShell Module | 250 KB | 150 KB | 40% |
| Zsh Functions | 80 KB | 55 KB | 31% |
| Bash Functions | 60 KB | 42 KB | 30% |
| Fish Functions | 75 KB | 52 KB | 31% |
| Profile Script | 40 KB | 25 KB | 37.5% |
| **Total Code** | 505 KB | 324 KB | **35.8%** |
| With Docs | 4.2 MB | 2.8 MB | **33.3%** |

---

## 🛠️ Advanced Usage

### Custom Build Configuration

Edit `build-config.json`:

```json
{
  "buildConfiguration": {
    "minify": {
      "enabled": true,
      "removeComments": true,
      "removeEmptyLines": true,
      "preserveShebang": true
    }
  }
}
```

### Custom Exclusions

Edit `.buildignore`:

```
# Exclude additional files
docs/archives/
*.backup
dev-tools/
```

### Multiple Version Builds

```powershell
# Build multiple versions
@("5.0.0", "5.0.1", "5.1.0") | ForEach-Object {
    .\scripts\build\build.ps1 -Version $_ -Configuration Release
}
```

### Cross-Platform Build

```powershell
# Windows
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Release

# Then on Linux
./scripts/build/build.sh 5.0.0 Release

# Compare artifacts
Compare-Object (Get-FileHash windows.zip) (Get-FileHash linux.tar.gz)
```

---

## 🐛 Troubleshooting

### Build Fails: "Version required"

**Problem:** Missing version parameter

**Solution:**
```powershell
.\scripts\build\build.ps1 -Version "5.0.0"
```

### Build Fails: "Tests failed"

**Problem:** Test failures blocking build

**Solution 1:** Fix the tests
```powershell
Invoke-Pester -Output Detailed
```

**Solution 2:** Skip tests
```powershell
.\scripts\build\build.ps1 -Version "5.0.0" -SkipTests
```

### Build Fails: "Pester not found"

**Problem:** Pester module not installed

**Solution:**
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### Build Produces Large Archive

**Problem:** Unnecessary files included

**Solution:** Check `.buildignore`:
```
tests/
*.log
.vscode/
```

### Minified Code Doesn't Work

**Problem:** Over-aggressive minification

**Solution:** Use Debug configuration:
```powershell
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Debug
```

Or skip minification:
```powershell
.\scripts\build\build.ps1 -Version "5.0.0" -SkipMinify
```

---

## 📚 Related Documentation

- [Build System README](../../scripts/build/README.md) - Detailed guide
- [SOLID Architecture](SOLID_ARCHITECTURE.md) - Architecture patterns
- [Contributing](contributing.md) - How to contribute
- [Optimization Summary](OPTIMIZATION_SUMMARY.md) - v5.0 changes

---

## 🎯 Best Practices

### Before Building

- ✅ Update version in all manifests
- ✅ Update CHANGELOG.md
- ✅ Run all tests
- ✅ Review code changes
- ✅ Update documentation

### During Building

- ✅ Use semantic versioning
- ✅ Build Release configuration
- ✅ Don't skip tests
- ✅ Verify output directory

### After Building

- ✅ Test extracted archive
- ✅ Verify checksums
- ✅ Test installation
- ✅ Create Git tag
- ✅ Push to GitHub
- ✅ Create GitHub release

---

## 🚀 Release Checklist

```markdown
- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Run all tests
- [ ] Build release
- [ ] Verify archive
- [ ] Test installation (Windows)
- [ ] Test installation (Linux)
- [ ] Test installation (macOS)
- [ ] Verify checksums
- [ ] Create Git tag
- [ ] Push tag
- [ ] Wait for CI/CD
- [ ] Verify GitHub release
- [ ] Announce release
```

---

<div align="center">

**ProfileCore Build System** - _Professional Release Engineering_

**[🏠 Home](../../README.md)** • **[📖 Architecture](SOLID_ARCHITECTURE.md)** • **[🔧 Build README](../../scripts/build/README.md)**

</div>

