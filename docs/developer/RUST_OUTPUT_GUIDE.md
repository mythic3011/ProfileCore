# Rust Output Helper Functions - Developer Guide

## Overview

ProfileCore includes native Rust implementations of common output formatting functions. These provide **significant performance benefits** for string-intensive operations.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  PowerShell Scripts (ProfileCore.Common)               │
│  ┌──────────────────────┐  ┌──────────────────────┐   │
│  │ OutputHelpers.ps1   │  │ RustOutputHelpers.ps1│   │
│  │ (Pure PowerShell)   │  │ (Rust FFI Wrapper)   │   │
│  └──────────────────────┘  └──────────────────────┘   │
│                                      │                  │
└──────────────────────────────────────┼──────────────────┘
                                       │ P/Invoke
                      ┌────────────────▼──────────────────┐
                      │  ProfileCore.dll (Rust)          │
                      │  ┌────────────────────────────┐  │
                      │  │  output.rs                │  │
                      │  │  - format_box_header()    │  │
                      │  │  - format_progress_bar()  │  │
                      │  │  - format_message()       │  │
                      │  │  - format_section_divider()│  │
                      │  └────────────────────────────┘  │
                      └───────────────────────────────────┘
```

## When to Use Rust vs PowerShell

### Use Rust (`Write-Rust*` functions) when:

✅ **High-volume operations** (1000+ calls)

- Build scripts processing many files
- Installation scripts with extensive logging
- Bulk operations on large datasets

✅ **Complex string formatting**

- Unicode/UTF-8 manipulation
- ANSI color code generation
- Multi-line text alignment

✅ **Performance-critical paths**

- Module initialization
- Real-time output streaming
- CI/CD pipelines

### Use PowerShell (`Write-*` functions) when:

✅ **Low-volume operations** (<100 calls)

- Interactive user prompts
- Simple status messages
- One-off formatting

✅ **Rapid development**

- Prototyping
- Quick scripts
- Testing

## Performance Characteristics

### String Generation Performance

| Operation          | PowerShell | Rust   | Speedup |
| ------------------ | ---------- | ------ | ------- |
| Box Header (raw)   | ~40µs      | ~2µs   | **20x** |
| Progress Bar (raw) | ~36µs      | ~1µs   | **36x** |
| Message Format     | ~17µs      | ~0.5µs | **34x** |

### End-to-End Performance (with FFI + Write-Host)

| Operation              | PowerShell | Rust FFI  | Speedup      |
| ---------------------- | ---------- | --------- | ------------ |
| Box Header (display)   | ~40ms/1k   | ~250ms/1k | **0.16x** ⚠️ |
| Progress Bar (display) | ~36ms/1k   | ~235ms/1k | **0.15x** ⚠️ |

**Note:** The current FFI implementation has overhead from:

- P/Invoke boundary crossing (~20-30µs per call)
- String marshalling between .NET and C (~10-20µs)
- Write-Host calls (still in PowerShell)

### Optimization Strategies

#### ✅ Good: Batch Operations

```powershell
# Generate 1000 headers at once (bypasses per-call FFI overhead)
$headers = 1..1000 | ForEach-Object {
    Write-RustBoxHeader "Item $_" -PassThru  # Returns string instead of printing
}
$headers | Out-String | Write-Host
```

#### ✅ Good: Pre-compute Strings

```powershell
# Generate progress strings once, reuse many times
$progressStrings = 0..100 | ForEach-Object {
    Write-RustInstallProgress "Processing..." -Percent $_ -PassThru
}

