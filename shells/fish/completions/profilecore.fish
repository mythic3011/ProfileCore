# ProfileCore Fish Shell Completions
# Provides tab completion for ProfileCore commands
# Author: ProfileCore Team

# ===================================================================
# Main profilecore command completions
# ===================================================================

# Basic options
complete -c profilecore -s h -l help -d 'Show help information'
complete -c profilecore -s v -l version -d 'Show ProfileCore version'
complete -c profilecore -l verbose -d 'Enable verbose output'
complete -c profilecore -l quiet -d 'Suppress output messages'

# Subcommands
complete -c profilecore -n "__fish_use_subcommand" -a update -d 'Update ProfileCore'
complete -c profilecore -n "__fish_use_subcommand" -a status -d 'Show ProfileCore status'
complete -c profilecore -n "__fish_use_subcommand" -a config -d 'Manage configuration'
complete -c profilecore -n "__fish_use_subcommand" -a plugin -d 'Manage plugins'
complete -c profilecore -n "__fish_use_subcommand" -a cache -d 'Manage cache'
complete -c profilecore -n "__fish_use_subcommand" -a doctor -d 'Check system health'
complete -c profilecore -n "__fish_use_subcommand" -a uninstall -d 'Uninstall ProfileCore'

# Update subcommand options
complete -c profilecore -n "__fish_seen_subcommand_from update" -s f -l force -d 'Force update'
complete -c profilecore -n "__fish_seen_subcommand_from update" -l check -d 'Check for updates'
complete -c profilecore -n "__fish_seen_subcommand_from update" -l no-backup -d 'Skip backup'

# Config subcommand options
complete -c profilecore -n "__fish_seen_subcommand_from config" -a "get set list edit reset" -d 'Config action'

# Plugin subcommand options
complete -c profilecore -n "__fish_seen_subcommand_from plugin" -a "list enable disable install uninstall" -d 'Plugin action'

# Cache subcommand options
complete -c profilecore -n "__fish_seen_subcommand_from cache" -a "clear stats optimize" -d 'Cache action'

# ===================================================================
# Package management completions
# ===================================================================

# pkg install
complete -c pkg -n "__fish_use_subcommand" -a install -d 'Install package'
complete -c pkg -n "__fish_seen_subcommand_from install" -s y -l yes -d 'Assume yes'
complete -c pkg -n "__fish_seen_subcommand_from install" -l global -d 'Install globally'

# pkg search (pkgs)
complete -c pkgs -a '(__fish_complete_packages)'

# pkg update
complete -c pkgu -s a -l all -d 'Update all packages'
complete -c pkgu -l check -d 'Check for updates'

# pkg remove
complete -c pkg -n "__fish_use_subcommand" -a remove -d 'Remove package'
complete -c pkg -n "__fish_seen_subcommand_from remove" -a '(__fish_print_packages)'

# pkg list
complete -c pkg -n "__fish_use_subcommand" -a list -d 'List installed packages'
complete -c pkg -n "__fish_seen_subcommand_from list" -l outdated -d 'Show outdated packages'

# ===================================================================
# Network tools completions
# ===================================================================

# myip
complete -c myip -s c -l copy -d 'Copy IP to clipboard'
complete -c myip -s 4 -l ipv4 -d 'Show IPv4 only'
complete -c myip -s 6 -l ipv6 -d 'Show IPv6 only'

# netstat_listen
complete -c netstat_listen -s t -l tcp -d 'Show TCP only'
complete -c netstat_listen -s u -l udp -d 'Show UDP only'

# checkport
complete -c checkport -s t -l timeout -d 'Connection timeout' -r
complete -c checkport -s v -l verbose -d 'Verbose output'

# ===================================================================
# Git tools completions
# ===================================================================

# git_info
complete -c git_info -s v -l verbose -d 'Show detailed information'
complete -c git_info -s r -l remote -d 'Include remote information'

# git_branch_cleanup
complete -c git_branch_cleanup -s f -l force -d 'Force deletion'
complete -c git_branch_cleanup -s d -l dry-run -d 'Show what would be deleted'
complete -c git_branch_cleanup -s a -l all -d 'Include remote branches'

# git_commit_stats
complete -c git_commit_stats -s a -l author -d 'Filter by author' -r
complete -c git_commit_stats -s s -l since -d 'Show commits since date' -r
complete -c git_commit_stats -s u -l until -d 'Show commits until date' -r

# ===================================================================
# Docker tools completions
# ===================================================================

# docker_cleanup
complete -c docker_cleanup -s a -l all -d 'Remove all unused data'
complete -c docker_cleanup -s v -l volumes -d 'Remove volumes'
complete -c docker_cleanup -s f -l force -d 'Do not prompt'

# docker_ps
complete -c docker_ps -s a -l all -d 'Show all containers'
complete -c docker_ps -s q -l quiet -d 'Only show IDs'

# ===================================================================
# System tools completions
# ===================================================================

# disk_usage
complete -c disk_usage -s h -l human -d 'Human readable format'
complete -c disk_usage -s a -l all -d 'Show all filesystems'
complete -c disk_usage -s t -l type -d 'Filesystem type' -r

# process_monitor
complete -c process_monitor -s t -l top -d 'Show top processes' -r
complete -c process_monitor -s u -l user -d 'Filter by user' -r

# ===================================================================
# Path and environment completions
# ===================================================================

# path_add
complete -c path_add -s p -l prepend -d 'Prepend to PATH'
complete -c path_add -s a -l append -d 'Append to PATH'
complete -c path_add -s f -l force -d 'Add even if already exists'

# path_remove
complete -c path_remove -a '(__fish_complete_directories)'

# ===================================================================
# Helper functions
# ===================================================================

function __fish_complete_packages
    # This would need to be implemented based on the active package manager
    # For now, return empty
    return 0
end

function __fish_print_packages
    # This would list installed packages
    # Implementation depends on the package manager
    return 0
end

# ===================================================================
# ProfileCore specific completions
# ===================================================================

# Completion for plugin names
function __fish_profilecore_plugins
    if test -d ~/.profilecore/plugins
        command ls -1 ~/.profilecore/plugins 2>/dev/null
    end
end

complete -c profilecore -n "__fish_seen_subcommand_from plugin" -n "__fish_seen_subcommand_from enable disable uninstall" -a '(__fish_profilecore_plugins)' -d 'Plugin name'

# Completion for config keys
function __fish_profilecore_config_keys
    echo "shell"
    echo "theme"
    echo "auto_update"
    echo "check_interval"
    echo "backup_enabled"
    echo "cache_ttl"
end

complete -c profilecore -n "__fish_seen_subcommand_from config" -n "__fish_seen_subcommand_from get set" -a '(__fish_profilecore_config_keys)' -d 'Config key'

