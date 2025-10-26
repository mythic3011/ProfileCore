#!/usr/bin/env bash
# ProfileCore v4.0.0 - Main Bash Configuration
# Cross-Platform Shell Profile with Dual-Shell Support
# Author: Mythic3011

# ===== PERFORMANCE OPTIMIZATION START =====
# Track load time
BASH_LOAD_START=$(date +%s%3N)

# ===== ENVIRONMENT SETUP =====
# Set ProfileCore home
export PROFILECORE_HOME="${HOME}/.config/shell-profile"

# Load environment variables from shared .env file
if [[ -f "${PROFILECORE_HOME}/.env" ]]; then
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^#.*$ ]] && continue
        [[ -z $key ]] && continue
        # Export variable
        export "$key=$value"
    done < "${PROFILECORE_HOME}/.env"
fi

# ===== PATH CONFIGURATION =====
# Add common paths (will be overridden by path-resolver if needed)
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon

# ===== BASH CONFIGURATION =====
# History settings
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Directory navigation
shopt -s autocd 2>/dev/null  # cd by typing directory name
shopt -s cdspell             # Auto-correct cd typos
shopt -s dirspell 2>/dev/null

# Completion
if [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
elif [[ -f /usr/local/etc/bash_completion ]]; then
    source /usr/local/etc/bash_completion
fi

# Case-insensitive completion
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"

# ===== LOAD PROFILECORE FUNCTIONS =====
# Load all function files in order
PROFILECORE_FUNCTIONS_DIR="${HOME}/Documents/PowerShell/MacOS/.bash/functions"

if [[ -d "$PROFILECORE_FUNCTIONS_DIR" ]]; then
    # Load functions in numbered order
    for func_file in "$PROFILECORE_FUNCTIONS_DIR"/*.bash; do
        [[ -f "$func_file" ]] && source "$func_file"
    done
fi

# ===== PROMPT CONFIGURATION =====
# Check if Starship is available
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
else
    # Fallback to simple prompt with git branch
    parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }
    
    PS1='\[\033[0;36m\]\u@\h\[\033[0m\] \[\033[0;33m\]\w\[\033[0;35m\]$(parse_git_branch)\[\033[0m\]\n\[\033[0;32m\]❯\[\033[0m\] '
fi

# ===== ALIASES =====
# System aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Enable color support
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
fi

# ===== CUSTOM CONFIGURATION =====
# Load user-specific customizations (not tracked in git)
if [[ -f "$HOME/.bashrc.local" ]]; then
    source "$HOME/.bashrc.local"
fi

# ===== PERFORMANCE TRACKING =====
BASH_LOAD_END=$(date +%s%3N)
BASH_LOAD_TIME=$((BASH_LOAD_END - BASH_LOAD_START))

# ===== WELCOME MESSAGE =====
echo ""
echo "🚀 Welcome to Bash with ProfileCore v4.0.0 (${BASH_LOAD_TIME}ms)"
echo "💡 Type 'profile-perf' for performance info"
echo ""
