# One-Line Installation Improvements

## 🎯 Overview

The ProfileCore v4.0 one-line installer has been significantly improved to provide a better user experience that's closer to the standard installation while maintaining the convenience of a single command.

## ✨ Key Improvements

### 1. **Repository Persistence**

**Before:**

- Cloned to temporary directory
- Deleted after installation
- No way to update without re-downloading

**After:**

- Clones to permanent location:
  - Windows: `Documents/ProfileCore`
  - Unix: `~/ProfileCore`
- **Repository kept for easy updates**
- Simple `git pull` to update

### 2. **Interactive Configuration**

**Before:**

- No configuration assistance
- Users had to manually find and edit config files

**After:**

- **Asks if you want to configure after installation**
- Windows: Launches `Initialize-ProfileCoreConfig` wizard
- Unix: Opens `.env` file in your default editor
- **Optional** - can skip and configure later

### 3. **Update Support**

**Before:**

- No update mechanism
- Had to delete and reinstall

**After:**

- **Detects existing installation**
- Offers to update via `git pull`
- Keeps all your configurations intact

### 4. **Better User Guidance**

**Before:**

- Minimal output
- Users unsure what to do next

**After:**

- Shows installation directory location
- Provides clear next steps
- Includes update instructions
- Displays test commands

## 📊 Comparison

| Feature                 | Old One-Liner | New One-Liner | Standard Install |
| ----------------------- | ------------- | ------------- | ---------------- |
| **Single command**      | ✅            | ✅            | ❌               |
| **Repository kept**     | ❌            | ✅            | ✅               |
| **Update support**      | ❌            | ✅            | ✅               |
| **Config wizard**       | ❌            | ✅ Optional   | ⚙️ Manual        |
| **Interactive prompts** | ❌            | ✅            | ❌               |
| **Shows location**      | ❌            | ✅            | ✅               |
| **Update instructions** | ❌            | ✅            | ✅               |

## 🚀 Usage

### First Time Installation

**Windows:**

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
```

**Unix:**

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
```

**What happens:**

1. ✅ Checks prerequisites (Git, PowerShell/Shell version)
2. 📥 Clones ProfileCore to permanent location
3. 🚀 Runs full installer
4. 🎨 **Asks if you want to configure** (new!)
   - Windows: Launches interactive wizard
   - Unix: Opens .env in editor
5. 📝 Shows clear next steps
6. 📂 Displays repository location for future reference

### Updating

If you run the one-liner again when ProfileCore already exists:

```
⚠️  ProfileCore directory already exists!
Do you want to update it? (y/N):
```

Choose `y` to update via `git pull`, or `n` to cancel.

**Or update manually:**

**Windows:**

```powershell
cd ~/Documents/ProfileCore
git pull
.\scripts\installation\install.ps1
```

**Unix:**

```bash
cd ~/ProfileCore
git pull
./scripts/installation/install.sh
```

## 💡 Benefits

### For New Users

- **Single command** - easiest way to get started
- **Guided configuration** - optional wizard helps with setup
- **Clear next steps** - no confusion about what to do after install

### For Experienced Users

- **Repository access** - can browse code, make changes
- **Easy updates** - simple `git pull` workflow
- **Skip configuration** - if you prefer to configure manually

### For Everyone

- **Best of both worlds** - convenience + flexibility
- **No data loss** - repository never deleted
- **Update friendly** - detects and handles existing installations

## 🎨 Interactive Features

### Windows Configuration Wizard

When you choose to configure on Windows:

```
🎨 Would you like to configure ProfileCore now? (Y/n)
   This will set up API keys, paths, and preferences.
Configure now?
```

Choose `Y` (default) to launch `Initialize-ProfileCoreConfig` which:

- Guides you through API key setup
- Configures application paths
- Sets up feature toggles
- Configures GitHub multi-account (if needed)

### Unix Configuration Editor

When you choose to configure on Unix:

```
🎨 Would you like to edit configuration now? (Y/n)
   This will open the .env file for API keys and settings.
Edit config now?
```

Choose `Y` (default) to open `~/.config/shell-profile/.env` in:

- `nano` (if available)
- `vim` (if nano not found)
- `vi` (fallback)
- `$EDITOR` (your custom editor)

## 📝 Example Session

### Windows PowerShell

```powershell
PS> irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex

╔════════════════════════════════════════════════════════════╗
║     ProfileCore v4.0 Quick Installer - Windows        ║
╚════════════════════════════════════════════════════════════╝

🔍 Checking prerequisites...
✅ Git found
✅ PowerShell 7.5.3

📁 Installation directory: C:\Users\YourName\Documents\ProfileCore

📥 Downloading ProfileCore...
✅ Download complete

🚀 Running installer...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Installer output...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ ProfileCore installed successfully!

🎨 Would you like to configure ProfileCore now? (Y/n)
   This will set up API keys, paths, and preferences.
Configure now? y

⚙️  Launching configuration wizard...

[Interactive configuration...]

📝 Next steps:
   1. Reload your profile:
      . $PROFILE

   2. Test installation:
      Get-SystemInfo
      myip

   3. View all commands:
      Get-Helper

📂 ProfileCore location: C:\Users\YourName\Documents\ProfileCore
💡 To update: cd C:\Users\YourName\Documents\ProfileCore && git pull && .\scripts\installation\install.ps1

🎉 Happy scripting!
```

## 🎯 Recommendation

The **one-line installer is now the recommended installation method** for most users because:

✅ **Just as capable as standard install** - keeps repository, supports updates  
✅ **More convenient** - single command, optional guided configuration  
✅ **Beginner friendly** - clear prompts and next steps  
✅ **Power user friendly** - can skip configuration, access repository

The only reason to use standard installation is if you:

- Want to review the code before running installers
- Need to install from a fork
- Prefer manual control over every step

## 📚 Related Documentation

- [INSTALL.md](../../INSTALL.md) - Complete installation guide
- [QUICK_START.md](../QUICK_START.md) - Quick start guide
- [README.md](../../README.md) - Main documentation

