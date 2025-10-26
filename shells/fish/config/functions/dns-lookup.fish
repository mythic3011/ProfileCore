function dns-lookup -d "Perform DNS lookup for specified domain and record type"
    if test (count $argv) -lt 1
        echo "Usage: dns-lookup <domain> [record-type]"
        echo "Record types: A, AAAA, MX, TXT, NS, CNAME, SOA, PTR, ALL"
        echo ""
        echo "Examples:"
        echo "  dns-lookup google.com"
        echo "  dns-lookup google.com MX"
        echo "  dns-lookup microsoft.com ALL"
        return 1
    end
    
    set domain $argv[1]
    set record_type "A"
    
    if test (count $argv) -ge 2
        set record_type (string upper $argv[2])
    end
    
    echo ""
    echo -e "\033[0;36m🌐 DNS Lookup: $domain\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    if test "$record_type" = "ALL"
        # Query all common record types
        for type in A AAAA MX TXT NS CNAME SOA
            echo -e "\033[1;33m$type Records:\033[0m"
            dig +short $domain $type | while read line
                echo -e "  \033[0;32m✓\033[0m $line"
            end
            echo ""
        end
    else
        # Query specific record type
        echo -e "\033[1;33m$record_type Records:\033[0m"
        dig +short $domain $record_type | while read line
            echo -e "  \033[0;32m✓\033[0m $line"
        end
        echo ""
    end
end

