//! Generate shell completions
//!
//! Manual completion generation since gumdrop doesn't have clap_complete

pub fn generate(shell: &str) {
    match shell.to_lowercase().as_str() {
        "bash" => print_bash_completions(),
        "zsh" => print_zsh_completions(),
        "fish" => print_fish_completions(),
        "powershell" | "pwsh" => print_powershell_completions(),
        _ => {
            eprintln!("Error: Unsupported shell '{}'", shell);
            eprintln!("Supported: bash, zsh, fish, powershell");
        }
    }
}

fn print_bash_completions() {
    print!(r#"# ProfileCore bash completions
# Installation: profilecore completions bash > ~/.bash_completion.d/profilecore

_profilecore_completions() {{
    local cur prev commands
    cur="${{COMP_WORDS[COMP_CWORD]}}"
    prev="${{COMP_WORDS[COMP_CWORD-1]}}"
    
    # Top-level commands (all 17 command groups)
    commands="init completions system network git docker security package file env text process archive string http data shell utils uninstall-legacy"
    
    # Subcommands (all 97 commands - 100% complete!)
    system_cmds="info uptime processes disk-usage memory cpu load network-stats temperature users service-list service-status"
    network_cmds="public-ip test-port local-ips dns reverse-dns whois trace ping"
    git_cmds="status log diff branch remote switch-account add-account list-accounts whoami clone pull push stash commit tag rebase"
    docker_cmds="ps stats logs"
    security_cmds="ssl-check gen-password check-password hash-password"
    package_cmds="install list search update upgrade remove info"
    file_cmds="hash size find permissions type"
    env_cmds="list get set"
    text_cmds="grep head tail"
    process_cmds="list kill info tree"
    archive_cmds="compress extract list"
    string_cmds="base64 url-encode hash"
    http_cmds="get post download head"
    data_cmds="json yaml-to-json json-to-yaml"
    shell_cmds="history which exec path alias"
    utils_cmds="calc random random-string sleep time timezone version config-get config-set config-list"
    
    case "${{COMP_CWORD}}" in
        1)
            COMPREPLY=($(compgen -W "${{commands}}" -- "${{cur}}"))
            ;;
        2)
            case "${{prev}}" in
                init|completions)
                    COMPREPLY=($(compgen -W "bash zsh fish powershell" -- "${{cur}}"))
                    ;;
                system)
                    COMPREPLY=($(compgen -W "${{system_cmds}}" -- "${{cur}}"))
                    ;;
                network)
                    COMPREPLY=($(compgen -W "${{network_cmds}}" -- "${{cur}}"))
                    ;;
                git)
                    COMPREPLY=($(compgen -W "${{git_cmds}}" -- "${{cur}}"))
                    ;;
                docker)
                    COMPREPLY=($(compgen -W "${{docker_cmds}}" -- "${{cur}}"))
                    ;;
                security)
                    COMPREPLY=($(compgen -W "${{security_cmds}}" -- "${{cur}}"))
                    ;;
                package)
                    COMPREPLY=($(compgen -W "${{package_cmds}}" -- "${{cur}}"))
                    ;;
                file)
                    COMPREPLY=($(compgen -W "${{file_cmds}}" -- "${{cur}}"))
                    ;;
                env)
                    COMPREPLY=($(compgen -W "${{env_cmds}}" -- "${{cur}}"))
                    ;;
                text)
                    COMPREPLY=($(compgen -W "${{text_cmds}}" -- "${{cur}}"))
                    ;;
                process)
                    COMPREPLY=($(compgen -W "${{process_cmds}}" -- "${{cur}}"))
                    ;;
                archive)
                    COMPREPLY=($(compgen -W "${{archive_cmds}}" -- "${{cur}}"))
                    ;;
                string)
                    COMPREPLY=($(compgen -W "${{string_cmds}}" -- "${{cur}}"))
                    ;;
                http)
                    COMPREPLY=($(compgen -W "${{http_cmds}}" -- "${{cur}}"))
                    ;;
                data)
                    COMPREPLY=($(compgen -W "${{data_cmds}}" -- "${{cur}}"))
                    ;;
                shell)
                    COMPREPLY=($(compgen -W "${{shell_cmds}}" -- "${{cur}}"))
                    ;;
                utils)
                    COMPREPLY=($(compgen -W "${{utils_cmds}}" -- "${{cur}}"))
                    ;;
            esac
            ;;
    esac
}}

