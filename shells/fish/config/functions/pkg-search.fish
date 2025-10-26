#!/usr/bin/env fish
# Package Search for Fish Shell
# Part of ProfileCore v3.0

function pkg-search -d "Search for packages"
    set -l query $argv[1]
    set -l limit 20
    
    if test (count $argv) -gt 1
        set limit $argv[2]
    end
    
    if test -z "$query"
        echo "❌ Usage: pkg-search <query> [limit]"
        return 1
    end
    
    set -l os (get_os)
    
    echo ""
    echo (set_color cyan)"🔍 Searching for:"(set_color normal) (set_color yellow)"$query"(set_color normal)
    echo (set_color brblack)"Platform: $os"(set_color normal)
    echo ""
    
    switch "$os"
        case macos
            if command -v brew &> /dev/null
                echo (set_color green)"📦 Homebrew Packages:"(set_color normal)
                brew search "$query" 2>&1 | head -n $limit | while read -l pkg
                    echo "  "(set_color white)"$pkg"(set_color normal)
                end
                
                echo ""
                echo (set_color green)"📦 Homebrew Casks (GUI apps):"(set_color normal)
                brew search --cask "$query" 2>&1 | head -n $limit | while read -l pkg
                    echo "  "(set_color cyan)"$pkg"(set_color normal)
                end
            else
                echo "⚠️  Homebrew not found. Install from https://brew.sh"
            end
            
        case linux
            if command -v apt-cache &> /dev/null
                echo (set_color green)"📦 APT Packages:"(set_color normal)
                apt-cache search "$query" | head -n $limit
            else if command -v dnf &> /dev/null
                echo (set_color green)"📦 DNF Packages:"(set_color normal)
                dnf search "$query" 2>&1 | head -n $limit
            else if command -v pacman &> /dev/null
                echo (set_color green)"📦 Pacman Packages:"(set_color normal)
                pacman -Ss "$query" | head -n (math $limit \* 2)
            else if command -v zypper &> /dev/null
                echo (set_color green)"📦 Zypper Packages:"(set_color normal)
                zypper search "$query" | head -n $limit
            else
                echo "⚠️  No supported package manager found"
            end
    end
    
    echo ""
    echo (set_color cyan)"💡 To install:"(set_color normal) (set_color yellow)"pkg <package-name>"(set_color normal)
    echo (set_color cyan)"💡 To install multiple:"(set_color normal) (set_color yellow)"pkg-install-list"(set_color normal)
    echo ""
end

