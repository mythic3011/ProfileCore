#!/usr/bin/env bash

#
# ProfileCore v5.0.0 Uninstaller - Unix/Linux/macOS Edition
#
# Safely uninstalls ProfileCore and removes shell configurations
# with backup restoration options and comprehensive cleanup.
#
# Usage:
#   ./uninstall.sh [options]
#
# Options:
#   --keep-config      Keep configuration files and user data
#   --keep-backups     Keep profile backups
#   --force           Force uninstallation without prompts
#   --quiet           Minimal output mode
#   --restore-backup  Restore most recent profile backup
#   --help            Show this help message
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Options
KEEP_CONFIG=false
KEEP_BACKUPS=false
FORCE=false
QUIET=false
RESTORE_BACKUP=false

# Paths
SHELL_TYPE=""
PROFILE_PATH=""
MODULE_PATH=""
CONFIG_DIR="$HOME/.config/shell-profile"
START_TIME=$(date +%s)
UNINSTALL_LOG=()

# Functions
write_step() {
    if [ "$QUIET" = false ]; then
        echo -e "${CYAN}🔹 $1${NC}"
    fi
    UNINSTALL_LOG+=("$1")
}

write_progress() {
    if [ "$QUIET" = false ]; then
        echo -e "${GRAY}[$2%] $1${NC}"
    fi
}

write_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}✅ $1${NC}"
    fi
    UNINSTALL_LOG+=("[SUCCESS] $1")
}

write_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${NC}ℹ️  $1${NC}"
    fi
}

write_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

write_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_help() {
    cat << EOF
ProfileCore v5.0.0 Uninstaller

Usage: ./uninstall.sh [options]

Options:
    --keep-config      Keep configuration files and user data
    --keep-backups     Keep profile backups
    --force           Force uninstallation without prompts
    --quiet           Minimal output mode
    --restore-backup  Restore most recent profile backup
    --help            Show this help message

Examples:
    ./uninstall.sh                                    # Interactive uninstall
    ./uninstall.sh --keep-config --keep-backups      # Keep user data
    ./uninstall.sh --restore-backup --force          # Restore and force

EOF
    exit 0
}

write_uninstall_log() {
    local log_file="$1"
    cat > "$log_file" << EOF
ProfileCore Uninstallation Log
Generated: $(date '+%Y-%m-%d %H:%M:%S')
User: $USER
Hostname: $(hostname)
Shell: $SHELL_TYPE

========================================
Uninstallation Steps:
========================================

$(printf '%s\n' "${UNINSTALL_LOG[@]}")

========================================
Status: Completed Successfully
========================================
EOF
    write_info "Uninstallation log saved: $log_file"
}

detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_TYPE="zsh"
        PROFILE_PATH="$HOME/.zshrc"
        MODULE_PATH="$HOME/.profilecore"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_TYPE="bash"
        if [ "$(uname)" = "Darwin" ]; then
            PROFILE_PATH="$HOME/.bash_profile"
        else
            PROFILE_PATH="$HOME/.bashrc"
        fi
        MODULE_PATH="$HOME/.profilecore"
    elif [ -n "$FISH_VERSION" ]; then
        SHELL_TYPE="fish"
        PROFILE_PATH="$HOME/.config/fish/config.fish"
        MODULE_PATH="$HOME/.config/fish/functions"
    else
        SHELL_TYPE="unknown"
        write_warning "Could not detect shell type"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep-config)
            KEEP_CONFIG=true
            shift
            ;;
        --keep-backups)
            KEEP_BACKUPS=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --restore-backup)
            RESTORE_BACKUP=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            write_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Start
clear

if [ "$QUIET" = false ]; then
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       ProfileCore v5.0 Uninstaller - Unix/Linux/macOS  ║"
    echo "║            Uninstallation Process                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
fi

# Detect shell and paths
detect_shell

# Confirmation prompt (unless --force)
if [ "$FORCE" = false ]; then
    echo -e "${YELLOW}⚠️  This will remove ProfileCore from your system.${NC}"
    echo -e "${YELLOW}   The following will be removed:${NC}"
    echo -e "${GRAY}   • ProfileCore shell configurations${NC}"
    echo -e "${GRAY}   • Shell profile modifications${NC}"
    
    if [ "$KEEP_CONFIG" = false ]; then
        echo -e "${GRAY}   • Configuration files and user data${NC}"
    fi
    
    if [ "$KEEP_BACKUPS" = false ]; then
        echo -e "${GRAY}   • Profile backups${NC}"
    fi
    
    echo ""
    read -p "Continue with uninstallation? (yes/no) " -r response
    if [[ ! $response =~ ^(y|yes|Y|YES)$ ]]; then
        echo -e "\n${YELLOW}❌ Uninstallation cancelled by user.${NC}"
        exit 0
    fi
fi

write_step "Starting ProfileCore uninstallation..."
write_progress "Detecting installation..." 5

