# ProfileCore v4.0.0 - Quick Reference 📖

**Fast command reference for all ProfileCore functions.**

---

## 🔐 **Security Functions**

### **Port Scanner**

```powershell
# Single port
Test-Port -Target google.com -Port 80

# Multiple ports
scan-port google.com 80,443,8080

# Port range
scan-port 192.168.1.1 1-1000

# Quick scans
quick-scan google.com web      # Common web ports
quick-scan localhost all        # All common ports
```

### **SSL/TLS Certificate Checker**

```powershell
# Check SSL certificate
check-ssl github.com

# Check multiple domains
cert-expiry github.com,google.com,microsoft.com

# Detailed analysis
Test-SSLCertificate -Domain github.com -Detailed
```

### **DNS Tools**

```powershell
# DNS lookup
dns-lookup google.com A

# All records
dns-lookup microsoft.com ALL

# Check propagation
dns-propagation example.com

# Reverse DNS
reverse-dns 8.8.8.8
```

### **WHOIS Lookup**

```powershell
# Domain info
whois-lookup example.com

# Detailed WHOIS
Get-WHOISInfo -Domain github.com
```

### **Password Tools**

```powershell
# Generate password
gen-password 20 -IncludeSymbols

# Check password strength
check-password "MyP@ssw0rd123"

# Hash password
hash-password "MyPassword" SHA256
```

### **Web Security**

```powershell
# Check security headers
check-headers https://github.com

# Check CORS
check-cors https://api.example.com
```

---

## 🔧 **Developer Functions**

### **Git Automation**

```powershell
# Quick commit and push
gqc "Fixed bug in login"

# Enhanced git status
git-status

# Clean merged branches
git-cleanup --dry-run

# Create new branch
new-branch feature/api-update main

# Sync repository
git-sync
```

### **Docker Management**

```powershell
# Container status
docker-status

# Stop all containers
docker-stop-all

# Clean stopped containers
docker-clean

# System cleanup
docker-prune --all --volumes

# Docker Compose
dc-up --build
dc-down
dlogs myapp --follow
```

### **Project Initializer**

```powershell
# Initialize Node.js project
init-project my-app -Type Node -Git

# React app with MIT license
init-project my-react-app -Type React -Git -License MIT

# Python project
init-project my-api -Type Python -Git -License Apache2
```

---

## 💻 **System Administration**

### **System Monitoring**

```powershell
# System information
sysinfo

# Top processes (CPU)
pinfo 20 CPU

# Top processes (Memory)
pinfo 15 Memory

# Disk usage
diskinfo

# Active network connections
netstat-active

# Filter by port
netstat-active 80
```

### **Process Management**

```powershell
# Kill process by name
killp chrome

# Force kill
killp node --force
```

---

## 📦 **Package Management**

### **Cross-Platform Package Manager**

```powershell
# Install package
pkg install git

# Search packages
pkg-search docker

# Update all packages
pkgu

# Package information
pkg-info nodejs
```

### **Bulk Installation**

```powershell
# Install from file
pkg-install-list packages.txt

# Install from list
pkg-install-list git,docker,nodejs,python
```

---

## ⚡ **Performance Tools**

### **Performance Analysis**

```powershell
# Check performance
profile-perf

# Detailed metrics
Measure-ProfilePerformance
```

### **Optimization**

```powershell
# Auto-optimize
Optimize-ProfileCore

# Clear caches
Reset-ProfileCache
```

---

## 🌍 **Cross-Platform Utilities**

### **OS Detection**

```powershell
# Get OS
Get-OperatingSystem          # "Windows", "macOS", or "Linux"

# OS checks
Test-IsWindows              # True on Windows
Test-IsMacOS                # True on macOS
Test-IsLinux                # True on Linux
```

### **Path Management**

```powershell
# Get cross-platform path
Get-CrossPlatformPath "downloads"

# Open current directory
Open-cd
```

### **Network Utilities**

```powershell
# Get public IP
myip

# Get local IPs
localips
```

---

## 🎯 **Common Workflows**

### **Security Audit**

