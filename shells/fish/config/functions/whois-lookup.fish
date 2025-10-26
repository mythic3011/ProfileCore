function whois-lookup -d "Perform WHOIS lookup for domain"
    if test (count $argv) -lt 1
        echo "Usage: whois-lookup <domain>"
        echo ""
        echo "Examples:"
        echo "  whois-lookup example.com"
        echo "  whois-lookup github.com"
        return 1
    end
    
    set domain $argv[1]
    
    # Check if whois is installed
    if not type -q whois
        echo -e "\033[0;31m✗ Error: 'whois' command not found\033[0m"
        echo ""
        echo "Install whois:"
        echo "  macOS:  brew install whois"
        echo "  Linux:  sudo apt install whois  # Debian/Ubuntu"
        echo "          sudo dnf install whois  # Fedora"
        return 1
    end
    
    echo ""
    echo -e "\033[0;36m📝 WHOIS Lookup: $domain\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    set -l whois_output (whois $domain 2>/dev/null)
    
    if test -z "$whois_output"
        echo -e "\033[0;31m✗ No WHOIS data found\033[0m"
        echo ""
        return 1
    end
    
    # Extract and display key information
    echo -e "\033[1;33mDomain Information:\033[0m"
    echo "$whois_output" | grep -i "domain name:" | head -1
    echo ""
    
    echo -e "\033[1;33mRegistrar:\033[0m"
    echo "$whois_output" | grep -i "registrar:" | head -1
    echo ""
    
    echo -e "\033[1;33mRegistration Dates:\033[0m"
    echo "$whois_output" | grep -i "creation date:" | head -1
    echo "$whois_output" | grep -i "expir" | head -1
    echo "$whois_output" | grep -i "updated date:" | head -1
    echo ""
    
    echo -e "\033[1;33mName Servers:\033[0m"
    echo "$whois_output" | grep -i "name server:" | head -5
    echo ""
    
    echo -e "\033[0;36m💡 Tip: Use 'whois $domain' for full output\033[0m"
    echo ""
end

