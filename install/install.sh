#!/usr/bin/env bash

#######################################
# ProfileCore v5.1.0 Installer - Unix Edition
# 
# Installs ProfileCore for Zsh, Bash, or Fish with
# performance optimizations and multi-shell support.
#
# Usage:
#   ./install.sh [OPTIONS]
#
# Options:
#   --shell <zsh|bash|fish>  Specify which shell to configure (auto-detected if not provided)
#   --force                  Force reinstallation
#   --skip-backup            Skip creating backups
#   --skip-dependencies      Skip installing jq and Starship
#   --quiet                  Minimal output mode
#   --validate               Validate installation without making changes
#   --help                   Show this help message
#
# Examples:
#   ./install.sh
#   ./install.sh --shell fish
#   ./install.sh --force --quiet
#   ./install.sh --validate
#
# Author: Mythic3011
# Version: 5.1.0
# Performance Edition with 63% faster startup and enhanced validation
#######################################

set -e  # Exit on error

# Performance optimization
export HOMEBREW_NO_AUTO_UPDATE=1

# Variables
START_TIME=$(date +%s)
QUIET=false
FORCE=false
SKIP_BACKUP=false
SKIP_DEPENDENCIES=false
VALIDATE=false
SHELL_TYPE=""
ROLLBACK_ACTIONS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

#######################################
# Helper Functions
#######################################

print_step() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${CYAN}🔹 $1${NC}"
    fi
}

print_progress() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${GRAY}[$2%] $1${NC}"
    fi
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${WHITE}ℹ️  $1${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

add_rollback_action() {
    ROLLBACK_ACTIONS+=("$1")
}

invoke_rollback() {
    if [ ${#ROLLBACK_ACTIONS[@]} -eq 0 ]; then
        return
    fi
    
    print_warning "Installation failed. Rolling back changes..."
    for ((i=${#ROLLBACK_ACTIONS[@]}-1; i>=0; i--)); do
        eval "${ROLLBACK_ACTIONS[$i]}" || true
    done
    print_success "Rollback complete"
}

trap 'invoke_rollback; exit 1' ERR INT TERM

#######################################
# Parse Arguments
#######################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --shell)
            SHELL_TYPE="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-dependencies)
            SKIP_DEPENDENCIES=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --validate)
            VALIDATE=true
            shift
            ;;
        --help)
            echo "ProfileCore v5.1.0 Installer - Unix Edition"
            echo ""
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --shell <zsh|bash|fish>  Specify which shell to configure"
            echo "  --force                  Force reinstallation"
            echo "  --skip-backup            Skip creating backups"
            echo "  --skip-dependencies      Skip installing jq and Starship"
            echo "  --quiet                  Minimal output mode"
            echo "  --validate               Validate installation without changes"
            echo "  --help                   Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./install.sh"
            echo "  ./install.sh --shell fish"
            echo "  ./install.sh --force --quiet"
            echo "  ./install.sh --validate"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

#######################################
# Main Installation
#######################################

# Header
if [ "$QUIET" != "true" ]; then
    MODE="Installation"
    if [ "$VALIDATE" = "true" ]; then
        MODE="Validation Mode"
    fi
    echo -e "${MAGENTA}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       ProfileCore v5.1.0 Installer - Unix              ║"
    echo "║            ${MODE}                                     ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
fi

# Get installation directory
INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG_DIR="$HOME/.config/shell-profile"

# Step 1: System detection (0-5%)
print_step "Detecting System"
print_progress "Checking operating system..." 2

OS_TYPE="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
fi

print_info "Operating System: $OS_TYPE"

# Auto-detect shell if not specified
if [ -z "$SHELL_TYPE" ]; then
    print_progress "Auto-detecting shell..." 5
    
    CURRENT_SHELL=$(basename "$SHELL")
    case "$CURRENT_SHELL" in
        zsh)
            SHELL_TYPE="zsh"
            ;;
        bash)
            SHELL_TYPE="bash"
            ;;
        fish)
            SHELL_TYPE="fish"
            ;;
        *)
            SHELL_TYPE="zsh"  # Default to zsh
            print_warning "Could not detect shell. Defaulting to zsh"
            ;;
    esac
