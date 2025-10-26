#!/usr/bin/env zsh
# ProfileCore v4.0.0 - Main Zsh Configuration
# Cross-Platform Shell Profile with Dual-Shell Support
# Author: Mythic3011

# ===== PERFORMANCE OPTIMIZATION START =====
# Track load time
typeset -g ZSH_LOAD_START=$(date +%s%3N)

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

# ===== ZSH CONFIGURATION =====
# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit
# Only regenerate completion cache once per day (performance)
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select

# ===== LOAD PROFILECORE FUNCTIONS =====
# Load all function files in order
PROFILECORE_FUNCTIONS_DIR="${HOME}/Documents/PowerShell/MacOS/.zsh/functions"

if [[ -d "$PROFILECORE_FUNCTIONS_DIR" ]]; then
    # Load functions in numbered order
    for func_file in "$PROFILECORE_FUNCTIONS_DIR"/*.zsh(N); do
        source "$func_file"
    done
fi

# ===== PROMPT CONFIGURATION =====
# Check if Starship is available
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    # Fallback to simple prompt
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' (%b)'
    setopt PROMPT_SUBST
    PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f%F{magenta}${vcs_info_msg_0_}%f
%F{green}❯%f '
fi

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
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
fi

# ===== CUSTOM CONFIGURATION =====
# Load user-specific customizations (not tracked in git)
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

# ===== PERFORMANCE TRACKING =====
typeset -g ZSH_LOAD_END=$(date +%s%3N)
typeset -g ZSH_LOAD_TIME=$((ZSH_LOAD_END - ZSH_LOAD_START))

# ===== WELCOME MESSAGE =====
echo ""
echo "🚀 Welcome to Zsh with ProfileCore v4.0.0 (${ZSH_LOAD_TIME}ms)"
echo "💡 Type 'profile-perf' for performance info"
echo ""
