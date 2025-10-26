# ProfileCore Build System

## Overview

Professional build system for creating optimized, minified releases of ProfileCore v5.0.

## Features

- ✅ **Code Minification** - Removes comments and extra whitespace
- ✅ **Multi-Platform** - PowerShell and Bash build scripts
- ✅ **Testing Integration** - Optional test execution before build
- ✅ **Archive Creation** - ZIP and TAR.GZ formats
- ✅ **Checksum Generation** - MD5 and SHA256 hashes
- ✅ **Release Notes** - Automatically generated
- ✅ **Size Optimization** - 30-50% size reduction

---

## Quick Start

### Windows (PowerShell)

```powershell
# Build release version 5.0.0
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Release

# Build debug version (no minification)
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Debug

# Skip tests
.\scripts\build\build.ps1 -Version "5.0.0" -SkipTests

# Skip minification
.\scripts\build\build.ps1 -Version "5.0.0" -SkipMinify
```

### Unix (Linux/macOS)

```bash
# Make script executable
chmod +x scripts/build/build.sh

# Build release
./scripts/build/build.sh 5.0.0 Release

# Build with environment variables
SKIP_MINIFY=true ./scripts/build/build.sh 5.0.0 Release
SKIP_TESTS=true ./scripts/build/build.sh 5.0.0 Release
SKIP_ARCHIVE=true ./scripts/build/build.sh 5.0.0 Release
```

---

## Build Process

### Steps Executed

1. **Initialize** - Create build directories, clean previous builds
2. **Test** - Run Pester tests (optional)
3. **Build PowerShell Module** - Minify and optimize .ps1, .psm1, .psd1 files
4. **Build Shell Functions** - Optimize Zsh, Bash, Fish scripts
5. **Build Profile** - Optimize main profile script
6. **Build Plugins** - Package example plugins
7. **Copy Documentation** - Include essential docs
8. **Build Scripts** - Package installation scripts
9. **Create Archive** - Generate ZIP/TAR.GZ
10. **Generate Checksums** - MD5 and SHA256
11. **Create Release Notes** - Markdown documentation

### Optimization Details

**PowerShell Scripts (.ps1, .psm1):**
- Remove multi-line comments (`<# ... #>`)
- Remove single-line comments (`# ...`)
- Remove empty lines (Release mode)
- Preserve string content
- Maintain functionality

**Shell Scripts (.zsh, .bash, .fish):**
- Remove comments (preserve shebang)
- Remove trailing whitespace
- Remove empty lines (Release mode)
- Preserve executable permissions

**Size Reduction:**
- Typical reduction: 30-50%
- Larger for files with extensive comments
- No functionality changes

---

## Output Structure

```
build/
├── output/
│   └── ProfileCore-v5.0.0/
│       ├── modules/
│       │   └── ProfileCore/
│       ├── shells/
│       │   ├── zsh/
│       │   ├── bash/
│       │   └── fish/
│       ├── examples/
│       │   └── plugins/
│       ├── scripts/
│       │   └── installation/
│       ├── docs/
│       ├── README.md
│       ├── QUICK_START.md
│       ├── INSTALL.md
│       ├── LICENSE
│       └── MIGRATION_V5.md
└── releases/
    ├── ProfileCore-v5.0.0-Release.zip
    ├── ProfileCore-v5.0.0-checksums.txt
    └── RELEASE_NOTES_v5.0.0.md
```

---

## Parameters

### PowerShell (build.ps1)

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `-Version` | String | Release version (required) | - |
| `-Configuration` | String | Release or Debug | Release |
| `-SkipMinify` | Switch | Skip code minification | False |
| `-SkipTests` | Switch | Skip running tests | False |
| `-SkipArchive` | Switch | Skip archive creation | False |

### Bash (build.sh)

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `$1` | String | Release version (required) | - |
| `$2` | String | Release or Debug | Release |
| `SKIP_MINIFY` | Env Var | Skip code minification | false |
| `SKIP_TESTS` | Env Var | Skip running tests | false |
| `SKIP_ARCHIVE` | Env Var | Skip archive creation | false |

---

## Configuration

### build-config.json

Configure build behavior via `build-config.json`:

```json
{
  "version": "5.0.0",
  "buildConfiguration": {
    "minify": {
      "enabled": true,
      "removeComments": true,
      "removeEmptyLines": true,
      "preserveShebang": true
    },
    "optimization": {
      "bundleModules": false,
      "compressArchives": true,
      "generateChecksums": true
    },
    "testing": {
      "runTests": true,
      "requireAllPass": true
    }
  }
}
```

### .buildignore

Exclude files from release (similar to .gitignore):

