function dns-propagation -d "Check DNS propagation across multiple nameservers"
    if test (count $argv) -lt 1
        echo "Usage: dns-propagation <domain> [record-type]"
        echo ""
        echo "Examples:"
        echo "  dns-propagation example.com"
        echo "  dns-propagation example.com MX"
        return 1
    end
    
    set domain $argv[1]
    set record_type "A"
    
    if test (count $argv) -ge 2
        set record_type (string upper $argv[2])
    end
    
    echo ""
    echo -e "\033[0;36m🌍 DNS Propagation Check: $domain ($record_type)\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    # Public DNS servers
    set -l nameservers \
        "8.8.8.8:Google" \
        "1.1.1.1:Cloudflare" \
        "208.67.222.222:OpenDNS" \
        "9.9.9.9:Quad9"
    
    for ns in $nameservers
        set -l parts (string split ':' $ns)
        set -l ip $parts[1]
        set -l name $parts[2]
        
        echo -n -e "\033[1;33m$name ($ip):\033[0m "
        set -l result (dig @$ip +short $domain $record_type 2>/dev/null)
        
        if test -n "$result"
            echo -e "\033[0;32m✓\033[0m"
            echo "$result" | while read line
                echo -e "  \033[0;90m→\033[0m $line"
            end
        else
            echo -e "\033[0;31m✗ No response\033[0m"
        end
        echo ""
    end
end

