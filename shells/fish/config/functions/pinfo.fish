function pinfo -d "Show top processes by CPU or Memory usage"
    set -l count 10
    set -l sort_by "CPU"
    
    if test (count $argv) -ge 1
        set count $argv[1]
    end
    
    if test (count $argv) -ge 2
        set sort_by (string upper $argv[2])
    end
    
    echo ""
    echo -e "\033[0;36m📊 Top $count Processes by $sort_by\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    if test "$sort_by" = "MEMORY"; or test "$sort_by" = "MEM"
        # Sort by memory
        if test (uname) = "Darwin"
            ps aux | head -1
            ps aux | tail -n +2 | sort -k4 -rn | head -n $count
        else
            ps aux | head -1
            ps aux | tail -n +2 | sort -k4 -rn | head -n $count
        end
    else
        # Sort by CPU (default)
        if test (uname) = "Darwin"
            ps aux | head -1
            ps aux | tail -n +2 | sort -k3 -rn | head -n $count
        else
            ps aux | head -1
            ps aux | tail -n +2 | sort -k3 -rn | head -n $count
        end
    end
    
    echo ""
end