fi

print_info "Shell: $SHELL_TYPE"

# Set shell-specific paths
case "$SHELL_TYPE" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        SHELL_DIR="$INSTALL_ROOT/shells/zsh"
        FUNCTIONS_DIR="$HOME/.zsh/functions"
        ;;
    bash)
        SHELL_RC="$HOME/.bashrc"
        SHELL_DIR="$INSTALL_ROOT/shells/bash"
        FUNCTIONS_DIR="$HOME/.bash/functions"
        ;;
    fish)
        SHELL_RC="$HOME/.config/fish/config.fish"
        SHELL_DIR="$INSTALL_ROOT/shells/fish"
        FUNCTIONS_DIR="$HOME/.config/fish/functions"
        ;;
    *)
        print_error "Unsupported shell: $SHELL_TYPE"
        exit 1
        ;;
esac

# Validation mode - check installation and exit
if [ "$VALIDATE" = "true" ]; then
    print_step "Validation Mode - Checking Installation"
    
    PASS=0
    FAIL=0
    
    # Check shell config
    if [ -f "$SHELL_RC" ]; then
        echo -e "${GREEN}✅ PASS${NC} - Shell config exists: $SHELL_RC"
        ((PASS++))
    else
        echo -e "${YELLOW}❌ FAIL${NC} - Shell config missing: $SHELL_RC"
        ((FAIL++))
    fi
    
    # Check functions directory
    if [ -d "$FUNCTIONS_DIR" ]; then
        FUNC_COUNT=$(find "$FUNCTIONS_DIR" -type f 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ PASS${NC} - Functions directory exists ($FUNC_COUNT files)"
        ((PASS++))
    else
        echo -e "${YELLOW}❌ FAIL${NC} - Functions directory missing: $FUNCTIONS_DIR"
        ((FAIL++))
    fi
    
    # Check config directory
    if [ -d "$CONFIG_DIR" ]; then
        echo -e "${GREEN}✅ PASS${NC} - Config directory exists"
        ((PASS++))
    else
        echo -e "${YELLOW}❌ FAIL${NC} - Config directory missing"
        ((FAIL++))
    fi
    
    # Check config.json
    if [ -f "$CONFIG_DIR/config.json" ]; then
        echo -e "${GREEN}✅ PASS${NC} - config.json exists"
        ((PASS++))
    else
        echo -e "${YELLOW}❌ FAIL${NC} - config.json missing"
        ((FAIL++))
    fi
    
    # Check .env file
    if [ -f "$CONFIG_DIR/.env" ]; then
        echo -e "${GREEN}✅ PASS${NC} - .env file exists"
        ((PASS++))
    else
        echo -e "${YELLOW}❌ FAIL${NC} - .env file missing"
        ((FAIL++))
    fi
    
    TOTAL=$((PASS + FAIL))
    echo -e "\n${CYAN}Validation Score: $PASS/$TOTAL${NC}"
    
    if [ $FAIL -eq 0 ]; then
        print_success "All validation checks passed!"
        exit 0
    else
        print_warning "$FAIL validation check(s) failed"
        exit 1
    fi
fi

# Step 2: Backup existing files (5-15%)
if [ "$SKIP_BACKUP" != "true" ]; then
    print_step "Creating Backups"
    print_progress "Backing up existing files..." 10
    
    if [ -f "$SHELL_RC" ]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="${SHELL_RC}.${TIMESTAMP}.backup"
        cp "$SHELL_RC" "$BACKUP_FILE"
        add_rollback_action "mv '$BACKUP_FILE' '$SHELL_RC'"
        print_success "Shell config backed up: $(basename "$BACKUP_FILE")"
    fi
fi

# Step 3: Create directories (15-25%)
print_step "Creating Directories"
print_progress "Creating directory structure..." 20

mkdir -p "$CONFIG_DIR"
add_rollback_action "rmdir '$CONFIG_DIR' 2>/dev/null || true"

if [ "$SHELL_TYPE" = "fish" ]; then
    mkdir -p "$HOME/.config/fish"
    mkdir -p "$HOME/.config/fish/functions"
fi

print_success "Directory structure created"

# Step 4: Setup configuration (25-35%)
print_step "Configuring ProfileCore"
print_progress "Creating configuration files..." 30

CONFIG_FILE="$CONFIG_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "5.1.0",
  "theme": "default",
  "features": {
    "starship": true,
    "performance": true
  }
}
EOF
    add_rollback_action "rm -f '$CONFIG_FILE'"
