# Package Management Guide 📦

**ProfileCore v3.0** - Cross-Platform Package Management

---

## 🎯 Overview

ProfileCore provides unified package management across all platforms and shells, including search, installation, and bulk operations.

---

## 🔍 **Package Search**

### Search for Packages

Find packages across different package managers:

**PowerShell:**
```powershell
Search-Package python
pkg-search nodejs
pkgfind docker
```

**Zsh/Bash/Fish:**
```bash
pkg-search python
pkgfind nodejs
```

### Search with Limits

Limit the number of results:

```bash
pkg-search python 10    # Show top 10 results
pkg-search docker 5     # Show top 5 results
```

### What Gets Searched

| Platform | Package Managers |
|----------|-----------------|
| **Windows** | Scoop, Chocolatey, WinGet |
| **macOS** | Homebrew (formulae + casks) |
| **Linux** | APT, DNF, Pacman, Zypper |

---

## 📦 **Single Package Installation**

Install one package at a time:

**PowerShell:**
```powershell
Invoke-PackageManager install git
pkg git
```

**Zsh/Bash/Fish:**
```bash
pkg git
```

---

## 📋 **Bulk Package Installation**

### Install Multiple Packages

**PowerShell:**
```powershell
# Method 1: Comma-separated
Install-PackageList git,python,nodejs

# Method 2: Array
Install-PackageList -Packages @("git", "python", "nodejs")

# Method 3: Pipeline
"git","python","nodejs" | Install-PackageList

# Aliases
pkg-install-list git,python,nodejs
pkglist git,python,nodejs
```

**Zsh/Bash/Fish:**
```bash
# Space-separated
pkg-install-list git python nodejs

# Or use alias
pkglist git python nodejs
```

### Skip Confirmation

```powershell
# PowerShell
Install-PackageList git,python,nodejs -Force

# Unix shells need manual -y flags (varies by package manager)
```

### Interactive Installation Flow

```
📦 Package Installation List
════════════════════════════
Platform: macOS
Packages to install: 3

  1. git
  2. python
  3. nodejs

❓ Install these 3 packages? [y/N]: y

🚀 Starting installation...

[1/3] Installing git...
  ✅ Success

[2/3] Installing python...
  ✅ Success

[3/3] Installing nodejs...
  ✅ Success

═══════════════════════════════
📊 Installation Summary
═══════════════════════════════
✅ Successful: 3
❌ Failed: 0
```

---

## ℹ️ **Package Information**

Get detailed information about a package:

**PowerShell:**
```powershell
Get-PackageInfo git
pkg-info python
pkginfo nodejs
```

**Zsh/Bash/Fish:**
```bash
pkg-info git
pkginfo python
```

**Output includes:**
- Package name and version
- Description
- Dependencies
- Install size
- Homepage
- And more (varies by package manager)

---

## 🛠️ **Package Manager Operations**

### Update Package Lists

**PowerShell:**
```powershell
Invoke-PackageManager update
pkgu
```

**Zsh/Bash/Fish:**
```bash
pkgu
```

### Search Installed Packages

**PowerShell:**
```powershell
Invoke-PackageManager search python
pkgs python
```

**Zsh/Bash/Fish:**
```bash
pkgs python
```

---

## 🚀 **Real-World Examples**

### Setup Development Environment

**Install development tools:**

```powershell
# PowerShell
Install-PackageList git,vscode,nodejs,python,docker -Force

# Zsh/Bash/Fish
pkg-install-list git vscode nodejs python docker
```

### Install Language Runtimes

```bash
# Search for Python versions
pkg-search python

# Install specific version
pkg python@3.11

# Or install multiple runtimes
pkglist python ruby nodejs golang
```

### Install macOS GUI Apps

```bash
# Search for GUI apps (casks)
pkg-search chrome

# Install multiple apps
pkglist google-chrome visual-studio-code slack discord
```

### System Admin Tools

```bash
# Search for monitoring tools
pkg-search htop

# Install admin tools
pkglist htop curl wget jq fzf ripgrep
```

---

