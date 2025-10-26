//! ProfileCore v1.0.0 - Unified Cross-Shell Interface
//!
//! Smart wrapper around mature tools (git2, bollard, rustls, etc.)
//! Fast startup with gumdrop parsing (~160ns vs clap's 5-10ms)

use gumdrop::Options;
use std::process;

// Import command modules
mod commands;
mod init;
mod completions;
mod config;

#[derive(Options)]
struct Cli {
    #[options(help = "show help message")]
    help: bool,
    
    #[options(help = "show version")]
    version: bool,
    
    #[options(command)]
    command: Option<Command>,
}

#[derive(Options)]
enum Command {
    #[options(help = "generate shell-specific initialization code")]
    Init(InitOpts),
    
    #[options(help = "generate shell completions")]
    Completions(CompletionsOpts),
    
    #[options(help = "system information commands")]
    System(SystemOpts),
    
    #[options(help = "network utility commands")]
    Network(NetworkOpts),
    
    #[options(help = "git operations")]
    Git(GitOpts),
    
    #[options(help = "docker operations")]
    Docker(DockerOpts),
    
    #[options(help = "security tools")]
    Security(SecurityOpts),
    
    #[options(help = "package management")]
    Package(PackageOpts),
    
    #[options(help = "file operations")]
    File(FileOpts),
    
    #[options(help = "uninstall legacy v6.0.0 PowerShell modules")]
    UninstallLegacy(UninstallOpts),
}

#[derive(Options)]
struct InitOpts {
    #[options(help = "show help for init")]
    help: bool,
    
    #[options(free, help = "target shell: bash, zsh, fish, powershell")]
        shell: String,
}

#[derive(Options)]
struct CompletionsOpts {
    #[options(help = "show help for completions")]
    help: bool,
    
    #[options(free, help = "target shell: bash, zsh, fish, powershell")]
        shell: String,
}

#[derive(Options)]
struct SystemOpts {
    #[options(help = "show help for system")]
    help: bool,
    
    #[options(command)]
    command: Option<SystemCmd>,
}

#[derive(Options)]
enum SystemCmd {
    #[options(help = "display system information")]
    Info(InfoOpts),
    
    #[options(help = "show system uptime")]
    Uptime(UptimeOpts),
    
    #[options(help = "show top processes")]
    Processes(ProcessesOpts),
    
    #[options(help = "show disk usage")]
    DiskUsage(DiskUsageOpts),
    
    #[options(help = "show memory information")]
    Memory(MemoryOpts),
    
    #[options(help = "show CPU information")]
    Cpu(CpuOpts),
}

#[derive(Options)]
struct InfoOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(help = "output format: text, json")]
    format: Option<String>,
}

#[derive(Options)]
struct UptimeOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct ProcessesOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(help = "number of processes to show", default = "10", meta = "N")]
    limit: usize,
}

#[derive(Options)]
struct DiskUsageOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct MemoryOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct CpuOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct NetworkOpts {
    #[options(help = "show help for network")]
    help: bool,
    
    #[options(command)]
    command: Option<NetworkCmd>,
}

#[derive(Options)]
enum NetworkCmd {
    #[options(help = "get public IP address")]
    PublicIp(PublicIpOpts),
    
    #[options(help = "test port connectivity")]
    TestPort(TestPortOpts),
    
    #[options(help = "get local network IPs")]
    LocalIps(LocalIpsOpts),
    
    #[options(help = "DNS lookup (A, AAAA, MX records)")]
    Dns(DnsOpts),
    
    #[options(help = "reverse DNS lookup (PTR records)")]
    ReverseDns(ReverseDnsOpts),
    
    #[options(help = "WHOIS domain lookup")]
    Whois(WhoisOpts),
    
    #[options(help = "traceroute to host")]
    Trace(TraceOpts),
    
    #[options(help = "ping host")]
    Ping(PingOpts),
}

#[derive(Options)]
struct PublicIpOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct TestPortOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "host to test")]
    host: String,
    
    #[options(free, help = "port to test")]
    port: Option<u16>,
}

#[derive(Options)]
struct LocalIpsOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct DnsOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "domain name to lookup")]
    domain: String,
}

#[derive(Options)]
struct ReverseDnsOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "IP address for reverse lookup")]
    ip: String,
}

#[derive(Options)]
struct WhoisOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "domain to lookup")]
    domain: String,
}

#[derive(Options)]
struct TraceOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "host to traceroute")]
    host: String,
    
    #[options(help = "maximum hops", default = "30", meta = "N")]
    max_hops: u32,
}

