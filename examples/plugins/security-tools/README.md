# Security Tools Plugin

## Overview

Essential security tools for penetration testing, system analysis, and security verification. Migrated from legacy commands to SOLID architecture plugin.

## Features

### 🔑 SSH Key Management

- **`Copy-SshId`** / **`ssh-copy-id`** - Copy SSH public key to remote server
  ```powershell
  ssh-copy-id user@hostname
  ssh-copy-id -UserAtMachine user@server -KeyPath ~/.ssh/custom_key.pub
  ```

### 🔍 File Verification

- **`Test-FileHash`** - Verify file integrity with hash comparison

  ```powershell
  Test-FileHash -FilePath ./download.iso -ExpectedHash "abc123..." -Algorithm SHA256
  ```

  Supported algorithms: MD5, SHA1, SHA256, SHA384, SHA512

### 🛡️ VirusTotal Integration

- **`Test-FileOnVirusTotal`** - Check files against VirusTotal database

  ```powershell
  Test-FileOnVirusTotal -FilePath ./suspicious.exe
  ```

  Requires: VirusTotal API key

### 🌐 Shodan IP Lookup

- **`Get-ShodanIPInfo`** / **`Check-IPonShodan`** - Query Shodan for IP information

  ```powershell
  Get-ShodanIPInfo -IPAddress "8.8.8.8"
  Check-IPonShodan "1.1.1.1"
  ```

  Requires: Shodan API key

## Installation

### Copy to Plugins Directory

```powershell
$pluginSource = "./examples/plugins/security-tools"
$pluginDest = "$HOME/.profilecore/plugins/security-tools"

Copy-Item -Path $pluginSource -Destination $pluginDest -Recurse -Force
```

### Enable the Plugin

```powershell
Enable-ProfileCorePlugin -Name 'security-tools'

# Reload profile
. $PROFILE
```

## Configuration

### API Keys

Create `~/.config/shell-profile/secrets.json`:

```json
{
  "VIRUSTOTAL_API": "your-virustotal-api-key-here",
  "SHODAN_API": "your-shodan-api-key-here"
}
```

Or use environment variables:

```powershell
$env:PWSH_VIRUSTOTAL_API = "your-key"
$env:PWSH_SHODAN_API = "your-key"
```

### Plugin Configuration

`~/.config/shell-profile/security-tools.json`:

```json
{
  "DefaultKeyPath": "~/.ssh/id_rsa.pub",
  "DefaultHashAlgorithm": "SHA256",
  "EnableVirusTotal": true,
  "EnableShodan": true
}
```

## Usage Examples

### SSH Key Copy

```powershell
# Basic usage
ssh-copy-id user@server.com

# Custom key
ssh-copy-id user@server.com -KeyPath ~/.ssh/custom_key.pub

# With SSH options
ssh-copy-id user@server.com -SshArgs "-p 2222"
```

### File Hash Verification

```powershell
# Interactive mode
Test-FileHash

# Programmatic
$result = Test-FileHash -FilePath ./file.zip -ExpectedHash "abc123..." -Algorithm SHA256

if ($result.Valid) {
    Write-Host "File is valid"
} else {
    Write-Host "File is corrupted or tampered"
}
```

### VirusTotal Scanning

```powershell
# Scan a file
$result = Test-FileOnVirusTotal -FilePath ./download.exe

if ($result.Safe) {
    Write-Host "File is safe to use"
} else {
    Write-Host "WARNING: $($result.Malicious) threats detected!"
    Write-Host "Report: $($result.Url)"
}
```

### Shodan IP Reconnaissance

```powershell
# Lookup IP
$info = Get-ShodanIPInfo -IPAddress "1.2.3.4"

Write-Host "Organization: $($info.Organization)"
Write-Host "Country: $($info.Country)"
Write-Host "Open Ports: $($info.Ports -join ', ')"

if ($info.Vulnerabilities) {
    Write-Host "⚠️  Known vulnerabilities found!"
}
```

## Architecture

### SOLID Principles

**Single Responsibility:**

- Each command has one purpose
- Separate concerns for API integration, file operations, etc.

**Open/Closed:**

- Extend via plugin without modifying core
- Add new security tools by registering commands

**Dependency Injection:**

- Uses ConfigurationManager for settings
- Accesses services via ServiceContainer

### Command Provider Pattern

```powershell
class SecurityToolsPlugin : PluginBaseV2 {
    [void] RegisterCommands() {
        $cmdCapability = [CommandProviderCapability]::new()

        $cmdCapability.RegisterCommand('Copy-SshId', {
            # Command implementation
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })

        $this.RegisterCapability('CommandProvider', $cmdCapability)
    }
}
```

## Security Considerations

### API Keys

- Never commit API keys to version control
- Store in `secrets.json` (excluded from sync)
- Use environment variables for CI/CD

### File Operations

- Always validate file paths
- Check file existence before operations
- Handle errors gracefully

### Network Requests

- API calls are cached to reduce quota usage
- Timeouts prevent hanging
- Error handling for network failures

## Troubleshooting

### Command Not Found

```powershell
# Check plugin status
Get-ProfileCorePluginInfo -Name 'security-tools'

# Reload plugin
Disable-ProfileCorePlugin -Name 'security-tools'
Enable-ProfileCorePlugin -Name 'security-tools'
. $PROFILE
```

### API Key Issues

```powershell
# Verify configuration
$configMgr = [ServiceLocator]::Get('ConfigurationManager')
$apiKey = $configMgr.GetValue('secrets', 'VIRUSTOTAL_API')

if ($apiKey) {
    Write-Host "✅ API key configured"
} else {
    Write-Host "❌ API key not found"
}
```

### Debug Logging

```powershell
# Enable verbose output
$VerbosePreference = 'Continue'

# Check logs
Get-Content "$HOME/.profilecore/logs/plugin-security-tools.log"
```

## Migration from Legacy

### Old Way (v4.0)

```powershell
# Functions in profile
function Register-LegacyCommands {
    function Copy-SshId { ... }
    function Test-FileOnVirusTotal { ... }
    # Mixed in with profile code
}
```

### New Way (v5.0)

```powershell
# Plugin with SOLID architecture
class SecurityToolsPlugin : PluginBaseV2 {
    # Proper separation of concerns
    # Dependency injection
    # Testable, extensible
}
```

## Contributing

### Adding New Security Tools

```powershell
# In security-tools.psm1
$cmdCapability.RegisterCommand('New-SecurityCommand', {
    param($params)

    # Your implementation

}, @{
    EnableCache = $true
    RequiresElevation = $false
})

# Export in Initialize-SecurityTools
New-Item -Path "Function:\global:New-SecurityCommand" -Value {
    # Wrapper function
} -Force | Out-Null
```

## License

MIT License - See ProfileCore LICENSE

---

<div align="center">

**Security Tools Plugin** - _Essential Security Utilities_

**[🏠 ProfileCore](../../../README.md)** • **[📖 Plugin Guide](../../../docs/development/SOLID_ARCHITECTURE.md)**

</div>
