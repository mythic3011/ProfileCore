# 00-core.fish
# Core utilities and OS detection for Fish
# Part of ProfileCore v5.0 - Optimized Shell Functions

# ═══════════════════════════════════════════════════════════════════════════
#  PERFORMANCE OPTIMIZATION
# ═══════════════════════════════════════════════════════════════════════════

# Cache variables (Fish uses universal variables for persistence)
set -g PROFILECORE_CACHE_TTL 300

# Function to check cache
function _profilecore_cache_get
    set -l key $argv[1]
    set -l ttl 300
    if set -q argv[2]
        set ttl $argv[2]
    end
    
    set -l cache_var "PROFILECORE_CACHE_$key"
    set -l time_var "PROFILECORE_CACHE_TIME_$key"
    
    if set -q $cache_var
        set -l cache_time $$time_var
        set -l current_time (date +%s)
        
        if test (math "$current_time - $cache_time") -lt $ttl
            echo $$cache_var
            return 0
        end
    end
    return 1
end

# Function to set cache
function _profilecore_cache_set
    set -l key $argv[1]
    set -l value $argv[2]
    
    set -g "PROFILECORE_CACHE_$key" "$value"
    set -g "PROFILECORE_CACHE_TIME_$key" (date +%s)
end

# ═══════════════════════════════════════════════════════════════════════════
#  OS DETECTION
# ═══════════════════════════════════════════════════════════════════════════

# Detect operating system
function get_os
    set -l cached_os (_profilecore_cache_get "os")
    if test -n "$cached_os"
        echo $cached_os
        return 0
    end
    
    set -l os_name
    switch (uname -s)
        case 'Darwin*'
            set os_name "macOS"
        case 'Linux*'
            set os_name "Linux"
        case 'CYGWIN*' 'MINGW*' 'MSYS*'
            set os_name "Windows"
        case '*'
            set os_name "Unknown"
    end
    
    _profilecore_cache_set "os" "$os_name"
    echo $os_name
end

# Check if running on macOS
function is_macos
    test (get_os) = "macOS"
end

# Check if running on Linux
function is_linux
    test (get_os) = "Linux"
end

# Check if running on Windows
function is_windows
    test (get_os) = "Windows"
end

# ═══════════════════════════════════════════════════════════════════════════
#  CONFIGURATION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════

# Configuration directory
set -gx PROFILECORE_CONFIG_DIR "$HOME/.config/shell-profile"
if set -q XDG_CONFIG_HOME
    set PROFILECORE_CONFIG_DIR "$XDG_CONFIG_HOME/shell-profile"
end

# Get config value
function get_config_value
    set -l config_name $argv[1]
    set -l key $argv[2]
    set -l default ""
    if set -q argv[3]
        set default $argv[3]
    end
    
    set -l config_file "$PROFILECORE_CONFIG_DIR/$config_name.json"
    
    if not test -f "$config_file"
        echo $default
        return 0
    end
    
    if command -v jq > /dev/null 2>&1
        set -l value (jq -r ".$key // empty" "$config_file" 2>/dev/null)
        if test -n "$value"
            echo $value
        else
            echo $default
        end
    else
        echo $default
    end
end

# Load environment variables from .env file
function load_env_file
    set -l env_file "$PROFILECORE_CONFIG_DIR/.env"
    if set -q argv[1]
        set env_file $argv[1]
    end
    
    if test -f "$env_file"
        while read -l line
            if string match -qr '^[^#].*=' "$line"
                set -l parts (string split -m 1 '=' "$line")
                set -gx $parts[1] $parts[2]
            end
        end < "$env_file"
    end
end

# ═══════════════════════════════════════════════════════════════════════════
#  UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

# Print colored output
function print_color
    set -l color $argv[1]
    set -l message $argv[2..-1]
    
    switch $color
        case red
            set_color red
        case green
            set_color green
        case yellow
            set_color yellow
        case blue
            set_color blue
        case magenta
            set_color magenta
        case cyan
            set_color cyan
        case white
            set_color white
        case '*'
            set_color normal
    end
    
    echo $message
    set_color normal
end

# Check if command exists
function command_exists
    command -v $argv[1] > /dev/null 2>&1
end

# Check if running with sudo/root
function is_root
    test (id -u) -eq 0
end

# ═══════════════════════════════════════════════════════════════════════════
#  INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════

# Create config directory if it doesn't exist
if not test -d "$PROFILECORE_CONFIG_DIR"
    mkdir -p "$PROFILECORE_CONFIG_DIR"
end

# Load environment variables
load_env_file

# Mark as loaded
set -gx PROFILECORE_CORE_LOADED 1

