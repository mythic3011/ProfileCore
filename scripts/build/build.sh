#!/usr/bin/env bash
# build.sh
# ProfileCore Build Script for Unix Systems
# Creates optimized, minified releases

set -euo pipefail

# ═════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════

VERSION="${1:-}"
CONFIGURATION="${2:-Release}"
SKIP_MINIFY="${SKIP_MINIFY:-false}"
SKIP_TESTS="${SKIP_TESTS:-false}"
SKIP_ARCHIVE="${SKIP_ARCHIVE:-false}"

if [ -z "$VERSION" ]; then
    echo "❌ Usage: $0 <version> [configuration]"
    echo "Example: $0 5.0.0 Release"
    exit 1
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
OUTPUT_DIR="$BUILD_DIR/output"
RELEASE_DIR="$OUTPUT_DIR/ProfileCore-v$VERSION"
ARCHIVE_DIR="$BUILD_DIR/releases"

BUILD_START=$(date +%s)

# ═════════════════════════════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════

print_step() {
    echo ""
    echo -e "\033[36m$1\033[0m"
    printf '=%.0s' {1..80}
    echo ""
}

print_success() {
    echo -e "\033[32m✅ $1\033[0m"
}

print_warning() {
    echo -e "\033[33m⚠️  $1\033[0m"
}

print_error() {
    echo -e "\033[31m❌ $1\033[0m"
}

# ═════════════════════════════════════════════════════════════════════════════
#  CODE OPTIMIZATION
# ═════════════════════════════════════════════════════════════════════════════

