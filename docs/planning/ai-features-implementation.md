# AI-Powered Features Implementation Guide

**Phase 1 of v5.0 Roadmap - Detailed Implementation Plan**

---

## 🤖 Overview

Phase 1 introduces AI-powered features to ProfileCore, making the shell experience more intelligent and user-friendly through:

1. **AI Command Suggestions** - Natural language to commands
2. **Intelligent Error Recovery** - Auto-fix common errors

---

## 1. AI Command Suggestions

### 🎯 Goal

Transform natural language queries into executable shell commands using AI.

### 🏗️ Architecture

```
User Input → Context Analyzer → AI Engine → Command Validator → Execute/Suggest
```

### 💡 Implementation Approaches

#### Option A: OpenAI Integration (Cloud-based)

**Pros:** Most accurate, constantly improving, minimal local resources  
**Cons:** Requires API key, internet connection, costs money

```powershell
function Invoke-AICommand {
    param(
        [Parameter(Mandatory)]
        [string]$Query,

        [switch]$ExecuteDirectly
    )

    # Build context
    $context = @{
        CurrentDirectory = Get-Location
        Shell = "PowerShell $($PSVersionTable.PSVersion)"
        OS = [System.Environment]::OSVersion.Platform
        RecentCommands = Get-History | Select-Object -Last 5
        DirectoryContents = Get-ChildItem -Name | Select-Object -First 10
    }

    # Prepare prompt for OpenAI
    $systemPrompt = @"
You are a PowerShell command expert. Convert natural language queries to PowerShell commands.
Only respond with the command, no explanations unless asked.

Context:
- Current Directory: $($context.CurrentDirectory)
- OS: $($context.OS)
- Available files: $($context.DirectoryContents -join ', ')

Recent commands:
$($context.RecentCommands | ForEach-Object { "- $($_.CommandLine)" } | Out-String)
"@

    # Call OpenAI API
    $headers = @{
        "Authorization" = "Bearer $env:OPENAI_API_KEY"
        "Content-Type" = "application/json"
    }

    $body = @{
        model = "gpt-4"
        messages = @(
            @{
                role = "system"
                content = $systemPrompt
            }
            @{
                role = "user"
                content = $Query
            }
        )
        temperature = 0.3
        max_tokens = 200
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
        -Method Post -Headers $headers -Body $body

    $suggestedCommand = $response.choices[0].message.content.Trim()

    # Display suggestion
    Write-Host "`n💡 Suggested Command:" -ForegroundColor Cyan
    Write-Host "   $suggestedCommand" -ForegroundColor Green

    if ($ExecuteDirectly) {
        Write-Host "`n⚡ Executing..." -ForegroundColor Yellow
        Invoke-Expression $suggestedCommand
    } else {
        $confirm = Read-Host "`nExecute this command? (y/N)"
        if ($confirm -eq 'y') {
            Invoke-Expression $suggestedCommand
        } else {
            Write-Host "Command copied to clipboard" -ForegroundColor Gray
            Set-Clipboard $suggestedCommand
        }
    }
}

# Aliases
Set-Alias -Name ai -Value Invoke-AICommand
```

**Usage Examples:**

```powershell
# Simple queries
ai "show me large files in current directory"
# Suggests: Get-ChildItem | Sort-Object Length -Descending | Select-Object -First 10

ai "find all txt files modified today"
# Suggests: Get-ChildItem -Filter "*.txt" | Where-Object { $_.LastWriteTime.Date -eq (Get-Date).Date }

