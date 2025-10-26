# ProfileCore v1.0.0-alpha - Release Notes

**Release Date**: 2025-01-26  
**Status**: Alpha Release  
**Type**: Complete Rewrite

---

## 🎉 What's New

ProfileCore v1.0.0-alpha is a **complete rewrite** from PowerShell to Rust, inspired by [Starship](https://starship.rs)'s architecture.

### ✅ Features

**Architecture**:

- ✅ Single cross-shell binary (`profilecore`)
- ✅ Minimal shell wrappers (3 lines per shell)
- ✅ Dynamic shell initialization
- ✅ Ultra-fast startup (<50ms vs 180ms in v6.0.0)

**Commands**:

- ✅ `profilecore system info` - Beautiful system information display
- ✅ `profilecore network public-ip` - Get your public IP
- ✅ `profilecore network test-port <host> <port>` - TCP port testing
- ✅ `profilecore network local-ips` - Local IP address
- ✅ `profilecore git status` - Git repository status
- ✅ `profilecore security gen-password --length <n>` - Strong password generation
- ✅ `profilecore package install <pkg>` - OS-aware package installation
- ✅ `profilecore uninstall-legacy` - Remove v6.0.0 PowerShell modules

**Shell Support**:

- ✅ Bash (`eval "$(profilecore init bash)"`)
- ✅ Zsh (`eval "$(profilecore init zsh)"`)
- ✅ Fish (`profilecore init fish | source`)
- ✅ PowerShell (`profilecore init powershell | iex`)

**Completions**:

- ✅ Manual completion scripts for all shells
- ✅ `profilecore completions <shell>` to generate

---

## 📊 Performance

| Metric               | v6.0.0 (PowerShell) | v1.0.0-alpha (Rust)  | Improvement    |
| -------------------- | ------------------- | -------------------- | -------------- |
| **Startup Time**     | ~180ms              | **<50ms**            | **73% faster** |
| **Binary Size**      | N/A (interpreted)   | **4.3MB**            | Tiny           |
| **Memory Usage**     | ~25MB               | **~5MB**             | **80% less**   |
| **Argument Parsing** | PowerShell          | **~160ns** (gumdrop) | Ultra-fast     |

---

## ⚠️ Breaking Changes

**This is a complete rewrite**. All PowerShell modules have been removed.

### Migration Required

See **[MIGRATION_V1.0.0.md](MIGRATION_V1.0.0.md)** for full migration guide.

**Quick migration**:

```bash
# 1. Uninstall v6.0.0
profilecore uninstall-legacy

# 2. Update shell config
# OLD: Import-Module ProfileCore
# NEW: eval "$(profilecore init bash)"  # or zsh/fish/powershell
```

---

## 📦 Installation

### Option 1: Download Binary (Recommended)

**Windows**:

```powershell
# Download from GitHub Releases
# https://github.com/mythic3011/ProfileCore/releases/tag/v1.0.0-alpha
# Extract profilecore.exe to a directory in your PATH
```

**macOS/Linux**:

```bash
# Download from GitHub Releases
curl -L https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0-alpha/profilecore-<os> -o profilecore
chmod +x profilecore
sudo mv profilecore /usr/local/bin/
```

### Option 2: Build from Source

```bash
git clone https://github.com/mythic3011/ProfileCore
cd ProfileCore
cargo build --release
# Binary: target/release/profilecore
```

### Shell Configuration

**Bash** (`~/.bashrc`):

```bash
eval "$(profilecore init bash)"
```

**Zsh** (`~/.zshrc`):

```zsh
eval "$(profilecore init zsh)"
```

**Fish** (`~/.config/fish/config.fish`):

```fish
profilecore init fish | source
```

**PowerShell** (`$PROFILE`):

```powershell
profilecore init powershell | Invoke-Expression
```

---

## 🧪 Testing

This is an **alpha release** for early adopters and testing.

**Test Coverage**:

- ✅ 8 unit tests passing
- ✅ CI/CD: GitHub Actions (test + build on Windows, macOS, Linux)
- ⚠️ Limited integration testing

**Known Limitations**:

- Only 10/97 commands from v6.0.0 implemented (11%)
- Some commands are placeholders (docker, ssl-check, git multi-account)
- No backward compatibility with v6.0.0 PowerShell modules

---

## 🗺️ Roadmap

**v1.0.0-beta** (2-3 weeks):

- Docker integration (bollard)
- DNS tools (trust-dns)
- Security tools (rustls, zxcvbn)
- Git multi-account with config
- 20+ more commands

**v1.0.0** (6-8 weeks):

- All 97 commands from v6.0.0 migrated
- Comprehensive testing
- Universal installer
- Full documentation

---

## 📚 Documentation

- **[README.md](../README.md)** - Project overview
- **[MIGRATION_V1.0.0.md](MIGRATION_V1.0.0.md)** - Migration guide
- **[NEXT_STEPS.md](NEXT_STEPS.md)** - Development roadmap
- **[CHANGELOG.md](../CHANGELOG.md)** - Full changelog

---

## 🐛 Known Issues

1. **Placeholder commands**: `docker ps`, `security ssl-check`, `git switch-account` print messages but don't fully work yet
2. **No JSON output**: Most commands don't support `--format json` yet
3. **No configuration**: No `~/.config/profilecore/config.toml` yet
4. **Limited error handling**: Some error messages could be more helpful

---

## 🙏 Feedback

Please report issues and request features:

- **GitHub Issues**: https://github.com/mythic3011/ProfileCore/issues
- **Discussions**: https://github.com/mythic3011/ProfileCore/discussions

---

## 📊 Statistics

- **Lines of Rust**: ~1,500
- **Commands**: 10 implemented, 87 planned
- **Dependencies**: 20 crates
- **Binary size**: 4.3MB (release)
- **Test suite**: 8 tests
- **Shells supported**: 4 (bash, zsh, fish, PowerShell)
- **Platforms**: 3 (Windows, macOS, Linux)

---

## 🎓 Technical Details

**Architecture**: Starship-inspired CLI

- Minimal shell wrappers (not complex scripts)
- All logic in Rust binary
- Dynamic code generation
- Smart library wrappers

**Dependencies**:

- `gumdrop` 0.8 - Ultra-fast parsing (~160ns)
- `sysinfo` 0.31 - System information
- `git2` 0.18 - Git operations
- `bollard` 0.17 - Docker client
- `trust-dns-resolver` 0.23 - DNS
- `rustls` 0.23 - TLS/SSL
- `reqwest` 0.12 - HTTP client
- `comfy-table` 7.1 - Beautiful tables
- `colored` 2.1 - ANSI colors
- `indicatif` 0.17 - Progress bars
- `dialoguer` 0.11 - Interactive prompts

---

## 🚀 Try It!

```bash
# System info
profilecore system info

# Network utilities
profilecore network public-ip
profilecore network test-port google.com 443

# Security
profilecore security gen-password --length 20

# Git
profilecore git status

# Shell functions (after init)
sysinfo       # alias for: profilecore system info
publicip      # alias for: profilecore network public-ip
gitstatus     # alias for: profilecore git status
genpass       # alias for: profilecore security gen-password
```

---

## 🎉 Thank You!

Thank you for trying ProfileCore v1.0.0-alpha! This is a complete rewrite and your feedback will shape the future of the project.

**Status**: Alpha - Expect bugs, missing features, breaking changes  
**Next Release**: v1.0.0-beta (2-3 weeks)  
**Architecture**: Starship-inspired, gumdrop-powered, Rust-native

---

_Built with ❤️ using Rust, gumdrop, and Starship's architecture principles_  
_ProfileCore v1.0.0 - Unified Cross-Shell Interface to Mature Tools_
