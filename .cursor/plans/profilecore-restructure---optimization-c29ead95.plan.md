<!-- c29ead95-4edb-4758-884a-ad5d67a5cac8 6028f84a-63e0-4878-8e45-12e9c8a500b6 -->
# ProfileCore v1.0.0 - Starship Architecture (Smart Wrapper)

## Philosophy: Don't Reinvent The Wheel

**ProfileCore = Unified Cross-Shell Interface to Existing Mature Tools**

Provide consistent, fast CLI that orchestrates best-in-class libraries/tools, not reimplementing everything.

## Phase 1: Directory Restructuring

### Target (Starship-like)

```
ProfileCore/
├── src/                      # Single Rust codebase
│   ├── main.rs              # CLI (gumdrop parsing)
│   ├── commands/            # Command implementations
│   ├── init/                # Shell init generation
│   └── modules/             # Utilities
├── shells/                  # Thin wrappers (3 lines)
├── install/                 # Universal installer
└── Cargo.toml               # v1.0.0

DELETE: modules/ProfileCore/, modules/ProfileCore.Common/, modules/deprecated-v5.2/
```

### Actions

1. Move `modules/ProfileCore-rs/src/` → `src/`
2. Move `modules/ProfileCore-rs/Cargo.toml` → `Cargo.toml`
3. **DELETE** all PowerShell modules:

   - `modules/ProfileCore/` (97 functions - rewrite in Rust)
   - `modules/ProfileCore.Common/`
   - `modules/ProfileCore.CloudSync/`
   - `modules/ProfileCore.Security/`
   - `modules/deprecated-v5.2/`

4. **DELETE** all complex shell scripts:

   - `shells/bash/lib/*.bash` (git, docker, network helpers)
   - `shells/zsh/lib/*.zsh` (INCLUDING `60-git-multi-account.zsh`)
   - `shells/fish/functions/*.fish`
   - Replace ALL with Rust CLI calls

5. **SIMPLIFY** `shells/` to ONLY thin init wrappers (3 lines each)
6. Move `scripts/installation/` → `install/`

## Phase 2: Command Strategy (Smart Wrappers)

| Command | Strategy | Tool |

|---------|----------|------|

| System info | Native | `sysinfo` |

| Git | Library | `git2` |

| Docker | Library | `bollard` |

| Port scan | External CLI | `rustscan`/`nmap` |

| SSL check | Library | `rustls` |

| DNS | Library | `trust-dns` |

| WHOIS | External CLI | `whois` |

| Password | Library | `argon2`, `bcrypt` |

| Package | External CLI | `apt`/`brew`/`choco` |

## Phase 3: Cargo Dependencies (Minimal)

```toml
[dependencies]
# FAST parsing (160ns vs clap's 5-10ms)
gumdrop = "0.8"
gumdrop_derive = "0.8"

# Native implementations
sysinfo = "0.31"
whoami = "1.5"

# Library wrappers
git2 = "0.18"
bollard = "0.16"
trust-dns-resolver = "0.23"
rustls = "0.23"
argon2 = "0.5"
bcrypt = "0.15"

# External CLI helpers
which = "6.0"        # Find executables
tokio = { version = "1", features = ["rt", "process"] }

# UX only
comfy-table = "7.1"
colored = "2.1"
indicatif = "0.17"
anyhow = "1.0"
```

## Phase 4: Implementation Examples

**Main CLI (gumdrop):**

```rust
use gumdrop::Options;

#[derive(Options)]
struct Cli {
    #[options(command)]
    command: Option<Command>,
}

#[derive(Options)]
enum Command {
    Init(InitOpts),
    System(SystemOpts),
    Git(GitOpts),
    // ...
}
```

**External CLI Wrapper:**

```rust
pub fn scan_port(target: &str) -> anyhow::Result<()> {
    if which::which("rustscan").is_ok() {
        Command::new("rustscan").args(["-a", target]).status()?;
    } else {
        anyhow::bail!("Install rustscan: cargo install rustscan");
    }
    Ok(())
}
```

## Phase 5: Universal Installer

**Unix (`install/install.sh`):**

```bash
#!/usr/bin/env bash
# Auto-detect shell, download binary, configure
curl -sSL https://profilecore.sh/install | bash
```

**Windows (`install/install.ps1`):**

```powershell
# Auto-configure PowerShell
irm https://profilecore.sh/install.ps1 | iex
```

**Self-install:**

```rust
// After manual install
profilecore install  // Auto-configures current shell
```

## Phase 6: Shell Completions

### Challenge

`gumdrop` doesn't have built-in completion generation like `clap_generate`. Trade-off for speed.

### Solution Options

**Option 1: Manual completion generation (recommended)**

```rust
// src/commands/completions.rs
pub fn generate_bash() -> String {
    r#"
_profilecore_completions() {
    local cur prev commands
    commands="init install system git docker network package"
    
    COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
}
complete -F _profilecore_completions profilecore
"#.to_string()
}
```

**Option 2: Dynamic completion**

```rust
// profilecore completions bash > ~/.bash_completions.d/profilecore
Commands::Completions { shell } => {
    match shell.as_str() {
        "bash" => print!("{}", generate_bash_completions()),
        "zsh" => print!("{}", generate_zsh_completions()),
        "fish" => print!("{}", generate_fish_completions()),
        _ => bail!("Unsupported shell"),
    }
}
```

**Option 3: Switch back to clap** (if completions > speed)

- Use `clap_complete` for auto-generation
- Accept 5-10ms startup penalty
- Better ecosystem support

### Recommendation

Start with **manual completion** (Option 1). If too complex, reconsider clap trade-off.

