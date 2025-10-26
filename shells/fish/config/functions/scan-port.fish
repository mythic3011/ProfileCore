#!/usr/bin/env fish
# Port Scanner for Fish Shell
# Part of ProfileCore v3.5+ - Phase 1.1

function scan-port -d "Advanced port scanner"
    set -l target $argv[1]
    set -l ports $argv[2]
    set -l timeout 1
    
    if test (count $argv) -gt 2
        set timeout $argv[3]
    end
    
    if test -z "$target"; or test -z "$ports"
        echo "❌ Usage: scan-port <target> <port|port-range> [timeout]"
        echo "Examples:"
        echo "  scan-port 192.168.1.1 80"
        echo "  scan-port example.com 1-1000"
        echo "  scan-port localhost 22,80,443"
        return 1
    end
    
    echo ""
    echo (set_color cyan)"🔍 Port Scan Report"(set_color normal)
    echo "═══════════════════════════════════════"
    echo (set_color white)"Target:"(set_color normal) (set_color yellow)"$target"(set_color normal)
    echo (set_color white)"Timeout:"(set_color normal) (set_color yellow)"$timeout"s(set_color normal)
    echo ""
    
    # Common services
    set -l services_20 "FTP-Data"
    set -l services_21 "FTP"
    set -l services_22 "SSH"
    set -l services_23 "Telnet"
    set -l services_25 "SMTP"
    set -l services_53 "DNS"
    set -l services_80 "HTTP"
    set -l services_110 "POP3"
    set -l services_143 "IMAP"
    set -l services_443 "HTTPS"
    set -l services_445 "SMB"
    set -l services_3306 "MySQL"
    set -l services_3389 "RDP"
    set -l services_5432 "PostgreSQL"
    set -l services_6379 "Redis"
    set -l services_27017 "MongoDB"
    set -l services_8080 "HTTP-Alt"
    set -l services_8443 "HTTPS-Alt"
    set -l services_9200 "Elasticsearch"
    
    set -l open_count 0
    set -l closed_count 0
    set -l port_list
    
    # Parse port specification
    if string match -q "*-*" -- "$ports"
        # Port range
        set -l range (string split "-" "$ports")
        set port_list (seq $range[1] $range[2])
    else if string match -q "*,*" -- "$ports"
        # Comma-separated
        set port_list (string split "," "$ports")
    else
        # Single port
        set port_list $ports
    end
    
    # Scan ports
    for port in $port_list
        if command -v nc &> /dev/null
            if nc -z -w"$timeout" "$target" "$port" 2>/dev/null
                set open_count (math $open_count + 1)
                set -l service_var "services_$port"
                set -l service "Unknown"
                if set -q $service_var
                    set service $$service_var
                end
                echo "  "(set_color brblack)"[$port]"(set_color normal) (set_color green)"OPEN"(set_color normal) "- "(set_color cyan)"$service"(set_color normal)
            else
                set closed_count (math $closed_count + 1)
            end
        else
            # Fallback (less reliable on Fish)
            set closed_count (math $closed_count + 1)
        end
    end
    
    # Summary
    echo ""
    echo "═══════════════════════════════════════"
    echo (set_color cyan)"📊 Scan Summary"(set_color normal)
    echo (set_color white)"Open Ports:"(set_color normal) (set_color green)"$open_count"(set_color normal)
    echo (set_color white)"Closed Ports:"(set_color normal) (set_color red)"$closed_count"(set_color normal)
    echo (set_color white)"Total Scanned:"(set_color normal) (set_color yellow)(count $port_list)(set_color normal)
    echo ""
end