#[derive(Options)]
struct PingOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "host to ping")]
    host: String,
    
    #[options(help = "number of packets", default = "4", meta = "N")]
    count: u32,
}

#[derive(Options)]
struct GitOpts {
    #[options(help = "show help for git")]
    help: bool,
    
    #[options(command)]
    command: Option<GitCmd>,
}

#[derive(Options)]
enum GitCmd {
    #[options(help = "show git status")]
    Status(GitStatusOpts),
    
    #[options(help = "show git log")]
    Log(GitLogOpts),
    
    #[options(help = "switch git account")]
    SwitchAccount(SwitchAccountOpts),
    
    #[options(help = "add a new git account")]
    AddAccount(AddAccountOpts),
    
    #[options(help = "list all git accounts")]
    ListAccounts(ListAccountsOpts),
    
    #[options(help = "show current git identity")]
    Whoami(WhoamiOpts),
}

#[derive(Options)]
struct GitStatusOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct GitLogOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(help = "number of commits to show", default = "10", meta = "N")]
    limit: usize,
}

#[derive(Options)]
struct SwitchAccountOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "account name")]
    account: String,
}

#[derive(Options)]
struct AddAccountOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "account name")]
    name: String,
    
    #[options(free, help = "email address")]
    email: String,
    
    #[options(help = "GPG/SSH signing key", meta = "KEY")]
    signing_key: Option<String>,
}

#[derive(Options)]
struct ListAccountsOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct WhoamiOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct DockerOpts {
    #[options(help = "show help for docker")]
    help: bool,
    
    #[options(command)]
    command: Option<DockerCmd>,
}

#[derive(Options)]
enum DockerCmd {
    #[options(help = "list docker containers")]
    Ps(DockerPsOpts),
    
    #[options(help = "show container stats")]
    Stats(StatsOpts),
    
    #[options(help = "show container logs")]
    Logs(LogsOpts),
}

#[derive(Options)]
struct DockerPsOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct StatsOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "container name or ID")]
    container: String,
}

#[derive(Options)]
struct LogsOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "container name or ID")]
    container: String,
    
    #[options(help = "number of lines to show", default = "50", meta = "N")]
    lines: usize,
}

#[derive(Options)]
struct SecurityOpts {
    #[options(help = "show help for security")]
    help: bool,
    
    #[options(command)]
    command: Option<SecurityCmd>,
}

#[derive(Options)]
enum SecurityCmd {
    #[options(help = "check SSL certificate")]
    SslCheck(SslCheckOpts),
    
    #[options(help = "generate password")]
    GenPassword(GenPasswordOpts),
    
    #[options(help = "check password strength")]
    CheckPassword(CheckPasswordOpts),
    
    #[options(help = "hash password (argon2/bcrypt)")]
    HashPassword(HashPasswordOpts),
}

#[derive(Options)]
struct SslCheckOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "domain to check")]
    domain: String,
}

#[derive(Options)]
struct GenPasswordOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(help = "password length", default = "16")]
    length: usize,
}

#[derive(Options)]
struct CheckPasswordOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "password to check")]
    password: String,
}

#[derive(Options)]
struct HashPasswordOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "password to hash")]
    password: String,
    
    #[options(help = "hashing algorithm (argon2/bcrypt)", default = "argon2", meta = "ALG")]
    algorithm: String,
}

#[derive(Options)]
struct PackageOpts {
    #[options(help = "show help for package")]
    help: bool,
    
    #[options(command)]
    command: Option<PackageCmd>,
}

#[derive(Options)]
enum PackageCmd {
    #[options(help = "install package")]
    Install(InstallOpts),
    
    #[options(help = "list installed packages")]
    List(ListOpts),
    
    #[options(help = "search for packages")]
    Search(SearchOpts),
    
    #[options(help = "update package lists")]
    Update(UpdateOpts),
    
    #[options(help = "upgrade a package")]
    Upgrade(UpgradeOpts),
    
    #[options(help = "remove a package")]
    Remove(RemoveOpts),
    
    #[options(help = "show package information")]
    Info(PackageInfoOpts),
}

#[derive(Options)]
struct InstallOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "package name")]
    package: String,
}

#[derive(Options)]
struct ListOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct SearchOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "search query")]
    query: String,
}

#[derive(Options)]
struct UpdateOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct UpgradeOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "package name")]
    package: String,
}

#[derive(Options)]
struct RemoveOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "package name")]
    package: String,
}

