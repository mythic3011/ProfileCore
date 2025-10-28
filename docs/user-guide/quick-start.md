# ProfileCore Quick Start Guide 🚀

**Get ProfileCore v1.0.0 running in 3 minutes or less!**

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

**⏱️ Time:** 2-3 minutes | **📦 What it does:**

- Downloads ProfileCore binary
- Adds to PATH
- Runs interactive installer
- Configures your shell automatically

### Alternative: Manual Installation

1. Download binary for your platform from [Releases](https://github.com/mythic3011/ProfileCore/releases/tag/v1.0.0)
2. Move to PATH directory
3. Run: `profilecore install`

**📖 More options:** See [INSTALL.md](../../INSTALL.md) for detailed instructions

---

## ✅ 2. Verify Installation

**Restart your shell or reload:**

```bash
# PowerShell
. $PROFILE

# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

**Quick Test:**

```bash
# Check version
profilecore --version

# Try a command
profilecore system info
sysinfo  # or use alias
```

---

## 🎯 3. Essential Commands

ProfileCore v1.0.0 provides 97 commands across 17 categories. Here are some to get started:

### System Information

```bash
profilecore system info              # Comprehensive system info
sysinfo                              # Alias

profilecore system uptime            # System uptime
profilecore system processes         # Top processes
profilecore system disk-usage        # Disk usage
```

### Network Tools

```bash
profilecore network public-ip        # Get public IP
publicip                             # Alias

profilecore network test-port google.com 443
profilecore network dns example.com
profilecore network whois github.com
```

### Git Operations

```bash
profilecore git status               # Repository status
gitstatus                            # Alias

profilecore git log                  # Commit history
profilecore git switch-account personal
profilecore git add-account work user@work.com
```

### Security Tools

```bash
profilecore security ssl-check github.com
profilecore security gen-password --length 20
genpass 20                           # Alias

profilecore security check-password "MyP@ssw0rd"
```

### Docker (if installed)

```bash
profilecore docker ps                # List containers
dps                                  # Alias

profilecore docker stats container-name
profilecore docker logs container-name
```

### Package Management

```bash
profilecore package search python
profilecore package install neovim
profilecore package upgrade git
```

**See all commands:** `profilecore --help`

---

## ⚙️ 4. Configuration (Optional)

ProfileCore v1.0.0 stores configuration in `~/.config/profilecore/`.

### Configuration Files (Auto-created)

- `~/.config/profilecore/` - Main config directory

# Unix - Edit environment file

nano ~/.config/shell-profile/.env

````

### Add API Keys

```bash
# Edit ~/.config/shell-profile/.env
export GITHUB_TOKEN="your_token"
export OPENAI_API_KEY="your_key"
````

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
