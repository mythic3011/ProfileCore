# ═══════════════════════════════════════════════════════════════════════════
# Example Plugin: Development Workflow
# Place this file in: ~/.config/shell-profile/plugins/
# ═══════════════════════════════════════════════════════════════════════════

# Register commands
Register-ProfileCommand `
    -Command 'work-start <project>' `
    -Description 'Start work session for project' `
    -Category 'Developer'

Register-ProfileCommand `
    -Command 'work-end' `
    -Description 'End work session (commits, pushes)' `
    -Category 'Developer'

Register-ProfileCommand `
    -Command 'pr-create <title>' `
    -Description 'Create pull request' `
    -Category 'Developer' `
    -Alias 'pr'

Register-ProfileCommand `
    -Command 'dev-clean' `
    -Description 'Clean dev environment' `
    -Category 'Developer'

# ═══════════════════════════════════════════════════════════════════════════
# Work Session Management
# ═══════════════════════════════════════════════════════════════════════════

function Start-WorkSession {
    <#
    .SYNOPSIS
        Start a development work session
    .DESCRIPTION
        - Creates/switches to feature branch
        - Opens project in editor
        - Shows project status
    .EXAMPLE
        work-start feature-auth
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$ProjectOrBranch
    )
    
    Write-Host "🚀 Starting work session: $ProjectOrBranch" -ForegroundColor Cyan
    
    # Check if in git repo
    if (Test-Path .git) {
        # Create/switch to branch
        $branchExists = git branch --list $ProjectOrBranch
        if ($branchExists) {
            git checkout $ProjectOrBranch
            Write-Host "✅ Switched to branch: $ProjectOrBranch" -ForegroundColor Green
        } else {
            git checkout -b $ProjectOrBranch
            Write-Host "✅ Created new branch: $ProjectOrBranch" -ForegroundColor Green
        }
        
        # Pull latest changes
        git pull origin $(git branch --show-current) 2>$null
        
        # Show status
        Write-Host "`n📊 Repository Status:" -ForegroundColor Yellow
        git status --short
    }
    
    # Open in editor if available
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code .
        Write-Host "✅ Opened in VS Code" -ForegroundColor Green
    }
    
    # Record session start time
    $global:WorkSessionStart = Get-Date
    $global:WorkSessionProject = $ProjectOrBranch
    
    Write-Host "`n💡 Session started at $(Get-Date -Format 'HH:mm')" -ForegroundColor Cyan
    Write-Host "   Run 'work-end' when done" -ForegroundColor Gray
}

function Stop-WorkSession {
    <#
    .SYNOPSIS
        End work session and commit changes
    .DESCRIPTION
        - Shows changed files
        - Commits all changes
        - Pushes to remote
        - Shows session summary
    .EXAMPLE
        work-end
    #>
    
    if (-not $global:WorkSessionProject) {
        Write-Warning "No active work session. Use 'work-start' first."
        return
    }
    
    Write-Host "🏁 Ending work session: $global:WorkSessionProject" -ForegroundColor Cyan
    
    # Check for changes
    $changes = git status --porcelain
    if ($changes) {
        Write-Host "`n📝 Changes detected:" -ForegroundColor Yellow
        git status --short
        
        # Commit
        $commitMsg = Read-Host "`nCommit message (or press Enter for auto-message)"
        if ([string]::IsNullOrWhiteSpace($commitMsg)) {
            $commitMsg = "Work session: $global:WorkSessionProject - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }
        
        git add .
        git commit -m $commitMsg
        
        # Push
        $push = Read-Host "Push to remote? (Y/n)"
        if ($push -ne 'n') {
            git push origin $(git branch --show-current)
            Write-Host "✅ Changes pushed" -ForegroundColor Green
        }
    } else {
        Write-Host "ℹ️  No changes to commit" -ForegroundColor Gray
    }
    
    # Session summary
    if ($global:WorkSessionStart) {
        $duration = (Get-Date) - $global:WorkSessionStart
        Write-Host "`n⏱️  Session Duration: $([math]::Floor($duration.TotalHours))h $($duration.Minutes)m" -ForegroundColor Cyan
    }
    
    # Cleanup
    Remove-Variable -Name WorkSessionProject -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name WorkSessionStart -Scope Global -ErrorAction SilentlyContinue
    
    Write-Host "✅ Session ended" -ForegroundColor Green
}

# ═══════════════════════════════════════════════════════════════════════════
# Pull Request Creation
# ═══════════════════════════════════════════════════════════════════════════

function New-PullRequest {
    <#
    .SYNOPSIS
        Create a pull request using GitHub CLI
    .EXAMPLE
        pr-create "Add authentication feature"
        pr "Fix bug in payment processing"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Title
    )
    
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Warning "GitHub CLI (gh) not installed. Install: winget install GitHub.cli"
        return
    }
    
    try {
        # Get current branch
        $branch = git branch --show-current
        
        # Create PR
        Write-Host "📝 Creating pull request..." -ForegroundColor Cyan
        gh pr create --title $Title --body "Created from PowerShell profile" --head $branch
        
        Write-Host "✅ Pull request created!" -ForegroundColor Green
        
        # Open in browser
        $open = Read-Host "Open in browser? (Y/n)"
        if ($open -ne 'n') {
            gh pr view --web
        }
    } catch {
        Write-Error "Failed to create PR: $_"
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# Development Environment Cleanup
# ═══════════════════════════════════════════════════════════════════════════

function Invoke-DevCleanup {
    <#
    .SYNOPSIS
        Clean up development environment
    .DESCRIPTION
        - Removes node_modules
        - Clears build artifacts
        - Cleans Docker
        - Prunes git
    #>
    
    Write-Host "🧹 Cleaning development environment..." -ForegroundColor Cyan
    
    # Node modules
    if (Test-Path "node_modules") {
        Write-Host "  Removing node_modules..." -ForegroundColor Gray
        Remove-Item -Path "node_modules" -Recurse -Force
        Write-Host "  ✅ node_modules removed" -ForegroundColor Green
    }
    
    # Build directories
    $buildDirs = @("dist", "build", "out", "bin", "obj", "target")
    foreach ($dir in $buildDirs) {
        if (Test-Path $dir) {
            Write-Host "  Removing $dir..." -ForegroundColor Gray
            Remove-Item -Path $dir -Recurse -Force
            Write-Host "  ✅ $dir removed" -ForegroundColor Green
        }
    }
    
    # Git cleanup
    if (Test-Path .git) {
        Write-Host "  Pruning git..." -ForegroundColor Gray
        git gc --prune=now --quiet
        Write-Host "  ✅ Git optimized" -ForegroundColor Green
    }
    
    # Docker cleanup (if available)
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "  Cleaning Docker..." -ForegroundColor Gray
        docker system prune -f 2>$null | Out-Null
        Write-Host "  ✅ Docker cleaned" -ForegroundColor Green
    }
    
    Write-Host "`n✨ Cleanup complete!" -ForegroundColor Green
}

# ═══════════════════════════════════════════════════════════════════════════
# Aliases
# ═══════════════════════════════════════════════════════════════════════════

Set-Alias -Name work-start -Value Start-WorkSession
Set-Alias -Name work-end -Value Stop-WorkSession
Set-Alias -Name pr-create -Value New-PullRequest
Set-Alias -Name pr -Value New-PullRequest
Set-Alias -Name dev-clean -Value Invoke-DevCleanup

# ═══════════════════════════════════════════════════════════════════════════
# Plugin Info
# ═══════════════════════════════════════════════════════════════════════════

Write-Verbose "✅ Development Workflow plugin loaded (4 commands)"