ai "compress all logs to archive.zip"
# Suggests: Compress-Archive -Path *.log -DestinationPath archive.zip
```

#### Option B: Local LLM (Offline)

**Pros:** No API costs, works offline, privacy-friendly  
**Cons:** Requires local resources, needs model download

```powershell
function Invoke-LocalAI {
    param([string]$Query)

    # Use Ollama or LM Studio locally
    # Example with Ollama
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" `
        -Method Post `
        -Body (@{
            model = "codellama"
            prompt = "Convert to PowerShell command: $Query"
            stream = $false
        } | ConvertTo-Json)

    return $response.response
}
```

#### Option C: Hybrid Approach (Pattern Matching + AI)

**Pros:** Fast for common tasks, falls back to AI for complex queries  
**Cons:** Requires maintaining pattern database

```powershell
function Invoke-SmartCommand {
    param([string]$Query)

    # Try pattern matching first (fast)
    $patterns = @{
        'find.*files.*' = { Get-ChildItem -Recurse }
        'show.*large.*files' = { Get-ChildItem | Sort-Object Length -Descending | Select-Object -First 10 }
        'compress.*' = { param($path) Compress-Archive -Path $path }
        'list.*process.*' = { Get-Process | Sort-Object CPU -Descending }
    }

    foreach ($pattern in $patterns.Keys) {
        if ($Query -match $pattern) {
            Write-Host "📋 Pattern Match Found" -ForegroundColor Green
            return & $patterns[$pattern]
        }
    }

    # Fall back to AI for complex queries
    Write-Host "🤖 Using AI..." -ForegroundColor Cyan
    return Invoke-AICommand -Query $Query
}
```

---

### 🔍 Context-Aware Suggestions

**Context Types:**

1. **Directory Context**

   ```powershell
   # In a Git repository
   ai "commit changes"
   # → git add -A && git commit -m "Update"

   # In Node.js project (package.json present)
   ai "install dependencies"
   # → npm install
   ```

2. **File Type Context**

   ```powershell
   # Many .log files present
   ai "clean up logs older than 7 days"
   # → Get-ChildItem *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item
   ```

3. **Error Context**
   ```powershell
   # After command failure
   ai "fix it"
   # Analyzes last error and suggests fix
   ```

---

## 2. Intelligent Error Recovery

### 🎯 Goal

Automatically detect errors and suggest fixes based on error patterns.

### 🏗️ Architecture

```
Command Execution → Error Detection → Pattern Matching → AI Analysis → Suggested Fix
```

### 💡 Implementation

```powershell
# Error recovery engine
class ErrorRecoveryEngine {
    [hashtable]$ErrorPatterns
    [array]$ErrorHistory

    ErrorRecoveryEngine() {
        $this.ErrorPatterns = @{
            # Pattern 1: Command not found
            'CommandNotFoundException' = @{
                Analyzer = { param($error)
                    $cmd = $error.TargetObject
                    # Check if it's a typo
                    $allCommands = Get-Command -Name "*$cmd*" -ErrorAction SilentlyContinue
                    if ($allCommands) {
                        return @{
                            Confidence = 0.9
                            Suggestions = $allCommands | Select-Object -First 3 -ExpandProperty Name
                            Fix = "Use: $($allCommands[0].Name)"
                        }
                    }
                    # Check if package needs installing
                    $packageSuggestions = @{
                        'git' = 'winget install Git.Git'
                        'docker' = 'winget install Docker.DockerDesktop'
                        'node' = 'winget install OpenJS.NodeJS'
                    }
                    if ($packageSuggestions.ContainsKey($cmd)) {
                        return @{
                            Confidence = 0.95
                            Fix = $packageSuggestions[$cmd]
                        }
                    }
                    return $null
                }
            }

            # Pattern 2: Permission denied
            'UnauthorizedAccessException' = @{
                Analyzer = { param($error)
                    return @{
                        Confidence = 0.9
                        Fix = "Run as Administrator: Start-Process powershell -Verb RunAs"
                        Explanation = "This command requires elevated privileges"
                    }
                }
            }

            # Pattern 3: File not found
            'ItemNotFoundException' = @{
                Analyzer = { param($error)
                    $path = $error.TargetObject
                    $suggestions = Get-ChildItem -Filter "*$path*" -ErrorAction SilentlyContinue
                    if ($suggestions) {
                        return @{
                            Confidence = 0.85
                            Suggestions = $suggestions.Name
                            Fix = "Did you mean: $($suggestions[0].Name)?"
                        }
                    }
                    return $null
                }
            }

            # Pattern 4: Network errors
            'WebException' = @{
                Analyzer = { param($error)
                    # Check internet connectivity
                    $ping = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
                    if (-not $ping) {
                        return @{
                            Confidence = 0.95
                            Fix = "Check internet connection"
                            Diagnostic = "No internet connectivity detected"
                        }
                    }
                    # Check if it's a proxy issue
                    return @{
                        Confidence = 0.7
                        Fix = "Try: [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy()"
                    }
                }
            }
        }

        $this.ErrorHistory = @()
    }

    [object] AnalyzeError([System.Management.Automation.ErrorRecord]$error) {
        # Add to history
        $this.ErrorHistory += @{
            Error = $error
            Timestamp = Get-Date
        }

        # Pattern matching
        $errorType = $error.Exception.GetType().Name

        if ($this.ErrorPatterns.ContainsKey($errorType)) {
            $result = & $this.ErrorPatterns[$errorType].Analyzer $error
            return $result
        }

        # Use AI for unknown errors
        return $this.AIAnalyzeError($error)
    }

    [object] AIAnalyzeError([System.Management.Automation.ErrorRecord]$error) {
        $prompt = @"
Analyze this PowerShell error and suggest a fix:

Error: $($error.Exception.Message)
Command: $($error.InvocationInfo.MyCommand)
Line: $($error.InvocationInfo.Line)

Provide:
1. Root cause
2. Suggested fix (PowerShell command or action)
3. Prevention tip
"@

        # Call OpenAI
        $response = Invoke-AICommand -Query $prompt -GetSuggestionOnly

        return @{
            Confidence = 0.8
            Analysis = $response
            Source = "AI"
        }
    }
}

# Global error handler
$global:ErrorRecovery = [ErrorRecoveryEngine]::new()

function Enable-ErrorRecovery {
    # Override error action
    $global:PSDefaultParameterValues['*:ErrorAction'] = 'Continue'

    # Add error trap
    trap {
        Write-Host "`n❌ Error Detected!" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Yellow

        # Analyze error
        $analysis = $global:ErrorRecovery.AnalyzeError($_)

        if ($analysis) {
            Write-Host "`n💡 Suggestion (Confidence: $($analysis.Confidence * 100)%):" -ForegroundColor Cyan
            Write-Host "   $($analysis.Fix)" -ForegroundColor Green

            if ($analysis.Suggestions) {
                Write-Host "`n   Similar commands:" -ForegroundColor Gray
                $analysis.Suggestions | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
            }

            # Ask to apply fix
            $apply = Read-Host "`nApply suggested fix? (y/N)"
            if ($apply -eq 'y') {
                Invoke-Expression $analysis.Fix
            }
        } else {
            Write-Host "`n🤔 No automatic fix available" -ForegroundColor Yellow
            Write-Host "   Try: ai-fix" -ForegroundColor Gray
        }

        continue
    }
}

