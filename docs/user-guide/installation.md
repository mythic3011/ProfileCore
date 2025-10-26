# ProfileCore Installation Guide 🚀

**Choose your installation method - from 30 seconds to full control.**

---

## 📊 Visual Installation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   START INSTALLATION                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │ Have Git?      │
         └────┬───────┬───┘
              │ Yes   │ No
              │       └────────────────┐
              │                        ▼
              │              ┌───────────────────┐
              │              │ Install Git first │
              │              └─────────┬─────────┘
              │                        │
              ▼◄───────────────────────┘
    ┌─────────────────┐
    │ Choose Method   │
    └────┬───┬────┬───┘
         │   │    │
    ┌────┘   │    └────┐
    │        │         │
    ▼        ▼         ▼
┌───────┐ ┌──────┐ ┌──────────┐
│One-   │ │Stan- │ │Advanced  │
│Line   │ │dard  │ │w/Options │
└───┬───┘ └──┬───┘ └────┬─────┘
    │        │          │
    └────────┴──────────┘
             │
             ▼
    ┌────────────────┐
    │ Run Installer  │
    │  - Check prereq│
    │  - Backup files│
    │  - Copy modules│
    │  - Create conf │
    │  - Validate    │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ Configure?     │◄──── Optional
    └────┬───────────┘
         │
         ▼
    ┌────────────────┐
    │ Reload Shell   │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ Test Commands  │
    │ get_os/myip    │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │   ✅ DONE!     │
    └────────────────┘
```

**📖 For more visual guides:** See [Visual Installation Guide](docs/guides/installation-guide.md)

---

## 🎯 Quick Decision Guide

| If you want...         | Use this method                                     | Time    | Difficulty      |
| ---------------------- | --------------------------------------------------- | ------- | --------------- |
| ⚡ **Fastest install** | [One-Line Install](#-one-line-installation-fastest) | 2-5 min | ⭐ Easy         |
| 🎮 **More control**    | [Standard Install](#-standard-installation)         | 2-5 min | ⭐⭐ Moderate   |
| ⚙️ **Custom options**  | [Advanced Install](#️-advanced-installation)        | 2-5 min | ⭐⭐⭐ Advanced |

---

## 🔥 One-Line Installation (Fastest)

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
```

**⏱️ Installation time:** 2-5 minutes | **🔄 Repository:** Kept for updates

<details>
<summary>📋 What happens during installation?</summary>

**Automatic steps:**

1. ✅ Clones repository to `Documents/ProfileCore` (Windows) or `~/ProfileCore` (Unix)
2. ✅ Checks prerequisites (Git, PowerShell/Shell version)
3. ✅ Installs ProfileCore module and shell configurations
4. ✅ Creates shared configuration files
5. ✅ Optionally installs dependencies (Pester, PSScriptAnalyzer, jq, Starship)

**Interactive prompts:**

- 🎨 **Configure now?** - Launch configuration wizard (optional)
- 🔧 **Edit settings?** - Open .env file for API keys (optional)

**Result:**

- ✨ Fully functional ProfileCore installation
- 📂 Repository kept for easy updates (`git pull`)
- ⚙️ Configuration wizard available anytime

</details>

---

## 📦 Standard Installation

**Best for:** Users who want to review the code before running, or need to keep the repository for development.

### Step 1: Clone Repository

```bash
git clone https://github.com/mythic3011/ProfileCore.git
cd ProfileCore
```

### Step 2: Run Installer

**Windows (PowerShell):**

```powershell
.\scripts\installation\install.ps1
```

**macOS / Linux:**

```bash
chmod +x ./scripts/installation/install.sh
./scripts/installation/install.sh
```

### Step 3: Reload Your Shell

**PowerShell:**

```powershell
. $PROFILE
```

**Zsh:**

```bash
source ~/.zshrc
```

**Bash:**

```bash
source ~/.bashrc
```

**Fish:**

```bash
source ~/.config/fish/config.fish
```

**⏱️ Installation time:** 2-5 minutes

---

## ⚙️ Advanced Installation

