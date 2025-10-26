//! Generate shell-specific initialization code
//! 
//! Similar to Starship's approach - minimal shell wrappers that call the binary

pub fn generate(shell: &str) {
    match shell.to_lowercase().as_str() {
        "bash" => print_bash_init(),
        "zsh" => print_zsh_init(),
        "fish" => print_fish_init(),
        "powershell" | "pwsh" => print_powershell_init(),
        _ => {
            eprintln!("Error: Unsupported shell '{}'", shell);
            eprintln!("Supported: bash, zsh, fish, powershell");
        }
    }
}

fn print_bash_init() {
    println!(r#"# ProfileCore v1.0.0 - Bash Integration

# System Info
alias sysinfo='profilecore system info'

# Network Tools
alias publicip='profilecore network public-ip'
alias testport='profilecore network test-port'
alias localips='profilecore network local-ips'

# Git Operations
alias gitstatus='profilecore git status'
git-switch() {{
    profilecore git switch-account "$1"
}}

# Docker
alias dps='profilecore docker ps'

# Security
alias sslcheck='profilecore security ssl-check'
genpass() {{
    profilecore security gen-password --length="${{1:-16}}"
}}

# Package Management
pkginstall() {{
    profilecore package install "$1"
}}

# Load completions
if command -v profilecore &> /dev/null; then
    eval "$(profilecore completions bash)"
fi
"#);
}

fn print_zsh_init() {
    println!(r#"# ProfileCore v1.0.0 - Zsh Integration

# System Info
alias sysinfo='profilecore system info'

# Network Tools
alias publicip='profilecore network public-ip'
alias testport='profilecore network test-port'
alias localips='profilecore network local-ips'

# Git Operations
alias gitstatus='profilecore git status'
git-switch() {{
    profilecore git switch-account "$1"
}}

# Docker
alias dps='profilecore docker ps'

# Security
alias sslcheck='profilecore security ssl-check'
genpass() {{
    profilecore security gen-password --length="${{1:-16}}"
}}

# Package Management
pkginstall() {{
    profilecore package install "$1"
}}

# Load completions
if command -v profilecore &> /dev/null; then
    eval "$(profilecore completions zsh)"
fi
"#);
}

fn print_fish_init() {
    println!(r#"# ProfileCore v1.0.0 - Fish Integration

# System Info
alias sysinfo='profilecore system info'

# Network Tools
alias publicip='profilecore network public-ip'
alias testport='profilecore network test-port'
alias localips='profilecore network local-ips'

# Git Operations
alias gitstatus='profilecore git status'
function git-switch
    profilecore git switch-account $argv[1]
end

# Docker
alias dps='profilecore docker ps'

# Security
alias sslcheck='profilecore security ssl-check'
function genpass
    set -l length $argv[1]
    if test -z "$length"
        set length 16
    end
    profilecore security gen-password --length=$length
end

# Package Management
function pkginstall
    profilecore package install $argv[1]
end

# Load completions
if command -v profilecore > /dev/null
    profilecore completions fish | source
end
"#);
}

fn print_powershell_init() {
    println!(r#"# ProfileCore v1.0.0 - PowerShell Integration

# System Info
function sysinfo {{ profilecore system info }}

# Network Tools
function publicip {{ profilecore network public-ip }}
function testport {{ param($host, $port=80); profilecore network test-port $host $port }}
function localips {{ profilecore network local-ips }}

# Git Operations
function gitstatus {{ profilecore git status }}
function git-switch {{ param($account); profilecore git switch-account $account }}

# Docker
function dps {{ profilecore docker ps }}

# Security
function sslcheck {{ param($domain); profilecore security ssl-check $domain }}
function genpass {{ param($length=16); profilecore security gen-password --length $length }}

# Package Management
function pkginstall {{ param($package); profilecore package install $package }}

# Load completions (if supported)
if (Get-Command profilecore -ErrorAction SilentlyContinue) {{
    # PowerShell completions would go here
}}

Write-Host "ProfileCore v1.0.0 loaded" -ForegroundColor Green
"#);
}

