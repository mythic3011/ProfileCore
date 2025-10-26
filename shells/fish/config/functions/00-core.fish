# MacOS/.config/fish/functions/00-core.fish
# Core functions for Fish - loading shared configuration and environment variables

# Define the shared configuration directory
set -gx SHELL_PROFILE_CONFIG_DIR "$HOME/.config/shell-profile"

# Function to load environment variables from .env file
function load_env
    set env_file "$SHELL_PROFILE_CONFIG_DIR/.env"
    if test -f "$env_file"
        # Read .env file line by line
        while read -l line
            # Skip comments and empty lines
            if string match -qr '^\s*#' -- $line; or test -z "$line"
                continue
            end

            # Split key=value
            set key_value (string split -m 1 '=' -- $line)
            if test (count $key_value) -eq 2
                set key (string trim -- $key_value[1])
                set value (string trim -- $key_value[2])
                # Remove quotes
                set value (string replace -ra '^["\']|["\']$' '' -- $value)
                # Export the variable
                set -gx $key $value
            end
        end < "$env_file"
    else
        echo "⚠️  .env file not found at $env_file. Please create it from env.template."
    end
end

# Function to load a shared JSON configuration file
# Usage: load_config <config_name>
function load_config
    set config_name $argv[1]
    set config_file "$SHELL_PROFILE_CONFIG_DIR/$config_name.json"

    if test -f "$config_file"
        if command -v jq &> /dev/null
            cat "$config_file"
        else
            echo "❌ Error: 'jq' is not installed. Cannot parse JSON configuration." >&2
            echo "Please install 'jq' (e.g., brew install jq)" >&2
            return 1
        end
    else
        echo "❌ Error: Configuration file not found: $config_file" >&2
        return 1
    end
end

# Function to get a specific value from a loaded config
# Usage: get_config_value <json_string> <jq_path>
function get_config_value
    set json_string $argv[1]
    set jq_path $argv[2]
    
    if test -z "$json_string"
        echo "❌ Error: JSON string is empty." >&2
        return 1
    end
    
    if command -v jq &> /dev/null
        echo "$json_string" | jq -r "$jq_path"
    else
        echo "❌ Error: 'jq' is not installed. Cannot parse JSON configuration." >&2
        return 1
    end
end

# Load environment variables on shell start
load_env

# Load shared aliases for Fish
function load_shared_aliases
    set aliases_json (load_config aliases)
    if test -n "$aliases_json"
        set os_type (get_os | string lower)
        
        # Get all aliases that have fish or zsh definitions
        set alias_keys (echo "$aliases_json" | jq -r 'keys[]')
        
        for alias_name in $alias_keys
            # Try fish-specific first, fall back to zsh
            set alias_cmd (echo "$aliases_json" | jq -r ".\"$alias_name\".fish // .\"$alias_name\".zsh // empty")
            
            if test -n "$alias_cmd"; and test "$alias_cmd" != "null"
                alias $alias_name $alias_cmd
            end
        end
    end
end

# Ensure jq is installed for config loading
if not command -v jq &> /dev/null
    echo "❌ Warning: 'jq' is not installed. Some Fish profile features may not work."
    echo "Please install 'jq' (e.g., brew install jq)"
end