#[derive(Options)]
struct PackageInfoOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "package name")]
    package: String,
}

#[derive(Options)]
struct FileOpts {
    #[options(help = "show help for file")]
    help: bool,
    
    #[options(command)]
    command: Option<FileCmd>,
}

#[derive(Options)]
enum FileCmd {
    #[options(help = "calculate file hash")]
    Hash(HashOpts),
    
    #[options(help = "get file/directory size")]
    Size(SizeOpts),
}

#[derive(Options)]
struct HashOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "file path")]
    file: String,
    
    #[options(help = "hash algorithm: md5, sha256, all", default = "sha256", meta = "ALG")]
    algorithm: String,
}

#[derive(Options)]
struct SizeOpts {
    #[options(help = "show help")]
    help: bool,
    
    #[options(free, help = "file or directory path")]
    path: String,
}

#[derive(Options)]
struct UninstallOpts {
    #[options(help = "show help")]
    help: bool,
}

fn main() {
    let args = Cli::parse_args_default_or_exit();
    
    if args.version {
        println!("profilecore v1.0.0");
        return;
    }
    
    if args.help || args.command.is_none() {
        print_help();
        return;
    }
    
    match args.command.unwrap() {
        Command::Init(opts) => {
            if opts.help || opts.shell.is_empty() {
                println!("Usage: profilecore init <shell>");
                println!("Shells: bash, zsh, fish, powershell");
                return;
            }
            init::generate(&opts.shell);
        }
        
        Command::Completions(opts) => {
            if opts.help || opts.shell.is_empty() {
                println!("Usage: profilecore completions <shell>");
                println!("Shells: bash, zsh, fish, powershell");
                return;
            }
            completions::generate(&opts.shell);
        }
        
        Command::System(opts) => {
            if opts.help {
                println!("Usage: profilecore system <command>");
                println!("Commands: info, uptime, processes, disk-usage, memory, cpu");
                return;
            }
            
            match opts.command {
                Some(SystemCmd::Info(info_opts)) => {
                    commands::system::info(info_opts.format.as_deref());
                }
                Some(SystemCmd::Uptime(_)) => {
                    commands::system::uptime();
                }
                Some(SystemCmd::Processes(proc_opts)) => {
                    commands::system::processes(proc_opts.limit);
                }
                Some(SystemCmd::DiskUsage(_)) => {
                    commands::system::disk_usage();
                }
                Some(SystemCmd::Memory(_)) => {
                    commands::system::memory();
                }
                Some(SystemCmd::Cpu(_)) => {
                    commands::system::cpu();
                }
                None => {
                    eprintln!("Error: No system command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::Network(opts) => {
            if opts.help {
                println!("Usage: profilecore network <command>");
                println!("Commands: public-ip, test-port, local-ips, dns, reverse-dns, whois, trace, ping");
                return;
            }
            
            match opts.command {
                Some(NetworkCmd::PublicIp(_)) => {
                    commands::network::public_ip();
                }
                Some(NetworkCmd::TestPort(test_opts)) => {
                    let port = test_opts.port.unwrap_or(80);
                    commands::network::test_port(&test_opts.host, port);
                }
                Some(NetworkCmd::LocalIps(_)) => {
                    commands::network::local_ips();
                }
                Some(NetworkCmd::Dns(dns_opts)) => {
                    commands::network::dns_lookup(&dns_opts.domain);
                }
                Some(NetworkCmd::ReverseDns(rdns_opts)) => {
                    commands::network::reverse_dns(&rdns_opts.ip);
                }
                Some(NetworkCmd::Whois(whois_opts)) => {
                    commands::network::whois(&whois_opts.domain);
                }
                Some(NetworkCmd::Trace(trace_opts)) => {
                    commands::network::trace(&trace_opts.host, trace_opts.max_hops);
                }
                Some(NetworkCmd::Ping(ping_opts)) => {
                    commands::network::ping(&ping_opts.host, ping_opts.count);
                }
                None => {
                    eprintln!("Error: No network command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::Git(opts) => {
            if opts.help {
                println!("Usage: profilecore git <command>");
                println!("Commands: status, log, switch-account, add-account, list-accounts, whoami");
                return;
            }
            
            match opts.command {
                Some(GitCmd::Status(_)) => {
                    commands::git::status();
                }
                Some(GitCmd::Log(log_opts)) => {
                    commands::git::log(log_opts.limit);
                }
                Some(GitCmd::SwitchAccount(switch_opts)) => {
                    commands::git::switch_account(&switch_opts.account);
                }
                Some(GitCmd::AddAccount(add_opts)) => {
                    commands::git::add_account(add_opts.name, add_opts.email, add_opts.signing_key);
                }
                Some(GitCmd::ListAccounts(_)) => {
                    commands::git::list_accounts();
                }
                Some(GitCmd::Whoami(_)) => {
                    commands::git::whoami();
                }
                None => {
                    eprintln!("Error: No git command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::Docker(opts) => {
            if opts.help {
                println!("Usage: profilecore docker <command>");
                println!("Commands: ps, stats, logs");
                return;
            }
            
            match opts.command {
                Some(DockerCmd::Ps(_)) => {
                    commands::docker::ps();
                }
                Some(DockerCmd::Stats(stats_opts)) => {
                    commands::docker::stats(&stats_opts.container);
                }
                Some(DockerCmd::Logs(logs_opts)) => {
                    commands::docker::logs(&logs_opts.container, logs_opts.lines);
                }
                None => {
                    eprintln!("Error: No docker command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::Security(opts) => {
            if opts.help {
                println!("Usage: profilecore security <command>");
                println!("Commands: ssl-check, gen-password, check-password, hash-password");
                return;
            }
            
            match opts.command {
                Some(SecurityCmd::SslCheck(ssl_opts)) => {
                    commands::security::ssl_check(&ssl_opts.domain);
                }
                Some(SecurityCmd::GenPassword(gen_opts)) => {
                    commands::security::gen_password(gen_opts.length);
                }
                Some(SecurityCmd::CheckPassword(check_opts)) => {
                    commands::security::check_password(&check_opts.password);
                }
                Some(SecurityCmd::HashPassword(hash_opts)) => {
                    commands::security::hash_password(&hash_opts.password, &hash_opts.algorithm);
                }
                None => {
                    eprintln!("Error: No security command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::Package(opts) => {
            if opts.help {
                println!("Usage: profilecore package <command>");
                println!("Commands: install, list, search, update, upgrade, remove, info");
                return;
            }
            
            match opts.command {
                Some(PackageCmd::Install(install_opts)) => {
                    commands::package::install(&install_opts.package);
                }
                Some(PackageCmd::List(_)) => {
                    commands::package::list();
                }
                Some(PackageCmd::Search(search_opts)) => {
                    commands::package::search(&search_opts.query);
                }
                Some(PackageCmd::Update(_)) => {
                    commands::package::update();
                }
                Some(PackageCmd::Upgrade(upgrade_opts)) => {
                    commands::package::upgrade(&upgrade_opts.package);
                }
                Some(PackageCmd::Remove(remove_opts)) => {
                    commands::package::remove(&remove_opts.package);
                }
                Some(PackageCmd::Info(info_opts)) => {
                    commands::package::info(&info_opts.package);
                }
                None => {
                    eprintln!("Error: No package command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::File(opts) => {
            if opts.help {
                println!("Usage: profilecore file <command>");
                println!("Commands: hash, size");
                return;
            }
            
            match opts.command {
                Some(FileCmd::Hash(hash_opts)) => {
                    commands::file::hash(&hash_opts.file, &hash_opts.algorithm);
                }
                Some(FileCmd::Size(size_opts)) => {
                    commands::file::size(&size_opts.path);
                }
                None => {
                    eprintln!("Error: No file command specified");
                    process::exit(1);
                }
            }
        }
        
        Command::UninstallLegacy(_) => {
            commands::uninstall::uninstall_legacy();
        }
    }
}

fn print_help() {
    println!("ProfileCore v1.0.0 - Unified Cross-Shell Interface");
    println!();
    println!("USAGE:");
    println!("    profilecore <COMMAND>");
    println!();
    println!("COMMANDS:");
    println!("    init                Generate shell initialization code");
    println!("    completions         Generate shell completions");
    println!("    system              System information");
    println!("    network             Network utilities");
    println!("    git                 Git operations");
    println!("    docker              Docker operations");
    println!("    security            Security tools");
    println!("    package             Package management");
    println!("    uninstall-legacy    Remove v6.0.0 PowerShell modules");
    println!();
    println!("EXAMPLES:");
    println!("    profilecore init bash          # Generate bash init code");
    println!("    profilecore system info        # Show system info");
    println!("    profilecore network public-ip  # Get public IP");
    println!("    profilecore git status         # Show git status");
    println!();
    println!("For more help: https://github.com/mythic3011/ProfileCore");
}