### Installation Options

**Windows (PowerShell):**

```powershell
# Basic installation
.\scripts\installation\install.ps1

# Available options
-SkipDependencies    # Skip installing Pester, PSScriptAnalyzer, Starship
-SkipBackup          # Don't backup existing profile
-Force               # Force reinstall over existing installation
-Quiet               # Minimal output (for automation)

# Examples
.\scripts\installation\install.ps1 -SkipDependencies
.\scripts\installation\install.ps1 -Force -Quiet
```

**macOS / Linux:**

```bash
# Basic installation
./scripts/installation/install.sh

# Available options
--shell <zsh|bash|fish>  # Specify shell (auto-detected by default)
--skip-dependencies      # Skip jq and Starship
--skip-backup            # Don't backup existing config
--force                  # Force reinstall
--quiet                  # Minimal output
--help                   # Show help

# Examples
./scripts/installation/install.sh --shell zsh
./scripts/installation/install.sh --force --quiet
./scripts/installation/install.sh --skip-dependencies
```

---

## 🎯 What Gets Installed

### 📂 File Structure

**All Platforms (Shared Configuration):**

```
~/.config/shell-profile/
├── config.json      # Feature toggles
├── paths.json       # Application paths
├── aliases.json     # Custom aliases
├── .env             # API keys and secrets (editable)
└── .gitignore       # Version control
```

**Windows (PowerShell):**

```
Documents/PowerShell/
├── modules/
│   ├── ProfileCore/
│   │   ├── ProfileCore.psd1         # Module manifest
│   │   ├── ProfileCore.psm1         # Module loader
│   │   ├── public/                  # 64+ public functions
│   │   └── private/                 # Internal utilities
│   └── ProfileCore.Binary/          # 🦀 Rust binary module (v6.1.0+)
│       ├── bin/ProfileCore.dll      # High-performance native code
│       └── ProfileCore.psm1         # FFI wrapper
└── Microsoft.PowerShell_profile.ps1
```

**Unix (Zsh/Bash/Fish):**

| Shell    | Profile                      | Functions                   | Count      |
| -------- | ---------------------------- | --------------------------- | ---------- |
| **Zsh**  | `~/.zshrc`                   | `~/.zsh/functions/`         | 18 modules |
| **Bash** | `~/.bashrc`                  | `~/.bash/functions/`        | 7 modules  |
| **Fish** | `~/.config/fish/config.fish` | `~/.config/fish/functions/` | 18 modules |

### 📦 Dependencies (Optional)

**Windows:**

- Pester 5.7.1+ (testing framework)
- PSScriptAnalyzer 1.24.0+ (code linting)
- Starship (modern prompt)

**Unix:**

- jq (JSON processor - required for config management)
- Starship (modern prompt)

---

## 🦀 Optional: Rust Binary Module (v6.1.0)

ProfileCore v6.1.0 includes an **optional high-performance Rust binary module** that gets installed automatically:

### Performance Benefits

| Operation          | PowerShell | Rust  | Improvement     |
| ------------------ | ---------- | ----- | --------------- |
| System Info        | ~50ms      | ~5ms  | **10x faster**  |
| Platform Detection | ~10ms      | <1ms  | **10x faster**  |
| Network Stats      | ~100ms     | ~15ms | **6-7x faster** |

### How It Works

✅ **Automatic Installation** - Installer deploys the Rust module if available  
✅ **Automatic Fallback** - Uses PowerShell if Rust unavailable (fully functional)  
✅ **No Action Required** - ProfileCore picks the best available option  
⚠️ **Antivirus Notice** - Some antivirus may initially block unsigned DLLs

### What This Means

- **Installation succeeds either way** - Rust is a bonus, not required
- **ProfileCore works perfectly** - Just faster with Rust
- **You don't need Rust installed** - The binary is included

📖 **Antivirus blocking the DLL?** See [Antivirus & Rust Binary Guide](antivirus-and-rust.md) for solutions

---

## 🔧 Prerequisites