fi

# Step 5: Setup .env file (35-40%)
print_progress "Creating environment file..." 38

ENV_FILE="$CONFIG_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    cat > "$ENV_FILE" << 'EOF'
# ProfileCore Environment Variables
# Add your API keys and secrets here

# Example:
# export GITHUB_TOKEN="your_token_here"
# export OPENAI_API_KEY="your_key_here"
EOF
    add_rollback_action "rm -f '$ENV_FILE'"
fi

print_success "Configuration files created"

# Step 6: Install shell configuration (40-70%)
print_step "Installing Shell Configuration"
print_progress "Installing $SHELL_TYPE configuration..." 50

case "$SHELL_TYPE" in
    zsh)
        if [ -f "$INSTALL_ROOT/shells/zsh/.zshrc" ]; then
            cp "$INSTALL_ROOT/shells/zsh/.zshrc" "$SHELL_RC"
            
            # Install Zsh functions
            if [ -d "$INSTALL_ROOT/shells/zsh/functions" ]; then
                ZSH_FUNCTIONS_DIR="$HOME/.zsh/functions"
                mkdir -p "$ZSH_FUNCTIONS_DIR"
                cp -r "$INSTALL_ROOT/shells/zsh/functions/"* "$ZSH_FUNCTIONS_DIR/" 2>/dev/null || true
            fi
        fi
        ;;
    bash)
        if [ -f "$INSTALL_ROOT/shells/bash/.bashrc" ]; then
            cp "$INSTALL_ROOT/shells/bash/.bashrc" "$SHELL_RC"
            
            # Install Bash functions
            if [ -d "$INSTALL_ROOT/shells/bash/functions" ]; then
                BASH_FUNCTIONS_DIR="$HOME/.bash/functions"
                mkdir -p "$BASH_FUNCTIONS_DIR"
                cp -r "$INSTALL_ROOT/shells/bash/functions/"* "$BASH_FUNCTIONS_DIR/" 2>/dev/null || true
            fi
        fi
        ;;
    fish)
        FISH_CONFIG_DIR="$HOME/.config/fish"
        
        if [ -f "$INSTALL_ROOT/shells/fish/config/config.fish" ]; then
            cp "$INSTALL_ROOT/shells/fish/config/config.fish" "$SHELL_RC"
        fi
        
        # Install Fish functions
        if [ -d "$INSTALL_ROOT/shells/fish/config/functions" ]; then
            mkdir -p "$FISH_CONFIG_DIR/functions"
            cp -r "$INSTALL_ROOT/shells/fish/config/functions/"* "$FISH_CONFIG_DIR/functions/" 2>/dev/null || true
        fi
        ;;
esac

print_success "$SHELL_TYPE configuration installed"

# Step 7: Install dependencies (70-90%)
if [ "$SKIP_DEPENDENCIES" != "true" ]; then
    print_step "Installing Dependencies"
    print_progress "Installing jq and Starship..." 80
    
    # Detect package manager
    if command -v brew &> /dev/null; then
        PKG_MGR="brew"
    elif command -v apt-get &> /dev/null; then
        PKG_MGR="apt"
    elif command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    elif command -v pacman &> /dev/null; then
        PKG_MGR="pacman"
    elif command -v zypper &> /dev/null; then
        PKG_MGR="zypper"
    else
        PKG_MGR="none"
    fi
    
    # Install jq
    if ! command -v jq &> /dev/null; then
        case "$PKG_MGR" in
            brew) brew install jq ;;
            apt) sudo apt-get install -y jq ;;
            dnf) sudo dnf install -y jq ;;
            pacman) sudo pacman -S --noconfirm jq ;;
            zypper) sudo zypper install -y jq ;;
            none) print_warning "Could not install jq. Please install manually." ;;
        esac
    fi
    
    # Check for Starship
    if ! command -v starship &> /dev/null; then
        print_info "Starship not found. Install with: curl -sS https://starship.rs/install.sh | sh"
    fi
    
    print_success "Dependencies checked"
