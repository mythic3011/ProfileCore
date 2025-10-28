#!/bin/bash
# ProfileCore v1.0.0 - Quick Install Script for Unix
# Usage: curl -fsSL https://raw.githubusercontent.com/mythic3011/ProfileCore/main/scripts/quick-install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   ProfileCore v1.0.0 - Quick Installer (Unix)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)
        OS_TYPE="linux"
        ;;
    Darwin*)
        OS_TYPE="macos"
        ;;
    *)
        echo -e "${RED}✗ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

case "$ARCH" in
    x86_64|amd64)
        ARCH_TYPE="x86_64"
        ;;
    aarch64|arm64)
        ARCH_TYPE="aarch64"
        ;;
    *)
        echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✓ Detected OS: $OS_TYPE${NC}"
echo -e "${GREEN}✓ Detected architecture: $ARCH_TYPE${NC}"
echo ""

# Step 2: Download URL
VERSION="v1.0.0"
BINARY_NAME="profilecore"
DOWNLOAD_URL="https://github.com/mythic3011/ProfileCore/releases/download/$VERSION/profilecore-${OS_TYPE}-${ARCH_TYPE}"

echo -e "${GREEN}✓ Download URL: $DOWNLOAD_URL${NC}"
echo ""

# Step 3: Determine install location
if [ "$(id -u)" = "0" ]; then
    # Root - system-wide install
    INSTALL_DIR="/usr/local/bin"
    echo -e "${GREEN}✓ Installing system-wide to: $INSTALL_DIR${NC}"
else
    # User install
    INSTALL_DIR="$HOME/.local/bin"
    echo -e "${YELLOW}ℹ Installing for current user to: $INSTALL_DIR${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}⚠ Warning: $INSTALL_DIR is not in your PATH${NC}"
        echo -e "${YELLOW}  Add this line to your shell config (~/.bashrc, ~/.zshrc, etc.):${NC}"
        echo -e "${CYAN}  export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        echo ""
    fi
fi

BINARY_PATH="$INSTALL_DIR/$BINARY_NAME"

# Step 4: Download binary
echo -e "${CYAN}Downloading ProfileCore binary...${NC}"
if command -v curl > /dev/null 2>&1; then
    curl -fsSL -o "$BINARY_PATH" "$DOWNLOAD_URL"
elif command -v wget > /dev/null 2>&1; then
    wget -q -O "$BINARY_PATH" "$DOWNLOAD_URL"
else
    echo -e "${RED}✗ Error: neither curl nor wget found${NC}"
    echo -e "${YELLOW}Please install curl or wget and try again${NC}"
    exit 1
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}✗ Binary not found at: $BINARY_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Download complete${NC}"
echo ""

# Step 5: Make executable
chmod +x "$BINARY_PATH"
echo -e "${GREEN}✓ Binary saved to: $BINARY_PATH${NC}"
echo ""

# Step 6: Verify installation
if command -v profilecore > /dev/null 2>&1; then
    echo -e "${GREEN}✓ profilecore is now in PATH${NC}"
else
    echo -e "${YELLOW}⚠ profilecore not found in PATH${NC}"
    echo -e "${YELLOW}  You may need to restart your shell or add $INSTALL_DIR to PATH${NC}"
fi
echo ""

# Step 7: Run interactive installer
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   Starting Interactive Installer...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

# Run the installer directly with full path
"$BINARY_PATH" install

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
echo -e "  2. Try: profilecore system info"
echo ""