| Requirement          | Windows     | macOS       | Linux       | Auto-installed? |
| -------------------- | ----------- | ----------- | ----------- | --------------- |
| **Git**              | ✅ Required | ✅ Required | ✅ Required | ❌ Manual       |
| **PowerShell 5.1+**  | ✅ Built-in | ⚙️ Optional | ⚙️ Optional | ❌ Manual       |
| **Bash/Zsh/Fish**    | ⚙️ Optional | ✅ Built-in | ✅ Built-in | -               |
| **jq**               | -           | ⚙️ Optional | ⚙️ Optional | ✅ Yes          |
| **Starship**         | ⚙️ Optional | ⚙️ Optional | ⚙️ Optional | ⚠️ Prompted     |
| **Pester**           | ⚙️ Optional | -           | -           | ✅ Yes          |
| **PSScriptAnalyzer** | ⚙️ Optional | -           | -           | ✅ Yes          |

**Legend:** ✅ Built-in/Auto-installed | ⚙️ Optional | ❌ Manual install required | ⚠️ User prompted

### Quick Install Missing Prerequisites

**Git:**

```bash
# Windows
winget install Git.Git

# macOS
brew install git

# Linux
sudo apt install git    # Debian/Ubuntu
sudo dnf install git    # Fedora
```

---

## ✅ Verify Installation

**Quick Test (All Platforms):**

```bash
# PowerShell
Get-OperatingSystem    # Should show OS details

# Unix (Zsh/Bash/Fish)
get_os                 # Should show OS details
```

**Full Verification:**

<details>
<summary>PowerShell Commands</summary>

```powershell
# Module check
Get-Module ProfileCore

# Core functions
Get-PublicIP             # Show public IP
Get-SystemInfo           # System info

# v4.0 features
Test-Port google.com 443 # Port scanner
New-SecurePassword       # Password generator
Get-GitBranchInfo        # Git info
```

</details>

<details>
<summary>Unix Shell Commands</summary>

```bash
# Core functions
myip                     # Show public IP
sysinfo                  # System info

# Package management
pkg --help               # Package help
pkgs python              # Search packages

# v4.0 features
scan-port google.com 443 # Port scanner
gen-password             # Password generator
```

</details>

**✅ If commands work, installation successful!**

---

## 🐛 Troubleshooting

### Common Issues

| Issue                       | Solution                                               | Platform   |
| --------------------------- | ------------------------------------------------------ | ---------- |
| **Git not found**           | `winget install Git.Git`                               | Windows    |
|                             | `brew install git`                                     | macOS      |
|                             | `sudo apt install git`                                 | Linux      |
| **Cannot run scripts**      | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`  | Windows    |
| **jq not found**            | `brew install jq`                                      | macOS      |
|                             | `sudo apt install jq`                                  | Linux      |
| **Functions not available** | `. $PROFILE`                                           | PowerShell |
|                             | `source ~/.zshrc`                                      | Zsh        |
|                             | `source ~/.bashrc`                                     | Bash       |
| **Module not loading**      | Re-run installer: `.\scripts\installation\install.ps1` | Windows    |
|                             | Re-run installer: `./scripts/installation/install.sh`  | Unix       |
| **Rust DLL blocked by AV**  | See [Antivirus & Rust Guide](antivirus-and-rust.md)    | Windows    |
|                             | Add folder exclusion for ProfileCore directory         | All        |
| **Rust module not found**   | Installation works without Rust (PowerShell fallback)  | All        |
|                             | Check: `Test-ProfileCoreRustAvailable`                 | PowerShell |

### Get Help

1. 📖 [Full Documentation](README.md)
2. 🚀 [Quick Start Guide](QUICK_START.md)
3. 🐛 [Open an Issue](https://github.com/mythic3011/ProfileCore/issues)

---

## 🔄 Updating ProfileCore

### Automatic Update (Recommended)

```powershell
# Check for updates
Update-ProfileCore -CheckOnly

# Install updates
Update-ProfileCore

