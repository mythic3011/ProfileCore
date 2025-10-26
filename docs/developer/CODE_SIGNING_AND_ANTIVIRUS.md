# Code Signing and Antivirus/EDR Protection Guide

**Date:** October 26, 2025  
**Target:** ProfileCore Rust DLL  
**Audience:** Developers deploying to production

---

## 🎯 Problem Overview

Unsigned DLLs trigger antivirus/EDR systems (Windows Defender, ESET, CrowdStrike, etc.) because:

- **No Digital Signature** - Can't verify publisher identity
- **Low Reputation** - SmartScreen has no usage data
- **Heuristic Detection** - Behavior analysis flags unknown binaries

**Solution:** Code sign the DLL with a trusted certificate.

---

## 📜 Part 1: Code Signing the DLL

### Option 1: Commercial Code Signing Certificate (RECOMMENDED for Production)

#### Step 1: Obtain a Certificate

**Trusted Certificate Authorities:**

1. **DigiCert** - Industry standard ($474/year)
   - https://www.digicert.com/code-signing
   - EV (Extended Validation) provides instant reputation
2. **Sectigo (formerly Comodo)** - Budget option ($215/year)
   - https://sectigo.com/ssl-certificates-tls/code-signing
3. **GlobalSign** - Good reputation ($249/year)

   - https://www.globalsign.com/en/code-signing-certificate

4. **SSL.com** - eSigner cloud signing ($299/year)
   - https://www.ssl.com/esigner/
   - **Recommended** - No USB token needed, cloud-based

**Requirements:**

- Business verification (D-U-N-S number, incorporation docs)
- Identity verification (government ID)
- Processing time: 3-7 business days

#### Step 2: Sign the DLL

**Using signtool.exe (Windows SDK):**

```powershell
# Install Windows SDK if not present
# Download from: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/

# Sign the DLL
$certThumbprint = "YOUR_CERT_THUMBPRINT"  # From certificate store
$dllPath = "modules\ProfileCore-rs\target\release\profilecore_rs.dll"
$timestampServer = "http://timestamp.digicert.com"

& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe" sign `
    /sha256 `
    /fd SHA256 `
    /tr $timestampServer `
    /td SHA256 `
    /sha1 $certThumbprint `
    $dllPath

# Verify signature
& signtool.exe verify /pa /v $dllPath
```

**Using SSL.com eSigner (Cloud Signing - No USB Token):**

```powershell
# Install eSigner client
# Download from: https://www.ssl.com/how-to/automate-esigner-ev-code-signing/

# Set credentials
$env:SSL_COM_USERNAME = "your-email@example.com"
$env:SSL_COM_PASSWORD = "your-password"
$env:SSL_COM_TOTP_SECRET = "your-totp-secret"

# Sign via cloud
esigner-codesigner.ps1 sign `
    -username "$env:SSL_COM_USERNAME" `
    -password "$env:SSL_COM_PASSWORD" `
    -totp_secret "$env:SSL_COM_TOTP_SECRET" `
    -input_file_path $dllPath `
    -output_dir_path "signed"
```

**Automated Signing in Build Script:**

```powershell
# scripts/build/build-rust-signed.ps1
param(
    [string]$CertThumbprint,
    [switch]$UseCloudSigning
)

# Build Rust DLL
cd modules/ProfileCore-rs
cargo build --release

if ($UseCloudSigning) {
    # Cloud signing with SSL.com
    & esigner-codesigner.ps1 sign `
        -username $env:SSL_COM_USERNAME `
        -password $env:SSL_COM_PASSWORD `
        -totp_secret $env:SSL_COM_TOTP_SECRET `
        -input_file_path "target/release/profilecore_rs.dll" `
        -output_dir_path "target/release/signed"

    # Copy signed DLL
    Copy-Item "target/release/signed/profilecore_rs.dll" "../../modules/ProfileCore.Binary/bin/ProfileCore.dll"
} else {
    # Local signing
    & signtool.exe sign /sha256 /fd SHA256 `
        /tr "http://timestamp.digicert.com" /td SHA256 `
        /sha1 $CertThumbprint `
        "target/release/profilecore_rs.dll"

    Copy-Item "target/release/profilecore_rs.dll" "../../modules/ProfileCore.Binary/bin/ProfileCore.dll"
}

