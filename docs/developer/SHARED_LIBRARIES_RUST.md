# ProfileCore Rust Shared Libraries

**Version:** 1.0.0  
**Last Updated:** October 28, 2024

---

## Overview

ProfileCore v1.0.0 uses a modular shared library architecture to eliminate code duplication and improve maintainability across the Rust codebase.

## Architecture

```
src/
├── commands/          # Command implementations
│   ├── install.rs    # Uses: shell, paths, fs_helpers
│   ├── uninstall.rs  # Uses: shell, paths
│   └── ...
├── utils/            # Shared utilities
│   ├── mod.rs
│   ├── shell.rs      # Shell detection & configuration
│   ├── paths.rs      # Path utilities
│   └── fs_helpers.rs # File system operations
└── main.rs
```

---

## Module: `utils::shell`

**Purpose:** Shell detection, configuration, and code generation

### Types

#### `ShellType` Enum

```rust
pub enum ShellType {
    Bash,
    Zsh,
    Fish,
    PowerShell,
    WslBash,
}
```

### Functions

| Function                        | Purpose                               | Return Type                 |
| ------------------------------- | ------------------------------------- | --------------------------- |
| `detect_current_shell()`        | Auto-detect shell from environment    | `ShellType`                 |
| `get_available_shells()`        | List shells available on system       | `Vec<ShellType>`            |
| `generate_init_code(shell)`     | Generate shell-specific init code     | `String`                    |
| `get_reload_command(shell)`     | Get shell reload command              | `&str`                      |
| `parse_shell_type(shell_str)`   | Parse shell type with validation      | `Result<ShellType, String>` |
| `is_supported_shell(shell_str)` | Check if shell name is supported      | `bool`                      |
| `get_supported_shell_names()`   | Get list of all supported shell names | `Vec<&'static str>`         |

### Usage Example

```rust
use crate::utils::shell;

let current = shell::detect_current_shell();
println!("Detected: {}", current.as_str());

let available = shell::get_available_shells();
for shell in available {
    println!("Available: {}", shell.as_str());
}

let init_code = shell::generate_init_code(&current);
// Write to profile...

// Parse shell from string
if let Ok(shell) = shell::parse_shell_type("zsh") {
    println!("Parsed: {}", shell.as_str());
}

// Validate user input
if shell::is_supported_shell("fish") {
    println!("Fish is supported!");
}

// Show all supported shells
for name in shell::get_supported_shell_names() {
    println!("Supported: {}", name);
}
```

---

## Module: `utils::paths`

**Purpose:** Path management for shell profiles and configuration

### Functions

| Function                         | Purpose                            | Return Type |
| -------------------------------- | ---------------------------------- | ----------- |
| `get_shell_profile_path(shell)`  | Get profile path for shell         | `PathBuf`   |
| `get_config_dir()`               | Get ProfileCore config directory   | `PathBuf`   |
| `is_profilecore_installed(path)` | Check if ProfileCore is in profile | `bool`      |

### Usage Example

```rust
use crate::utils::{shell, paths};

let current_shell = shell::detect_current_shell();
let profile_path = paths::get_shell_profile_path(&current_shell);
let config_dir = paths::get_config_dir();

if paths::is_profilecore_installed(&profile_path) {
    println!("Already installed!");
}
```

---

## Module: `utils::fs_helpers`

**Purpose:** Safe file system operations with error handling

### Functions

| Function                                  | Purpose                         | Return Type                  |
| ----------------------------------------- | ------------------------------- | ---------------------------- |
| `backup_file(path)`                       | Create .bak backup              | `Result<PathBuf, io::Error>` |
| `ensure_dir_exists(path)`                 | Create directory if needed      | `Result<(), io::Error>`      |
| `append_to_file(path, content)`           | Append to file safely           | `Result<(), io::Error>`      |
| `is_in_path(binary)`                      | Check if binary is in PATH      | `bool`                       |
| `print_file_op_result(op, path, success)` | Print operation result          | `()`                         |
| `backup_file_verbose(path)`               | Backup with printed feedback    | `Result<PathBuf, io::Error>` |
| `ensure_dir_exists_verbose(path)`         | Create directory with feedback  | `Result<(), io::Error>`      |
| `append_to_file_verbose(path, content)`   | Append to file with feedback    | `Result<(), io::Error>`      |
| `check_file_exists(path)`                 | Check file exists with feedback | `bool`                       |

### Usage Example

