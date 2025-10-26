# ═══════════════════════════════════════════════════════════════════════════
# Example Plugin: Custom Commands
# Place this file in: ~/.config/shell-profile/plugins/
# ═══════════════════════════════════════════════════════════════════════════

# Register your custom commands (they will appear in Get-Helper automatically)
Register-ProfileCommand `
    -Command 'hello <name>' `
    -Description 'Greet someone' `
    -Category 'Custom' `
    -Alias 'hi'

Register-ProfileCommand `
    -Command 'note <text>' `
    -Description 'Quick note to file' `
    -Category 'Custom'

Register-ProfileCommand `
    -Command 'weather <city>' `
    -Description 'Get weather for city' `
    -Category 'Custom'

# ═══════════════════════════════════════════════════════════════════════════
# Function Implementations
# ═══════════════════════════════════════════════════════════════════════════

function Say-Hello {
    <#
    .SYNOPSIS
        Greet someone with style
    .EXAMPLE
        hello World
        hi Alice
    #>
    param(
        [Parameter(Position=0)]
        [string]$Name = "World"
    )
    
    $greeting = @(
        "Hello", "Hi", "Hey", "Greetings", "Welcome", "Good day"
    ) | Get-Random
    
    Write-Host "$greeting, " -NoNewline -ForegroundColor Cyan
    Write-Host $Name -NoNewline -ForegroundColor Yellow
    Write-Host "! 👋" -ForegroundColor Cyan
}

function Add-QuickNote {
    <#
    .SYNOPSIS
        Quickly save a note to your notes file
    .EXAMPLE
        note "Remember to buy milk"
        note "Meeting at 3pm"
    #>
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Text
    )
    
    $notesFile = Join-Path $HOME "quick-notes.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Text"
    
    Add-Content -Path $notesFile -Value $entry
    Write-Host "✅ Note saved: " -NoNewline -ForegroundColor Green
    Write-Host $Text -ForegroundColor Gray
}

function Get-Weather {
    <#
    .SYNOPSIS
        Get weather information for a city
    .DESCRIPTION
        Uses wttr.in service to fetch weather
    .EXAMPLE
        weather London
        weather "New York"
    #>
    param(
        [Parameter(Position=0)]
        [string]$City = "London"
    )
    
    try {
        $City = $City -replace ' ', '+'
        $url = "https://wttr.in/${City}?format=3"
        $weather = Invoke-RestMethod -Uri $url -ErrorAction Stop
        Write-Host $weather -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Could not fetch weather for $City" -ForegroundColor Red
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# Aliases
# ═══════════════════════════════════════════════════════════════════════════

Set-Alias -Name hello -Value Say-Hello
Set-Alias -Name hi -Value Say-Hello
Set-Alias -Name note -Value Add-QuickNote
Set-Alias -Name weather -Value Get-Weather

# ═══════════════════════════════════════════════════════════════════════════
# Plugin Info
# ═══════════════════════════════════════════════════════════════════════════

Write-Verbose "✅ Custom Commands plugin loaded (3 commands)"

