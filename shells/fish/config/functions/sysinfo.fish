function sysinfo -d "Display comprehensive system information"
    echo ""
    echo -e "\033[0;36m💻 System Information\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    # OS Information
    echo -e "\033[1;33m🖥️  Operating System:\033[0m"
    if test (uname) = "Darwin"
        echo -e "  OS: \033[1;37mmacOS\033[0m"
        echo -e "  Version: \033[1;37m"(sw_vers -productVersion)"\033[0m"
        echo -e "  Build: \033[1;37m"(sw_vers -buildVersion)"\033[0m"
    else if test (uname) = "Linux"
        echo -e "  OS: \033[1;37mLinux\033[0m"
        if test -f /etc/os-release
            set -l distro (grep "^NAME=" /etc/os-release | cut -d'"' -f2)
            set -l version (grep "^VERSION=" /etc/os-release | cut -d'"' -f2)
            echo -e "  Distribution: \033[1;37m$distro\033[0m"
            if test -n "$version"
                echo -e "  Version: \033[1;37m$version\033[0m"
            end
        end
        echo -e "  Kernel: \033[1;37m"(uname -r)"\033[0m"
    end
    echo ""
    
    # Hardware Information
    echo -e "\033[1;33m🔧 Hardware:\033[0m"
    if test (uname) = "Darwin"
        echo -e "  Model: \033[1;37m"(sysctl -n hw.model)"\033[0m"
        set -l cpu (sysctl -n machdep.cpu.brand_string)
        echo -e "  CPU: \033[1;37m$cpu\033[0m"
        set -l cores (sysctl -n hw.ncpu)
        echo -e "  Cores: \033[1;37m$cores\033[0m"
    else if test (uname) = "Linux"
        if test -f /proc/cpuinfo
            set -l cpu (grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | string trim)
            echo -e "  CPU: \033[1;37m$cpu\033[0m"
            set -l cores (grep -c "^processor" /proc/cpuinfo)
            echo -e "  Cores: \033[1;37m$cores\033[0m"
        end
    end
    echo ""
    
    # Memory Information
    echo -e "\033[1;33m💾 Memory:\033[0m"
    if test (uname) = "Darwin"
        set -l total_mem (sysctl -n hw.memsize)
        set -l total_gb (math "$total_mem / 1024 / 1024 / 1024")
        echo -e "  Total: \033[1;37m$total_gb GB\033[0m"
    else if test (uname) = "Linux"
        if type -q free
            set -l mem_info (free -h | grep "^Mem:")
            set -l total (echo $mem_info | awk '{print $2}')
            set -l used (echo $mem_info | awk '{print $3}')
            set -l available (echo $mem_info | awk '{print $7}')
            echo -e "  Total: \033[1;37m$total\033[0m"
            echo -e "  Used: \033[1;37m$used\033[0m"
            echo -e "  Available: \033[1;37m$available\033[0m"
        end
    end
    echo ""
    
    # Shell Information
    echo -e "\033[1;33m🐚 Shell:\033[0m"
    echo -e "  Current: \033[1;37mFish "(fish --version)"\033[0m"
    echo -e "  Path: \033[1;37m"(which fish)"\033[0m"
    echo ""
    
    # Uptime
    echo -e "\033[1;33m⏱️  Uptime:\033[0m"
    if type -q uptime
        echo -e "  \033[1;37m"(uptime)"\033[0m"
    end
    echo ""
end