```rust
use crate::utils::fs_helpers;
use std::path::PathBuf;

let profile = PathBuf::from("/path/to/.bashrc");

// Backup
if let Ok(backup) = fs_helpers::backup_file(&profile) {
    println!("Backed up to: {}", backup.display());
}

// Append content
let init_code = "# ProfileCore init\neval \"$(profilecore init bash)\"\n";
fs_helpers::append_to_file(&profile, init_code)?;

// Check PATH
if fs_helpers::is_in_path("profilecore") {
    println!("✓ Found in PATH");
}

// Verbose operations with automatic feedback
fs_helpers::backup_file_verbose(&profile)?;
fs_helpers::ensure_dir_exists_verbose(&config_dir)?;
fs_helpers::append_to_file_verbose(&profile, init_code)?;

// Check file with feedback
if fs_helpers::check_file_exists(&profile) {
    println!("Profile is ready!");
}
```

---

## Benefits

### 1. Code Reduction

- **Before:** Duplicated shell detection, path logic in multiple commands
- **After:** Single source of truth in `utils/` modules
- **Result:** ~40% less duplication

### 2. Consistency

All commands use the same:

- Shell detection logic
- Profile path resolution
- File backup procedures
- Error handling patterns

### 3. Maintainability

- **Single Update Point:** Fix a bug once, all commands benefit
- **Easy Testing:** Unit tests in each util module
- **Clear Dependencies:** Explicit `use crate::utils::*`

### 4. Type Safety

- Enum-based `ShellType` prevents string typos
- Result types for error handling
- PathBuf for safe path operations

---

## Refactoring Example

### Before (Duplicated Code)

```rust
// commands/install.rs
fn detect_shell() -> String {
    if let Ok(shell_path) = env::var("SHELL") {
        if shell_path.contains("bash") {
            return "bash".to_string();
        }
        // ... more logic
    }
    "bash".to_string()
}

// commands/configure.rs
fn detect_shell() -> String {
    // Same logic duplicated!
    if let Ok(shell_path) = env::var("SHELL") {
        if shell_path.contains("bash") {
            return "bash".to_string();
        }
    }
    "bash".to_string()
}
```

### After (Shared Library)

```rust
// commands/install.rs
use crate::utils::shell;

pub fn run_installer() {
    let current_shell = shell::detect_current_shell();
    // Use shell...
}

// commands/configure.rs
use crate::utils::shell;

pub fn configure() {
    let current_shell = shell::detect_current_shell();
    // Use shell...
}
```

---

## Testing

Each utility module includes unit tests:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_shell_type_conversion() {
        assert_eq!(ShellType::from_str("bash"), Some(ShellType::Bash));
    }
}
```

Run tests:

```bash
cargo test
cargo test --package profilecore --lib utils::shell
```

---

## Best Practices

### 1. Always Use Typed Enums

```rust
// ❌ Bad - stringly typed
let shell = "bash";

// ✅ Good - type-safe
let shell = ShellType::Bash;
```

### 2. Handle Errors Properly

```rust
// ❌ Bad - unwrap can panic
let backup = fs_helpers::backup_file(&path).unwrap();

// ✅ Good - handle error
if let Ok(backup) = fs_helpers::backup_file(&path) {
    println!("Backed up to: {}", backup.display());
} else {
    println!("Warning: Could not backup file");
}
```

### 3. Use Result Types

```rust
// ❌ Bad - returns success bool, no error info
pub fn backup_file(path: &PathBuf) -> bool

// ✅ Good - returns Result with error details
pub fn backup_file(path: &PathBuf) -> Result<PathBuf, io::Error>
```

### 4. Add Tests for New Functions

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_new_function() {
        let temp_dir = TempDir::new().unwrap();
        // Test implementation...
    }
}
```

---

## Future Enhancements

Planned utilities:

### v1.1.0

- `utils::network` - Network helpers (download with progress, connectivity checks)
- `utils::validation` - Input validation helpers
- `utils::output` - Formatted output helpers (tables, progress bars)

### v1.2.0

- `utils::config` - Configuration file management
- `utils::logging` - Logging infrastructure
- `utils::telemetry` - Anonymous usage statistics

---

## Migration Guide

### Adding a New Shared Utility

1. **Create module file:**

```bash
touch src/utils/new_util.rs
```

2. **Add to `utils/mod.rs`:**

```rust
pub mod new_util;
```

3. **Implement with tests:**

```rust
// src/utils/new_util.rs
pub fn my_function() -> String {
    "result".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_my_function() {
        assert_eq!(my_function(), "result");
    }
}
```

4. **Use in commands:**

```rust
use crate::utils::new_util;

pub fn my_command() {
    let result = new_util::my_function();
}
```

---

## Related Documentation

- **[Installation Improvements](INSTALLATION_IMPROVEMENTS.md)** - Install command architecture
- **[Contributing Guide](contributing.md)** - How to contribute
- **[Testing Guide](testing.md)** - Testing practices

---

**ProfileCore Shared Libraries** - Building a maintainable, type-safe codebase 🦀
