# Configuration Templates 📝

**Example configuration files for ProfileCore**

---

## 📦 Templates Included

| File                   | Purpose               | Location                               |
| ---------------------- | --------------------- | -------------------------------------- |
| `example-config.json`  | Feature toggles       | `~/.config/shell-profile/config.json`  |
| `example-paths.json`   | Application paths     | `~/.config/shell-profile/paths.json`   |
| `example-aliases.json` | Custom aliases        | `~/.config/shell-profile/aliases.json` |
| `example.env`          | Environment variables | `~/.config/shell-profile/.env`         |

---

## 🚀 Quick Start

### Copy All Templates

```powershell
# Create config directory if needed
New-Item -Path ~/.config/shell-profile -ItemType Directory -Force

# Copy all templates
Copy-Item examples/config-templates/example-*.* ~/.config/shell-profile/

# Rename to remove 'example-' prefix
Rename-Item ~/.config/shell-profile/example-config.json config.json
Rename-Item ~/.config/shell-profile/example-paths.json paths.json
Rename-Item ~/.config/shell-profile/example-aliases.json aliases.json
Rename-Item ~/.config/shell-profile/example.env .env
```

### Or Copy Individually

```powershell
# Just what you need
Copy-Item examples/config-templates/example-config.json ~/.config/shell-profile/config.json
```

---

## 📋 Template Details

### example-config.json

```json
{
  "version": "4.1.0",
  "theme": "default",
  "features": {
    "starship": true,
    "psreadline": true,
    "performance": true,
    "plugins": true,
    "cloudSync": false
  },
  "autoUpdate": {
    "enabled": false,
    "schedule": "Weekly"
  }
}
```

### example-paths.json

```json
{
  "vscode": {
    "windows": "C:\\Program Files\\Microsoft VS Code\\Code.exe",
    "macos": "/Applications/Visual Studio Code.app",
    "linux": "/usr/bin/code"
  },
  "chrome": {
    "windows": "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    "macos": "/Applications/Google Chrome.app",
    "linux": "/usr/bin/google-chrome"
  }
}
```

### example-aliases.json

```json
{
  "ll": "ls -la",
  "work": "cd ~/Projects/work",
  "home": "cd ~",
  "reload": ". $PROFILE"
}
```

### example.env

```bash
# GitHub Token (for sync, plugins)
export GITHUB_TOKEN="ghp_your_token_here"

# OpenAI API Key (for AI features - future)
export OPENAI_API_KEY="sk-your_key_here"

# Custom Variables
export MY_PROJECT_PATH="/path/to/project"
export MY_EMAIL="your@email.com"
```

---

## 💡 Customization Tips

### Add Your Own Paths

```json
{
  "myapp": {
    "windows": "C:\\MyApp\\app.exe",
    "macos": "/Applications/MyApp.app",
    "linux": "/usr/local/bin/myapp"
  }
}
```

### Add Custom Aliases

```json
{
  "deploy": "git push && npm run build",
  "test": "npm test",
  "dev": "npm run dev"
}
```

### Add Environment Variables

```bash
# API Keys
export MY_API_KEY="your_key_here"

# Paths
export MY_DATA_DIR="/path/to/data"

# Settings
export MY_SETTING="value"
```

---

<div align="center">

**Configuration Templates** - _Copy, Customize, Use_

**[📖 Examples Guide](../README.md)** • **[🚀 Quick Start](../../QUICK_START.md)**

</div>

