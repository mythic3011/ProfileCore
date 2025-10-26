# Windows Certificate Store Guide

**Date:** October 26, 2025  
**Purpose:** Managing code signing certificates in Windows

---

## 🔍 What is the Certificate Store?

Windows Certificate Store is a secure repository where Windows stores:

- SSL/TLS certificates
- Code signing certificates
- User certificates
- Root CA certificates

**Two Main Stores:**

- **CurrentUser** - User-specific certificates
- **LocalMachine** - System-wide certificates (requires admin)

---

## 📂 Method 1: Certificate Manager GUI (Easiest)

### View Current User Certificates

**Open Certificate Manager:**

```powershell
# Run this command
certmgr.msc
```

Or:

1. Press `Win + R`
2. Type `certmgr.msc`
3. Press Enter

**Navigate to Code Signing Certificates:**

1. Expand **Personal** folder
2. Click **Certificates**
3. Look for certificates with "Code Signing" purpose

**View Certificate Details:**

1. Double-click any certificate
2. Go to **Details** tab
3. Scroll to find **Thumbprint** (this is what you need for signing!)

### View System-Wide Certificates (Requires Admin)

```powershell
# Run this command as Administrator
mmc
```

Then:

1. File → Add/Remove Snap-in (Ctrl+M)
2. Select **Certificates** → Add
3. Choose **Computer account** → Next
4. Select **Local computer** → Finish
5. Click OK
6. Navigate: Certificates (Local Computer) → Personal → Certificates

---

## 💻 Method 2: PowerShell (Recommended for Automation)

### List All Certificates in Current User Store

```powershell
# List all certificates
Get-ChildItem -Path Cert:\CurrentUser\My

# More readable output
Get-ChildItem -Path Cert:\CurrentUser\My | Format-Table Subject, Thumbprint, NotAfter
```

### List Code Signing Certificates Only

```powershell
# Filter by Enhanced Key Usage (EKU)
Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert

# Or filter manually
Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object { $_.EnhancedKeyUsageList.FriendlyName -contains "Code Signing" } |
    Format-Table Subject, Thumbprint, NotAfter, @{Label="Expires";Expression={$_.NotAfter}}
```

### List System-Wide Certificates (Requires Admin)

```powershell
# System-wide Personal store
Get-ChildItem -Path Cert:\LocalMachine\My

# Code signing certificates
Get-ChildItem -Path Cert:\LocalMachine\My -CodeSigningCert
```

### Find Certificate by Subject Name

```powershell
# Find by subject (common name)
Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object { $_.Subject -like "*ProfileCore*" }

# Find by issuer
Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object { $_.Issuer -like "*DigiCert*" }
```

### Get Certificate Thumbprint (For Signing)

```powershell
# Get thumbprint for a specific certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert |
    Where-Object { $_.Subject -like "*YourName*" } |
    Select-Object -First 1

Write-Host "Thumbprint: $($cert.Thumbprint)"
Write-Host "Subject: $($cert.Subject)"
Write-Host "Expires: $($cert.NotAfter)"

# Copy thumbprint to clipboard
$cert.Thumbprint | Set-Clipboard
Write-Host "✅ Thumbprint copied to clipboard!"
```

---

## 📥 Method 3: Import Certificate to Store

### Import PFX (Personal Certificate with Private Key)

```powershell
# Import to Current User store
$pfxPath = "C:\Path\To\YourCertificate.pfx"
$pfxPassword = Read-Host "Enter PFX password" -AsSecureString

Import-PfxCertificate -FilePath $pfxPath `
    -CertStoreLocation Cert:\CurrentUser\My `
    -Password $pfxPassword `
    -Exportable

Write-Host "✅ Certificate imported to Current User store"
```

### Import to System Store (Requires Admin)

```powershell
# Run as Administrator
Import-PfxCertificate -FilePath $pfxPath `
    -CertStoreLocation Cert:\LocalMachine\My `
    -Password $pfxPassword
```

### Import CER (Public Certificate Only)

```powershell
# Import public certificate
Import-Certificate -FilePath "C:\Path\To\Certificate.cer" `
    -CertStoreLocation Cert:\CurrentUser\My
```

---

## 🔑 Method 4: Create Self-Signed Certificate (Development)

### Create Code Signing Certificate

```powershell
# Create self-signed cert for development
$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject "CN=ProfileCore Development, O=Your Company, C=US" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyUsage DigitalSignature `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
    -NotAfter (Get-Date).AddYears(3)

Write-Host "✅ Certificate created!"
Write-Host "Thumbprint: $($cert.Thumbprint)"
Write-Host "Subject: $($cert.Subject)"
Write-Host "Location: Cert:\CurrentUser\My\$($cert.Thumbprint)"