complete -F _profilecore_completions profilecore
"#);
}

fn print_zsh_completions() {
    print!(r#"#compdef profilecore
# ProfileCore zsh completions

_profilecore() {{
    local -a commands
    commands=(
        'init:Generate shell initialization code'
        'completions:Generate shell completions'
        'system:System information commands'
        'network:Network utility commands'
        'git:Git operations'
        'docker:Docker operations'
        'security:Security tools'
        'package:Package management'
        'file:File operations'
        'env:Environment variables'
        'text:Text processing'
        'process:Process management'
        'archive:Archive operations'
        'string:String utilities'
        'http:HTTP utilities'
        'data:Data processing'
        'shell:Shell utilities'
        'utils:Utility commands'
        'uninstall-legacy:Uninstall v6.0.0 modules'
    )
    
    local -a system_cmds
    system_cmds=(
        'info:Display system information'
        'uptime:Show system uptime'
        'processes:Show top processes'
        'disk-usage:Show disk usage'
        'memory:Show memory information'
        'cpu:Show CPU information'
        'load:Show system load average'
        'network-stats:Show network statistics'
        'temperature:Show temperature sensors'
        'users:List system users'
        'service-list:List system services'
        'service-status:Show service status'
    )
    
    local -a network_cmds
    network_cmds=(
        'public-ip:Get public IP address'
        'test-port:Test port connectivity'
        'local-ips:Get local network IPs'
        'dns:DNS lookup (A/AAAA/MX)'
        'reverse-dns:Reverse DNS (PTR)'
        'whois:WHOIS domain lookup'
        'trace:Traceroute to host'
        'ping:Ping host'
    )
    
    local -a git_cmds
    git_cmds=(
        'status:Show git status'
        'log:Show git log'
        'diff:Show working tree changes'
        'branch:List branches'
        'remote:List remote repositories'
        'switch-account:Switch git account'
        'add-account:Add new git account'
        'list-accounts:List git accounts'
        'whoami:Show current git identity'
        'clone:Clone a repository'
        'pull:Pull from remote'
        'push:Push to remote'
        'stash:Stash changes'
        'commit:Create a commit'
        'tag:Create or list tags'
        'rebase:Rebase current branch'
    )
    
    local -a docker_cmds
    docker_cmds=(
        'ps:List containers'
        'stats:Container stats'
        'logs:Container logs'
    )
    
    local -a security_cmds
    security_cmds=(
        'ssl-check:Check SSL certificate'
        'gen-password:Generate password'
        'check-password:Check password strength'
        'hash-password:Hash password'
    )
    
    local -a package_cmds
    package_cmds=(
        'install:Install package'
        'list:List installed packages'
        'search:Search for packages'
        'update:Update package lists'
        'upgrade:Upgrade package'
        'remove:Remove package'
        'info:Show package information'
    )
    
    local -a file_cmds
    file_cmds=(
        'hash:Calculate file hash'
        'size:Get file/directory size'
        'find:Find files by pattern'
        'permissions:Show file permissions'
        'type:Detect file type'
    )
    
    local -a env_cmds
    env_cmds=(
        'list:List all environment variables'
        'get:Get environment variable'
        'set:Set environment variable'
    )
    
    local -a text_cmds
    text_cmds=(
        'grep:Search text in file'
        'head:Show first N lines'
        'tail:Show last N lines'
    )
    
    local -a process_cmds
    process_cmds=(
        'list:List running processes'
        'kill:Terminate a process'
        'info:Show process information'
        'tree:Show process tree'
    )
    
    local -a archive_cmds
    archive_cmds=(
        'compress:Compress files/directories'
        'extract:Extract archive'
        'list:List archive contents'
    )
    
    local -a string_cmds
    string_cmds=(
        'base64:Base64 encode/decode'
        'url-encode:URL encode/decode'
        'hash:Hash string (MD5/SHA256)'
    )
    
    local -a http_cmds
    http_cmds=(
        'get:HTTP GET request'
        'post:HTTP POST request'
        'download:Download file'
        'head:HTTP HEAD request'
    )
    
    local -a data_cmds
    data_cmds=(
        'json:Format or minify JSON'
        'yaml-to-json:Convert YAML to JSON'
        'json-to-yaml:Convert JSON to YAML'
    )
    
    local -a shell_cmds
    shell_cmds=(
        'history:Show shell history'
        'which:Find command in PATH'
        'exec:Execute command'
        'path:Show PATH variable'
        'alias:List aliases'
    )
    
    local -a utils_cmds
    utils_cmds=(
        'calc:Calculator'
        'random:Random number generator'
        'random-string:Random string generator'
        'sleep:Sleep/delay'
        'time:Show current time'
        'timezone:Show time zones'
        'version:Show version information'
        'config-get:Get configuration value'
        'config-set:Set configuration value'
        'config-list:List configuration'
    )
    
    if (( CURRENT == 2 )); then
        _describe 'command' commands
    elif (( CURRENT == 3 )); then
        case "$words[2]" in
            init|completions)
                _values 'shell' bash zsh fish powershell
                ;;
            system)
                _describe 'system command' system_cmds
                ;;
            network)
                _describe 'network command' network_cmds
                ;;
            git)
                _describe 'git command' git_cmds
                ;;
            docker)
                _describe 'docker command' docker_cmds
                ;;
            security)
                _describe 'security command' security_cmds
                ;;
            package)
                _describe 'package command' package_cmds
                ;;
            file)
                _describe 'file command' file_cmds
                ;;
            env)
                _describe 'env command' env_cmds
                ;;
            text)
                _describe 'text command' text_cmds
                ;;
            process)
                _describe 'process command' process_cmds
                ;;
            archive)
                _describe 'archive command' archive_cmds
                ;;
            string)
                _describe 'string command' string_cmds
                ;;
            http)
                _describe 'http command' http_cmds
                ;;
            data)
                _describe 'data command' data_cmds
                ;;
            shell)
                _describe 'shell command' shell_cmds
                ;;
            utils)
                _describe 'utils command' utils_cmds
                ;;
        esac
    fi
}}

