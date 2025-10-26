#!/usr/bin/env bash

#######################################
# ProfileCore v5.1.1 Quick Installer - One-Line Installation for Unix
#
# Downloads ProfileCore to ~/ProfileCore, runs the installer, and optionally
# launches configuration. Repository is kept for easy updates.
# Automatically detects and installs missing prerequisites (Git) without prompting.
# This script is designed to be run via: curl -fsSL <url> | bash
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash
#
# Author: Mythic3011
# Version: 5.1.1
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     ProfileCore v5.1.1 Quick Installer - Unix          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
echo -e "${CYAN}[CHECK] Checking prerequisites...${NC}"

# Check and auto-install Git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[WARN] Git is not installed${NC}"
    echo -e "${CYAN}[INSTALL] Attempting to install Git automatically...${NC}"
    
    INSTALLED=false
    
    # macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            echo -e "${GRAY}  Using Homebrew to install Git...${NC}"
            brew install git --quiet 2>/dev/null && INSTALLED=true
        else
            echo -e "${YELLOW}  Homebrew not found. Install from: https://brew.sh${NC}"
        fi
    # Debian/Ubuntu
    elif command -v apt-get &> /dev/null; then
        echo -e "${GRAY}  Using apt-get to install Git...${NC}"
        sudo apt-get update -qq 2>/dev/null && sudo apt-get install -y -qq git 2>/dev/null && INSTALLED=true
    # Fedora/RHEL
    elif command -v dnf &> /dev/null; then
        echo -e "${GRAY}  Using dnf to install Git...${NC}"
        sudo dnf install -y -q git 2>/dev/null && INSTALLED=true
    # Arch Linux
    elif command -v pacman &> /dev/null; then
        echo -e "${GRAY}  Using pacman to install Git...${NC}"
        sudo pacman -S --noconfirm --quiet git 2>/dev/null && INSTALLED=true
    # Alpine Linux
    elif command -v apk &> /dev/null; then
        echo -e "${GRAY}  Using apk to install Git...${NC}"
        sudo apk add --quiet git 2>/dev/null && INSTALLED=true
    fi
    
    # Verify installation
    if $INSTALLED && command -v git &> /dev/null; then
        echo -e "${GREEN}[OK] Git installed successfully: $(git --version)${NC}"
    else
        echo -e "${RED}[ERROR] Failed to install Git automatically${NC}"
        echo -e "${YELLOW}Please install Git manually:${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${CYAN}   brew install git${NC}"
        elif command -v apt-get &> /dev/null; then
            echo -e "${CYAN}   sudo apt-get install git${NC}"
        elif command -v dnf &> /dev/null; then
            echo -e "${CYAN}   sudo dnf install git${NC}"
        elif command -v pacman &> /dev/null; then
            echo -e "${CYAN}   sudo pacman -S git${NC}"
        else
            echo -e "${CYAN}   https://git-scm.com/${NC}"
        fi
        exit 1
    fi
else
    echo -e "${GREEN}[OK] Git found: $(git --version)${NC}"
fi

# Detect shell
CURRENT_SHELL=$(basename "$SHELL")
echo -e "${GREEN}[OK] Shell: $CURRENT_SHELL${NC}"

# Determine installation directory
INSTALL_DIR="$HOME/ProfileCore"
echo -e "\n${WHITE}[DIR] Installation directory: $INSTALL_DIR${NC}"

# Check if already exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "\n${YELLOW}[WARN] ProfileCore directory already exists!${NC}"
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    
    echo -e "\n${CYAN}[UPDATE] Updating existing installation...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main 2>&1 >/dev/null
else
    # Clone repository
    echo -e "\n${CYAN}[DOWNLOAD] Downloading ProfileCore...${NC}"
    git clone --quiet https://github.com/mythic3011/ProfileCore.git "$INSTALL_DIR" 2>&1 >/dev/null
    
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}[ERROR] Failed to clone repository${NC}"
        exit 1
    fi
    echo -e "${GREEN}[OK] Download complete${NC}"
    cd "$INSTALL_DIR"
fi

# Run installer
echo -e "\n${CYAN}[INSTALL] Running installer...${NC}"
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

chmod +x ./scripts/installation/install.sh
./scripts/installation/install.sh

echo -e "\n${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${GREEN}[OK] ProfileCore installed successfully!${NC}"

# Ask about configuration
echo -e "\n${CYAN}[CONFIG] Would you like to edit configuration now? (Y/n)${NC}"
echo -e "${GRAY}         This will open the .env file for API keys and settings.${NC}"
read -p "Edit config now? " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    ENV_FILE="$HOME/.config/shell-profile/.env"
    if [ -f "$ENV_FILE" ]; then
        echo -e "\n${CYAN}[EDITOR] Opening configuration file...${NC}"
        
        # Try to find an editor
        if command -v nano &> /dev/null; then
            nano "$ENV_FILE"
        elif command -v vim &> /dev/null; then
            vim "$ENV_FILE"
        elif command -v vi &> /dev/null; then
            vi "$ENV_FILE"
        elif [ -n "$EDITOR" ]; then
            $EDITOR "$ENV_FILE"
        else
            echo -e "${YELLOW}[WARN] No editor found. Please edit manually:${NC}"
            echo -e "${CYAN}       $ENV_FILE${NC}"
        fi
        
        echo -e "\n${GREEN}[OK] Configuration updated${NC}"
    else
        echo -e "${YELLOW}[WARN] Config file not found yet. Run installer again if needed.${NC}"
    fi
else
    echo -e "\n${YELLOW}[NOTE] You can configure ProfileCore later by editing:${NC}"
    echo -e "${CYAN}       ~/.config/shell-profile/.env${NC}"
fi

echo -e "\n${YELLOW}[NEXT] Next steps:${NC}"
echo -e "${WHITE}       1. Reload your shell:${NC}"

case "$CURRENT_SHELL" in
    zsh)
        echo -e "${CYAN}      source ~/.zshrc${NC}"
        ;;
    bash)
        echo -e "${CYAN}      source ~/.bashrc${NC}"
        ;;
    fish)
        echo -e "${CYAN}      source ~/.config/fish/config.fish${NC}"
        ;;
    *)
        echo -e "${CYAN}      source ~/.${CURRENT_SHELL}rc${NC}"
        ;;
esac

echo -e "\n${WHITE}   2. Test installation:${NC}"
echo -e "${CYAN}      sysinfo${NC}"
echo -e "${CYAN}      myip${NC}"

echo -e "\n${WHITE}   3. View all commands:${NC}"
echo -e "${CYAN}      pkg --help${NC}"

echo -e "\n${WHITE}[PATH] ProfileCore location: $INSTALL_DIR${NC}"
echo -e "${GRAY}[TIP]  To update: cd $INSTALL_DIR && git pull && ./scripts/installation/install.sh${NC}"
echo -e "\n${GREEN}[OK] Happy scripting!${NC}\n"

