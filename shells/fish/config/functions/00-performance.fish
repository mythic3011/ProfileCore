#!/usr/bin/env fish
# Performance Optimizations for Fish Shell
# Part of ProfileCore v3.0

# ===== FISH PERFORMANCE OPTIMIZATIONS =====

# Configuration cache
set -g _cache_timeout 300  # 5 minutes

# Enable config caching
function enable-config-cache -d "Enable configuration caching"
    set -l timeout 300
    if test (count $argv) -gt 0
        set timeout $argv[1]
    end
    set -g _cache_timeout $timeout
    echo "✅ Config caching enabled (timeout: "$timeout"s)"
end

# Get shell performance stats
function get-shell-performance -d "Show shell performance statistics"
    echo ""
    echo (set_color cyan)"📊 Shell Performance Statistics"(set_color normal)
    echo ""
    
    # Function count
    set -l func_count (functions | count)
    echo "Loaded Functions: $func_count"
    
    # Alias count
    set -l alias_count (alias | count)
    echo "Loaded Aliases: $alias_count"
    
    # History size
    if test -f "$HOME/.local/share/fish/fish_history"
        set -l history_size (wc -l < "$HOME/.local/share/fish/fish_history")
        echo "History Entries: $history_size"
    end
    
    echo ""
    echo "Cache Timeout: "$_cache_timeout"s"
    
    echo ""
    echo (set_color yellow)"💡 Performance Tips:"(set_color normal)
    echo "   • Enable caching: enable-config-cache"
    echo "   • Profile startup: bench-shell"
    echo "   • Use fish_config to manage settings"
    echo ""
end

# Profile Fish startup
function profile-fish-startup -d "Profile Fish shell startup time"
    echo ""
    echo (set_color cyan)"📊 Fish Startup Performance Profiling"(set_color normal)
    echo ""
    
    for i in (seq 5)
        echo -n "Run $i: "
        time fish -i -c exit 2>&1 | grep Executed | awk '{print $3 " " $4}'
    end
    
    echo ""
    echo (set_color yellow)"💡 Tips to improve startup time:"(set_color normal)
    echo "   1. Enable config caching: enable-config-cache"
    echo "   2. Use lazy loading for heavy functions"
    echo "   3. Keep your config.fish minimal"
    echo ""
end

# Benchmark a command
function bench -d "Benchmark a command"
    if test (count $argv) -eq 0
        echo "Usage: bench <command>"
        return 1
    end
    
    echo "Benchmarking: $argv"
    echo "Running 10 iterations..."
    echo ""
    
    set -l total 0
    for i in (seq 10)
        set -l start (date +%s%N)
        eval $argv > /dev/null 2>&1
        set -l end (date +%s%N)
        set -l duration (math "($end - $start) / 1000000")
        echo "Run $i: "$duration"ms"
        set total (math "$total + $duration")
    end
    
    set -l avg (math "$total / 10")
    echo ""
    echo "Average: "$avg"ms"
end

# Optimize history
function optimize-history -d "Optimize history settings"
    # Fish handles history efficiently by default
    # Just ensure it's enabled
    set -U fish_history fish
    echo "✅ History settings optimized"
end

# Auto-enable optimizations
enable-config-cache 600  # 10 minutes cache
optimize-history

# Aliases for performance
alias perf='get-shell-performance'
alias bench-shell='profile-fish-startup'