Write-Host "✅ DLL built and signed successfully" -ForegroundColor Green
```

---

### Option 2: Self-Signed Certificate (Development/Testing Only)

**⚠️ WARNING:** Self-signed certificates DON'T prevent antivirus deletion. They only work for:

- Internal corporate deployments with custom certificate trust
- Development/testing scenarios

```powershell
# Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -Subject "CN=ProfileCore Development" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyUsage DigitalSignature `
    -KeyAlgorithm RSA `
    -KeyLength 2048

# Export certificate
$certPath = "ProfileCore-Dev.cer"
Export-Certificate -Cert $cert -FilePath $certPath

# Sign DLL
$dllPath = "modules\ProfileCore-rs\target\release\profilecore_rs.dll"
Set-AuthenticodeSignature -FilePath $dllPath -Certificate $cert

# Add to Trusted Root (DO NOT DO IN PRODUCTION)
Import-Certificate -FilePath $certPath -CertStoreLocation "Cert:\LocalMachine\Root"
```

**Limitations:**

- Still triggers SmartScreen warnings
- Not trusted by default
- Antivirus/EDR may still quarantine
- Users must manually trust certificate

---

## 🛡️ Part 2: Preventing Antivirus/EDR False Positives

### Strategy 1: Build Reputation Over Time

**SmartScreen Reputation:**

1. **Sign with EV Certificate** - Instant reputation boost
2. **Distribution Volume** - Get 1000+ downloads in 30 days
3. **Clean History** - Zero reported malware detections
4. **Time** - 6-12 months for full reputation

**How to Build:**

- Release on GitHub with releases page
- Submit to PowerShell Gallery
- Distribute via trusted channels
- Engage with user community

### Strategy 2: Submit to Antivirus Vendors

**Whitelist Submission Process:**

**1. Microsoft Defender:**

- Portal: https://www.microsoft.com/en-us/wdsi/filesubmission
- Submit signed DLL for analysis
- Usually processed within 24-48 hours
- Include: Purpose, publisher info, why it's safe

**2. ESET:**

- Portal: https://www.eset.com/us/false-positive/
- Fill out false positive form
- Attach signed DLL
- Explain: "PowerShell module for system information"
- Processing: 2-5 business days

**3. VirusTotal:**

- Upload to: https://www.virustotal.com/
- Check which AVs flag it
- Use "Request re-analysis" after signing
- Vendors see signed files and often whitelist

**4. Other Major EDRs:**

**CrowdStrike:**

- Contact support: support@crowdstrike.com
- Provide signed binary + context
- Request application hash whitelisting

**Carbon Black (VMware):**

- https://community.carbonblack.com/
- Submit via support portal
- Usually whitelisted within 1 week

**SentinelOne:**

- Contact TAM (Technical Account Manager)
- Provide signed binary
- Request Static AI whitelisting

### Strategy 3: Metadata and Attributes

**Add Proper Version Info to Rust DLL:**

```rust
// Cargo.toml
[package]
name = "profilecore-rs"
version = "6.1.0"
description = "High-performance system operations for ProfileCore PowerShell module"
authors = ["Your Name <your.email@example.com>"]
license = "MIT"
homepage = "https://github.com/yourusername/ProfileCore"
repository = "https://github.com/yourusername/ProfileCore"

[package.metadata.winres]
ProductName = "ProfileCore Rust Module"
FileDescription = "System information and networking module"
CompanyName = "Your Company/Name"
LegalCopyright = "Copyright © 2025"
```

**Build with version info:**

```powershell
# Install winres
cargo install cargo-winres

# Add to Cargo.toml (Windows only):
[target.'cfg(windows)'.build-dependencies]
winres = "0.1"

# Create build.rs:
fn main() {
    if cfg!(target_os = "windows") {
        let mut res = winres::WindowsResource::new();
        res.set_icon("icon.ico")
           .set("ProductName", "ProfileCore Rust Module")
           .set("FileDescription", "System information module")
           .set("CompanyName", "ProfileCore")
           .set("LegalCopyright", "Copyright © 2025");
        res.compile().unwrap();
    }
}

# Build
cargo build --release
```

