# 10-package-manager.fish
# Cross-platform package management for Fish
# Part of ProfileCore v5.0 - Optimized Shell Functions

# Detect best available package manager
function _detect_package_manager
    set -l cached_pm (_profilecore_cache_get "package_manager")
    if test -n "$cached_pm"
        echo $cached_pm
        return 0
    end
    
    set -l pm ""
    
    if command_exists brew
        set pm "brew"
    else if command_exists apt
        set pm "apt"
    else if command_exists dnf
        set pm "dnf"
    else if command_exists pacman
        set pm "pacman"
    else if command_exists zypper
        set pm "zypper"
    end
    
    if test -n "$pm"
        _profilecore_cache_set "package_manager" "$pm"
        echo $pm
        return 0
    end
    
    return 1
end

# Install package
function pkg
    set -l package_name $argv[1]
    
    if test -z "$package_name"
        print_color red "❌ Package name required"
        return 1
    end
    
    set -l pm (_detect_package_manager)
    
    if test -z "$pm"
        print_color red "❌ No package manager found"
        return 1
    end
    
    print_color cyan "📦 Installing $package_name via $pm..."
    
    switch $pm
        case brew
            brew install $package_name
        case apt
            sudo apt install -y $package_name
        case dnf
            sudo dnf install -y $package_name
        case pacman
            sudo pacman -S --noconfirm $package_name
        case zypper
            sudo zypper install -y $package_name
    end
    
    if test $status -eq 0
        print_color green "✅ Package installed: $package_name"
    end
end

# Search for packages
function pkg-search
    set -l query $argv[1]
    
    if test -z "$query"
        print_color red "❌ Search query required"
        return 1
    end
    
    set -l pm (_detect_package_manager)
    
    if test -z "$pm"
        print_color red "❌ No package manager found"
        return 1
    end
    
    print_color cyan "🔍 Searching for '$query' with $pm..."
    
    switch $pm
        case brew
            brew search $query
        case apt
            apt search $query
        case dnf
            dnf search $query
        case pacman
            pacman -Ss $query
        case zypper
            zypper search $query
    end
end

# Update all packages
function pkgu
    set -l pm (_detect_package_manager)
    
    if test -z "$pm"
        print_color red "❌ No package manager found"
        return 1
    end
    
    print_color cyan "🔄 Updating packages with $pm..."
    
    switch $pm
        case brew
            brew update; and brew upgrade; and brew cleanup
        case apt
            sudo apt update; and sudo apt upgrade -y; and sudo apt autoremove -y
        case dnf
            sudo dnf upgrade -y
        case pacman
            sudo pacman -Syu --noconfirm
        case zypper
            sudo zypper update -y
    end
end

# Aliases
alias pkgs='pkg-search'