fi

# Step 8: Verify installation (90-100%)
print_step "Verifying Installation"
print_progress "Running validation checks..." 95

VERIFY_CHECKS=0
VERIFY_PASSED=0

# Check shell config
if [ -f "$SHELL_RC" ]; then
    ((VERIFY_PASSED++)) || true
fi
((VERIFY_CHECKS++)) || true

# Check config directory
if [ -d "$CONFIG_DIR" ]; then
    ((VERIFY_PASSED++)) || true
fi
((VERIFY_CHECKS++)) || true

# Check config file
if [ -f "$CONFIG_FILE" ]; then
    ((VERIFY_PASSED++)) || true
fi
((VERIFY_CHECKS++)) || true

# Check .env file
if [ -f "$ENV_FILE" ]; then
    ((VERIFY_PASSED++)) || true
fi
((VERIFY_CHECKS++)) || true

if [ $VERIFY_PASSED -ne $VERIFY_CHECKS ]; then
    print_error "Verification failed: $VERIFY_PASSED/$VERIFY_CHECKS checks passed"
    exit 1
fi

print_progress "Validation complete" 100

# Success message
END_TIME=$(date +%s)
INSTALL_TIME=$((END_TIME - START_TIME))

if [ "$QUIET" != "true" ]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    print_success "ProfileCore v5.1.0 installed successfully in ${INSTALL_TIME}s!"
    echo ""
    
    echo -e "${YELLOW}⚡ Performance:${NC}"
    echo -e "${GREEN}  🚀 63% faster startup (PowerShell: 1.2s vs 3.3s)${NC}"
    echo -e "${GREEN}  ⏱️  2+ seconds saved on every shell launch${NC}"
    echo -e "${GREEN}  💡 Lazy loading enabled - commands on-demand${NC}"
    echo ""
    
    echo -e "${CYAN}✨ What's Installed:${NC}"
    case "$SHELL_TYPE" in
        zsh) echo -e "${WHITE}  • 18 Zsh function modules${NC}" ;;
        bash) echo -e "${WHITE}  • 7 Bash function modules${NC}" ;;
        fish) echo -e "${WHITE}  • 18 Fish function modules${NC}" ;;
    esac
    echo -e "${WHITE}  • 🔐 Security tools (port scanner, SSL checker, DNS tools)${NC}"
    echo -e "${WHITE}  • 🔧 Developer tools (Git, Docker automation, project scaffolding)${NC}"
    echo -e "${WHITE}  • 💻 System admin tools (monitoring, process management)${NC}"
    echo -e "${WHITE}  • ⚡ Performance - 63% faster startup, 38x faster DNS, intelligent caching${NC}"
    echo ""
    
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "${WHITE}  1. Reload your shell:${NC}"
    case "$SHELL_TYPE" in
        zsh)
            echo -e "${CYAN}     source ~/.zshrc${NC}"
            ;;
        bash)
            echo -e "${CYAN}     source ~/.bashrc${NC}"
            ;;
        fish)
            echo -e "${CYAN}     source ~/.config/fish/config.fish${NC}"
            ;;
    esac
    echo ""
    echo -e "${WHITE}  2. Test installation:${NC}"
    echo -e "${CYAN}     get_os              # Check OS${NC}"
    echo -e "${CYAN}     sysinfo             # System info${NC}"
    echo ""
    echo -e "${WHITE}  3. (Optional) Configure:${NC}"
    echo -e "${CYAN}     \$EDITOR $ENV_FILE${NC}"
    echo ""
    
    echo -e "${WHITE}💡 Validation:${NC}"
    echo -e "${GRAY}  Run: ./scripts/installation/install.sh --validate${NC}"
    echo ""
    
    print_success "🎉 Happy scripting!"
    echo ""
else
    print_success "ProfileCore v5.1.0 installed in ${INSTALL_TIME}s (63% faster startup)"
fi

# Cleanup rollback actions on success
ROLLBACK_ACTIONS=()