write_info "Shell type: $SHELL_TYPE"
write_info "Profile path: $PROFILE_PATH"
write_info "Module path: $MODULE_PATH"
write_info "Config path: $CONFIG_DIR"

# Check if ProfileCore is installed
IS_INSTALLED=false
if [ -d "$MODULE_PATH" ] || [ -d "$CONFIG_DIR" ]; then
    IS_INSTALLED=true
fi

if [ "$IS_INSTALLED" = false ]; then
    write_warning "ProfileCore not found in standard locations"
    write_info "The module may already be uninstalled"
    
    if [ "$FORCE" = false ]; then
        read -p "Continue anyway? (yes/no) " -r response
        if [[ ! $response =~ ^(y|yes|Y|YES)$ ]]; then
            echo -e "\n${YELLOW}❌ Uninstallation cancelled.${NC}"
            exit 0
        fi
    fi
fi

# Step 1: Handle shell profile (20-40%)
write_step "Handling shell profile"
write_progress "Processing profile..." 20

if [ "$RESTORE_BACKUP" = true ]; then
    # Find most recent backup
    if [ -f "$PROFILE_PATH" ]; then
        BACKUPS=($(ls -t "${PROFILE_PATH}".*.backup 2>/dev/null))
        
        if [ ${#BACKUPS[@]} -gt 0 ]; then
            LATEST_BACKUP="${BACKUPS[0]}"
            write_progress "Restoring backup: $(basename "$LATEST_BACKUP")..." 25
            
            cp "$LATEST_BACKUP" "$PROFILE_PATH"
            write_success "Profile restored from backup: $(basename "$LATEST_BACKUP")"
        else
            write_warning "No profile backups found"
        fi
    fi
else
    # Remove ProfileCore from profile
    if [ -f "$PROFILE_PATH" ]; then
        if grep -q "ProfileCore\|profilecore" "$PROFILE_PATH"; then
            write_progress "Removing ProfileCore from profile..." 30
            
            # Create backup
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            BACKUP_PATH="${PROFILE_PATH}.pre-uninstall-${TIMESTAMP}.backup"
            cp "$PROFILE_PATH" "$BACKUP_PATH"
            write_info "Profile backed up to: $BACKUP_PATH"
            
            # Remove ProfileCore lines
            sed -i.tmp '/ProfileCore/d;/profilecore/d' "$PROFILE_PATH" 2>/dev/null || \
                sed -i '' '/ProfileCore/d;/profilecore/d' "$PROFILE_PATH" 2>/dev/null
            rm -f "${PROFILE_PATH}.tmp" 2>/dev/null
            
            write_success "ProfileCore references removed from profile"
        else
            write_info "Profile does not contain ProfileCore references"
        fi
    else
        write_info "Profile file does not exist"
    fi
fi

# Step 2: Remove ProfileCore module/functions (40-60%)
write_step "Removing ProfileCore module"
write_progress "Deleting module files..." 40

if [ -d "$MODULE_PATH" ]; then
    FILE_COUNT=$(find "$MODULE_PATH" -type f 2>/dev/null | wc -l)
    write_progress "Removing $FILE_COUNT module files..." 50
    
    rm -rf "$MODULE_PATH"
    write_success "ProfileCore module removed ($FILE_COUNT files)"
else
    write_info "Module directory not found (may already be removed)"
fi

# Remove shell-specific installations
case "$SHELL_TYPE" in
    zsh)
        if [ -f "$HOME/.zsh/profilecore.zsh" ]; then
            rm -f "$HOME/.zsh/profilecore.zsh"
            write_success "Zsh ProfileCore file removed"
        fi
        ;;
    bash)
        if [ -f "$HOME/.bash/profilecore.bash" ]; then
            rm -f "$HOME/.bash/profilecore.bash"
            write_success "Bash ProfileCore file removed"
        fi
        ;;
    fish)
        if [ -d "$HOME/.config/fish/functions/profilecore" ]; then
            rm -rf "$HOME/.config/fish/functions/profilecore"
            write_success "Fish ProfileCore functions removed"
        fi
        ;;
esac

# Step 3: Remove configuration (60-80%)
if [ "$KEEP_CONFIG" = false ]; then
    write_step "Removing configuration files"
    write_progress "Cleaning up configuration..." 60
    
    if [ -d "$CONFIG_DIR" ]; then
        CONFIG_FILE_COUNT=$(find "$CONFIG_DIR" -type f 2>/dev/null | wc -l)
        write_info "Found $CONFIG_FILE_COUNT configuration files"
        
        write_progress "Deleting configuration directory..." 70
        rm -rf "$CONFIG_DIR"
        write_success "Configuration directory removed"
    else
        write_info "Configuration directory not found"
    fi
else
    write_success "Configuration files preserved (--keep-config)"
    write_progress "Skipping configuration removal..." 70
fi