# AI fix command
function Invoke-AIFix {
    $lastError = $Error[0]
    if (-not $lastError) {
        Write-Host "No recent error to fix" -ForegroundColor Yellow
        return
    }

    Write-Host "🔍 Analyzing last error with AI..." -ForegroundColor Cyan

    $analysis = $global:ErrorRecovery.AIAnalyzeError($lastError)

    Write-Host "`n📊 AI Analysis:" -ForegroundColor Cyan
    Write-Host $analysis.Analysis -ForegroundColor White
}

Set-Alias -Name ai-fix -Value Invoke-AIFix
```

### 📊 Learning from Corrections

```powershell
class ErrorLearningSystem {
    [hashtable]$LearnedPatterns

    [void] LearnFromCorrection([object]$error, [string]$userFix) {
        $errorSignature = "$($error.Exception.GetType().Name):$($error.Exception.Message)"

        if (-not $this.LearnedPatterns.ContainsKey($errorSignature)) {
            $this.LearnedPatterns[$errorSignature] = @{
                Count = 0
                Fixes = @()
            }
        }

        $this.LearnedPatterns[$errorSignature].Count++
        $this.LearnedPatterns[$errorSignature].Fixes += $userFix

        # Save to file
        $this.LearnedPatterns | ConvertTo-Json | Out-File ~/.profilecore/learned-fixes.json
    }

    [string] GetLearnedFix([object]$error) {
        $errorSignature = "$($error.Exception.GetType().Name):$($error.Exception.Message)"

        if ($this.LearnedPatterns.ContainsKey($errorSignature)) {
            # Return most common fix
            $fixes = $this.LearnedPatterns[$errorSignature].Fixes
            $mostCommon = $fixes | Group-Object | Sort-Object Count -Descending | Select-Object -First 1
            return $mostCommon.Name
        }

        return $null
    }
}
```

---

## 3. Advanced Features

### 🎨 Command Explanation

```powershell
function Get-CommandExplanation {
    param([string]$Command)

    $prompt = @"
Explain this PowerShell command in simple terms:

$Command

Provide:
1. What it does
2. Each parameter's purpose
3. Potential risks/side effects
4. Alternative approaches
"@

    $explanation = Invoke-AICommand -Query $prompt -GetSuggestionOnly

    Write-Host "`n📚 Command Explanation:" -ForegroundColor Cyan
    Write-Host $explanation -ForegroundColor White
}

