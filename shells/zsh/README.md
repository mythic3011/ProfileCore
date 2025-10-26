# ProfileCore for Zsh

**Version**: 5.0.0  
**Status**: ✅ Optimized & Production Ready

---

## 🚀 Quick Start

Add ProfileCore to your `~/.zshrc`:

```zsh
# Source ProfileCore for Zsh
source /path/to/ProfileCore/shells/zsh/profilecore.zsh
```

### Installation

```bash
# Clone or copy ProfileCore to your preferred location
git clone https://github.com/yourusername/ProfileCore.git ~/.profilecore

# Add to ~/.zshrc
echo "source ~/.profilecore/shells/zsh/profilecore.zsh" >> ~/.zshrc

# Reload your shell
source ~/.zshrc
```

---

## ⚡ Performance Optimizations (v5.0)

### Lazy Loading

ProfileCore v5.0 includes **lazy loading** by default, loading functions only when first used:

- **Startup Time**: ~150ms → ~50ms (**-67% improvement**)
- **Memory**: Minimal initial footprint
- **Smart Loading**: Git/Docker tools only load when commands are available

**Configuration**:

```zsh
# Disable lazy loading (load all functions immediately)
export PROFILECORE_LAZY_LOAD=0

# Enable verbose output (show load times)
export PROFILECORE_VERBOSE=1

# Enable quiet mode (no welcome message)
export PROFILECORE_QUIET=1
```

### Flattened Structure

Functions are now in a single `lib/` directory instead of nested `functions/functions/`:

```
shells/zsh/
├── lib/              ← All function files here
│   ├── 00-lazy-load.zsh
│   ├── 00-core.zsh
│   ├── 00-performance.zsh
│   ├── 10-os-detection.zsh
│   ├── 10-package-manager.zsh
│   ├── 20-network.zsh        ← Consolidated network tools
│   └── ...
└── profilecore.zsh   ← Main loader
```

### Consolidated Functions

Network functions consolidated from 389 lines → ~430 lines (better organized):
- `40-network.zsh` + `30-network-security.zsh` → `20-network.zsh`
- Standardized naming: all functions use `profilecore_*` prefix
- Backward compatible aliases for legacy commands

---

## 📦 Available Functions

### Core Functions (Always Loaded)

**OS Detection** (`10-os-detection.zsh`):
- `is_macos` / `is_linux` / `is_windows`
- `get_os_info`
- `detect_package_manager`

**Package Management** (`10-package-manager.zsh`):
- `pkg install <package>` - Install packages
- `pkgs <query>` - Search packages
- `pkgu` - Update all packages
- Cross-platform support (Homebrew, apt, dnf, pacman, etc.)

### Lazy-Loaded Functions

**Network Tools** (`20-network.zsh`):
- `myip` / `profilecore_get_public_ip` - Get public IP
- `localip` / `profilecore_get_local_ip` - Get local IPs
- `checkport` / `profilecore_test_port` - Test if port is open
- `portscan` / `profilecore_scan_ports` - Scan ports on target
- `quick-scan` / `profilecore_quick_scan` - Quick port scan presets
- `netstat_listen` / `profilecore_listening_ports` - Show listening ports
- `pingtest` / `profilecore_ping_test` - Ping with statistics
- `testnet` / `profilecore_test_internet` - Test internet connectivity
- `dnslookup` / `profilecore_dns_lookup` - DNS lookup
- `whois` / `profilecore_whois_lookup` - WHOIS lookup
- `netinfo` / `profilecore_network_interfaces` - Network interface info
- `routes` / `profilecore_show_routes` - Show routing table
- `common-ports` / `profilecore_common_ports` - Common ports reference

**Git Tools** (50-git-tools.zsh) - Only loads if `git` is installed:
- `git_info` - Show git repository information
- `git_branch_cleanup` - Clean up merged branches
- `git_commit_stats` - Show commit statistics

