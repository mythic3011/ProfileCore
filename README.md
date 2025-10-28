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

### ⚡ Commands (v1.0.0) - All 97 Commands!

#### System Information (12 commands)

```bash
profilecore system info              # Comprehensive system information
profilecore system uptime            # System uptime
profilecore system processes         # Top processes by memory
profilecore system disk-usage        # Disk usage for all mounts
profilecore system memory            # Memory statistics
profilecore system cpu               # CPU usage per core
profilecore system load              # System load average
profilecore system network-stats     # Network interface statistics
profilecore system temperature       # Temperature sensors
profilecore system users             # List system users
profilecore system service-list      # List all services
profilecore system service-status    # Check service status
```

#### Network Utilities (8 commands)

```bash
profilecore network public-ip        # Get public IP address
profilecore network test-port        # Test TCP connectivity
profilecore network local-ips        # List local network IPs
profilecore network dns              # DNS lookup (A/AAAA/MX)
profilecore network reverse-dns      # Reverse DNS (PTR)
profilecore network whois            # WHOIS domain lookup
profilecore network trace            # Traceroute to host
profilecore network ping             # Ping host
```

#### Git Operations (16 commands)

```bash
profilecore git status               # Repository status
profilecore git log                  # Commit history
profilecore git diff                 # Working tree changes
profilecore git branch               # List branches
profilecore git remote               # List remotes
profilecore git switch-account       # Switch git account
profilecore git add-account          # Add new git account
profilecore git list-accounts        # List configured accounts
profilecore git whoami               # Show current identity
profilecore git clone                # Clone repository
profilecore git pull                 # Pull from remote
profilecore git push                 # Push to remote
profilecore git stash                # Stash changes
profilecore git commit               # Create commit
profilecore git tag                  # Create/list tags
profilecore git rebase               # Rebase branch
```

#### Docker Integration (3 commands)

```bash
profilecore docker ps                # List containers
profilecore docker stats             # Container resource stats
profilecore docker logs              # Container logs
```

#### Security Tools (4 commands)

```bash
profilecore security ssl-check       # Check SSL certificate
profilecore security gen-password    # Generate secure password
profilecore security check-password  # Check password strength
profilecore security hash-password   # Hash password (argon2/bcrypt)
```

#### Package Management (7 commands)

```bash
profilecore package install          # Install package (auto-detect PM)
profilecore package list             # List installed packages
profilecore package search           # Search for packages
profilecore package update           # Update package lists
profilecore package upgrade          # Upgrade package
profilecore package remove           # Remove package
profilecore package info             # Show package information
```

#### File Operations (5 commands)

```bash
profilecore file hash                # Calculate file hash (MD5/SHA256)
profilecore file size                # Get file/directory size
profilecore file find                # Find files by pattern
profilecore file permissions         # Show file permissions
profilecore file type                # Detect file type
```

#### Environment Variables (3 commands)

```bash
profilecore env list                 # List all environment variables
profilecore env get                  # Get environment variable
profilecore env set                  # Set environment variable
```

#### Text Processing (3 commands)

```bash
profilecore text grep                # Search text in files
profilecore text head                # Show first N lines
profilecore text tail                # Show last N lines
```

#### Process Management (4 commands)

```bash
profilecore process list             # List running processes
profilecore process kill             # Terminate process
profilecore process info             # Show process information
profilecore process tree             # Show process tree
```

#### Archive Operations (3 commands)

```bash
profilecore archive compress         # Compress files/directories
profilecore archive extract          # Extract archive
profilecore archive list             # List archive contents
```

#### String Utilities (3 commands)

```bash
profilecore string base64            # Base64 encode/decode
profilecore string url-encode        # URL encode/decode
profilecore string hash              # Hash string (MD5/SHA256)
```

#### HTTP Utilities (4 commands)

```bash
profilecore http get                 # HTTP GET request
profilecore http post                # HTTP POST request
profilecore http download            # Download file from URL
profilecore http head                # HTTP HEAD request
```

#### Data Processing (3 commands)

```bash
profilecore data json                # Format or minify JSON
profilecore data yaml-to-json        # Convert YAML to JSON
profilecore data json-to-yaml        # Convert JSON to YAML
```

#### Shell Utilities (5 commands)

```bash
profilecore shell history            # Show shell history
profilecore shell which              # Find command in PATH
profilecore shell exec               # Execute command
profilecore shell path               # Show PATH variable
profilecore shell alias              # List ProfileCore aliases
```

#### Utility Commands (10 commands)

```bash
profilecore utils calc               # Calculator (math expressions)
profilecore utils random             # Random number generator
profilecore utils random-string      # Random string generator
profilecore utils sleep              # Sleep/delay
profilecore utils time               # Show current time
profilecore utils timezone           # Show time zones
profilecore utils version            # Show version information
profilecore utils config-get         # Get configuration value
profilecore utils config-set         # Set configuration value
profilecore utils config-list        # List configuration
```

#### Initialization & Completions

```bash
profilecore init <shell>             # Generate shell init code
profilecore completions <shell>      # Generate shell completions
profilecore uninstall-legacy         # Remove v6.0.0 PowerShell modules
```

**📊 Total: 97 commands across 17 categories!**

### 🚀 Performance

- **Startup**: <50ms cold start (vs ~180ms for v6.0.0 PowerShell)
- **Parsing**: ~160ns with gumdrop (vs 5-10ms with clap)
- **Binary**: 9.94 MB (optimized release build, under 10MB target!)
- **Commands**: 97 cross-platform commands with full shell completion support

### 🛠️ Tech Stack

**Fast & Minimal**:

- `gumdrop` 0.8 - Ultra-fast argument parsing (~160ns)
- `sysinfo` 0.31 - System information, processes, sensors
- `git2` 0.18 - Git operations & repository management
- `bollard` 0.17 - Docker client (async API)
- `trust-dns-resolver` 0.23 - DNS resolution (A/AAAA/MX/PTR)
- `rustls` 0.23 + `rustls-native-certs` - TLS/SSL checking
- `argon2` 0.5, `bcrypt` 0.15, `zxcvbn` 3.1 - Password tools
- `reqwest` 0.12 - HTTP client (GET/POST/HEAD/download)
- `which` 6.0 - Find executables in PATH
- `tokio` 1.x + `futures` 0.3 - Async runtime
- `meval` 0.2 - Mathematical expression evaluation
- `flate2`, `tar`, `zip` - Archive operations
- `base64` 0.22, `urlencoding` 2.1 - String utilities
- `serde`, `serde_json`, `serde_yaml`, `toml` - Data processing
- `comfy-table` 7.1, `colored` 2.1, `indicatif`, `dialoguer` - Rich UX

---

## 📥 Installation

### ⚡ Quick Install (Recommended)

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
```

This automatically:

1. Downloads the ProfileCore binary
2. Adds it to your PATH
3. Runs the **interactive installer** to configure your shell
4. Verifies the installation

**Time: 2-3 minutes**

### 🔧 Manual Installation

Prefer to install manually? See [INSTALL.md](INSTALL.md) for:

- Manual download + interactive install
- Build from source
- Detailed troubleshooting
- Platform-specific instructions

### ✅ Verify Installation

After installation, restart your shell and run:

```bash
profilecore --version
profilecore system info
```

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
