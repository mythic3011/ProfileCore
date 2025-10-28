# ProfileCore v1.0.0 Installation Guide

**Three ways to install ProfileCore - choose what works best for you.**

---

## 🚀 Quick Install (Recommended)

### Option 1: One-Line Install

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
```

This will:

1. ✅ Download the latest ProfileCore binary
2. ✅ Add it to your PATH
3. ✅ Run the interactive installer
4. ✅ Configure your shell automatically
5. ✅ Verify the installation

**Time: 2-3 minutes | Difficulty: Easy**

---

### Option 2: Manual Download + Interactive Install

1. **Download the binary for your platform:**

   - Windows: [profilecore-windows-x86_64.exe](https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-windows-x86_64.exe)
   - macOS (Intel): [profilecore-macos-x86_64](https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-macos-x86_64)
   - macOS (Apple Silicon): [profilecore-macos-aarch64](https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-macos-aarch64)
   - Linux: [profilecore-linux-x86_64](https://github.com/mythic3011/ProfileCore/releases/download/v1.0.0/profilecore-linux-x86_64)

2. **Make it executable (Unix only):**

   ```bash
   chmod +x profilecore
   ```

3. **Move to a directory in your PATH:**

   ```bash
   # Windows (PowerShell as Admin)
   Move-Item profilecore.exe C:\Windows\System32\

   # macOS / Linux
   sudo mv profilecore /usr/local/bin/

   # Or user-local install (no sudo needed)
   mkdir -p ~/.local/bin
   mv profilecore ~/.local/bin/
   export PATH="$HOME/.local/bin:$PATH"  # Add to ~/.bashrc or ~/.zshrc
   ```

4. **Run the interactive installer:**
   ```bash
   profilecore install
   ```

The installer will:

- ✅ Detect your shell automatically
- ✅ Add ProfileCore init code to your shell profile
- ✅ Create configuration directories
- ✅ Verify the installation

**Time: 3-5 minutes | Difficulty: Easy**

---

### Option 3: Build from Source

For developers who want the latest code or want to contribute:

```bash
# Prerequisites: Rust 1.75+
git clone https://github.com/mythic3011/ProfileCore
cd ProfileCore

# Build
cargo build --release

# The binary is at: target/release/profilecore
# Copy to PATH or run directly
./target/release/profilecore install
```

**Time: 5-10 minutes | Difficulty: Moderate**

---

## ✅ Verify Installation

After installation, restart your shell and run:

```bash
# Check version
profilecore --version

# Try a command
profilecore system info

# Or use an alias
sysinfo
```

If everything works, you're ready to go! 🎉

---

## 🔄 Update ProfileCore

### With Quick Install Script

Just run the quick install script again - it will download and update automatically.

### Manual Update

1. Download the new binary
2. Replace the old one
3. Restart your shell

---

## 🗑️ Uninstall

### Interactive Uninstaller

```bash
profilecore uninstall
```

This will remove ProfileCore from your shell configuration.

### Complete Removal

1. Run `profilecore uninstall`
2. Delete the binary from your PATH
3. (Optional) Remove config directory: `~/.config/profilecore`

---

## 🐛 Troubleshooting

### "profilecore: command not found"

The binary is not in your PATH. Either:

- Run the quick install script (it adds to PATH automatically)
- Manually add the directory to PATH (see Option 2 above)

### "Permission denied"

On Unix systems, make sure the binary is executable:

```bash
chmod +x profilecore
```

### Installation hangs or fails

Check:

1. Internet connection (for downloading binary)
2. Write permissions for target directory
3. Available disk space

### Shell doesn't load ProfileCore after installation

1. Make sure you restarted your shell or ran:

   ```bash
   # Bash
   source ~/.bashrc

   # Zsh
   source ~/.zshrc

   # Fish
   source ~/.config/fish/config.fish

   # PowerShell
   . $PROFILE
   ```

2. Check that the init code was added:

   ```bash
   # Bash/Zsh
   cat ~/.bashrc | grep profilecore
   cat ~/.zshrc | grep profilecore

   # Fish
   cat ~/.config/fish/config.fish | grep profilecore

   # PowerShell
   cat $PROFILE | Select-String profilecore
   ```

---

## 📖 What Gets Installed

### Binary Location

- **Windows (system)**: `C:\Program Files\ProfileCore\profilecore.exe`
- **Windows (user)**: `%LOCALAPPDATA%\ProfileCore\profilecore.exe`
- **Unix (system)**: `/usr/local/bin/profilecore`
- **Unix (user)**: `~/.local/bin/profilecore`

### Configuration Directory

- **All platforms**: `~/.config/profilecore/`

### Shell Integration

ProfileCore adds a small init snippet to your shell profile:

**Bash/Zsh**:

```bash
# ProfileCore v1.0.0 - Added by installer
if command -v profilecore &> /dev/null; then
    eval "$(profilecore init bash)"  # or zsh
fi
```

**Fish**:

```fish
# ProfileCore v1.0.0 - Added by installer
if command -v profilecore > /dev/null
    profilecore init fish | source
end
```

**PowerShell**:

```powershell
# ProfileCore v1.0.0 - Added by installer
if (Get-Command profilecore -ErrorAction SilentlyContinue) {
    profilecore init powershell | Invoke-Expression
}
```

This code:

- ✅ Only runs if `profilecore` is in PATH
- ✅ Generates shell-specific aliases and functions
- ✅ Takes <50ms to execute
- ✅ Doesn't slow down shell startup

---

## 🎓 Next Steps

Once installed, explore ProfileCore:

1. **Check available commands**:

   ```bash
   profilecore --help
   ```

2. **Try some commands**:

   ```bash
   # System info
   profilecore system info
   sysinfo  # alias

   # Network
   profilecore network public-ip
   publicip  # alias

   # Git
   profilecore git status
   gitstatus  # alias

   # Security
   profilecore security gen-password --length 20
   genpass 20  # alias
   ```

3. **Read the documentation**:
   - [Quick Start Guide](docs/user-guide/quick-start.md)
   - [Command Reference](docs/user-guide/command-reference.md)
   - [Full Documentation](README.md)

---

## 🆘 Need Help?

- 📖 [Full Documentation](README.md)
- 🐛 [Report an Issue](https://github.com/mythic3011/ProfileCore/issues)
- 💬 [Discussions](https://github.com/mythic3011/ProfileCore/discussions)

---

**ProfileCore v1.0.0** - _Fast, cross-platform, unified shell interface_ 🚀
