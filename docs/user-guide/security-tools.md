# Security Features Guide 🔐

**ProfileCore v3.5** - Complete Information Security Toolkit

---

## 🎯 Overview

ProfileCore v3.5 includes a comprehensive suite of **14 information security functions** for network scanning, vulnerability assessment, password management, and web security analysis. All tools are fully cross-platform compatible (Windows, macOS, Linux) and designed with security best practices.

**✨ What's Included:**

- 🔍 Network Security Tools (4 features)
- 🔐 Security Analysis Tools (2 features)
- 🌐 DNS & Domain Tools (2 features)
- 🔑 Password Management (1 feature)
- 🔒 Web Security (1 feature)

**Total: 6 Major Security Features | 14 Functions | Cross-Platform**

---

## 🔍 Network Security Tools

### 1. Port Scanner

**Advanced port scanning with service detection and banner grabbing.**

#### PowerShell Usage

```powershell
# Scan single port
Test-Port -Target 192.168.1.1 -Port 80

# Scan multiple ports
Test-Port -Target example.com -Port 22,80,443

# Scan port range
Test-Port -Target 192.168.1.1 -Port "1-1000"

# With service detection and banner grabbing
Test-Port -Target example.com -Port 80,443 -ServiceDetection

# Show closed ports
Test-Port -Target localhost -Port "1-100" -ShowClosed

# Custom timeout (in milliseconds)
Test-Port -Target slow-server.com -Port 80 -Timeout 5000
```

#### Unix Shell Usage (Zsh/Bash/Fish)

```bash
# Scan single port
scan-port 192.168.1.1 80

# Scan multiple ports
scan-port example.com 22,80,443

# Scan port range
scan-port 192.168.1.1 1-1000

# With custom timeout (in seconds)
scan-port example.com 80 5
```

---

### Quick Scan Presets

**Predefined port ranges for common scenarios.**

#### PowerShell

```powershell
# Top 20 most common ports
Test-PortRange -Target 192.168.1.1 -Range Top20

# Top 100 ports
Test-PortRange -Target example.com -Range Top100

# Top 1000 ports
Test-PortRange -Target server.local -Range Top1000

# All ports (1-65535) - WARNING: Very slow!
Test-PortRange -Target 127.0.0.1 -Range All

# Using alias
quick-scan 192.168.1.1 Top20
```

#### Unix Shells

```bash
# Top 20 most common ports
quick-scan 192.168.1.1 top20

# Top 100 ports
quick-scan example.com top100

# Web servers only
quick-scan example.com web

# Database servers only
quick-scan 192.168.1.1 database
```

---

### Common Ports Reference

**List of commonly used ports by category.**

#### PowerShell

```powershell
# Get all common ports
Get-CommonPorts

# Get ports by category
Get-CommonPorts -Category Web
Get-CommonPorts -Category Database
Get-CommonPorts -Category Mail
Get-CommonPorts -Category File
Get-CommonPorts -Category Remote
```

#### Unix Shells

```bash
# Display common ports reference
get-common-ports
common-ports
```

---

## 📊 Port Scanner Features

### ✨ Core Features

- ✅ **Single Port Scanning** - Check if a specific port is open
- ✅ **Multiple Port Scanning** - Scan comma-separated port list
- ✅ **Port Range Scanning** - Scan continuous range (e.g., 1-1000)
- ✅ **Service Detection** - Auto-identify common services
- ✅ **Banner Grabbing** - Capture service banners (PowerShell)
- ✅ **Async Scanning** - Fast concurrent scanning
- ✅ **Configurable Timeout** - Adjust for slow networks
- ✅ **Quick Scan Presets** - Predefined common scenarios
- ✅ **Cross-Platform** - Works on Windows, macOS, Linux

### 🎯 Use Cases

1. **Network Discovery**

   ```powershell
   # Find active services on local network
   quick-scan 192.168.1.1 top20
   ```

2. **Security Auditing**

   ```powershell
   # Check for exposed services
   Test-Port -Target myserver.com -Port 22,3389,5900 -ServiceDetection
   ```

3. **Troubleshooting**

   ```bash
   # Verify service availability
   scan-port localhost 80,443,3000
   ```

4. **Vulnerability Assessment**
   ```powershell
   # Scan for database ports
   quick-scan database-server database
   ```

---

## 🔒 Security Best Practices

### ⚠️ Legal & Ethical Considerations

**IMPORTANT:** Only scan systems you own or have explicit permission to test.

- ✅ **DO**: Scan your own servers and networks
- ✅ **DO**: Get written permission before scanning
- ✅ **DO**: Use for legitimate security assessments
- ❌ **DON'T**: Scan systems without authorization
- ❌ **DON'T**: Use for malicious purposes
- ❌ **DON'T**: Scan production systems without approval

### 🛡️ Security Recommendations

1. **Rate Limiting**

   - Don't scan too aggressively
   - Use appropriate timeouts
   - Respect network resources