# Step 4: Clean up backups (80-90%)
if [ "$KEEP_BACKUPS" = false ]; then
    write_step "Removing profile backups"
    write_progress "Cleaning up backup files..." 80
    
    BACKUP_COUNT=$(ls -1 "${PROFILE_PATH}".*.backup 2>/dev/null | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        write_info "Found $BACKUP_COUNT backup files"
        rm -f "${PROFILE_PATH}".*.backup
        write_success "Backup files removed"
    else
        write_info "No backup files found"
    fi
else
    write_success "Backup files preserved (--keep-backups)"
    write_progress "Skipping backup removal..." 85
fi

# Step 5: Verify uninstallation (90-95%)
write_step "Verifying uninstallation"
write_progress "Running verification checks..." 90

CHECKS_PASSED=0
CHECKS_TOTAL=0

# Check module directory
CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
if [ ! -d "$MODULE_PATH" ]; then
    if [ "$QUIET" = false ]; then
        echo -e "  ${GREEN}✅ Module directory removed${NC}"
    fi
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
else
    write_warning "Module directory still exists"
fi

# Check config directory
if [ "$KEEP_CONFIG" = false ]; then
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    if [ ! -d "$CONFIG_DIR" ]; then
        if [ "$QUIET" = false ]; then
            echo -e "  ${GREEN}✅ Config directory removed${NC}"
        fi
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        write_warning "Config directory still exists"
    fi
fi

# Step 6: Generate uninstall log (95-100%)
write_progress "Generating uninstallation log..." 95

LOG_FILE="/tmp/profilecore-uninstall-$(date +%Y%m%d-%H%M%S).log"
write_uninstall_log "$LOG_FILE"

write_progress "Uninstallation complete!" 100

# Final summary
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

if [ "$QUIET" = false ]; then
    echo -e "\n${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         ✅ Uninstallation Complete Successfully! ✅       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    write_success "ProfileCore v5.0 uninstalled in ${ELAPSED}s!"
    
    echo -e "\n${CYAN}📊 Uninstallation Summary:${NC}"
    echo -e "  ${GREEN}✅ Module removed: $MODULE_PATH${NC}"
    
    if [ "$KEEP_CONFIG" = false ]; then
        echo -e "  ${GREEN}✅ Configuration removed: $CONFIG_DIR${NC}"
    else
        echo -e "  ${YELLOW}ℹ️  Configuration preserved: $CONFIG_DIR${NC}"
    fi
    
    if [ "$RESTORE_BACKUP" = true ]; then
        echo -e "  ${GREEN}✅ Profile restored from backup${NC}"
    else
        echo -e "  ${GREEN}✅ Profile cleaned${NC}"
    fi
    
    if [ "$KEEP_BACKUPS" = false ]; then
        echo -e "  ${GREEN}✅ Backup files removed${NC}"
    else
        echo -e "  ${YELLOW}ℹ️  Backup files preserved${NC}"
    fi
    
    echo -e "\n${CYAN}📝 What was removed:${NC}"
    echo -e "   ${GRAY}• ProfileCore shell configurations${NC}"
    echo -e "   ${GRAY}• Shell profile modifications${NC}"
    
    if [ "$KEEP_CONFIG" = false ]; then
        echo -e "   ${GRAY}• Configuration and user data${NC}"
    fi
    
    if [ "$KEEP_BACKUPS" = false ]; then
        echo -e "   ${GRAY}• Profile backup files${NC}"
    fi
    
    echo -e "\n${CYAN}💾 Preserved:${NC}"
    echo -e "   ${GRAY}• Uninstallation log: $LOG_FILE${NC}"
    
    if [ "$KEEP_CONFIG" = true ]; then
        echo -e "   ${GRAY}• Configuration files: $CONFIG_DIR${NC}"
    fi
    
    if [ "$KEEP_BACKUPS" = true ]; then
        echo -e "   ${GRAY}• Profile backups${NC}"
    fi
    
    echo -e "\n${YELLOW}💡 Next Steps:${NC}"
    echo -e "  ${NC}1️⃣  Restart your shell or run: source $PROFILE_PATH${NC}"
    
    if [ "$KEEP_CONFIG" = true ]; then
        echo -e "  ${NC}2️⃣  (Optional) Remove remaining configuration:${NC}"
        echo -e "     ${CYAN}rm -rf '$CONFIG_DIR'${NC}"
    fi
    
    if [ "$KEEP_BACKUPS" = true ]; then
        echo -e "  ${NC}3️⃣  (Optional) Remove profile backups:${NC}"
        echo -e "     ${CYAN}rm -f '${PROFILE_PATH}'.*.backup${NC}"
    fi
    
    echo -e "\n${CYAN}📚 Reinstallation:${NC}"
    echo -e "  ${NC}To reinstall ProfileCore, run:${NC}"
    echo -e "  ${CYAN}./scripts/installation/install.sh${NC}"
    
    echo -e "\n${GREEN}👋 Thank you for using ProfileCore!${NC}\n"
else
    write_success "ProfileCore v5.0 uninstalled in ${ELAPSED}s"
    write_info "Log: $LOG_FILE"
fi

# Exit with success
exit 0