_profilecore
"#);
}

fn print_fish_completions() {
    println!(r#"# ProfileCore fish completions
# Installation: profilecore completions fish > ~/.config/fish/completions/profilecore.fish

# Top-level commands
complete -c profilecore -f -n "__fish_use_subcommand" -a "init" -d "Generate shell initialization code"
complete -c profilecore -f -n "__fish_use_subcommand" -a "completions" -d "Generate shell completions"
complete -c profilecore -f -n "__fish_use_subcommand" -a "system" -d "System information commands"
complete -c profilecore -f -n "__fish_use_subcommand" -a "network" -d "Network utility commands"
complete -c profilecore -f -n "__fish_use_subcommand" -a "git" -d "Git operations"
complete -c profilecore -f -n "__fish_use_subcommand" -a "docker" -d "Docker operations"
complete -c profilecore -f -n "__fish_use_subcommand" -a "security" -d "Security tools"
complete -c profilecore -f -n "__fish_use_subcommand" -a "package" -d "Package management"
complete -c profilecore -f -n "__fish_use_subcommand" -a "file" -d "File operations"
complete -c profilecore -f -n "__fish_use_subcommand" -a "env" -d "Environment variables"
complete -c profilecore -f -n "__fish_use_subcommand" -a "text" -d "Text processing"
complete -c profilecore -f -n "__fish_use_subcommand" -a "process" -d "Process management"
complete -c profilecore -f -n "__fish_use_subcommand" -a "archive" -d "Archive operations"
complete -c profilecore -f -n "__fish_use_subcommand" -a "string" -d "String utilities"
complete -c profilecore -f -n "__fish_use_subcommand" -a "http" -d "HTTP utilities"
complete -c profilecore -f -n "__fish_use_subcommand" -a "data" -d "Data processing"
complete -c profilecore -f -n "__fish_use_subcommand" -a "shell" -d "Shell utilities"
complete -c profilecore -f -n "__fish_use_subcommand" -a "utils" -d "Utility commands"
complete -c profilecore -f -n "__fish_use_subcommand" -a "uninstall-legacy" -d "Uninstall v6.0.0 modules"

# Init/Completions shells
complete -c profilecore -f -n "__fish_seen_subcommand_from init completions" -a "bash zsh fish powershell"

# System subcommands (all 12 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "info" -d "Display system information"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "uptime" -d "Show system uptime"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "processes" -d "Show top processes"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "disk-usage" -d "Show disk usage"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "memory" -d "Show memory information"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "cpu" -d "Show CPU information"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "load" -d "Show system load average"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "network-stats" -d "Show network statistics"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "temperature" -d "Show temperature sensors"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "users" -d "List system users"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "service-list" -d "List system services"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "service-status" -d "Show service status"

# Network subcommands (all 8 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "public-ip" -d "Get public IP address"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "test-port" -d "Test port connectivity"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "local-ips" -d "Get local network IPs"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "dns" -d "DNS lookup"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "reverse-dns" -d "Reverse DNS"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "whois" -d "WHOIS lookup"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "trace" -d "Traceroute"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "ping" -d "Ping host"

# Git subcommands (all 16 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "status" -d "Show git status"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "log" -d "Show git log"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "diff" -d "Show working tree changes"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "branch" -d "List branches"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "remote" -d "List remotes"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "switch-account" -d "Switch git account"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "add-account" -d "Add git account"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "list-accounts" -d "List accounts"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "whoami" -d "Show git identity"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "clone" -d "Clone repository"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "pull" -d "Pull from remote"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "push" -d "Push to remote"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "stash" -d "Stash changes"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "commit" -d "Create commit"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "tag" -d "Create or list tags"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "rebase" -d "Rebase branch"

# Docker subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from docker" -a "ps" -d "List containers"
complete -c profilecore -f -n "__fish_seen_subcommand_from docker" -a "stats" -d "Container stats"
complete -c profilecore -f -n "__fish_seen_subcommand_from docker" -a "logs" -d "Container logs"

# Security subcommands (all 4 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from security" -a "ssl-check" -d "Check SSL certificate"
complete -c profilecore -f -n "__fish_seen_subcommand_from security" -a "gen-password" -d "Generate password"
complete -c profilecore -f -n "__fish_seen_subcommand_from security" -a "check-password" -d "Check password strength"
complete -c profilecore -f -n "__fish_seen_subcommand_from security" -a "hash-password" -d "Hash password"

# Package subcommands (all 7 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "install" -d "Install package"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "list" -d "List installed packages"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "search" -d "Search for packages"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "update" -d "Update package lists"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "upgrade" -d "Upgrade package"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "remove" -d "Remove package"
complete -c profilecore -f -n "__fish_seen_subcommand_from package" -a "info" -d "Show package information"

# File subcommands (all 5 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "hash" -d "Calculate file hash"
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "size" -d "Get file/directory size"
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "find" -d "Find files by pattern"
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "permissions" -d "Show file permissions"
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "type" -d "Detect file type"

# Environment variable subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from env" -a "list" -d "List all environment variables"
complete -c profilecore -f -n "__fish_seen_subcommand_from env" -a "get" -d "Get environment variable"
complete -c profilecore -f -n "__fish_seen_subcommand_from env" -a "set" -d "Set environment variable"

# Text processing subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from text" -a "grep" -d "Search text in file"
complete -c profilecore -f -n "__fish_seen_subcommand_from text" -a "head" -d "Show first N lines"
complete -c profilecore -f -n "__fish_seen_subcommand_from text" -a "tail" -d "Show last N lines"

# Process management subcommands (all 4 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from process" -a "list" -d "List running processes"
complete -c profilecore -f -n "__fish_seen_subcommand_from process" -a "kill" -d "Terminate a process"
complete -c profilecore -f -n "__fish_seen_subcommand_from process" -a "info" -d "Show process information"
complete -c profilecore -f -n "__fish_seen_subcommand_from process" -a "tree" -d "Show process tree"

# Archive operation subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from archive" -a "compress" -d "Compress files/directories"
complete -c profilecore -f -n "__fish_seen_subcommand_from archive" -a "extract" -d "Extract archive"
complete -c profilecore -f -n "__fish_seen_subcommand_from archive" -a "list" -d "List archive contents"

# String utility subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from string" -a "base64" -d "Base64 encode/decode"
complete -c profilecore -f -n "__fish_seen_subcommand_from string" -a "url-encode" -d "URL encode/decode"
complete -c profilecore -f -n "__fish_seen_subcommand_from string" -a "hash" -d "Hash string"

# HTTP utility subcommands (all 4 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from http" -a "get" -d "HTTP GET request"
complete -c profilecore -f -n "__fish_seen_subcommand_from http" -a "post" -d "HTTP POST request"
complete -c profilecore -f -n "__fish_seen_subcommand_from http" -a "download" -d "Download file"
complete -c profilecore -f -n "__fish_seen_subcommand_from http" -a "head" -d "HTTP HEAD request"

# Data processing subcommands (all 3 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from data" -a "json" -d "Format or minify JSON"
complete -c profilecore -f -n "__fish_seen_subcommand_from data" -a "yaml-to-json" -d "Convert YAML to JSON"
complete -c profilecore -f -n "__fish_seen_subcommand_from data" -a "json-to-yaml" -d "Convert JSON to YAML"

# Shell utility subcommands (all 5 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from shell" -a "history" -d "Show shell history"
complete -c profilecore -f -n "__fish_seen_subcommand_from shell" -a "which" -d "Find command in PATH"
complete -c profilecore -f -n "__fish_seen_subcommand_from shell" -a "exec" -d "Execute command"
complete -c profilecore -f -n "__fish_seen_subcommand_from shell" -a "path" -d "Show PATH variable"
complete -c profilecore -f -n "__fish_seen_subcommand_from shell" -a "alias" -d "List aliases"

# Utility command subcommands (all 10 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "calc" -d "Calculator"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "random" -d "Random number generator"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "random-string" -d "Random string generator"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "sleep" -d "Sleep/delay"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "time" -d "Show current time"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "timezone" -d "Show time zones"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "version" -d "Show version information"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "config-get" -d "Get configuration value"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "config-set" -d "Set configuration value"
complete -c profilecore -f -n "__fish_seen_subcommand_from utils" -a "config-list" -d "List configuration"
"#);
}

fn print_powershell_completions() {
    println!(r#"# ProfileCore PowerShell completions
# Installation: Add to $PROFILE: profilecore completions powershell | Out-String | Invoke-Expression

Register-ArgumentCompleter -CommandName profilecore -ScriptBlock {{
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $commands = @(
        @{{ Name = 'init'; Description = 'Generate shell initialization code' }}
        @{{ Name = 'completions'; Description = 'Generate shell completions' }}
        @{{ Name = 'system'; Description = 'System information commands' }}
        @{{ Name = 'network'; Description = 'Network utility commands' }}
        @{{ Name = 'git'; Description = 'Git operations' }}
        @{{ Name = 'docker'; Description = 'Docker operations' }}
        @{{ Name = 'security'; Description = 'Security tools' }}
        @{{ Name = 'package'; Description = 'Package management' }}
        @{{ Name = 'file'; Description = 'File operations' }}
        @{{ Name = 'env'; Description = 'Environment variables' }}
        @{{ Name = 'text'; Description = 'Text processing' }}
        @{{ Name = 'process'; Description = 'Process management' }}
        @{{ Name = 'archive'; Description = 'Archive operations' }}
        @{{ Name = 'string'; Description = 'String utilities' }}
        @{{ Name = 'http'; Description = 'HTTP utilities' }}
        @{{ Name = 'data'; Description = 'Data processing' }}
        @{{ Name = 'shell'; Description = 'Shell utilities' }}
        @{{ Name = 'utils'; Description = 'Utility commands' }}
        @{{ Name = 'uninstall-legacy'; Description = 'Uninstall legacy modules' }}
    )
    
    # All 97 commands
    $systemCmds = @('info', 'uptime', 'processes', 'disk-usage', 'memory', 'cpu', 'load', 'network-stats', 'temperature', 'users', 'service-list', 'service-status')
    $networkCmds = @('public-ip', 'test-port', 'local-ips', 'dns', 'reverse-dns', 'whois', 'trace', 'ping')
    $gitCmds = @('status', 'log', 'diff', 'branch', 'remote', 'switch-account', 'add-account', 'list-accounts', 'whoami', 'clone', 'pull', 'push', 'stash', 'commit', 'tag', 'rebase')
    $dockerCmds = @('ps', 'stats', 'logs')
    $securityCmds = @('ssl-check', 'gen-password', 'check-password', 'hash-password')
    $packageCmds = @('install', 'list', 'search', 'update', 'upgrade', 'remove', 'info')
    $fileCmds = @('hash', 'size', 'find', 'permissions', 'type')
    $envCmds = @('list', 'get', 'set')
    $textCmds = @('grep', 'head', 'tail')
    $processCmds = @('list', 'kill', 'info', 'tree')
    $archiveCmds = @('compress', 'extract', 'list')
    $stringCmds = @('base64', 'url-encode', 'hash')
    $httpCmds = @('get', 'post', 'download', 'head')
    $dataCmds = @('json', 'yaml-to-json', 'json-to-yaml')
    $shellCmds = @('history', 'which', 'exec', 'path', 'alias')
    $utilsCmds = @('calc', 'random', 'random-string', 'sleep', 'time', 'timezone', 'version', 'config-get', 'config-set', 'config-list')
    
    $tokens = $commandAst.ToString().Split(' ')
    
    if ($tokens.Length -eq 2) {{
        $commands | Where-Object {{ $_.Name -like "$wordToComplete*" }} | ForEach-Object {{
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Description)
        }}
    }}
    elseif ($tokens.Length -eq 3) {{
        $subcommands = switch ($tokens[1]) {{
            'system' {{ $systemCmds }}
            'network' {{ $networkCmds }}
            'git' {{ $gitCmds }}
            'docker' {{ $dockerCmds }}
            'security' {{ $securityCmds }}
            'package' {{ $packageCmds }}
            'file' {{ $fileCmds }}
            'env' {{ $envCmds }}
            'text' {{ $textCmds }}
            'process' {{ $processCmds }}
            'archive' {{ $archiveCmds }}
            'string' {{ $stringCmds }}
            'http' {{ $httpCmds }}
            'data' {{ $dataCmds }}
            'shell' {{ $shellCmds }}
            'utils' {{ $utilsCmds }}
            default {{ @() }}
        }}
        
        $subcommands | Where-Object {{ $_ -like "$wordToComplete*" }} | ForEach-Object {{
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }}
    }}
}}
"#);
}
