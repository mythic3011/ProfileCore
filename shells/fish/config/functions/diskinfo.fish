function diskinfo -d "Display disk usage information"
    echo ""
    echo -e "\033[0;36m💾 Disk Usage Information\033[0m"
    echo "═══════════════════════════════════════"
    echo ""
    
    if type -q df
        echo -e "\033[1;33mFilesystem Usage:\033[0m"
        df -h | head -1
        df -h | grep -v "tmpfs" | grep -v "devtmpfs" | tail -n +2
        echo ""
    end
    
    # Show directory sizes in current directory
    echo -e "\033[1;33mTop Directories (Current Location):\033[0m"
    if type -q du
        du -sh */ 2>/dev/null | sort -rh | head -10
    end
    
    echo ""
end