## 📊 **Supported Package Managers**

### Windows

| Manager | Search | Install | Info |
|---------|--------|---------|------|
| **Scoop** | ✅ | ✅ | ✅ |
| **Chocolatey** | ✅ | ✅ | ✅ |
| **WinGet** | ✅ | ✅ | ✅ |

**Priority:** Scoop → Chocolatey → WinGet

### macOS

| Manager | Search | Install | Info |
|---------|--------|---------|------|
| **Homebrew** | ✅ | ✅ | ✅ |

**Searches both:** Formulae (CLI) + Casks (GUI)

### Linux

| Manager | Search | Install | Info | Distros |
|---------|--------|---------|------|---------|
| **APT** | ✅ | ✅ | ✅ | Debian, Ubuntu, Mint |
| **DNF** | ✅ | ✅ | ✅ | Fedora, RHEL, CentOS |
| **Pacman** | ✅ | ✅ | ✅ | Arch, Manjaro |
| **Zypper** | ✅ | ✅ | ✅ | openSUSE |

---

## 💡 **Tips & Tricks**

### 1. Search Before Installing

Always search first to find the exact package name:

```bash
pkg-search neovim
# Then install the correct package
pkg neovim
```

### 2. Combine with Other Tools

```bash
# Search and immediately install
pkg-search python && pkg python

# Check info before installing
pkg-info docker && pkg docker
```

### 3. Create Installation Scripts

**PowerShell:**
```powershell
# setup-dev-env.ps1
$packages = @(
    "git",
    "nodejs",
    "python",
    "vscode",
    "docker"
)

Install-PackageList -Packages $packages -Force
```

**Bash/Zsh:**
```bash
#!/bin/bash
# setup-dev-env.sh
packages=(
    git
    nodejs
    python
    vscode
    docker
)

pkg-install-list "${packages[@]}"
```

### 4. Verify Installation

After bulk install, verify:

```bash
# Check if installed
git --version
python --version
node --version
```

---

## 🔧 **Troubleshooting**

### "Package not found"

1. Update package lists first:
   ```bash
   pkgu
   ```

2. Search with different terms:
   ```bash
   pkg-search "python 3"
   pkg-search py3
   ```

3. Check package manager docs for exact name

### "Permission denied"

**Linux:**
```bash
# Some commands need sudo
sudo apt update
sudo apt install <package>
```

**macOS:**
```bash
# Homebrew usually doesn't need sudo
brew install <package>
```

**Windows:**
```powershell
# Run PowerShell as Administrator
```

### Installation Fails

Check the error message:
- Network issues? Check connectivity with `netcheck`
- Disk space? Check with `df -h` (Unix) or `Get-PSDrive` (PowerShell)
- Dependencies? Try `pkg-info <package>` to see requirements

---

## 🎓 **Function Reference**

### PowerShell Functions

| Function | Alias | Description |
|----------|-------|-------------|
| `Search-Package` | `pkg-search`, `pkgfind` | Search for packages |
| `Install-PackageList` | `pkg-install-list`, `pkglist` | Install multiple packages |
| `Get-PackageInfo` | `pkg-info`, `pkginfo` | Get package details |
| `Invoke-PackageManager` | `pkg`, `pkgs`, `pkgu` | Core package operations |

### Unix Functions (Zsh/Bash/Fish)

| Function | Alias | Description |
|----------|-------|-------------|
| `pkg-search` | `pkgfind` | Search for packages |
| `pkg-install-list` | `pkglist` | Install multiple packages |
| `pkg-info` | `pkginfo` | Get package details |
| `pkg` | - | Install package |
| `pkgs` | - | Search installed |
| `pkgu` | - | Update lists |

---

## 📚 **Related Documentation**

- [Quick Start Guide](QUICK_START.md)
- [Cross-Platform Comparison](CROSS_PLATFORM_COMPARISON.md)
- [Main README](../README.md)

---

<div align="center">

**ProfileCore v3.0** - *Package Management Made Easy* 📦

**Now with Search & Bulk Install!**

</div>

