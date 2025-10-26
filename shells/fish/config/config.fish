# ProfileCore v4.0.0 - Main Fish Configuration
# Cross-Platform Shell Profile with Dual-Shell Support
# Author: Mythic3011

# ===== PERFORMANCE OPTIMIZATION START =====
set -g FISH_LOAD_START (date +%s%3N)

# ===== ENVIRONMENT SETUP =====
# Set ProfileCore home
set -gx PROFILECORE_HOME "$HOME/.config/shell-profile"

# Load environment variables from shared .env file
if test -f "$PROFILECORE_HOME/.env"
    while read -l line
        # Skip comments and empty lines
        if string match -qr '^#' $line; or test -z "$line"
            continue
        end
        # Parse and export
        set -l parts (string split -m 1 '=' $line)
        if test (count $parts) -eq 2
            set -gx $parts[1] $parts[2]
        end
    end < "$PROFILECORE_HOME/.env"
end

# ===== PATH CONFIGURATION =====
# Add common paths
fish_add_path "$HOME/.local/bin"
fish_add_path "/usr/local/bin"
fish_add_path "/opt/homebrew/bin"  # Apple Silicon

# ===== FISH CONFIGURATION =====
# Disable greeting
set fish_greeting

# History settings
set -g fish_history_limit 10000

# ===== LOAD PROFILECORE FUNCTIONS =====
# Fish automatically loads functions from ~/.config/fish/functions/
# Our functions are in: ~/Documents/PowerShell/MacOS/.config/fish/functions/
set -g PROFILECORE_FUNCTIONS_DIR "$HOME/Documents/PowerShell/MacOS/.config/fish/functions"

if test -d "$PROFILECORE_FUNCTIONS_DIR"
    # Add to function path
    set -gx fish_function_path $fish_function_path $PROFILECORE_FUNCTIONS_DIR
end

# ===== PROMPT CONFIGURATION =====
# Check if Starship is available
if type -q starship
    starship init fish | source
else
    # Fallback to simple prompt (fish has a nice default)
    # You can customize this if needed
end

# ===== ALIASES =====
# System aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Git aliases (if not using ProfileCore git-multi-account)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ===== CONDA INITIALIZATION (if available) =====
if test -f "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    source "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
else if test -f "$HOME/anaconda3/etc/fish/conf.d/conda.fish"
    source "$HOME/anaconda3/etc/fish/conf.d/conda.fish"
end

# ===== CUSTOM CONFIGURATION =====
# Load user-specific customizations (not tracked in git)
if test -f "$HOME/.config/fish/config.fish.local"
    source "$HOME/.config/fish/config.fish.local"
end

# ===== PERFORMANCE TRACKING =====
set -g FISH_LOAD_END (date +%s%3N)
set -g FISH_LOAD_TIME (math $FISH_LOAD_END - $FISH_LOAD_START)

# ===== WELCOME MESSAGE =====
echo ""
echo "🚀 Welcome to Fish with ProfileCore v4.0.0 ("$FISH_LOAD_TIME"ms)"
echo "💡 Type 'profile-perf' for performance info"
echo ""
