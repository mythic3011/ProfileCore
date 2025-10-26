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
    
    # Top-level commands
    commands="init completions system network git docker security package file uninstall-legacy"
    
    # Subcommands (updated with all 39 commands)
    system_cmds="info uptime processes disk-usage memory cpu"
    network_cmds="public-ip test-port local-ips dns reverse-dns whois trace ping"
    git_cmds="status log switch-account add-account list-accounts whoami"
    docker_cmds="ps stats logs"
    security_cmds="ssl-check gen-password check-password hash-password"
    package_cmds="install list search update upgrade remove info"
    file_cmds="hash size"
    
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
        'switch-account:Switch git account'
        'add-account:Add new git account'
        'list-accounts:List git accounts'
        'whoami:Show current git identity'
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
complete -c profilecore -f -n "__fish_use_subcommand" -a "uninstall-legacy" -d "Uninstall v6.0.0 modules"

# Init/Completions shells
complete -c profilecore -f -n "__fish_seen_subcommand_from init completions" -a "bash zsh fish powershell"

# System subcommands (all 6 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "info" -d "Display system information"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "uptime" -d "Show system uptime"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "processes" -d "Show top processes"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "disk-usage" -d "Show disk usage"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "memory" -d "Show memory information"
complete -c profilecore -f -n "__fish_seen_subcommand_from system" -a "cpu" -d "Show CPU information"

# Network subcommands (all 8 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "public-ip" -d "Get public IP address"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "test-port" -d "Test port connectivity"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "local-ips" -d "Get local network IPs"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "dns" -d "DNS lookup"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "reverse-dns" -d "Reverse DNS"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "whois" -d "WHOIS lookup"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "trace" -d "Traceroute"
complete -c profilecore -f -n "__fish_seen_subcommand_from network" -a "ping" -d "Ping host"

# Git subcommands (all 6 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "status" -d "Show git status"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "log" -d "Show git log"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "switch-account" -d "Switch git account"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "add-account" -d "Add git account"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "list-accounts" -d "List accounts"
complete -c profilecore -f -n "__fish_seen_subcommand_from git" -a "whoami" -d "Show git identity"

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

# File subcommands (all 2 commands)
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "hash" -d "Calculate file hash"
complete -c profilecore -f -n "__fish_seen_subcommand_from file" -a "size" -d "Get file/directory size"
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
        @{{ Name = 'uninstall-legacy'; Description = 'Uninstall legacy modules' }}
    )
    
    # All 39 commands
    $systemCmds = @('info', 'uptime', 'processes', 'disk-usage', 'memory', 'cpu')
    $networkCmds = @('public-ip', 'test-port', 'local-ips', 'dns', 'reverse-dns', 'whois', 'trace', 'ping')
    $gitCmds = @('status', 'log', 'switch-account', 'add-account', 'list-accounts', 'whoami')
    $dockerCmds = @('ps', 'stats', 'logs')
    $securityCmds = @('ssl-check', 'gen-password', 'check-password', 'hash-password')
    $packageCmds = @('install', 'list', 'search', 'update', 'upgrade', 'remove', 'info')
    $fileCmds = @('hash', 'size')
    
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
            default {{ @() }}
        }}
        
        $subcommands | Where-Object {{ $_ -like "$wordToComplete*" }} | ForEach-Object {{
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }}
    }}
}}
"#);
}
