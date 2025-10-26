function netstat-active -d "Show active network connections"
    set -l filter_port ""
    
    if test (count $argv) -ge 1
        set filter_port $argv[1]
    end
    
    echo ""
    if test -n "$filter_port"
        echo -e "\033[0;36m🌐 Active Connections (Port $filter_port)\033[0m"
    else
        echo -e "\033[0;36m🌐 Active Network Connections\033[0m"
    end
    echo "═══════════════════════════════════════"
    echo ""
    
    if test (uname) = "Darwin"
        # macOS
        if test -n "$filter_port"
            netstat -an | grep ESTABLISHED | grep ":$filter_port"
        else
            netstat -an | grep ESTABLISHED | head -20
        end
    else if test (uname) = "Linux"
        # Linux
        if type -q ss
            if test -n "$filter_port"
                ss -tunap | grep ESTAB | grep ":$filter_port"
            else
                ss -tunap | grep ESTAB | head -20
            end
        else if type -q netstat
            if test -n "$filter_port"
                netstat -an | grep ESTABLISHED | grep ":$filter_port"
            else
                netstat -an | grep ESTABLISHED | head -20
            end
        else
            echo -e "\033[0;31m✗ Error: Neither 'ss' nor 'netstat' command found\033[0m"
            return 1
        end
    end
    
    echo ""
end

