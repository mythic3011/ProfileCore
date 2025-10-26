#!/usr/bin/env fish
# Package Info for Fish Shell
# Part of ProfileCore v3.0

function pkg-info -d "Get detailed information about a package"
    set -l package $argv[1]
    
    if test -z "$package"
        echo "❌ Usage: pkg-info <package-name>"
        return 1
    end
    
    set -l os (get_os)
    
    echo ""
    echo (set_color cyan)"ℹ️  Package Information:"(set_color normal) (set_color yellow)"$package"(set_color normal)
    echo (set_color brblack)"Platform: $os"(set_color normal)
    echo ""
    
    switch "$os"
        case macos
            if command -v brew &> /dev/null
                brew info "$package"
            end
            
        case linux
            if command -v apt-cache &> /dev/null
                apt-cache show "$package"
            else if command -v dnf &> /dev/null
                dnf info "$package"
            else if command -v pacman &> /dev/null
                pacman -Si "$package"
            else if command -v zypper &> /dev/null
                zypper info "$package"
            end
    end
end