2. **Monitoring**

   - Be aware port scans may trigger alerts
   - Inform your security team
   - Document your testing

3. **Privacy**
   - Don't share scan results publicly
   - Protect sensitive information
   - Follow responsible disclosure

---

## 📋 Service Detection Reference

### Common Services Detected

| Port  | Service    | Description                      |
| ----- | ---------- | -------------------------------- |
| 20/21 | FTP        | File Transfer Protocol           |
| 22    | SSH        | Secure Shell                     |
| 23    | Telnet     | Telnet (Insecure!)               |
| 25    | SMTP       | Simple Mail Transfer Protocol    |
| 53    | DNS        | Domain Name System               |
| 80    | HTTP       | Web Server                       |
| 110   | POP3       | Post Office Protocol             |
| 143   | IMAP       | Internet Message Access Protocol |
| 443   | HTTPS      | Secure Web Server                |
| 445   | SMB        | Server Message Block             |
| 3306  | MySQL      | MySQL Database                   |
| 3389  | RDP        | Remote Desktop Protocol          |
| 5432  | PostgreSQL | PostgreSQL Database              |
| 6379  | Redis      | Redis Cache                      |
| 8080  | HTTP-Alt   | Alternative Web Server           |
| 27017 | MongoDB    | MongoDB Database                 |

---

## 💡 Advanced Usage Examples

### Example 1: Local Development Check

```powershell
# Check your local development environment
$devPorts = @(3000, 3001, 5000, 5432, 6379, 8080, 9000)
Test-Port -Target localhost -Port $devPorts
```

### Example 2: Production Server Audit

```powershell
# Comprehensive server audit
$server = "prod-server.company.com"
Write-Host "Scanning $server..."

# Check web services
Test-Port -Target $server -Port 80,443,8080 -ServiceDetection

# Check databases (should be closed!)
Test-Port -Target $server -Port 3306,5432,27017 -ServiceDetection

# Check remote access
Test-Port -Target $server -Port 22,3389 -ServiceDetection
```

### Example 3: Network Discovery

```bash
# Scan local network for common services
for ip in 192.168.1.{1..254}; do
    echo "Scanning $ip..."
    quick-scan $ip top20
done
```

### Example 4: Docker Container Check

```bash
# Verify Docker services are running
scan-port localhost 2375,2376  # Docker daemon
scan-port localhost 5000       # Registry
scan-port localhost 8080       # Portainer
```

---

## 🚀 Performance Tips

1. **Adjust Timeouts**

   ```powershell
   # Faster scan (1 second timeout)
   Test-Port -Target fast-server.com -Port "1-100" -Timeout 1000

   # Slower scan (5 second timeout for slow networks)
   Test-Port -Target slow-server.com -Port 80 -Timeout 5000
   ```

2. **Use Quick Scans**

   ```bash
   # Instead of scanning all ports, use presets
   quick-scan myserver top20  # Fast
   # vs
   scan-port myserver 1-65535  # Very slow!
   ```

3. **Parallel Scanning**
   ```powershell
   # PowerShell automatically uses async scanning
   # No additional configuration needed
   ```

---

## 🔧 Troubleshooting

### Port Scan Not Working

**Issue:** Scan shows all ports as closed

**Solutions:**

1. Check firewall settings
2. Verify network connectivity
3. Ensure target is reachable (`ping target`)
4. Increase timeout for slow networks
5. Check if `nc` (netcat) is installed on Unix

### Slow Scanning

**Issue:** Scans take very long

**Solutions:**

1. Reduce timeout value
2. Use quick scan presets instead of ranges
3. Scan fewer ports at once
4. Check network latency

### Permission Denied

**Issue:** Can't scan certain ports

**Solutions:**

1. On Unix, scanning ports < 1024 may need sudo
2. Check firewall rules
3. Verify you have network permissions

---

## 📚 Related Documentation

- [Feature Expansion Plan](FEATURE_EXPANSION_PLAN.md) - Upcoming security features
- [Performance Optimization](PERFORMANCE_OPTIMIZATION.md) - Speed tips
- [Quick Start Guide](QUICK_START.md) - Getting started

---

## 🔐 SSL/TLS Certificate Checker

**Comprehensive SSL certificate validation and security analysis.**

### PowerShell Usage

```powershell
# Check SSL certificate
Test-SSLCertificate -Domain github.com

# Check multiple domains
check-ssl google.com facebook.com twitter.com

# Show full certificate chain
Test-SSLCertificate -Domain github.com -ShowChain

# Quick expiration check for multiple domains
Test-CertificateExpiration -Domain google.com,github.com,microsoft.com
cert-expiry example.com mysite.com
```

### Unix Shell Usage

```bash
# Check SSL certificate
check-ssl github.com

# Quick expiry check
cert-expiry google.com github.com microsoft.com
```

### Features

- ✅ Certificate expiration checking with countdown
- ✅ Security grade rating (A+ to F)
- ✅ TLS/SSL version detection
- ✅ Cipher suite analysis
- ✅ Certificate chain display
- ✅ Weak algorithm detection
- ✅ Multi-domain batch checking
- ✅ Automatic expiration warnings