### Strategy 4: Behavioral Changes

**Reduce Suspicious Behaviors:**

1. **Avoid Dynamic Code Generation** - Already good (no eval, no reflection)
2. **Minimize Registry Access** - Not used in ProfileCore-rs
3. **No Process Injection** - Not used
4. **Clear Error Messages** - Already implemented
5. **Documented API Surface** - Public FFI functions documented

**What ProfileCore-rs Does (SAFE):**

- ✅ Read system information (RAM, CPU, hostname)
- ✅ Network interface enumeration
- ✅ Platform detection (Windows/Linux/macOS)
- ✅ Return JSON strings to PowerShell

**What it Does NOT Do (SUSPICIOUS):**

- ❌ Process injection
- ❌ Registry modification
- ❌ File system writes (except logs)
- ❌ Network connections (except GetPublicIP)
- ❌ Privilege escalation
- ❌ Code execution of external data

---

## 🔧 Part 3: Immediate Workarounds (Before Signing)

### For Development (Your Current Situation)

**Windows Defender Exclusion (TEMPORARY):**

```powershell
# Add exclusion (AS ADMINISTRATOR)
Add-MpPreference -ExclusionPath 'C:\Users\a1667\JetbrainsProject\03-Development-Projects\ProfileCore'
```

**ESET Exclusion:**

```
1. Open ESET GUI
2. Settings (F5) → Advanced Setup
3. Computer → Exclusions
4. Add folder: C:\Users\a1667\JetbrainsProject\03-Development-Projects\ProfileCore
5. Or add process: powershell.exe (when running from this directory)
```

**Generic EDR Bypass (Development Only):**

```powershell
# Option 1: Load DLL from memory (advanced)
# Not recommended for production

# Option 2: Use different extension temporarily
Copy-Item profilecore_rs.dll profilecore_rs.dat
# Load as .dat - some AVs don't scan non-standard extensions
# Then rename in memory
```

### For Distribution to Users

**1. Installation Script with Exclusion Prompt:**

```powershell
# scripts/installation/Install-ProfileCore.ps1
param([switch]$AddAVExclusion)

if ($AddAVExclusion) {
    Write-Warning "This will add an antivirus exclusion. Requires Administrator."
    $elevated = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $elevated) {
        Write-Error "Please run as Administrator to add AV exclusion"
        return
    }

    $installPath = $PSScriptRoot

    # Windows Defender
    Add-MpPreference -ExclusionPath $installPath -ErrorAction SilentlyContinue

    Write-Host "✅ Added Windows Defender exclusion: $installPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "For ESET, manually add exclusion:" -ForegroundColor Yellow
    Write-Host "  1. Open ESET → Settings (F5)" -ForegroundColor Gray
    Write-Host "  2. Computer → Exclusions" -ForegroundColor Gray
    Write-Host "  3. Add: $installPath" -ForegroundColor Gray
}

# Continue with installation...
```

**2. User Documentation:**

```markdown
# Installation Guide

## ⚠️ Antivirus Notice

ProfileCore includes a high-performance Rust module that may be flagged by antivirus software.

**Why?** The DLL is unsigned (for now). Signing requires a commercial certificate ($200-500/year).

**Is it safe?** Yes. The source code is public and auditable at: https://github.com/yourusername/ProfileCore

**Options:**

1. **Add Antivirus Exclusion** (Recommended)
   - Windows Defender: `Add-MpPreference -ExclusionPath 'C:\Program Files\ProfileCore'`
   - ESET: Settings → Computer → Exclusions → Add folder
2. **Wait for Signed Version** (v6.2.0 - Coming Q1 2026)

   - We're obtaining a code signing certificate
   - Signed versions won't trigger antivirus

3. **Use PowerShell-Only Mode** (Slower)
   - Install with: `Install-ProfileCore -NoBinaryModule`
   - No Rust, pure PowerShell
   - 5-10x slower but no AV issues
```

---

## 📊 Part 4: Cost-Benefit Analysis

### Code Signing Certificate Costs

