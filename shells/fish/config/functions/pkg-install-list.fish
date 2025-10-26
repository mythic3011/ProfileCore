#!/usr/bin/env fish
# Package List Installation for Fish Shell
# Part of ProfileCore v3.0

function pkg-install-list -d "Install multiple packages from a list"
    if test (count $argv) -eq 0
        echo "❌ Usage: pkg-install-list <package1> <package2> ..."
        echo "Example: pkg-install-list git python nodejs"
        return 1
    end
    
    set -l packages $argv
    set -l os (get_os)
    set -l total (count $packages)
    
    echo ""
    echo (set_color cyan)"📦 Package Installation List"(set_color normal)
    echo "════════════════════════════"
    echo (set_color white)"Platform: $os"(set_color normal)
    echo (set_color white)"Packages to install: $total"(set_color normal)
    echo ""
    
    # Display list
    set -l i 1
    for pkg in $packages
        echo "  "(set_color brblack)"$i."(set_color normal) (set_color yellow)"$pkg"(set_color normal)
        set i (math $i + 1)
    end
    
    # Confirm
    echo ""
    echo -n (set_color cyan)"❓ Install these $total packages? [y/N]: "(set_color normal)
    read -l response
    
    if not string match -qr '^[Yy]$' "$response"
        echo (set_color red)"❌ Installation cancelled"(set_color normal)
        echo ""
        return 0
    end
    
    echo ""
    echo (set_color green)"🚀 Starting installation..."(set_color normal)
    echo ""
    
    set -l success 0
    set -l failed
    set -l current 1
    
    for pkg in $packages
        echo (set_color cyan)"[$current/$total] Installing"(set_color normal) (set_color yellow)"$pkg"(set_color normal)(set_color cyan)"..."(set_color normal)
        
        if pkg $pkg &> /dev/null
            echo "  "(set_color green)"✅ Success"(set_color normal)
            set success (math $success + 1)
        else
            echo "  "(set_color red)"❌ Failed"(set_color normal)
            set -a failed $pkg
        end
        
        echo ""
        set current (math $current + 1)
    end
    
    # Summary
    echo "═══════════════════════════════"
    echo (set_color cyan)"📊 Installation Summary"(set_color normal)
    echo "═══════════════════════════════"
    echo (set_color green)"✅ Successful:"(set_color normal) $success
    echo (set_color red)"❌ Failed:"(set_color normal) (count $failed)
    
    if test (count $failed) -gt 0
        echo ""
        echo (set_color red)"❌ Failed packages:"(set_color normal)
        for pkg in $failed
            echo "  "(set_color yellow)"• $pkg"(set_color normal)
        end
    end
    
    echo ""
end

