function killp -d "Kill processes by name"
    if test (count $argv) -lt 1
        echo "Usage: killp <process-name> [--force]"
        echo ""
        echo "Examples:"
        echo "  killp chrome"
        echo "  killp node --force"
        return 1
    end
    
    set process_name $argv[1]
    set force_kill false
    
    if test (count $argv) -ge 2; and test "$argv[2]" = "--force"
        set force_kill true
    end
    
    echo ""
    echo -e "\033[0;36m🔫 Killing Processes: $process_name\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    # Find matching processes
    set -l pids (pgrep -i $process_name)
    
    if test -z "$pids"
        echo -e "\033[1;33m⚠️  No processes found matching '$process_name'\033[0m"
        echo ""
        return 1
    end
    
    # Display matching processes
    echo -e "\033[1;33mMatching Processes:\033[0m"
    for pid in $pids
        set -l proc_info (ps -p $pid -o pid=,comm= 2>/dev/null)
        echo -e "  \033[0;90mPID $pid:\033[0m $proc_info"
    end
    echo ""
    
    # Kill processes
    if test "$force_kill" = "true"
        echo -e "\033[0;31mForce killing processes...\033[0m"
        for pid in $pids
            kill -9 $pid 2>/dev/null
            if test $status -eq 0
                echo -e "  \033[0;32m✓\033[0m Killed PID $pid"
            else
                echo -e "  \033[0;31m✗\033[0m Failed to kill PID $pid"
            end
        end
    else
        echo -e "\033[1;33mTerminating processes...\033[0m"
        for pid in $pids
            kill $pid 2>/dev/null
            if test $status -eq 0
                echo -e "  \033[0;32m✓\033[0m Terminated PID $pid"
            else
                echo -e "  \033[0;31m✗\033[0m Failed to terminate PID $pid"
            end
        end
    end
    
    echo ""
end