# Force update
Update-ProfileCore -Force
```

### Manual Update

```bash
# Navigate to ProfileCore directory
cd ~/Documents/ProfileCore    # Windows (or ~/ProfileCore)
cd ~/ProfileCore              # Unix

# Pull and reinstall
git pull origin main
.\scripts\installation\install.ps1    # Windows
./scripts/installation/install.sh     # Unix

# Reload
. $PROFILE                   # PowerShell
source ~/.zshrc              # Zsh/Bash
```

---

## 🎓 Next Steps

### 1. Configure Environment

```bash
# Edit configuration file
nano ~/.config/shell-profile/.env   # Unix
notepad ~/.config/shell-profile/.env # Windows

# Or use wizard (PowerShell)
Initialize-ProfileCoreConfig
```

**Add your API keys:**

```bash
export GITHUB_TOKEN="your_token_here"
export OPENAI_API_KEY="your_key_here"
```

### 2. Explore Features

**Security Tools:**

```bash
scan-port google.com 443      # Port scanner
check-ssl github.com          # SSL checker
gen-password                  # Password generator
```

**Developer Tools:**

```bash
quick-commit "feat: update"   # Quick commit
docker-status                 # Docker status
init-project my-app nodejs    # Scaffolding
```

**System Admin:**

```bash
sysinfo                       # System info
top-processes                 # Process monitor
diskinfo                      # Disk usage
```

**Package Manager:**

```bash
pkg search python             # Search
pkg install neovim            # Install
pkgu                          # Update all
```

### 3. Read Documentation

- 🚀 [Quick Start Guide](QUICK_START.md)
- 📖 [Full Documentation](README.md)
- 🔧 [Feature Docs](docs/features/)
- 📋 [Command Reference](docs/guides/quick-reference.md)

---

## 📊 Installation Methods Comparison

| Method          | Time    | Difficulty      | Repository | Config         | Best For          |
| --------------- | ------- | --------------- | ---------- | -------------- | ----------------- |
| 🔥 **One-Line** | 2-5 min | ⭐ Easy         | ✅ Kept    | 🎨 Interactive | Quickest start    |
| 📦 **Standard** | 2-5 min | ⭐⭐ Moderate   | ✅ Kept    | ⚙️ Manual      | Code review first |
| ⚙️ **Advanced** | 2-5 min | ⭐⭐⭐ Advanced | ✅ Kept    | ⚙️ Manual      | Custom setup      |

**Recommendation:** Use **One-Line** for fastest setup, **Standard** to review code first, **Advanced** for custom options.

---

## 📄 Uninstallation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
# Backup first
Copy-Item $PROFILE "$PROFILE.backup"

# Remove module and config
Remove-Item "$HOME\Documents\PowerShell\modules\ProfileCore" -Recurse -Force
Remove-Item "$HOME\.config\shell-profile" -Recurse -Force
Remove-Item $PROFILE

# Optional: Remove dependencies
Uninstall-Module Pester -Force
Uninstall-Module PSScriptAnalyzer -Force
```

</details>

<details>
<summary>macOS / Linux</summary>

```bash
# Backup first
cp ~/.zshrc ~/.zshrc.backup     # Zsh
cp ~/.bashrc ~/.bashrc.backup   # Bash

# Remove shell config
rm -rf ~/.zsh/functions ~/.zshrc              # Zsh
rm -rf ~/.bash/functions ~/.bashrc            # Bash
rm -rf ~/.config/fish/functions ~/.config/fish/config.fish  # Fish

# Remove shared config
rm -rf ~/.config/shell-profile

# Restore backup if needed
mv ~/.zshrc.backup ~/.zshrc   # Example
```

</details>

---

<div align="center">

## 🎉 Ready to Install?

**[⚡ Start with One-Line Install](#-one-line-installation-fastest)** • **[📖 Read Quick Start](QUICK_START.md)** • **[🐛 Get Help](https://github.com/mythic3011/ProfileCore/issues)**

---

**ProfileCore v6.1.0** - _Where Every Shell Feels Like Home_ 🏠 • _Fast with Rust, Reliable with PowerShell_ 🦀

</div>