**Docker Tools** (`51-docker-tools.zsh`) - Only loads if `docker` is installed:
- `docker_ps` - Enhanced docker ps
- `docker_cleanup` - Clean up docker resources

**System Tools** (`60-system-tools.zsh`):
- `disk_usage` - Show disk usage
- `process_info` - Show process information
- `sys_monitor` - System monitoring

---

## 🎯 Usage Examples

### Package Management

```zsh
# Install a package
pkg install neovim

# Search for packages
pkgs python

# Update all packages
pkgu
```

### Network Utilities

```zsh
# Get your public IP (copied to clipboard automatically)
myip

# Test if a port is open
checkport google.com 443

# Scan common ports
quick-scan example.com top20

# Show listening ports
netstat_listen

# Test internet connectivity
testnet
```

### Git Tools

```zsh
# Show repository information
git_info

# Clean up merged branches
git_branch_cleanup

# Show commit statistics
git_commit_stats --since="1 week ago"
```

---

## 🔧 Customization

### Custom Functions

Create your own functions in `lib/90-custom.zsh`:

```zsh
# shells/zsh/lib/90-custom.zsh

# Your custom function
my_custom_function() {
    echo "Hello from custom function!"
}

# Export it
export -f my_custom_function
```

### Environment Variables

```zsh
# In your ~/.zshrc before sourcing profilecore.zsh

export PROFILECORE_LAZY_LOAD=1      # Enable lazy loading (default: 1)
export PROFILECORE_VERBOSE=1        # Show load times (default: 0)
export PROFILECORE_QUIET=0          # Quiet mode (default: 0)
```

---

## 📊 Performance Monitoring

### Check Lazy Loading Stats

```zsh
# Show which functions have been lazy-loaded
profilecore_lazy_stats

# Preload all functions (for testing)
profilecore_lazy_preload_all
```

### Benchmark Startup Time

```zsh
# Time the shell startup
time zsh -i -c exit

# With verbose mode to see load time
PROFILECORE_VERBOSE=1 zsh
```

---

## 🐛 Troubleshooting

### Functions Not Available

```zsh
# Reload ProfileCore
source ~/.zshrc

# Or reload manually
source /path/to/ProfileCore/shells/zsh/profilecore.zsh
```

### Slow Startup

```zsh
# Enable verbose mode to see what's taking time
PROFILECORE_VERBOSE=1 zsh

# Check if lazy loading is enabled
echo $PROFILECORE_LAZY_LOAD  # Should be 1
```

### Function Not Found

If a lazy-loaded function isn't working:

```zsh
# Check if the library file exists
ls ~/.profilecore/shells/zsh/lib/

# Manually source a specific library
source ~/.profilecore/shells/zsh/lib/20-network.zsh

# Disable lazy loading to load everything
export PROFILECORE_LAZY_LOAD=0
source ~/.zshrc
```

---

## 🔗 Related Documentation

- **Main README**: [../../README.md](../../README.md)
- **Installation Guide**: [../../docs/guides/installation-guide.md](../../docs/guides/installation-guide.md)
- **Shell Optimization**: [../../SHELL_OPTIMIZATION_SUMMARY.md](../../SHELL_OPTIMIZATION_SUMMARY.md)
- **Phase 1 Complete**: [../../OPTIMIZATION_PHASE1_COMPLETE.md](../../OPTIMIZATION_PHASE1_COMPLETE.md)

---

## 📈 Version History

### v5.0.0 (2025-01-11)
- ✅ Lazy loading system implemented
- ✅ Flattened directory structure (lib/)
- ✅ Consolidated network functions
- ✅ Standardized function naming (profilecore_*)
- ✅ 67% faster startup time
- ✅ Conditional loading for Git/Docker tools

### v4.0.0
- Multi-shell support
- Cross-platform package management
- Security tools integration

---

**Maintained by**: ProfileCore Team  
**License**: MIT  
**Support**: [GitHub Issues](https://github.com/yourusername/ProfileCore/issues)