## Phase 7: Command Mapping (97 PowerShell → Rust)

### High Priority (Week 3-4)

| Old (v6.0.0 PowerShell) | New (v1.0.0 Rust) | Implementation |

|-------------------------|-------------------|----------------|

| Get-SystemInfo | profilecore system info | Native (sysinfo) |

| Get-PublicIP | profilecore network public-ip | Native (reqwest) |

| Test-Port | profilecore network test-port | Native (socket2) |

| Get-GitStatus | profilecore git status | Library (git2) |

| Get-DockerContainers | profilecore docker ps | Library (bollard) |

| Get-LocalNetworkIPs | profilecore network local-ips | Native (local-ip-address) |

| Install-Package | profilecore package install | External (apt/brew/choco) |

### Git Multi-Account (Replace 60-git-multi-account.zsh)

| Old (zsh script) | New (v1.0.0 Rust) | Implementation |

|------------------|-------------------|----------------|

| git-switch-account | profilecore git switch-account | Library (git2) |

| git-add-account | profilecore git add-account | Library (git2 + config) |

| git-list-accounts | profilecore git list-accounts | Library (git2 + config) |

| git-whoami | profilecore git whoami | Library (git2) |

| git-clone-with | profilecore git clone --account | Library (git2) |

### Medium Priority (Week 5-6)

| Old (v6.0.0 PowerShell) | New (v1.0.0 Rust) | Implementation |

|-------------------------|-------------------|----------------|

| Test-SSLCertificate | profilecore security ssl-check | Library (rustls) |

| Get-DNSInfo | profilecore network dns | Library (trust-dns) |

| Get-WHOISInfo | profilecore network whois | External (whois CLI) |

| New-Password | profilecore security gen-password | Library (rand) |

| Test-PasswordStrength | profilecore security check-password | Library (zxcvbn) |

| Get-PasswordHash | profilecore security hash-password | Library (argon2/bcrypt) |

| Scan-Port | profilecore security scan-port | External (rustscan/nmap) |

### Lower Priority (Week 7-8)

Remaining 70+ functions → Similar pattern (wrapper approach)

## Phase 8: Migration Path (v6.0.0 → v1.0.0)

### Breaking Changes Notice

```markdown
# BREAKING: ProfileCore v1.0.0

ProfileCore v1.0.0 is a complete rewrite in Rust. All PowerShell modules removed.

## Migration Steps

1. Uninstall v6.0.0:
   profilecore uninstall-legacy  # Removes old modules

2. Install v1.0.0:
   curl -sSL https://profilecore.sh/install | bash

3. Update shell config:
   Old: Import-Module ProfileCore
   New: eval "$(profilecore init bash)"

## Command Changes

| v6.0.0 (PowerShell) | v1.0.0 (Rust) |
|---------------------|---------------|
| Get-SystemInfo | profilecore system info |
| Get-PublicIP | profilecore network public-ip |
| Test-Port 443 | profilecore network test-port 443 |
| git-switch-account work | profilecore git switch-account work |
```

### Uninstall Command

```rust
// src/commands/uninstall.rs
pub fn uninstall_legacy() -> anyhow::Result<()> {
    let ps_modules = vec![
        "ProfileCore",
        "ProfileCore.Common",
        "ProfileCore.CloudSync",
        "ProfileCore.Security",
    ];
    
    for module in ps_modules {
        let module_path = get_ps_module_path(module)?;
        if module_path.exists() {
            fs::remove_dir_all(&module_path)?;
            println!("✓ Removed {}", module);
        }
    }
    
    println!("✓ v6.0.0 modules removed");
    println!("  Run: profilecore install");
    Ok(())
}
```

## Timeline: v1.0.0 (2-3 months)

1. Week 1-2: Restructure, setup gumdrop, delete PowerShell
2. Week 3-4: High priority commands (system, network, git basics)
3. Week 5-6: Medium priority (security, DNS, git multi-account)
4. Week 7-8: Lower priority + shell init + completions
5. Week 9-10: Universal installer + uninstall-legacy
6. Week 11-12: Test, docs, release v1.0.0

## Success Criteria

- [ ] Starship directory structure
- [ ] gumdrop parsing (<50ms cold start)
- [ ] All 97 PowerShell functions mapped to Rust
- [ ] Git multi-account replaces zsh script (git2)
- [ ] Smart wrappers (not reimplementations)
- [ ] PowerShell modules deleted
- [ ] Shell completions work (bash/zsh/fish/pwsh)
- [ ] Universal install works
- [ ] `uninstall-legacy` removes v6.0.0
- [ ] Migration guide complete
- [ ] v1.0.0 release
- [ ] Binary <15MB
- [ ] Install <30s

### To-dos

- [ ] Create ProfileCore.Common module structure with manifest and loader
- [ ] Extract shared output functions (Write-BoxHeader, Write-Step, etc.) to OutputHelpers.ps1
- [ ] Extract installation helpers to InstallHelpers.ps1
- [ ] Update all scripts to import and use ProfileCore.Common
- [ ] Update ProfileCore.psm1 to use v6 Bootstrap instead of v5 private/ imports
- [ ] Add deprecation warnings to v5 private/ files and create migration guide
- [ ] Update ProfileCore.psd1 with Common module dependency and v6 notes
- [ ] Move ProfileCore.Binary to rust-binary/ subdirectory in main module
- [ ] Integrate Performance module, rationalize other sub-modules
- [ ] Create migration guide and update architecture documentation
- [ ] Modify build scripts to handle new structure
- [ ] Bump to v5.2.0 and update CHANGELOG with restructuring details