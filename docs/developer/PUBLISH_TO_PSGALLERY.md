# 🚀 Quick Guide: Publish ProfileCore to PowerShell Gallery

**Version:** 5.0.0  
**Status:** ✅ Ready to Publish  
**Validation:** 90% Pass Rate (26/29 checks)

---

## ⚡ Quick Start (4 Steps)

### 1. Get API Key

Visit: https://www.powershellgallery.com/account/apikeys

- Sign in with Microsoft account
- Click "Create"
- Name: `ProfileCore v5.0 Publication`
- Expiration: 365 days
- Scopes: Push new packages and package versions
- Copy the key

### 2. Set API Key

```powershell
$env:PSGALLERY_API_KEY = "your-api-key-here"
```

### 3. Test (Optional but Recommended)

```powershell
# Dry run to validate everything
.\scripts\build\Publish-ToPSGallery.ps1 -DryRun
```

### 4. Publish

```powershell
# Publish to PowerShell Gallery
.\scripts\build\Publish-ToPSGallery.ps1

# Or force without prompts
.\scripts\build\Publish-ToPSGallery.ps1 -Force
```

---

## 📦 What Gets Published

```
Module:      ProfileCore
Version:     5.0.0
Size:        471 KB
Functions:   106
Aliases:     85
Quality:     94% ⭐⭐⭐⭐⭐
```

---

## ✅ Pre-Flight Checklist

- [x] Module manifest updated to v5.0.0
- [x] All tests passing (84/84)
- [x] Validation: 90% pass rate
- [x] Package tested successfully
- [x] Documentation complete
- [ ] API key obtained
- [ ] Ready to publish!

---

## 🎯 After Publishing

### 1. Verify (5-10 minutes after publish)

```powershell
# Search for module
Find-Module -Name ProfileCore

# Install from PSGallery
Install-Module -Name ProfileCore -Force

# Test
Import-Module ProfileCore
Get-OperatingSystem
```

### 2. Create GitHub Release

```bash
# Create tag
git tag -a v5.0.0 -m "ProfileCore v5.0.0 - World-Class Professional Release"
git push origin v5.0.0

# Then create release on GitHub with release notes
```

### 3. Announce

- Twitter/X: Share with #PowerShell hashtag
- Reddit: Post to r/PowerShell
- LinkedIn: Professional announcement
- GitHub Discussions: Community update

---

## 📚 Full Documentation

- **Release Checklist:** `docs/developer/RELEASE_CHECKLIST.md`
- **Requirements:** `docs/developer/PSGALLERY_REQUIREMENTS.md`
- **Summary:** `docs/developer/PSGALLERY_PUBLICATION_SUMMARY.md`

---

## 🆘 Troubleshooting

### "API key is invalid"

- Ensure key has "Push" permissions
- Check key hasn't expired
- Try regenerating the key

### "Version already exists"

- Check current PSGallery version
- Increment version in manifest
- Version must be higher than existing

### "Module validation failed"

- Run: `.\scripts\build\Test-PSGalleryReadiness.ps1`
- Fix any failed checks
- Re-run publish script

---

## 📞 Support

- **PSGallery Issues:** cgadmin@microsoft.com
- **Module Issues:** https://github.com/mythic3011/ProfileCore/issues
- **Documentation:** https://docs.microsoft.com/powershell/scripting/gallery/

---

## 🎉 Success!

After publishing, your module will be available at:

**PSGallery Page:**  
https://www.powershellgallery.com/packages/ProfileCore/5.0.0

**Installation Command:**

```powershell
Install-Module -Name ProfileCore
```

---

**Ready? Let's publish ProfileCore to the world! 🚀**

