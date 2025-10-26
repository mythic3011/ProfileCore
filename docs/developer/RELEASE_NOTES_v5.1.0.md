# ProfileCore v5.1.0 - Performance Release

**Release Date:** October 13, 2025  
**Type:** Performance Optimization  
**Breaking Changes:** None

---

## 🚀 Performance Improvements

- **63% faster startup** (3305ms → 1200ms)
- **Lazy command registration** (instant shell availability)
- **Async prompt initialization** (non-blocking Starship)
- **Optimized environment loading** (streamlined I/O)

---

## 📊 Benchmarks

| Metric           | v5.0.0 | v5.1.0      | Improvement      |
| ---------------- | ------ | ----------- | ---------------- |
| Startup Time     | 3305ms | 1200ms      | **63% faster**   |
| Command Registry | 1770ms | 0ms (lazy)  | **Eliminated**   |
| Starship Init    | 325ms  | 0ms (async) | **Non-blocking** |
| Memory Usage     | ~25MB  | ~17MB       | **32% less**     |

**User Impact:** Save 2+ seconds on every shell launch!

---

## 🔧 What's New

### 1. Lazy Command Registration

- Commands register only when `Get-Helper` is first called
- Shell is usable immediately
- Saves 1770ms (53.6%) on startup
- One-time registration, then cached

### 2. Async Starship Initialization

- Simple prompt appears instantly
- Starship loads in background via `Register-EngineEvent`
- Saves 325ms (9.8%) from critical path
- Seamless transition to fancy prompt

### 3. Optimized Environment Loading

- Set defaults first (avoid I/O)
- Use `-LiteralPath` for faster checks
- Merge configs instead of replace
- Saves 20ms (0.6%)

### 4. Deferred Module Features

- Non-essential features load on-demand
- Reduced synchronous initialization
- Saves 4ms (0.1%)

**Total Savings: 2119ms (63% improvement)**

---

## 📦 Installation

### New Installation

**Windows:**

```powershell
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/installation/install.ps1 | iex
```

**Linux/macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/installation/install.sh | bash
```

### Update from v5.0.0

**Option 1: Git Pull**

```powershell
cd $env:USERPROFILE\.config\powershell\ProfileCore  # or your install location
git pull
. $PROFILE  # Reload profile
```

**Option 2: Reinstall**

```powershell
# Run the installer again - it will detect and update
irm https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/installation/install.ps1 | iex
```

---

## 🎯 Breaking Changes

**None!** This is a drop-in replacement for v5.0.0.

All existing functionality is preserved:

- ✅ All 97 commands work as before
- ✅ Configuration files compatible
- ✅ Plugins load normally
- ✅ PSReadLine settings preserved
- ✅ Starship configuration unchanged

---

## 💡 What to Expect

### First Launch

- **Shell appears in ~1.2s** (down from 3.3s!)
- Simple prompt shows immediately
- Starship prompt appears after ~300ms
- All commands available instantly

### Using Get-Helper

- **First call:** Takes ~1.7s (one-time registration)
- **Subsequent calls:** Instant (cached)
- This is the trade-off for faster startup

### Normal Usage

- Everything works exactly as before
- Just faster!
- No configuration changes needed

---

## 📚 Documentation

### Performance Details

- [Final Optimization Report](FINAL_OPTIMIZATION_REPORT.md) - Complete analysis
- [Migration Guide](docs/user-guide/migration-v5.1.md) - Upgrade instructions
- [Full Changelog](CHANGELOG.md) - All changes

### User Guides

- [Installation Guide](docs/user-guide/installation.md)
- [Quick Start](docs/user-guide/quick-start.md)
- [Command Reference](docs/user-guide/command-reference.md)

### Developer Docs

- [Architecture](docs/developer/architecture-principles.md)
- [Contributing](docs/developer/contributing.md)
- [Build System](docs/developer/build-system.md)

---

## 🔍 Verification

### Check Your Version

```powershell
Get-Module ProfileCore | Select-Object Name, Version
```

Should show: `Version: 5.1.0`

### Measure Your Startup

```powershell
# Time your profile load
Measure-Command { . $PROFILE }
```

Should be ~1200ms or less (first run may be slower due to caching).

### Verify Optimizations

```powershell
# Check if lazy loading is active
$global:ProfileCommands.Metadata.LazyLoaded  # Should be $true

# Check Starship is async
Get-Job | Where-Object { $_.Name -like "*Starship*" }  # Should see background job
```

---

## 🐛 Known Issues

None at this time!

If you encounter any issues:

1. Check [GitHub Issues](https://github.com/mythic3011/ProfileCore/issues)
2. [Open a new issue](https://github.com/mythic3011/ProfileCore/issues/new) with:
   - Your OS and PowerShell version
   - Error messages or unexpected behavior
   - Steps to reproduce

---

## 🙏 Acknowledgments

This performance release was made possible through:

- **Data-driven profiling** - Measured 10 iterations per component
- **Systematic optimization** - Focused on biggest bottlenecks first
- **Community feedback** - User reports of slow startups
- **PowerShell best practices** - Lazy loading, async operations

Special thanks to the PowerShell community for performance optimization techniques and best practices.

---

## 🔮 What's Next?

### v5.2.0 (Future)

Potential improvements being explored:

- Full module auto-loading (~1100ms additional savings possible)
- Further lazy loading of plugin discovery
- Cached prompt data
- Parallel initialization experiments
- Rust binary module (experimental)

**Goal:** Sub-500ms startup time

Stay tuned!

---

## 📞 Support

**Questions?**

- 📖 [Documentation](https://github.com/mythic3011/ProfileCore/tree/main/docs)
- 💬 [Discussions](https://github.com/mythic3011/ProfileCore/discussions)
- 🐛 [Issues](https://github.com/mythic3011/ProfileCore/issues)

**Enjoying ProfileCore?**

- ⭐ [Star us on GitHub](https://github.com/mythic3011/ProfileCore)
- 🔄 Share with your team
- 🎉 Spread the word!

---

**ProfileCore v5.1.0 - Making PowerShell Fast Again!** ⚡

_Released with ❤️ by the ProfileCore team_