# Later: fast lookup instead of regeneration
Write-Host $progressStrings[$currentPercent]
```

#### ❌ Bad: Single-Call Per Display

```powershell
# FFI overhead dominates performance
foreach ($item in $items) {
    Write-RustBoxHeader $item.Name  # Slow: FFI + Write-Host per iteration
}
```

## API Reference

### Core Functions

#### `Initialize-RustOutput`

Initializes the Rust output module. Call once at module load.

```powershell
$success = Initialize-RustOutput
if (-not $success) {
    # Fall back to PowerShell
}
```

#### `Write-RustBoxHeader`

Generates a formatted box header with centered text.

```powershell
Write-RustBoxHeader "Title" -Width 60 -Color Cyan
Write-RustBoxHeader "Title" -Subtitle "Description" -Color Magenta
```

**Parameters:**

- `Message` (required): Main header text
- `Subtitle` (optional): Secondary text
- `Width` (default: 60): Box width in characters
- `Color` (default: Cyan): Color name

#### `Write-RustSectionHeader`

Generates a section divider with optional text.

```powershell
Write-RustSectionHeader "Section 1" -Width 60 -Color Gray
Write-RustSectionHeader -Width 60  # No text, just divider
```

#### `Write-RustInstallProgress`

Displays a progress bar with percentage.

```powershell
Write-RustInstallProgress "Installing..." -Percent 50
```

#### `Write-RustMessage` (and variants)

Formatted message with prefix and color.

```powershell
Write-RustSuccess "Operation complete!"
Write-RustInfo "Processing item 5 of 10"
Write-RustWarn "Deprecated feature in use"
Write-RustError "Failed to connect"
Write-RustFail "Validation failed"
Write-RustStep "Step 1: Initialize"
```

**Variants:**

- `Write-RustSuccess` - `[OK]` prefix, green
- `Write-RustInfo` - `[INFO]` prefix, white
- `Write-RustWarn` - `[WARN]` prefix, yellow
- `Write-RustError` - `[ERROR]` prefix, red
- `Write-RustFail` - `[FAIL]` prefix, red
- `Write-RustStep` - `[*]` prefix, cyan

All support `-Quiet` switch to suppress output.

## Cross-Platform Support

### Windows

- **DLL:** `ProfileCore.dll` or `profilecore_rs.dll`
- **Location:** `modules/ProfileCore/rust-binary/bin/`
- **ANSI Support:** Works in PowerShell 7+, limited in PowerShell 5.1

### macOS

- **Library:** `libprofilecore_rs.dylib`
- **Location:** `modules/ProfileCore/rust-binary/bin/`
- **Build:** Requires Rust toolchain with macOS target

### Linux

- **Library:** `libprofilecore_rs.so`
- **Location:** `modules/ProfileCore/rust-binary/bin/`
- **Build:** Native Linux build with Rust

## Building

### Windows

```powershell
cd modules/ProfileCore-rs
cargo build --release
Copy-Item target/release/profilecore_rs.dll `
    ../ProfileCore/rust-binary/bin/ProfileCore.dll
```

### macOS

```bash
cd modules/ProfileCore-rs
cargo build --release --target=x86_64-apple-darwin
cp target/x86_64-apple-darwin/release/libprofilecore_rs.dylib \
    ../ProfileCore/rust-binary/bin/
```

### Linux

```bash
cd modules/ProfileCore-rs
cargo build --release
cp target/release/libprofilecore_rs.so \
    ../ProfileCore/rust-binary/bin/
```

## Fallback Behavior

The module automatically falls back to pure PowerShell if:

- Rust DLL is not found
- DLL fails to load
- P/Invoke initialization fails

This ensures **backward compatibility** and **graceful degradation**.

## Error Handling

```powershell
try {
    $result = Initialize-RustOutput
    if ($result) {
        Write-RustBoxHeader "Success!"
    } else {
        # Use PowerShell fallback
        Write-BoxHeader "Success!"
    }
} catch {
    Write-Warning "Rust initialization failed: $_"
    # Continue with PowerShell
}
```

## Testing

Run the benchmark script to measure performance:

```powershell
.\scripts\utilities\benchmark-rust-output.ps1 -Iterations 1000
```

## Future Optimizations

### Planned Improvements

1. **Batch API** - Accept arrays for bulk processing

   ```powershell
   Write-RustBoxHeaders @("Title1", "Title2", "Title3") -PassThru
   ```

2. **String Return Mode** - Return strings instead of printing

   ```powershell
   $header = Write-RustBoxHeader "Test" -PassThru
   # Do something with $header later
   ```

3. **Native Console Output** - Bypass PowerShell's Write-Host entirely

   - Direct Windows Console API calls
   - ANSI passthrough mode

4. **Compiled Scripts** - Entire script blocks in Rust
   ```powershell
   Invoke-RustScript -Path "install.rs" -Parameters @{Version="1.0"}
   ```

## Contributing

When adding new output functions:

1. **Add to `output.rs`**

   - Pure Rust implementation
   - FFI export with `#[no_mangle]`
   - Unit tests

2. **Add to `RustOutputHelpers.ps1`**

   - PowerShell wrapper
   - Error handling
   - Fallback to pure PowerShell

3. **Update manifest**

   - Add to `FunctionsToExport` in `ProfileCore.Common.psd1`

4. **Document**
   - Update this guide
   - Add examples
   - Note performance characteristics

## Troubleshooting

### "Unable to load DLL"

**Solution:** Ensure Rust binary is built for correct platform:

```powershell
rustc --version --verbose  # Check host triple
cargo build --release --target=<triple>
```

### "Initialize-RustOutput returns false"

**Solution:** Check verbose output:

```powershell
Initialize-RustOutput -Verbose
```

Common causes:

- DLL not found in expected path
- Architecture mismatch (x64 vs x86)
- Missing dependencies (VC++ Runtime on Windows)

### ANSI codes showing as garbage

**Solution:** Use PowerShell 7+ for full ANSI support:

```powershell
$PSVersionTable.PSVersion  # Check version
```

## See Also

- [Rust Performance Impact](./rust-performance-impact.md)
- [Rust Integration Guide](./RUST_INTEGRATION_GUIDE.md)
- [Build System Documentation](./build-system.md)