```bash
# Check domain security
check-ssl example.com
check-headers https://example.com
dns-lookup example.com ALL
whois-lookup example.com
```

### **Developer Workflow**

```bash
# Daily development
git-status                          # Check repo status
gqc "Fixed bug" --all --push       # Quick commit
docker-status                       # Check containers
pinfo 10 CPU                        # Check system load
```

### **System Health Check**

```bash
# Quick system overview
sysinfo
diskinfo
netstat-active
pinfo 15 CPU
```

### **Setup New Project**

```bash
# Initialize new React project
init-project my-app -Type React -Git -License MIT
cd my-app
git-status
```

---

## 📋 **Aliases Reference**

### **Security**

- `scan-port` → Test-Port
- `check-ssl` → Test-SSLCertificate
- `dns-lookup` → Get-DNSInfo
- `whois-lookup` → Get-WHOISInfo
- `gen-password` → New-SecurePassword
- `check-password` → Test-PasswordStrength
- `check-headers` → Test-SecurityHeaders

### **Developer**

- `gqc` → Invoke-GitQuickCommit
- `git-status` → Get-GitBranchInfo
- `git-cleanup` → Remove-GitMergedBranches
- `new-branch` → New-GitBranch
- `git-sync` → Sync-GitRepository
- `docker-status` → Get-DockerStatus
- `dc-up` → Start-DockerCompose
- `dc-down` → Stop-DockerCompose
- `dlogs` → Get-DockerLogs
- `init-project` → New-DevProject

### **System**

- `sysinfo` → Get-SystemInfo
- `pinfo` → Get-ProcessInfo
- `killp` → Stop-ProcessByName
- `diskinfo` → Get-DiskInfo
- `netstat-active` → Get-NetworkConnections

### **Package**

- `pkg` → Install-CrossPlatformPackage
- `pkgu` → Update-AllPackages
- `pkg-search` → Search-Package
- `pkg-info` → Get-PackageInfo

### **Performance**

- `profile-perf` / `perf` → Measure-ProfilePerformance
- `optimize-profile` → Optimize-ProfileCore

### **Utilities**

- `myip` → Get-PublicIP
- `localips` → Get-LocalNetworkIPs
- `Open-cd` → Open-CurrentDirectory

---

## 💡 **Tips & Tricks**

### **Get Command Help**

```powershell
Get-Help Test-Port -Full
Get-Help gen-password -Examples
```

### **Tab Completion**

All commands support tab completion for parameters:

```powershell
scan-port <TAB>           # Shows parameters
gen-password -<TAB>       # Shows switches
```

### **Performance**

```powershell
# Check if optimization needed
profile-perf

# Apply all optimizations
Optimize-ProfileCore

# Reload profile
. $PROFILE
```

### **Chaining Commands**

```powershell
# Multiple security checks
check-ssl github.com; check-headers https://github.com; dns-lookup github.com ALL

# Git workflow
git-cleanup; git-sync; gqc "Updated README" --all --push
```

---

## 📚 **Documentation Links**

- **[README.md](../README.md)** - Main documentation
- **[SECURITY_FEATURES.md](SECURITY_FEATURES.md)** - Security tools
- **[PERFORMANCE_EDITION.md](PERFORMANCE_EDITION.md)** - Performance guide
- **[IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)** - Full feature list
- **[INSTALL.md](../INSTALL.md)** - Installation guide

---

## 🎉 **Quick Start Examples**

### **First Time User**

```powershell
# 1. Check performance
profile-perf

# 2. Optimize system
Optimize-ProfileCore

# 3. Test security tools
gen-password 20 -IncludeSymbols

# 4. Test developer tools
git-status

# 5. Test system tools
sysinfo
```

### **Daily Use**

```powershell
# Morning routine
sysinfo                         # Check system health
git-status                      # Check repos
docker-status                   # Check containers
pinfo 10 CPU                    # Check processes
```

---

<div align="center">

**ProfileCore v4.0.0** - _Your Complete Shell Toolkit_ 🚀

**96 Functions | 65+ Aliases | Cross-Platform | Fast | Secure**

</div>
