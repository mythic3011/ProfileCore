#!/usr/bin/env fish
# Quick Scan Presets for Fish Shell
# Part of ProfileCore v3.5+ - Phase 1.1

function quick-scan -d "Quick port scan with presets"
    set -l target $argv[1]
    set -l range "top20"
    
    if test (count $argv) -gt 1
        set range $argv[2]
    end
    
    if test -z "$target"
        echo "❌ Usage: quick-scan <target> [top20|top100|web|database]"
        return 1
    end
    
    set -l ports ""
    switch "$range"
        case top20
            set ports "21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080"
        case top100
            set ports "1-100"
        case web
            set ports "80,443,8080,8443,3000,5000,8000"
        case database
            set ports "3306,5432,1433,27017,6379,9200"
        case '*'
            echo "❌ Unknown range: $range"
            return 1
    end
    
    echo (set_color cyan)"🚀 Quick Scan ($range)"(set_color normal)
    scan-port "$target" "$ports"
end