# Export for backup
$pfxPassword = ConvertTo-SecureString -String "YourPassword123!" -Force -AsPlainText
Export-PfxCertificate -Cert $cert `
    -FilePath "ProfileCore-Dev-Certificate.pfx" `
    -Password $pfxPassword

Write-Host "✅ Certificate exported to ProfileCore-Dev-Certificate.pfx"
```

**⚠️ Important:** Self-signed certificates won't prevent antivirus issues. Use for development only.

---

## 📋 Method 5: View Certificate Details

### Detailed Certificate Information

```powershell
# Get specific certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object { $_.Subject -like "*ProfileCore*" } |
    Select-Object -First 1

# Display all properties
$cert | Format-List *

# Key properties
Write-Host "Subject: $($cert.Subject)" -ForegroundColor Cyan
Write-Host "Issuer: $($cert.Issuer)" -ForegroundColor Cyan
Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
Write-Host "Valid From: $($cert.NotBefore)" -ForegroundColor Gray
Write-Host "Valid To: $($cert.NotAfter)" -ForegroundColor Gray
Write-Host "Has Private Key: $($cert.HasPrivateKey)" -ForegroundColor $(if($cert.HasPrivateKey){'Green'}else{'Red'})

# Enhanced Key Usage (what it's used for)
Write-Host "`nEnhanced Key Usage:" -ForegroundColor Cyan
$cert.EnhancedKeyUsageList | ForEach-Object {
    Write-Host "  • $($_.FriendlyName)" -ForegroundColor Gray
}
```

---

## 🗑️ Method 6: Remove/Delete Certificates

### Remove Certificate from Store

```powershell
# Find and remove certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My |
    Where-Object { $_.Subject -like "*ProfileCore Development*" }

if ($cert) {
    Write-Host "Found certificate: $($cert.Subject)"
    Write-Host "Thumbprint: $($cert.Thumbprint)"

    $confirm = Read-Host "Delete this certificate? (y/n)"
    if ($confirm -eq 'y') {
        Remove-Item -Path "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Force
        Write-Host "✅ Certificate removed" -ForegroundColor Green
    }
} else {
    Write-Host "Certificate not found" -ForegroundColor Yellow
}
```

---

## 🎯 Quick Reference: Certificate Store Paths

### PowerShell Certificate Provider Paths

```powershell
# Current User Stores
Cert:\CurrentUser\My                # Personal certificates (most common for code signing)
Cert:\CurrentUser\Root              # Trusted Root CAs
Cert:\CurrentUser\CA                # Intermediate CAs
Cert:\CurrentUser\TrustedPublisher  # Trusted publishers

# Local Machine Stores (Requires Admin)
Cert:\LocalMachine\My               # Computer personal certificates
Cert:\LocalMachine\Root             # Computer trusted root CAs
Cert:\LocalMachine\CA               # Computer intermediate CAs
```

### Common Certificate Extensions

- **`.pfx` / `.p12`** - Personal Information Exchange (includes private key)
- **`.cer` / `.crt`** - Certificate only (public key, no private key)
- **`.pem`** - Base64 encoded certificate (Linux/macOS common)
- **`.der`** - Binary encoded certificate

---

## 🔧 Practical Examples

### Example 1: Find Your Code Signing Certificate

```powershell
# Complete script to find and display your code signing certificate
Write-Host "`n🔍 Searching for Code Signing Certificates...`n" -ForegroundColor Cyan

$codeCerts = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert

if ($codeCerts.Count -eq 0) {
    Write-Host "❌ No code signing certificates found" -ForegroundColor Red
    Write-Host "`nTo create a self-signed certificate (development only):" -ForegroundColor Yellow
    Write-Host "  New-SelfSignedCertificate -Type CodeSigningCert -Subject 'CN=Dev' -CertStoreLocation 'Cert:\CurrentUser\My'" -ForegroundColor Gray
} else {
    Write-Host "✅ Found $($codeCerts.Count) code signing certificate(s):`n" -ForegroundColor Green

    $codeCerts | ForEach-Object {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "Subject:    $($_.Subject)" -ForegroundColor White
        Write-Host "Issuer:     $($_.Issuer)" -ForegroundColor Gray
        Write-Host "Thumbprint: $($_.Thumbprint)" -ForegroundColor Yellow
        Write-Host "Expires:    $($_.NotAfter)" -ForegroundColor $(if($_.NotAfter -lt (Get-Date).AddMonths(1)){'Red'}else{'Green'})
        Write-Host "Has Key:    $(if($_.HasPrivateKey){'✅ Yes'}else{'❌ No'})" -ForegroundColor $(if($_.HasPrivateKey){'Green'}else{'Red'})
        Write-Host ""
    }
}
```

### Example 2: Sign a DLL with Certificate from Store

```powershell
# Find certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert |
    Where-Object { $_.Subject -like "*YourName*" } |
    Select-Object -First 1

