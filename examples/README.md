# ProfileCore Examples 📚

**Example configurations and templates for ProfileCore**

---

## 📦 What's Here

### config-templates/

Example configuration files you can use as starting points:

- **example-config.json** - Feature toggles and settings
- **example-paths.json** - Application path mappings
- **example-aliases.json** - Custom shell aliases
- **example.env** - Environment variables template

---

## 🚀 How to Use

### 1. Copy Templates

```powershell
# Copy to your config directory
Copy-Item examples/config-templates/example-config.json ~/.config/shell-profile/config.json
Copy-Item examples/config-templates/example-paths.json ~/.config/shell-profile/paths.json
Copy-Item examples/config-templates/example-aliases.json ~/.config/shell-profile/aliases.json
Copy-Item examples/config-templates/example.env ~/.config/shell-profile/.env
```

### 2. Customize

Edit the copied files to match your preferences:

```powershell
# Edit configuration
code ~/.config/shell-profile/config.json

# Edit paths
code ~/.config/shell-profile/paths.json

# Edit aliases
code ~/.config/shell-profile/aliases.json

# Edit environment variables
code ~/.config/shell-profile/.env
```

### 3. Reload

```powershell
# Reload profile to apply changes
. $PROFILE
```

---

## 📋 Template Overview

### config.json - Feature Configuration

Controls which ProfileCore features are enabled:

- Starship prompt integration
- PSReadLine enhancements
- Performance optimizations
- Plugin auto-loading
- Cloud sync settings

### paths.json - Application Paths

Cross-platform path mappings for common applications:

- Code editors (VS Code, Sublime, Vim)
- Browsers (Chrome, Firefox, Edge)
- Development tools (Git, Docker, Node)
- Custom applications

### aliases.json - Custom Aliases

Define custom shell aliases that work across all shells:

- Short commands
- Common operations
- Project-specific shortcuts
- Team conventions

### .env - Environment Variables

Secure storage for API keys and secrets:

- GitHub tokens
- API keys
- Custom variables
- Secret values

**⚠️ Never commit .env files to Git!**

---

## 💡 Tips

### Best Practices

1. **Start with examples** - Copy and modify
2. **Back up before editing** - Save your work
3. **Test changes** - Reload profile to verify
4. **Keep it simple** - Add complexity gradually
5. **Document your changes** - Add comments

### Common Use Cases

**Different paths per machine:**

```json
{
  "vscode": {
    "windows": "C:\\Program Files\\Microsoft VS Code\\Code.exe",
    "macos": "/Applications/Visual Studio Code.app/Contents/MacOS/Electron",
    "linux": "/usr/bin/code"
  }
}
```

**Custom aliases:**

```json
{
  "work": "cd ~/Projects/work",
  "personal": "cd ~/Projects/personal",
  "deploy": "git push && docker build"
}
```

---

## 🔧 Advanced Examples

### Plugin Configuration Example

Create plugin-specific configs:

```powershell
# Plugin config location
~/.profilecore/plugins/my-plugin/config.json

# Example content
{
  "apiUrl": "https://api.example.com",
  "timeout": 30,
  "retries": 3
}
```

### Multi-Environment Setup

Use different configs for work/personal:

```powershell
# Work config
~/.config/shell-profile/config.work.json

# Personal config
~/.config/shell-profile/config.personal.json

# Switch between them with custom script
```

---

## 📚 Related Documentation

- [Installation Guide](../INSTALL.md)
- [Quick Start Guide](../QUICK_START.md)
- [Configuration Documentation](../docs/features/)
- [Plugin System](../PLUGIN_SYSTEM_README.md)

---

<div align="center">

**ProfileCore Examples** - _Templates to Get You Started_

**[📖 Main Docs](../README.md)** • **[⚙️ Configuration](config-templates/)** • **[🚀 Quick Start](../QUICK_START.md)**

</div>