---

## 🌐 DNS Security Tools

**Comprehensive DNS lookup and security analysis.**

### PowerShell Usage

```powershell
# DNS lookup (single record type)
Get-DNSInfo -Domain example.com -RecordType A

# All record types
dns-lookup microsoft.com ALL

# Check DNS propagation across multiple servers
Test-DNSPropagation -Domain example.com -RecordType A

# Reverse DNS lookup
Get-ReverseDNS -IPAddress 8.8.8.8
reverse-dns 1.1.1.1
```

### Unix Shell Usage

```bash
# DNS lookup
dns-lookup google.com A
dns-lookup example.com MX
dns-lookup github.com ALL

# DNS propagation check
dns-propagation example.com A

# Reverse DNS
reverse-dns 8.8.8.8
```

### Features

- ✅ Multiple record types (A, AAAA, MX, TXT, NS, CNAME, SOA)
- ✅ DNS propagation checking across major DNS servers
- ✅ Reverse DNS lookup (PTR records)
- ✅ Multi-server comparison
- ✅ Propagation consistency analysis

---

## 📝 WHOIS Lookup

**Enhanced WHOIS domain information retrieval.**

### PowerShell Usage

```powershell
# WHOIS lookup
Get-WHOISInfo -Domain github.com

# Check multiple domains
whois-lookup google.com example.com
```

### Unix Shell Usage

```bash
# WHOIS lookup
whois-lookup github.com
```

### Features

- ✅ Domain registration details
- ✅ Expiration date with countdown
- ✅ Registrar information
- ✅ Name server listing
- ✅ Domain status
- ✅ Expiration warnings
- ✅ Auto-formatted output

---

## 🔑 Password Tools

**Cryptographically secure password generation and strength analysis.**

### PowerShell Usage

```powershell
# Generate single password
New-SecurePassword -Length 16

# Generate with symbols
gen-password 20 -IncludeSymbols

# Generate multiple passwords
New-SecurePassword -Length 16 -Count 5

# Generate memorable passphrase
New-SecurePassword -Passphrase

# Exclude ambiguous characters
gen-password 16 -ExcludeAmbiguous -IncludeSymbols

# Test password strength
Test-PasswordStrength -Password "MyP@ssw0rd123"
check-password "SecureP@ss2024!"

# Hash password
ConvertTo-SecureHash -Password "MyPassword" -Algorithm SHA256
```

### Unix Shell Usage

```bash
# Generate password
gen-password 20
pwgen 16

# Generate with symbols
gen-password 20 --symbols

# Generate passphrase
gen-password --passphrase

# Test password strength
check-password "MyP@ssw0rd123"
pwstrength "SecureP@ss2024!"
```

### Features

- ✅ Cryptographically secure random generation
- ✅ Customizable length (4-128 characters)
- ✅ Multiple character sets (letters, numbers, symbols)
- ✅ Passphrase generation (4-word memorable phrases)
- ✅ Exclude ambiguous characters option
- ✅ Batch generation (multiple passwords at once)
- ✅ Password strength analysis (0-100 score)
- ✅ Pattern detection (repeated chars, common sequences)
- ✅ Complexity requirements validation
- ✅ Security recommendations
- ✅ Password hashing (SHA256, SHA512, MD5)

---

## 🔒 HTTP Security Headers

**Web application security header analysis.**

### PowerShell Usage

```powershell
# Basic security header check
Test-SecurityHeaders -URL https://github.com

# Detailed analysis
check-headers https://google.com -Detailed

# CORS configuration check
Test-CORSConfiguration -URL https://api.example.com
check-cors https://api.example.com -Origin "https://mysite.com"
```

### Unix Shell Usage

```bash
# Check security headers
check-headers https://github.com

# Detailed check
check-headers https://google.com --detailed
```

### Features

- ✅ Critical security header detection
- ✅ HSTS (HTTP Strict Transport Security)
- ✅ X-Frame-Options (clickjacking protection)
- ✅ Content-Security-Policy
- ✅ X-Content-Type-Options
- ✅ X-XSS-Protection
- ✅ Referrer-Policy
- ✅ Permissions-Policy
- ✅ Information disclosure checks
- ✅ Security score (0-100) and grade (A+ to F)
- ✅ CORS configuration analysis
- ✅ Detailed recommendations

---

## 🎓 Future Security Features

**Coming in Phase 2 (Developer Productivity):**

- 📁 File Integrity Monitor
- 🔍 Log Analysis Tools
- 🛠️ DevOps Automation

**Coming in Phase 3 (System Administration):**

- 💻 Process Monitoring
- 📊 Resource Usage Analysis
- 🔄 Service Management

Stay tuned! ⚡

---

<div align="center">

**ProfileCore v3.5** - _Security Made Simple_ 🔐

**Scan Responsibly. Secure Effectively.**

</div>