Set-Alias -Name ai-explain -Value Get-CommandExplanation
```

### 🔄 Command Optimization

```powershell
function Optimize-Command {
    param([string]$Command)

    $prompt = @"
Optimize this PowerShell command for better performance:

$Command

Suggest:
1. More efficient approach
2. Performance improvements
3. Best practices
"@

    $optimized = Invoke-AICommand -Query $prompt -GetSuggestionOnly

    Write-Host "`n⚡ Optimized Version:" -ForegroundColor Cyan
    Write-Host $optimized -ForegroundColor Green
}

Set-Alias -Name ai-optimize -Value Optimize-Command
```

---

## 📦 Installation & Setup

### Step 1: Install Dependencies

```powershell
# For OpenAI integration
Install-Module -Name PowerShellAI

# For local AI (optional)
# Download Ollama from https://ollama.ai
```

### Step 2: Configure API Keys

```bash
# Add to ~/.config/shell-profile/.env
export OPENAI_API_KEY="your-api-key-here"
```

### Step 3: Enable Features

```powershell
# In profile
Import-Module ProfileCore

# Enable AI features
Enable-AIFeatures

# Enable error recovery
Enable-ErrorRecovery
```

---

## 💰 Cost Considerations

### OpenAI Pricing (GPT-4)

- **Input:** $0.03 per 1K tokens
- **Output:** $0.06 per 1K tokens
- **Average command:** ~200 tokens = $0.012 per query

**Monthly estimates:**

- 100 queries/month: ~$1.20
- 500 queries/month: ~$6.00
- 1000 queries/month: ~$12.00

### Cost Optimization

```powershell
# Cache common queries
$global:AICache = @{}

function Invoke-AICommand {
    param([string]$Query)

    # Check cache first
    $cacheKey = $Query.ToLower().Trim()
    if ($global:AICache.ContainsKey($cacheKey)) {
        Write-Host "📦 Using cached result" -ForegroundColor Gray
        return $global:AICache[$cacheKey]
    }

    # Call AI
    $result = # ... AI call ...

    # Cache result
    $global:AICache[$cacheKey] = $result

    return $result
}
```

---

## 🔒 Privacy & Security

### Data Handling

1. **What's sent to AI:**

   - Current command/query
   - Directory name (not contents)
   - Shell type and OS
   - Recent command names (not parameters)

2. **What's NOT sent:**
   - File contents
   - Passwords/secrets
   - API keys from .env
   - Sensitive parameters

### Privacy Mode

```powershell
function Enable-AIPrivacyMode {
    $global:AIPrivacyMode = $true

    # Minimize context sent to AI
    $global:AIContextLevel = "minimal"  # vs "full"
}
```

---

## 📊 Success Metrics

### KPIs for Phase 1

| Metric                | Target | Measurement                 |
| --------------------- | ------ | --------------------------- |
| **Accuracy**          | >85%   | Correct command suggestions |
| **User Satisfaction** | >4/5   | User ratings                |
| **Error Resolution**  | >70%   | Auto-fixed errors           |
| **Response Time**     | <2s    | AI query response           |
| **Adoption**          | >50%   | Users enabling feature      |

---

## 🚀 Rollout Plan

### Week 1-2: Alpha Testing

- Internal testing
- Pattern database building
- Error collection

### Week 3-4: Beta Release

- Limited user group
- Feedback collection
- Refinement

### Week 5-6: General Release

- Full rollout
- Documentation
- Training materials

---

## 📚 Resources

### Documentation

- [OpenAI API Docs](https://platform.openai.com/docs)
- [Ollama Documentation](https://ollama.ai/docs)
- [PowerShellAI Module](https://github.com/dfinke/PowerShellAI)

### Examples

- [AI Shell Integration Examples](https://github.com/examples)
- [Error Pattern Database](https://github.com/patterns)

---

<div align="center">

**Phase 1: AI-Powered Features** - _Making Shells Smarter_ 🤖

**[← Back to Roadmap](roadmap.md)** • **[📖 Full Docs](../../README.md)**

</div>
