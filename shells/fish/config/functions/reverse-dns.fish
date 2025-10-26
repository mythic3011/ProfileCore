function reverse-dns -d "Perform reverse DNS lookup for IP address"
    if test (count $argv) -lt 1
        echo "Usage: reverse-dns <ip-address>"
        echo ""
        echo "Examples:"
        echo "  reverse-dns 8.8.8.8"
        echo "  reverse-dns 1.1.1.1"
        return 1
    end
    
    set ip $argv[1]
    
    echo ""
    echo -e "\033[0;36m🔍 Reverse DNS Lookup: $ip\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    set -l result (dig +short -x $ip 2>/dev/null)
    
    if test -n "$result"
        echo -e "\033[1;33mHostname:\033[0m"
        echo "$result" | while read line
            echo -e "  \033[0;32m✓\033[0m $line"
        end
    else
        echo -e "\033[0;31m✗ No PTR record found\033[0m"
    end
    
    echo ""
end