| Provider   | Standard  | EV Certificate | Notes                        |
| ---------- | --------- | -------------- | ---------------------------- |
| DigiCert   | $474/year | $699/year      | Best reputation              |
| Sectigo    | $215/year | $429/year      | Budget option                |
| SSL.com    | $299/year | $479/year      | Cloud signing (no USB token) |
| GlobalSign | $249/year | $599/year      | Good balance                 |

**Recommendation for ProfileCore:**

- **Short-term (now):** Use exclusions for development
- **Medium-term (3-6 months):** Get SSL.com certificate ($299)
- **Long-term (1 year+):** Upgrade to EV for instant reputation

### Return on Investment

**With Signing:**

- ✅ No user friction (no AV warnings)
- ✅ Professional appearance
- ✅ Builds trust
- ✅ Required for enterprise adoption
- ✅ Can submit to Windows Store / PowerShell Gallery

**Cost:** $299/year ÷ 12 months = **$25/month**

**Without Signing:**

- ❌ 30-50% of users blocked by antivirus
- ❌ Support burden (users asking "is this a virus?")
- ❌ Can't distribute via official channels
- ❌ Enterprise customers won't install

---

## 🚀 Part 5: Implementation Roadmap

### Phase 1: Immediate (This Week)

- [x] Document antivirus issue
- [x] Add development exclusion instructions
- [ ] User adds Windows Defender/ESET exclusion
- [ ] Test with exclusion in place

### Phase 2: Short-term (1-2 Weeks)

- [ ] Submit unsigned DLL to VirusTotal
- [ ] Request re-analysis from flagging vendors
- [ ] Document clean scan results

### Phase 3: Medium-term (1-3 Months)

- [ ] Obtain SSL.com code signing certificate ($299)
- [ ] Sign all DLLs (Windows, Linux, macOS)
- [ ] Re-submit to antivirus vendors
- [ ] Update installation scripts
- [ ] Release v6.2.0 with signed binaries

### Phase 4: Long-term (6-12 Months)

- [ ] Build SmartScreen reputation (1000+ downloads)
- [ ] Upgrade to EV certificate for instant reputation
- [ ] Submit to Microsoft Store / PowerShell Gallery
- [ ] Zero false positives across all major AVs

---

## 📚 References

### Code Signing

- [Microsoft: Signing with SignTool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool)
- [DigiCert: Code Signing Guide](https://www.digicert.com/kb/code-signing)
- [SSL.com: eSigner Documentation](https://www.ssl.com/esigner/)

### Antivirus Submission

- [Microsoft Defender Submission](https://www.microsoft.com/en-us/wdsi/filesubmission)
- [ESET False Positive Report](https://www.eset.com/us/false-positive/)
- [VirusTotal](https://www.virustotal.com/)

### SmartScreen Reputation

- [Microsoft SmartScreen Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview)

---

## ❓ FAQ

**Q: Can I use a free certificate?**
A: No free CAs issue code signing certificates. Code signing requires identity verification.

**Q: How long does signing take?**
A: Certificate purchase: 3-7 days. Actual signing: < 1 minute.

**Q: Will signing prevent all AV detections?**
A: Not immediately. It takes time to build reputation. But it's required for long-term success.

**Q: Can I sign once and use forever?**
A: Certificates expire (typically 1-3 years). Must renew and re-sign.

**Q: What about Linux/macOS?**
A: Linux: No signing infrastructure. macOS: Use Apple codesign ($99/year Developer Program).

**Q: Should I sign every build?**
A: Only release builds. Development builds can remain unsigned with local exclusions.

---

## 🎯 Recommended Action Plan for ProfileCore

1. **TODAY:** Add Windows Defender/ESET exclusion (you)
2. **This Week:** Continue development, test all FFI functions
3. **Week 2-3:** Research and budget for SSL.com certificate ($299)
4. **Month 2:** Obtain certificate, sign DLL, release v6.2.0
5. **Month 3-6:** Build reputation, submit to AV vendors
6. **Month 12:** Consider EV upgrade for instant reputation

**Total Investment:** ~$300 + time
**Payoff:** Professional deployment, zero AV issues, enterprise-ready

---

**Status:** Development phase - Exclusions acceptable  
**Next Milestone:** Signed binaries in v6.2.0 (Q1 2026)
