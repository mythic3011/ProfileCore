# Migration Guide: v6.0.0 → v1.0.0

## ⚠️ BREAKING CHANGES

ProfileCore v1.0.0 is a **complete rewrite** in Rust. All PowerShell modules have been removed and replaced with a single, fast, cross-shell CLI binary.

## Why the Change?

- **Performance**: gumdrop parsing is ~160ns vs clap's 5-10ms
- **Cross-Shell**: Works identically across bash, zsh, fish, and PowerShell
- **Smart Wrappers**: Wraps mature libraries (git2, bollard, rustls) instead of reimplementing
- **Starship-like Architecture**: Minimal shell wrappers, all logic in Rust
- **Fresh Start**: Reset versioning to v1.0.0 for clarity

## Migration Steps

### 1. Uninstall v6.0.0 PowerShell Modules

```powershell
# Windows PowerShell
profilecore uninstall-legacy
```

```bash
# Unix (bash/zsh/fish)
# Manually remove old modules
rm -rf ~/.local/share/powershell/Modules/ProfileCore*
```

### 2. Install v1.0.0 Binary

**Option A: Download Release**

```bash
# Download from GitHub Releases
# https://github.com/mythic3011/ProfileCore/releases/tag/v1.0.0
```

**Option B: Build from Source**

```bash
git clone https://github.com/mythic3011/ProfileCore
cd ProfileCore
cargo build --release
# Binary at: target/release/profilecore
```

### 3. Add to PATH

```bash
# Linux/macOS
sudo cp target/release/profilecore /usr/local/bin/
# OR add to ~/.local/bin/ and ensure it's in PATH

# Windows
# Copy profilecore.exe to a directory in your PATH
# Or add the target/release directory to your PATH
```

### 4. Update Shell Configuration

**Bash** (`~/.bashrc`):

```bash
# OLD v6.0.0:
Import-Module ProfileCore

# NEW v1.0.0:
eval "$(profilecore init bash)"
```

**Zsh** (`~/.zshrc`):

```zsh
# OLD v6.0.0:
Import-Module ProfileCore

# NEW v1.0.0:
eval "$(profilecore init zsh)"
```

**Fish** (`~/.config/fish/config.fish`):

```fish
# OLD v6.0.0:
# (N/A - PowerShell only)

# NEW v1.0.0:
profilecore init fish | source
```

**PowerShell** (`$PROFILE`):

```powershell
# OLD v6.0.0:
Import-Module ProfileCore

# NEW v1.0.0:
profilecore init powershell | Invoke-Expression
```

### 5. Restart Your Shell

```bash
# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc, etc.
# OR restart your terminal
```

## Command Mapping

| v6.0.0 (PowerShell)               | v1.0.0 (Rust CLI)                                     |
| --------------------------------- | ----------------------------------------------------- |
| `Get-SystemInfo`                  | `profilecore system info` (or `sysinfo` alias)        |
| `Get-PublicIP`                    | `profilecore network public-ip` (or `publicip` alias) |
| `Test-Port 443`                   | `profilecore network test-port example.com 443`       |
| `Get-LocalNetworkIPs`             | `profilecore network local-ips` (or `localips` alias) |
| `Get-GitStatus`                   | `profilecore git status` (or `gitstatus` alias)       |
| `Get-DockerContainers`            | `profilecore docker ps` (or `dps` alias)              |
| `Test-SSLCertificate example.com` | `profilecore security ssl-check example.com`          |
| `New-Password -Length 20`         | `profilecore security gen-password --length 20`       |
| `Install-Package git`             | `profilecore package install git`                     |
| N/A                               | `profilecore uninstall-legacy` (removes v6.0.0)       |

### Git Multi-Account (Replaces `60-git-multi-account.zsh`)

| Old (zsh script)           | New (v1.0.0 Rust)                                                  |
| -------------------------- | ------------------------------------------------------------------ |
| `git-switch-account work`  | `profilecore git switch-account work` (or `git-switch work` alias) |
| `git-add-account personal` | `profilecore git add-account personal`                             |
| `git-list-accounts`        | `profilecore git list-accounts`                                    |
| `git-whoami`               | `profilecore git whoami`                                           |

## What's Removed

- **All PowerShell modules**: `ProfileCore`, `ProfileCore.Common`, `ProfileCore.CloudSync`, `ProfileCore.Security`
- **Complex shell helper scripts**: `shells/bash/lib/`, `shells/zsh/lib/`, `shells/fish/functions/`
- **v6 DI architecture**: No longer needed with Rust
- **FFI layer**: Pure CLI approach, no PowerShell FFI

## What's New

- **Single binary**: `profilecore` executable
- **Faster startup**: <50ms cold start with gumdrop
- **Shell completions**: `profilecore completions bash/zsh/fish/powershell`
- **Dynamic init**: `profilecore init <shell>` generates shell-specific functions
- **JSON output**: `profilecore system info --format json`
- **Better errors**: Color-coded, user-friendly error messages

## Troubleshooting

### "profilecore: command not found"

- Ensure binary is in PATH
- Check: `which profilecore` (Unix) or `Get-Command profilecore` (PowerShell)

### "Old commands still exist"

- Run `profilecore uninstall-legacy` to remove v6.0.0 modules
- Restart shell after removal

### "Aliases don't work"

- Ensure you ran `eval "$(profilecore init <shell>)"`
- Check: `alias | grep profilecore`

### "Need old PowerShell functions"

- v6.0.0 functions are no longer maintained
- File an issue for priority v1.0.0 equivalents: https://github.com/mythic3011/ProfileCore/issues

## Feedback

Please report issues or request features:

- **GitHub Issues**: https://github.com/mythic3011/ProfileCore/issues
- **Discussions**: https://github.com/mythic3011/ProfileCore/discussions

## Version Timeline

- **v6.0.0** (2025-01): PowerShell + Rust FFI hybrid
- **v1.0.0** (2025-02): Pure Rust CLI (current)
- **Future**: Continuous improvements, more commands

Thank you for using ProfileCore! 🚀