optimize_script() {
    local input="$1"
    local output="$2"
    
    if [ "$SKIP_MINIFY" = "true" ]; then
        cp "$input" "$output"
        return
    fi
    
    mkdir -p "$(dirname "$output")"
    
    # Read file
    local content=$(cat "$input")
    
    # Remove comments (preserve shebang)
    if [ "$CONFIGURATION" = "Release" ]; then
        awk '
            NR==1 && /^#!/ { print; next }
            /^[[:space:]]*#/ { next }
            { gsub(/[[:space:]]+#.*$/, ""); if (NF) print }
        ' "$input" > "$output"
    else
        cp "$input" "$output"
    fi
    
    # Make executable if original was executable
    if [ -x "$input" ]; then
        chmod +x "$output"
    fi
}

# ═════════════════════════════════════════════════════════════════════════════
#  BUILD STEPS
# ═════════════════════════════════════════════════════════════════════════════

initialize_build() {
    print_step "Initializing Build"
    
    # Clean build directory
    if [ -d "$BUILD_DIR" ]; then
        echo "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
    fi
    
    # Create directories
    mkdir -p "$RELEASE_DIR"
    mkdir -p "$ARCHIVE_DIR"
    
    print_success "Build initialized"
    echo "  Version: $VERSION"
    echo "  Configuration: $CONFIGURATION"
    echo "  Minify: $([ "$SKIP_MINIFY" = "false" ] && echo "Yes" || echo "No")"
    echo "  Output: $RELEASE_DIR"
}

build_shell_functions() {
    print_step "Building Shell Functions"
    
    for shell in zsh bash fish; do
        local source_dir="$ROOT_DIR/shells/$shell"
        local target_dir="$RELEASE_DIR/shells/$shell"
        
        if [ ! -d "$source_dir" ]; then
            continue
        fi
        
        echo "Building $shell functions..."
        
        # Create target directory
        mkdir -p "$target_dir/lib"
        
        # Copy and optimize lib files
        if [ -d "$source_dir/lib" ]; then
            for file in "$source_dir/lib"/*; do
                if [ -f "$file" ]; then
                    optimize_script "$file" "$target_dir/lib/$(basename "$file")"
                fi
            done
        fi
        
        # Copy and optimize main loader
        local loader_file="profilecore.$shell"
        [ "$shell" = "fish" ] && loader_file="profilecore.fish"
        
        if [ -f "$source_dir/$loader_file" ]; then
            optimize_script "$source_dir/$loader_file" "$target_dir/$loader_file"
        fi
    done
    
    print_success "Shell functions built"
}

build_documentation() {
    print_step "Copying Documentation"
    
    # Essential documentation
    local docs=(
        "README.md"
        "QUICK_START.md"
        "INSTALL.md"
        "LICENSE"
        "MIGRATION_V5.md"
    )
    
    for doc in "${docs[@]}"; do
        if [ -f "$ROOT_DIR/$doc" ]; then
            cp "$ROOT_DIR/$doc" "$RELEASE_DIR/$doc"
        fi
    done
    
    # Copy essential docs directory
    mkdir -p "$RELEASE_DIR/docs/development"
    
    local essential_docs=(
        "PROFILECORE_V5_SUMMARY.md"
        "development/SOLID_ARCHITECTURE.md"
        "development/OPTIMIZATION_SUMMARY.md"
        "development/contributing.md"
    )
    
    for doc in "${docs[@]}"; do
        local source="$ROOT_DIR/docs/$doc"
        local target="$RELEASE_DIR/docs/$doc"
        
        if [ -f "$source" ]; then
            mkdir -p "$(dirname "$target")"
            cp "$source" "$target"
        fi
    done
    
    print_success "Documentation copied"
}

build_scripts() {
    print_step "Building Installation Scripts"
    
    local source_dir="$ROOT_DIR/scripts/installation"
    local target_dir="$RELEASE_DIR/scripts/installation"
    
    if [ -d "$source_dir" ]; then
        mkdir -p "$target_dir"
        
        # Copy install scripts
        for file in "$source_dir"/install.*; do
            if [ -f "$file" ]; then
                optimize_script "$file" "$target_dir/$(basename "$file")"
            fi
        done
    fi
    
    print_success "Scripts built"
}

create_archive() {
    if [ "$SKIP_ARCHIVE" = "true" ]; then
        print_warning "Skipping archive creation"
        return
    fi
    
    print_step "Creating Release Archive"
    
    local archive_name="ProfileCore-v$VERSION-$CONFIGURATION.tar.gz"
    local archive_path="$ARCHIVE_DIR/$archive_name"
    
    # Create archive
    cd "$OUTPUT_DIR"
    tar -czf "$archive_path" "ProfileCore-v$VERSION"
    
    local archive_size=$(du -h "$archive_path" | cut -f1)
    print_success "Archive created: $archive_name ($archive_size)"
    
    # Generate checksums
    echo "Generating checksums..."
    cd "$ARCHIVE_DIR"
    
    local md5sum_val=$(md5sum "$archive_name" | cut -d' ' -f1)
    local sha256sum_val=$(sha256sum "$archive_name" | cut -d' ' -f1)
    
    cat > "ProfileCore-v$VERSION-checksums.txt" <<EOF
ProfileCore v$VERSION - Checksums
Generated: $(date '+%Y-%m-%d %H:%M:%S')

File: $archive_name
Size: $archive_size

MD5:    $md5sum_val
SHA256: $sha256sum_val
EOF
    
    print_success "Checksums generated"
}

create_release_notes() {
    print_step "Generating Release Notes"
    
    cat > "$ARCHIVE_DIR/RELEASE_NOTES_v$VERSION.md" <<EOF
# ProfileCore v$VERSION Release Notes

**Release Date:** $(date '+%Y-%m-%d')
**Configuration:** $CONFIGURATION

## 📦 What's Included

### Core Components
- ✅ PowerShell Module (SOLID Architecture)
- ✅ Zsh Functions (Optimized)
- ✅ Bash Functions (Optimized)
- ✅ Fish Functions (Optimized)

### Features
- ✅ Provider Pattern for Package Managers (8 providers)
- ✅ Configuration Provider Pattern (4 providers)
- ✅ Service Container (Dependency Injection)
- ✅ Command Handler (Middleware Pipeline)
- ✅ OS Abstraction (Factory Pattern)
- ✅ Enhanced Plugin System

### Plugins
- ✅ security-tools - SSH, file verification, VirusTotal, Shodan
- ✅ example-docker-enhanced - Docker management

### Documentation
- ✅ SOLID Architecture Guide
- ✅ Optimization Summary
- ✅ Migration Guide
- ✅ Quick Start Guide
- ✅ Installation Guide

## 🚀 Installation

\`\`\`bash
# Extract archive
tar -xzf ProfileCore-v$VERSION-$CONFIGURATION.tar.gz
cd ProfileCore-v$VERSION

# Run installer
./scripts/installation/install.sh

# Reload shell
source ~/.zshrc  # or ~/.bashrc
\`\`\`

## 📊 Build Information

- **Version:** $VERSION
- **Configuration:** $CONFIGURATION
- **Build Date:** $(date '+%Y-%m-%d %H:%M:%S')
- **Platform:** $(uname -s)

## 🔗 Links

- [GitHub Repository](https://github.com/mythic3011/ProfileCore)
- [Documentation](https://github.com/mythic3011/ProfileCore/tree/main/docs)
- [Issues](https://github.com/mythic3011/ProfileCore/issues)

---

**ProfileCore v$VERSION** - _Professional • Extensible • Cross-Platform • SOLID_
EOF
    
    print_success "Release notes generated"
}

# ═════════════════════════════════════════════════════════════════════════════
#  MAIN BUILD PROCESS
# ═════════════════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         ProfileCore Build System v$VERSION                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    # Execute build steps
    initialize_build
    build_shell_functions
    build_documentation
    build_scripts
    create_archive
    create_release_notes
    
    # Calculate build time
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                  BUILD SUCCESSFUL                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    echo ""
    echo -e "\033[36m📊 Build Summary:\033[0m"
    echo "  Version:       $VERSION"
    echo "  Configuration: $CONFIGURATION"
    echo "  Build Time:    ${BUILD_TIME}s"
    echo "  Output:        $RELEASE_DIR"
    if [ "$SKIP_ARCHIVE" != "true" ]; then
        echo "  Archive:       $ARCHIVE_DIR"
    fi
    
    echo ""
    echo -e "\033[32m🎉 Release ready for distribution!\033[0m"
    echo ""
}

# Run main function
main "$@"

