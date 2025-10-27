# ProfileCore v1.0.0 - Official Release 🎉

**Release Date:** October 27, 2025  
**Binary Size:** 9.94 MB  
**Total Commands:** 97  
**Platforms:** Windows, macOS, Linux  
**Shells:** bash, zsh, fish, PowerShell

---

## 🎯 What is ProfileCore?

ProfileCore is a **unified cross-shell interface** that provides 97 powerful commands for system administration, development, and daily computing tasks. Written in Rust for maximum performance and reliability.

**Philosophy**: Don't reinvent the wheel. Wrap mature, battle-tested libraries (`git2`, `bollard`, `rustls`, `sysinfo`) rather than reimplementing everything.

---

## ✨ Highlights

### 🚀 Complete Feature Set

- **97 Commands** across 17 categories
- **4 Shell Support**: bash, zsh, fish, PowerShell
- **3 Platforms**: Windows, macOS, Linux
- **Full Tab Completion** for all shells

### ⚡ Performance

- **<50ms** cold start (vs ~180ms for v6.0.0 PowerShell)
- **~160ns** argument parsing with gumdrop
- **9.94 MB** optimized binary (under 10MB target!)

### 🛠️ Production Quality

- Zero code warnings (clean compilation)
- Comprehensive error handling
- Cross-platform compatibility
- Rich terminal UX with colored output and tables

---

## 📦 All 97 Commands

### System Information (12 commands)

- `system info` - Comprehensive system information
- `system uptime` - System uptime
- `system processes` - Top processes by memory
- `system disk-usage` - Disk usage for all mounts
- `system memory` - Memory statistics
- `system cpu` - CPU usage per core
- `system load` - System load average
- `system network-stats` - Network interface statistics
- `system temperature` - Temperature sensors
- `system users` - List system users
- `system service-list` - List all services
- `system service-status` - Check service status

### Network Utilities (8 commands)

- `network public-ip` - Get public IP address
- `network test-port` - Test TCP connectivity
- `network local-ips` - List local network IPs
- `network dns` - DNS lookup (A/AAAA/MX)
- `network reverse-dns` - Reverse DNS (PTR)
- `network whois` - WHOIS domain lookup
- `network trace` - Traceroute to host
- `network ping` - Ping host

### Git Operations (16 commands)

- `git status` - Repository status
- `git log` - Commit history
- `git diff` - Working tree changes
- `git branch` - List branches
- `git remote` - List remotes
- `git switch-account` - Switch git account
- `git add-account` - Add new git account
- `git list-accounts` - List configured accounts
- `git whoami` - Show current identity
- `git clone` - Clone repository
- `git pull` - Pull from remote
- `git push` - Push to remote
- `git stash` - Stash changes
- `git commit` - Create commit
- `git tag` - Create/list tags
- `git rebase` - Rebase branch

### Docker Integration (3 commands)

- `docker ps` - List containers
- `docker stats` - Container resource stats
- `docker logs` - Container logs

### Security Tools (4 commands)

- `security ssl-check` - Check SSL certificate
- `security gen-password` - Generate secure password
- `security check-password` - Check password strength
- `security hash-password` - Hash password (argon2/bcrypt)

### Package Management (7 commands)

- `package install` - Install package (auto-detect PM)
- `package list` - List installed packages
- `package search` - Search for packages
- `package update` - Update package lists
- `package upgrade` - Upgrade package
- `package remove` - Remove package
- `package info` - Show package information

### File Operations (5 commands)

- `file hash` - Calculate file hash (MD5/SHA256)
- `file size` - Get file/directory size
- `file find` - Find files by pattern
- `file permissions` - Show file permissions
- `file type` - Detect file type

### Environment Variables (3 commands)

- `env list` - List all environment variables
- `env get` - Get environment variable
- `env set` - Set environment variable

### Text Processing (3 commands)

- `text grep` - Search text in files
- `text head` - Show first N lines
- `text tail` - Show last N lines

### Process Management (4 commands)

- `process list` - List running processes
- `process kill` - Terminate process
- `process info` - Show process information
- `process tree` - Show process tree

### Archive Operations (3 commands)

- `archive compress` - Compress files/directories
- `archive extract` - Extract archive
- `archive list` - List archive contents

### String Utilities (3 commands)

- `string base64` - Base64 encode/decode
- `string url-encode` - URL encode/decode
- `string hash` - Hash string (MD5/SHA256)

### HTTP Utilities (4 commands)

- `http get` - HTTP GET request
- `http post` - HTTP POST request
- `http download` - Download file from URL
- `http head` - HTTP HEAD request

### Data Processing (3 commands)

- `data json` - Format or minify JSON
- `data yaml-to-json` - Convert YAML to JSON
- `data json-to-yaml` - Convert JSON to YAML

### Shell Utilities (5 commands)

- `shell history` - Show shell history
- `shell which` - Find command in PATH
- `shell exec` - Execute command
- `shell path` - Show PATH variable
- `shell alias` - List ProfileCore aliases

### Utility Commands (10 commands)

- `utils calc` - Calculator (math expressions)
- `utils random` - Random number generator
- `utils random-string` - Random string generator
- `utils sleep` - Sleep/delay
- `utils time` - Show current time
- `utils timezone` - Show time zones
- `utils version` - Show version information
- `utils config-get` - Get configuration value
- `utils config-set` - Set configuration value
- `utils config-list` - List configuration

### Initialization & Maintenance (4 commands)

- `init <shell>` - Generate shell initialization code
- `completions <shell>` - Generate shell completions
- `uninstall-legacy` - Remove v6.0.0 PowerShell modules
- `--version` - Show version
- `--help` - Show help

