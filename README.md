# ProfileCore v1.0.0 🚀

[![Rust](https://img.shields.io/badge/Rust-1.75%2B-orange.svg)](https://www.rust-lang.org/)
[![Shells](https://img.shields.io/badge/Shells-bash%20%7C%20zsh%20%7C%20fish%20%7C%20pwsh-success.svg)](https://github.com/mythic3011/ProfileCore)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/mythic3011/ProfileCore)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Startup](https://img.shields.io/badge/startup-<50ms-brightgreen)](#performance)

**Unified cross-shell interface to mature system tools**

ProfileCore v1.0.0 is a complete rewrite in Rust, following Starship's architecture: minimal shell wrappers, fast startup with gumdrop parsing (~160ns), smart wrappers around mature libraries (git2, bollard, rustls) instead of reimplementing everything.

**What's New in v1.0.0:** 🚀 Pure Rust CLI | ⚡ <50ms Startup | 🌍 Cross-Shell | 📦 Smart Wrappers

---

## 🎯 Philosophy

**Don't reinvent the wheel.** ProfileCore wraps best-in-class libraries/tools:

- **Git**: `git2` library (not reimplemented)
- **Docker**: `bollard` library (not reimplemented)
- **SSL/TLS**: `rustls` library (not reimplemented)
- **DNS**: `trust-dns` library (not reimplemented)
- **Package Management**: External CLIs (apt/brew/choco/winget)

**Result**: Fast, maintainable, production-quality tools.

---

## ✨ Features

### 🐚 Cross-Shell Support

One binary, all shells:

- **Bash** - `eval "$(profilecore init bash)"`
- **Zsh** - `eval "$(profilecore init zsh)"`
- **Fish** - `profilecore init fish | source`
- **PowerShell** - `profilecore init powershell | iex`

Dynamic shell function generation - no hardcoded shell scripts!

### ⚡ Commands (v1.0.0)

**System** (sysinfo):

```bash
profilecore system info              # Beautiful UTF-8 table
sysinfo                               # Alias
```

**Network** (reqwest, std::net):

```bash
profilecore network public-ip        # Get public IP
profilecore network test-port localhost 80
profilecore network local-ips
# Aliases: publicip, testport, localips
```

**Git** (git2):

```bash
profilecore git status               # Repository status
profilecore git switch-account work  # Multi-account (config TBD)
# Aliases: gitstatus, git-switch
```

**Docker** (bollard - placeholder):

```bash
profilecore docker ps                # List containers
dps                                   # Alias
```

**Security** (rustls, argon2, bcrypt, rand):

```bash
profilecore security ssl-check example.com
profilecore security gen-password --length 20
# Aliases: sslcheck, genpass
```

**Package** (external CLIs):

```bash
profilecore package install git      # Auto-detects OS package manager
pkginstall git                        # Alias
```

**Maintenance**:

```bash
profilecore uninstall-legacy         # Remove v6.0.0 PowerShell modules
```

### 🚀 Performance

- **Startup**: <50ms cold start (vs ~180ms for v6.0.0 PowerShell)
- **Parsing**: ~160ns with gumdrop (vs 5-10ms with clap)
- **Binary**: Target <15MB (release build)

### 🛠️ Tech Stack

**Fast & Minimal**:

- `gumdrop` 0.8 - Ultra-fast argument parsing
- `sysinfo` 0.31 - System information
- `git2` 0.18 - Git operations
- `bollard` 0.17 - Docker client
- `trust-dns-resolver` 0.23 - DNS
- `rustls` 0.23 - TLS/SSL
- `argon2` 0.5, `bcrypt` 0.15 - Password hashing
- `reqwest` 0.12 - HTTP client
- `which` 6.0 - Executable detection
- `tokio` 1.x - Async runtime
- `comfy-table` 7.1, `colored` 2.1 - UX

---

## 📥 Installation

### Option A: Pre-built Binary (Recommended)

```bash
# Download from GitHub Releases
# https://github.com/mythic3011/ProfileCore/releases/tag/v1.0.0

# Linux/macOS
curl -sSL https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-linux-x86_64 -o profilecore
chmod +x profilecore
sudo mv profilecore /usr/local/bin/

# Windows (PowerShell)
irm https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-windows-x86_64.exe -OutFile profilecore.exe
# Move to a directory in your PATH
```

### Option B: Build from Source

```bash
# Prerequisites: Rust 1.75+
git clone https://github.com/mythic3011/ProfileCore
cd ProfileCore
cargo build --release

# Binary at: target/release/profilecore
# Add to PATH or copy to /usr/local/bin/ (Unix) or a directory in PATH (Windows)
```

### Shell Integration

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

**Restart your shell** to activate ProfileCore.

---

## 🚀 Quick Start

```bash
# Check installation
profilecore --version

# Get system info
profilecore system info
sysinfo  # or use alias

# Get public IP
profilecore network public-ip
publicip  # or use alias

# Test port
profilecore network test-port google.com 443

# Git status (in a git repository)
profilecore git status
gitstatus  # or use alias

# Generate password
profilecore security gen-password --length 20
genpass 20  # or use alias

# Show help
profilecore --help
```

---

## 📖 Documentation

- **[MIGRATION_V1.0.0.md](docs/MIGRATION_V1.0.0.md)** - Migrate from v6.0.0 PowerShell
- **[CHANGELOG.md](CHANGELOG.md)** - Full change history
- **User Guides**: `docs/user-guide/`
- **Developer Docs**: `docs/developer/`

---

## 🔄 Upgrading from v6.0.0

**⚠️ BREAKING CHANGES**: v1.0.0 is a complete rewrite. All PowerShell modules removed.

**Quick steps**:

1. `profilecore uninstall-legacy` (removes v6.0.0)
2. Install v1.0.0 binary (see [Installation](#installation))
3. Replace `Import-Module ProfileCore` with `eval "$(profilecore init bash)"`
4. Restart shell

See [MIGRATION_V1.0.0.md](docs/MIGRATION_V1.0.0.md) for complete guide and command mapping.

---

## 🗺️ Roadmap

### v1.1.0 (Coming Soon)

- Complete git2 multi-account with config file
- Full bollard Docker integration
- Full rustls SSL certificate validation
- DNS tools with trust-dns
- WHOIS lookup (external CLI wrapper)

### v1.2.0+

- Password strength checking (zxcvbn)
- Port scanning (rustscan wrapper)
- Remaining 70+ commands from v6.0.0

### Long-term

- Plugin system
- Cloud sync (config)
- AI features

---

## 🤝 Contributing

Contributions welcome! Please see [docs/developer/contributing.md](docs/developer/contributing.md).

**Priority areas**:

- Implement remaining commands from v6.0.0
- Complete git2 multi-account configuration
- Full bollard Docker integration
- Documentation improvements

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- **Starship** - Architecture inspiration
- **Rust community** - Amazing libraries (sysinfo, git2, bollard, rustls, trust-dns, etc.)
- **ProfileCore v6.0.0** - PowerShell foundation (now legacy)

---

## 📊 Stats

- **Commands**: 10 core (70+ planned)
- **Binary size**: ~8MB (release build)
- **Startup time**: <50ms
- **Parsing speed**: ~160ns (gumdrop)
- **Supported shells**: 4 (bash, zsh, fish, PowerShell)
- **Platforms**: 3 (Windows, macOS, Linux)

---

**Star ⭐ this repo if ProfileCore makes your shell more powerful!**
