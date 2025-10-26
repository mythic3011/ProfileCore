# ProfileCore Quick Start Guide 🚀

**Get ProfileCore running in 5 minutes or less!**

---

## ⚡ 1. Install ProfileCore

### One-Line Installation (Recommended)

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
```

**macOS/Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
```

**⏱️ Time:** 2-5 minutes | **📦 What it does:** Clones repo, installs, prompts for config

### Alternative: Standard Installation

```bash
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore

# Windows
.\scripts\installation\install.ps1

# macOS/Linux
chmod +x ./scripts/installation/install.sh
./scripts/installation/install.sh
```

**📖 More options:** See [INSTALL.md](INSTALL.md) for advanced installation

---

## ✅ 2. Verify Installation

**Quick Test:**

```bash
# PowerShell
. $PROFILE
Get-OperatingSystem

# Unix (Zsh/Bash/Fish)
source ~/.zshrc     # or ~/.bashrc
get_os
```

**Validate Installation:**

```bash
# PowerShell
.\scripts\installation\install.ps1 -Validate

# Unix
./scripts/installation/install.sh --validate
```

---

## 🎯 3. Essential Commands

### Core Functions

| Command          | PowerShell            | Unix       | Description    |
| ---------------- | --------------------- | ---------- | -------------- |
| **OS Info**      | `Get-OperatingSystem` | `get_os`   | Check your OS  |
| **Public IP**    | `Get-PublicIP`        | `myip`     | Get public IP  |
| **System Info**  | `Get-SystemInfo`      | `sysinfo`  | System details |
| **Connectivity** | -                     | `netcheck` | Test internet  |

### Package Management

```bash
pkgs python          # Search packages
pkg neovim           # Install package
pkgu                 # Update all
```

### v4.0 Security Tools

```bash
scan-port google.com 443     # Port scanner
check-ssl github.com         # SSL checker
gen-password                 # Password generator
dns-lookup example.com       # DNS info
whois-lookup example.com     # WHOIS lookup
```

### v4.0 Developer Tools

```bash
quick-commit "feat: update"  # Quick Git commit
docker-status                # Docker containers
init-project my-app nodejs   # Project scaffolding
```

### v4.0 System Admin

```bash
sysinfo                      # System information
top-processes                # Process monitor
diskinfo                     # Disk usage
```

---

## ⚙️ 4. Configuration (Optional)

### Quick Config

```bash
# PowerShell - Interactive wizard
Initialize-ProfileCoreConfig

# Unix - Edit environment file
nano ~/.config/shell-profile/.env
```

### Add API Keys

```bash
# Edit ~/.config/shell-profile/.env
export GITHUB_TOKEN="your_token"
export OPENAI_API_KEY="your_key"
```

### Config Files

```
~/.config/shell-profile/
├── config.json      # Feature toggles
├── paths.json       # App paths
├── aliases.json     # Custom aliases
└── .env             # API keys
```

---

## 🚀 5. Common Workflows

### Developer Workflow

```bash
# Git
quick-commit "feat: update"      # Quick commit
git-cleanup                      # Clean branches
new-branch feature/name          # New branch

# Docker
docker-status                    # Check containers
dc-up                            # Compose up
dc-down                          # Compose down

# Projects
init-project my-app nodejs       # New Node.js project
```

### Security & Network

```bash
# Security
gen-password 32                  # Generate password
scan-port example.com 443        # Port scan
check-ssl github.com             # SSL check

# Network
dns-lookup example.com           # DNS info
whois-lookup example.com         # WHOIS info
```

### System Admin

```bash
# Monitoring
top-processes                    # Top processes
diskinfo                         # Disk usage
netstat-active                   # Connections

# Maintenance
Update-ProfileCore               # Update ProfileCore
profile-perf                     # Check performance
```

---

## 📚 6. Learn More

### Documentation

- 📖 [Full Documentation](README.md)
- 📥 [Installation Guide](INSTALL.md)
- 🔧 [Features](docs/features/)
- 📋 [Command Reference](docs/guides/quick-reference.md)

### Troubleshooting

| Problem               | Solution                                  |
| --------------------- | ----------------------------------------- |
| Functions not found   | Reload: `. $PROFILE` or `source ~/.zshrc` |
| `jq` not found (Unix) | `brew install jq` or `apt install jq`     |
| Permission denied     | `chmod +x ./scripts/installation/*.sh`    |
| Module not loading    | Re-run installer                          |

---

## 🎯 Quick Reference Card

### Must-Know Commands

```bash
# Package Management
pkg <name>              # Install
pkgs <name>             # Search
pkgu                    # Update all

# Network & Security
myip                    # Public IP
scan-port <host> <port> # Port scan
check-ssl <domain>      # SSL check

# Developer Tools
quick-commit <msg>      # Quick commit
docker-status           # Docker status
init-project <n> <type> # New project

# System Admin
sysinfo                 # System info
top-processes           # Top processes
diskinfo                # Disk usage

# Utilities
gen-password            # Password gen
Update-ProfileCore      # Update
```

---

<div align="center">

## 🎉 You're Ready!

**ProfileCore v4.0** is installed and configured.

**[📖 Full Docs](README.md)** • **[🐛 Issues](https://github.com/mythic3011/ProfileCore/issues)** • **[⭐ Star on GitHub](https://github.com/mythic3011/ProfileCore)**

**Happy Shelling!** 🚀

</div>