---

## 🛠️ Tech Stack

### Core Libraries

- **gumdrop** 0.8 - Ultra-fast argument parsing (~160ns)
- **sysinfo** 0.31 - System information, processes, sensors
- **git2** 0.18 - Git operations & repository management
- **bollard** 0.17 - Docker client (async API)
- **trust-dns-resolver** 0.23 - DNS resolution (A/AAAA/MX/PTR)
- **rustls** 0.23 - TLS/SSL checking
- **argon2** 0.5, **bcrypt** 0.15, **zxcvbn** 3.1 - Password tools
- **reqwest** 0.12 - HTTP client (GET/POST/HEAD/download)

### Utilities

- **which** 6.0 - Find executables in PATH
- **tokio** 1.x + **futures** 0.3 - Async runtime
- **meval** 0.2 - Mathematical expression evaluation
- **flate2**, **tar**, **zip** - Archive operations
- **base64** 0.22, **urlencoding** 2.1 - String utilities
- **serde**, **serde_json**, **serde_yaml**, **toml** - Data processing

### User Experience

- **comfy-table** 7.1 - Beautiful ASCII tables
- **colored** 2.1 - ANSI colors
- **indicatif** 0.17 - Progress bars
- **dialoguer** 0.11 - Interactive prompts

---

## 📥 Installation

### Pre-built Binary (Recommended)

**Linux/macOS:**

```bash
# Download and install
curl -sSL https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-linux-x86_64 -o profilecore
chmod +x profilecore
sudo mv profilecore /usr/local/bin/

# Initialize in your shell
echo 'eval "$(profilecore init bash)"' >> ~/.bashrc  # bash
echo 'eval "$(profilecore init zsh)"' >> ~/.zshrc    # zsh
echo 'profilecore init fish | source' >> ~/.config/fish/config.fish  # fish
```

**Windows (PowerShell):**

```powershell
# Download and install
irm https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-windows-x86_64.exe -OutFile profilecore.exe
# Move to a directory in your PATH (e.g., C:\Program Files\ProfileCore\)

# Initialize in your profile
Add-Content $PROFILE "`nInvoke-Expression (& profilecore init powershell)"
```

### Build from Source

```bash
# Prerequisites: Rust 1.75+
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore
cargo build --release

# Binary will be at: target/release/profilecore
```

---

## 🚀 Quick Start

1. **Install ProfileCore** (see above)
2. **Initialize your shell** (adds aliases and functions)
3. **Enable completions**:
   ```bash
   profilecore completions bash > ~/.bash_completion.d/profilecore  # bash
   profilecore completions zsh > ~/.zsh/completions/_profilecore    # zsh
   profilecore completions fish > ~/.config/fish/completions/profilecore.fish  # fish
   profilecore completions powershell | Out-String | iex  # PowerShell
   ```
4. **Start using commands**:
   ```bash
   profilecore system info
   profilecore network public-ip
   profilecore git status
   ```

---

## 🎨 Examples

### System Monitoring

```bash
# Get comprehensive system info
profilecore system info

# Check disk usage
profilecore system disk-usage

# Monitor processes
profilecore system processes --limit 10

# Check system load
profilecore system load
```

### Git Multi-Account Management

```bash
# Add git accounts
profilecore git add-account --name work --email work@company.com
profilecore git add-account --name personal --email me@personal.com

# Switch accounts
profilecore git switch-account work

# Check current identity
profilecore git whoami
```

### Network Utilities

```bash
# Check public IP
profilecore network public-ip

# DNS lookup
profilecore network dns example.com

# Test connectivity
profilecore network test-port google.com 443

# Traceroute
profilecore network trace github.com
```

### Data Processing

```bash
# Format JSON
echo '{"name":"test"}' | profilecore data json

# Convert YAML to JSON
cat config.yaml | profilecore data yaml-to-json

# Minify JSON
profilecore data json --minify '{"test": "value"}'
```

### HTTP & Downloads

```bash
# HTTP GET request
profilecore http get https://api.github.com

# Download file
profilecore http download https://example.com/file.zip output.zip

# HTTP HEAD (check headers)
profilecore http head https://example.com
```

---

## 🔄 Migration from v6.0.0

ProfileCore v1.0.0 is a **complete rewrite** in Rust. The old PowerShell modules are deprecated.

### Uninstall v6.0.0

```bash
profilecore uninstall-legacy
```

### Key Differences

- **Language**: Pure Rust (no PowerShell modules)
- **Performance**: 3-4x faster startup
- **Commands**: 97 commands (vs 30 in v6.0.0)
- **Size**: 9.94 MB (vs scattered PowerShell modules)

See `docs/MIGRATION_V1.0.0.md` for detailed migration guide.

---

## 🐛 Known Limitations

1. **Temperature sensors**: May require elevated privileges on some systems
2. **Process tree**: Currently placeholder implementation
3. **Service management**: Read-only on most systems (security by design)

---

## 🤝 Contributing

Contributions welcome! See `docs/developer/contributing.md` for guidelines.

---

## 📜 License

MIT License - See `LICENSE` file

---

## 🙏 Acknowledgments

Built with amazing Rust crates from the community. Special thanks to:

- The Rust team for an incredible language
- All crate authors whose work makes this possible
- The cross-platform system programming community

---

## 📞 Support

- **Issues**: https://github.com/mythic3011/ProfileCore/issues
- **Documentation**: https://github.com/mythic3011/ProfileCore/tree/main/docs
- **Repository**: https://github.com/mythic3011/ProfileCore

---

**🎉 Thank you for using ProfileCore v1.0.0!**

_Built with ❤️ in Rust_
