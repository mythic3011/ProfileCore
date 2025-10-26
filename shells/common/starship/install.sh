#!/bin/bash
#
# install.sh
# Cross-shell Starship installer for ProfileCore (Unix)
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║  ProfileCore Starship Installer                    ║"
echo "╚════════════════════════════════════════════════════╝${NC}"
echo

# Parse arguments
INSTALL_STARSHIP=false
SHELL_TARGET="bash"
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-starship)
            INSTALL_STARSHIP=true
            shift
            ;;
        --shell)
            SHELL_TARGET="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# ===========================================================================
# 1. Check/Install Starship
# ===========================================================================

if ! command -v starship &> /dev/null; then
    if [ "$INSTALL_STARSHIP" = true ]; then
        echo -e "${YELLOW}📦 Installing Starship...${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "   ${NC}Using Homebrew...${NC}"
            brew install starship
        else
            echo -e "   ${NC}Using install script...${NC}"
            curl -sS https://starship.rs/install.sh | sh
        fi
        
        if command -v starship &> /dev/null; then
            echo -e "   ${GREEN}✅ Starship installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Starship${NC}"
            echo -e "${YELLOW}Manual installation: https://starship.rs/guide/#🚀-installation${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Starship not installed${NC}"
        echo -e "   Run with --install-starship to install automatically"
        echo -e "   Or visit: https://starship.rs/guide/#🚀-installation"
        exit 1
    fi
else
    VERSION=$(starship --version)
    echo -e "${GREEN}✅ Starship installed: $VERSION${NC}"
fi

# ===========================================================================
# 2. Copy Unified Config
# ===========================================================================

echo
echo -e "${YELLOW}📝 Setting up configuration...${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_CONFIG="$SCRIPT_DIR/starship.toml"
CONFIG_DIR="$HOME/.profilecore"
DEST_CONFIG="$CONFIG_DIR/starship.toml"

# Ensure config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    echo -e "   ${NC}Created config directory: $CONFIG_DIR${NC}"
fi

# Copy config
if [ -f "$DEST_CONFIG" ] && [ "$FORCE" = false ]; then
    echo -e "   ${YELLOW}⚠️  Config already exists: $DEST_CONFIG${NC}"
    echo -e "   Use --force to overwrite"
else
    cp "$SOURCE_CONFIG" "$DEST_CONFIG"
    echo -e "   ${GREEN}✅ Copied unified config to: $DEST_CONFIG${NC}"
fi

# ===========================================================================
# 3. Configure Shells
# ===========================================================================

echo
echo -e "${YELLOW}🐚 Configuring shells...${NC}"

configure_bash() {
    echo -e "\n   ${CYAN}Bash${NC}"
    BASHRC="$HOME/.bashrc"
    
    if [ ! -f "$BASHRC" ]; then
        touch "$BASHRC"
        echo -e "      ${NC}Created .bashrc${NC}"
    fi
    
    if ! grep -q "Starship prompt (ProfileCore)" "$BASHRC"; then
        cat >> "$BASHRC" << 'EOF'

# Starship prompt (ProfileCore)
export STARSHIP_CONFIG="$HOME/.profilecore/starship.toml"
eval "$(starship init bash)"
EOF
        echo -e "      ${GREEN}✅ Added Starship to .bashrc${NC}"
    else
        echo -e "      ${YELLOW}⚠️  Starship already configured${NC}"
    fi
}

configure_zsh() {
    echo -e "\n   ${CYAN}Zsh${NC}"
    ZSHRC="$HOME/.zshrc"
    
    if [ ! -f "$ZSHRC" ]; then
        touch "$ZSHRC"
        echo -e "      ${NC}Created .zshrc${NC}"
    fi
    
    if ! grep -q "Starship prompt (ProfileCore)" "$ZSHRC"; then
        cat >> "$ZSHRC" << 'EOF'

# Starship prompt (ProfileCore)
export STARSHIP_CONFIG="$HOME/.profilecore/starship.toml"
eval "$(starship init zsh)"
EOF
        echo -e "      ${GREEN}✅ Added Starship to .zshrc${NC}"
    else
        echo -e "      ${YELLOW}⚠️  Starship already configured${NC}"
    fi
}

configure_fish() {
    echo -e "\n   ${CYAN}Fish${NC}"
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    FISH_DIR="$HOME/.config/fish"
    
    if [ ! -d "$FISH_DIR" ]; then
        mkdir -p "$FISH_DIR"
        echo -e "      ${NC}Created fish config directory${NC}"
    fi
    
    if [ ! -f "$FISH_CONFIG" ]; then
        touch "$FISH_CONFIG"
        echo -e "      ${NC}Created config.fish${NC}"
    fi
    
    if ! grep -q "Starship prompt (ProfileCore)" "$FISH_CONFIG"; then
        cat >> "$FISH_CONFIG" << 'EOF'

# Starship prompt (ProfileCore)
set -gx STARSHIP_CONFIG "$HOME/.profilecore/starship.toml"
starship init fish | source
EOF
        echo -e "      ${GREEN}✅ Added Starship to config.fish${NC}"
    else
        echo -e "      ${YELLOW}⚠️  Starship already configured${NC}"
    fi
}

# Configure based on --shell argument
case "$SHELL_TARGET" in
    bash)
        configure_bash
        ;;
    zsh)
        configure_zsh
        ;;
    fish)
        configure_fish
        ;;
    all)
        configure_bash
        configure_zsh
        configure_fish
        ;;
    *)
        echo -e "${RED}Unknown shell: $SHELL_TARGET${NC}"
        echo -e "Valid options: bash, zsh, fish, all"
        exit 1
        ;;
esac

# ===========================================================================
# 4. Summary
# ===========================================================================

echo
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║  Installation Complete!                            ║"
echo "╚════════════════════════════════════════════════════╝${NC}"
echo

echo -e "${CYAN}Starship Configuration:${NC}"
echo -e "  Config file:  $DEST_CONFIG"
echo -e "  Configured:   $SHELL_TARGET"

echo
echo -e "${CYAN}Next Steps:${NC}"
echo -e "  1. Restart your shell(s) to see the new prompt"
echo -e "  2. Customize: Edit $DEST_CONFIG"
echo -e "  3. Learn more: https://starship.rs/config/"

echo