```
# Exclude tests
tests/
*.Tests.ps1

# Exclude development files
.vscode/
*.log
```

---

## Examples

### Standard Release Build

```powershell
# Windows
.\scripts\build\build.ps1 -Version "5.0.0"

# Linux/macOS
./scripts/build/build.sh 5.0.0
```

**Output:**
- `build/output/ProfileCore-v5.0.0/` - Extracted files
- `build/releases/ProfileCore-v5.0.0-Release.zip` - Archive
- `build/releases/ProfileCore-v5.0.0-checksums.txt` - Checksums
- `build/releases/RELEASE_NOTES_v5.0.0.md` - Release notes

### Debug Build (No Minification)

```powershell
# Windows
.\scripts\build\build.ps1 -Version "5.0.0" -Configuration Debug

# Linux/macOS
./scripts/build/build.sh 5.0.0 Debug
```

**Result:** Full source code with comments preserved

### Quick Build (No Tests, No Archive)

```powershell
# Windows
.\scripts\build\build.ps1 -Version "5.0.0" -SkipTests -SkipArchive

# Linux/macOS
SKIP_TESTS=true SKIP_ARCHIVE=true ./scripts/build/build.sh 5.0.0
```

**Result:** Optimized files in `build/output/` only

### Development Build

```powershell
# Windows - Debug with no minification
.\scripts\build\build.ps1 -Version "5.0.0-dev" -Configuration Debug -SkipMinify -SkipArchive
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
      
      - name: Build release
        run: |
          chmod +x scripts/build/build.sh
          ./scripts/build/build.sh ${{ steps.version.outputs.VERSION }} Release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ProfileCore-Release
          path: build/releases/*
```

---

## Troubleshooting

### Issue: "Version required"

**Solution:** Provide version parameter:
```powershell
.\scripts\build\build.ps1 -Version "5.0.0"
```

### Issue: "Tests failed"

**Solution:** Fix tests or skip:
```powershell
.\scripts\build\build.ps1 -Version "5.0.0" -SkipTests
```

### Issue: "Pester not found"

**Solution:** Install Pester or skip tests:
```powershell
Install-Module -Name Pester -Force
```

### Issue: "Permission denied" (Unix)

**Solution:** Make script executable:
```bash
chmod +x scripts/build/build.sh
```

### Issue: "Archive too large"

**Solution:** Check .buildignore, exclude unnecessary files

---

## Best Practices

### Versioning

Use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Examples:
- `5.0.0` - Major release
- `5.1.0` - New features added
- `5.0.1` - Bug fixes

### Testing

Always run tests before release:
```powershell
# Run tests manually first
Invoke-Pester

# Then build
.\scripts\build\build.ps1 -Version "5.0.0"
```

### Release Process

1. **Update Version** - In manifests and docs
2. **Update CHANGELOG** - Document changes
3. **Run Tests** - Ensure all pass
4. **Build Release** - Create optimized package
5. **Verify Archive** - Test installation
6. **Tag Release** - Git tag
7. **Publish** - GitHub release

---

## Performance

### Build Times

| Configuration | Time (Typical) | Output Size |
|---------------|----------------|-------------|
| Release (minified) | 10-15s | ~2-3 MB |
| Debug (full source) | 5-10s | ~4-6 MB |

### Size Comparison

| Component | Original | Minified | Reduction |
|-----------|----------|----------|-----------|
| PowerShell Module | 200 KB | 120 KB | 40% |
| Shell Scripts | 100 KB | 70 KB | 30% |
| Documentation | 500 KB | 500 KB | 0% |
| **Total** | ~4 MB | ~2.5 MB | 37.5% |

---

## Advanced Usage

### Custom Minification

Modify optimization functions in `build.ps1`:

```powershell
function Optimize-PowerShellScript {
    # Add custom optimizations
    $content = $content -replace 'Write-Verbose', '#Write-Verbose'
}
```

### Custom Archive Formats

Add additional compression:

```powershell
# After ZIP creation, add 7z
Compress-7zip -Path $ReleaseDir -DestinationPath "$ArchiveDir/ProfileCore.7z"
```

### Multi-Version Build

```powershell
# Build multiple versions
$versions = @("5.0.0", "5.0.1", "5.1.0")
foreach ($ver in $versions) {
    .\scripts\build\build.ps1 -Version $ver
}
```

---

## Contributing

To improve the build system:

1. Test changes in Debug mode first
2. Verify minified code works
3. Update this README
4. Submit PR with examples

---

## License

Part of ProfileCore - MIT License

---

<div align="center">

**ProfileCore Build System** - _Professional Release Engineering_

**[🏠 ProfileCore](../../README.md)** • **[📖 Documentation](../../docs/)**

</div>