if (-not $cert) {
    Write-Error "Code signing certificate not found!"
    exit 1
}

Write-Host "✅ Found certificate: $($cert.Subject)"
Write-Host "   Thumbprint: $($cert.Thumbprint)"

# Sign the DLL
$dllPath = "modules\ProfileCore-rs\target\release\profilecore_rs.dll"

Set-AuthenticodeSignature -FilePath $dllPath -Certificate $cert -TimestampServer "http://timestamp.digicert.com"

Write-Host "✅ DLL signed successfully!"

# Verify signature
$signature = Get-AuthenticodeSignature -FilePath $dllPath
Write-Host "Signature Status: $($signature.Status)"
```

### Example 3: Export Certificate for Backup

```powershell
# Export certificate with private key (for backup)
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

if ($cert) {
    $backupPath = "Backup-Certificate-$(Get-Date -Format 'yyyy-MM-dd').pfx"
    $password = Read-Host "Enter password for backup" -AsSecureString

    Export-PfxCertificate -Cert $cert -FilePath $backupPath -Password $password

    Write-Host "✅ Certificate backed up to: $backupPath" -ForegroundColor Green
    Write-Host "⚠️  Keep this file secure! It contains your private key." -ForegroundColor Yellow
}
```

---

## 🛡️ Security Best Practices

### Protecting Your Certificates

1. **Use Strong Passwords**

   - PFX/P12 files should have complex passwords
   - Never commit passwords to source control

2. **Backup Certificates**

   ```powershell
   # Regular backup schedule
   Export-PfxCertificate -Cert $cert -FilePath "backup.pfx" -Password $securePassword
   ```

3. **Set Expiration Reminders**

   ```powershell
   # Check certificate expiration
   $cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
   $daysUntilExpiry = ($cert.NotAfter - (Get-Date)).Days

   if ($daysUntilExpiry -lt 30) {
       Write-Warning "Certificate expires in $daysUntilExpiry days!"
   }
   ```

4. **Use Hardware Tokens (Production)**
   - USB security tokens (YubiKey, etc.)
   - Cloud HSM (AWS CloudHSM, Azure Key Vault)
   - Prevents private key extraction

---

## 📚 Additional Resources

### Microsoft Documentation

- [Certificate Store](https://learn.microsoft.com/en-us/windows-hardware/drivers/install/certificate-stores)
- [PowerShell PKI Module](https://learn.microsoft.com/en-us/powershell/module/pki/)
- [Code Signing](https://learn.microsoft.com/en-us/windows/win32/seccrypto/cryptography-tools)

### Certificate Authorities

- DigiCert: https://www.digicert.com/
- Sectigo: https://sectigo.com/
- SSL.com: https://www.ssl.com/
- GlobalSign: https://www.globalsign.com/

---

## ❓ Troubleshooting

### "Cannot find path" Error

```powershell
# Ensure PowerShell PKI module is loaded
Import-Module PKI -ErrorAction SilentlyContinue

# Check if certificate provider is available
Get-PSProvider | Where-Object { $_.Name -eq "Certificate" }
```

### Certificate Doesn't Appear in Store

```powershell
# Refresh certificate store
Get-ChildItem -Path Cert:\CurrentUser\My -Force | Out-Null

# Check if running as correct user
whoami

# Check if certificate has private key
$cert | Select-Object HasPrivateKey
```

### "Private key not found" Error

- Certificate was imported without `-Exportable` flag
- Private key is on different machine/hardware token
- Certificate is corrupted

**Solution:** Re-import with private key:

```powershell
Import-PfxCertificate -FilePath cert.pfx `
    -CertStoreLocation Cert:\CurrentUser\My `
    -Password $password `
    -Exportable
```

---

## 🎯 Quick Start for ProfileCore

**For signing ProfileCore DLL:**

```powershell
# 1. Find your code signing certificate
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

# 2. Display certificate info
Write-Host "Subject: $($cert.Subject)"
Write-Host "Thumbprint: $($cert.Thumbprint)"
Write-Host "Expires: $($cert.NotAfter)"

# 3. Save thumbprint for build script
$cert.Thumbprint | Out-File -FilePath "certificate-thumbprint.txt"

# 4. Use in build script
$thumbprint = Get-Content "certificate-thumbprint.txt"
& signtool.exe sign /sha1 $thumbprint /tr http://timestamp.digicert.com /td SHA256 profilecore_rs.dll
```

---

**Need more help?** See `CODE_SIGNING_AND_ANTIVIRUS.md` for complete signing workflow.
