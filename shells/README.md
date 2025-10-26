# MacOS Shell Configurations

This directory contains Unix-compatible shell configurations for ProfileCore v3.0.

## 📁 Directory Structure

```
MacOS/
├── .zsh/              # Zsh function modules
│   └── functions/     # 7 modular function files
├── .bash/             # Bash function modules
│   └── functions/     # 5 modular function files
├── .config/           # Modern shell configs
│   └── fish/          # Fish shell configuration
├── .zshrc             # Zsh profile (v3.0)
└── .bashrc            # Bash profile (v3.0)
```

## 🐚 Supported Shells

### Zsh (Recommended for macOS)

- **Profile:** `.zshrc`
- **Functions:** `.zsh/functions/*.zsh`
- **Modules:** 7 (00-core, 10-os-detection, 20-path-resolver, 30-package-manager, 40-network, 60-git-multi-account, 90-custom)
- **Features:** Full ProfileCore integration, Oh My Zsh compatible

### Bash (Universal)

- **Profile:** `.bashrc`
- **Functions:** `.bash/functions/*.bash`
- **Modules:** 5 (00-core, 10-os-detection, 30-package-manager, 40-network)
- **Features:** POSIX compliant, wide compatibility

### Fish (Modern)

- **Profile:** `.config/fish/config.fish`
- **Functions:** `.config/fish/functions/*.fish`
- **Modules:** 4 (00-core, get_os, pkg, network utilities)
- **Features:** Clean syntax, auto-suggestions

## 🚀 Installation

### Quick Install (All Shells)

From the repository root:

```bash
# Run the universal installer
./Scripts/install.sh
```

This will:

1. Detect your OS and shell
2. Install appropriate configurations
3. Set up shared config directory
4. Install dependencies (jq, etc.)
5. Configure ProfileCore integration

### Manual Installation

#### Zsh

```bash
# Copy Zsh files
cp -r MacOS/.zsh ~/.zsh
cp MacOS/.zshrc ~/.zshrc

# Create shared config directory
mkdir -p ~/.config/shell-profile

# Copy shared configs
cp -r ~/.config/shell-profile/* ~/.config/shell-profile/

# Reload
source ~/.zshrc
```

#### Bash

```bash
# Copy Bash files
cp -r MacOS/.bash ~/.bash
cp MacOS/.bashrc ~/.bashrc

# Create shared config directory
mkdir -p ~/.config/shell-profile

# Reload
source ~/.bashrc
```

#### Fish

```bash
# Copy Fish files
mkdir -p ~/.config/fish/functions
cp -r MacOS/.config/fish/* ~/.config/fish/

# Create shared config directory
mkdir -p ~/.config/shell-profile

# Reload
fish
```

## 🔧 Configuration

All shells share the same configuration files:

```bash
~/.config/shell-profile/
├── config.json          # Feature toggles
├── paths.json           # Application paths
├── aliases.json         # Shell-agnostic aliases
├── .env                 # Environment variables
└── .gitignore          # Version control
```

Edit these files to customize your shell experience across all shells.

## ✨ Features

### Shared Across All Shells

- ✅ OS detection (`get_os`, `is_macos`, `is_linux`)
- ✅ Package management (`pkg`, `pkgs`, `pkgu`)
- ✅ Network tools (`myip`, `netcheck`, `pingtest`)
- ✅ Path resolution (from `paths.json`)
- ✅ Environment loading (from `.env`)
- ✅ Alias loading (from `aliases.json`)

### Zsh-Specific

- ✅ GitHub multi-account management
- ✅ Advanced custom utilities (90+ functions)
- ✅ Oh My Zsh integration
- ✅ Starship prompt support

### Bash-Specific

- ✅ POSIX compliance
- ✅ Git Bash compatibility (Windows)
- ✅ Minimal dependencies

### Fish-Specific

- ✅ Native function system
- ✅ Auto-suggestions
- ✅ Web-based configuration

## 📚 Function Reference

### Core Functions (All Shells)

```bash
# OS Detection
get_os              # Returns: macos, linux, or windows
is_macos            # Check if running on macOS
is_linux            # Check if running on Linux
show_os_info        # Display detailed OS information

# Package Management
pkg <name>          # Install package
pkgs <term>         # Search packages
pkgu                # Update all packages
pkg-remove <name>   # Remove package

# Network Utilities
myip                # Get public IP (copies to clipboard)
myip-detailed       # Detailed IP info with geolocation
netcheck            # Test internet connectivity
pingtest <host> [n] # Ping host n times
dnstest <host>      # DNS lookup
check-port <host> <port>  # Check if port is open
```

### Zsh-Specific Functions

```bash
# GitHub Multi-Account
git-switch <account>                    # Switch Git config
git-remote <account> <user/repo>        # Set remote for account
git-clone <account> <user/repo> [dir]   # Clone with account
git-list-accounts                       # List configured accounts
git-add-account <name> <user> <email> <ssh-host>
git-remove-account <name>
git-whoami                              # Show current Git config

# Custom Utilities
up [n]              # Go up n directories
mkcd <dir>          # Create and cd into directory
findproc <name>     # Find process by name
killproc <name>     # Kill process by name
extract <file>      # Extract any archive
backup <file>       # Create timestamped backup
```

## 🔄 Updating

To update your shell configurations:

```bash
# From repository root
./Scripts/install.sh

# Or manually
cd MacOS
cp .zshrc ~/.zshrc
cp .bashrc ~/.bashrc
source ~/.zshrc  # or source ~/.bashrc
```

## 🐛 Troubleshooting

### Functions Not Found

```bash
# Reload your shell configuration
source ~/.zshrc    # Zsh
source ~/.bashrc   # Bash
fish              # Fish
```

### jq Not Found

```bash
# Install jq (required for config loading)
brew install jq              # macOS
sudo apt install jq          # Debian/Ubuntu
sudo dnf install jq          # Fedora
```

### Permission Denied

```bash
# Make sure function files are readable
chmod +r ~/.zsh/functions/*
chmod +r ~/.bash/functions/*
```

### Config Not Loading

```bash
# Check if shared config exists
ls ~/.config/shell-profile/

# If missing, run installer
./Scripts/install.sh
```

## 📖 Additional Resources

- [Main README](../README.md)
- [Quick Start Guide](../QUICK_START.md)
- [Deployment Guide](../Documentation/DEPLOY_TO_MACOS.md)
- [Zsh Implementation Summary](../Documentation/ZSH_IMPLEMENTATION_SUMMARY.md)
- [Full Documentation](../Documentation/)

## 🤝 Contributing

Contributions to shell configurations are welcome! Please see [CONTRIBUTING.md](../CONTRIBUTING.md).

When adding new functions:

1. Add to appropriate function file
2. Export the function
3. Update this README
4. Add tests if applicable
5. Test on target shell(s)

---

**ProfileCore v3.0** - Unix shell configurations  
**Shells:** Zsh, Bash, Fish  
**Platform:** macOS, Linux  
**Status:** ✅ Production Ready
