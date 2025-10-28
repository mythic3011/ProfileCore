//! ProfileCore v1.0.0 - Unified Cross-Shell Interface
//!
//! Smart wrapper around mature tools (git2, bollard, rustls, etc.)
//! Fast startup with gumdrop parsing (~160ns vs clap's 5-10ms)

use gumdrop::Options;
use std::process;

// Import command modules
mod commands;
mod completions;
mod config;
mod init;
mod utils;

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

    #[options(help = "environment variable operations")]
    Env(EnvOpts),

    #[options(help = "text processing commands")]
    Text(TextOpts),

    #[options(help = "process management commands")]
    Process(ProcessOpts),

    #[options(help = "archive operations")]
    Archive(ArchiveOpts),

    #[options(help = "string utility commands")]
    String(StringOpts),

    #[options(help = "HTTP utility commands")]
    Http(HttpOpts),

    #[options(help = "data processing commands")]
    Data(DataOpts),

    #[options(help = "shell utility commands")]
    Shell(ShellOpts),

    #[options(help = "utility commands (calc, random, time, config)")]
    Utils(UtilsOpts),

    #[options(help = "install ProfileCore to your shell (interactive)")]
    Install(InstallOpts),

    #[options(help = "uninstall ProfileCore from your shell")]
    Uninstall(UninstallOpts2),

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

    #[options(help = "show system load average")]
    Load(LoadOpts),

    #[options(help = "show network statistics")]
    NetworkStats(NetworkStatsOpts),

    #[options(help = "show temperature sensors")]
    Temperature(TemperatureOpts),

    #[options(help = "list system users")]
    Users(UsersOpts),

    #[options(help = "list system services")]
    ServiceList(ServiceListOpts),

    #[options(help = "show service status")]
    ServiceStatus(ServiceStatusOpts),
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
struct LoadOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct NetworkStatsOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct TemperatureOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct UsersOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct ServiceListOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct ServiceStatusOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "service name")]
    name: String,
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

    #[options(help = "show working tree changes")]
    Diff(DiffOpts),

    #[options(help = "list branches")]
    Branch(BranchOpts),

    #[options(help = "list remote repositories")]
    Remote(RemoteOpts),

    #[options(help = "switch git account")]
    SwitchAccount(SwitchAccountOpts),

    #[options(help = "add a new git account")]
    AddAccount(AddAccountOpts),

    #[options(help = "list all git accounts")]
    ListAccounts(ListAccountsOpts),

    #[options(help = "show current git identity")]
    Whoami(WhoamiOpts),

    #[options(help = "clone a repository")]
    Clone(CloneOpts),

    #[options(help = "pull from remote")]
    Pull(PullOpts),

    #[options(help = "push to remote")]
    Push(PushOpts),

    #[options(help = "stash changes")]
    Stash(StashOpts),

    #[options(help = "create a commit")]
    Commit(CommitOpts),

    #[options(help = "create or list tags")]
    Tag(TagOpts),

    #[options(help = "rebase current branch")]
    Rebase(RebaseOpts),
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
struct DiffOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct BranchOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "list all branches", short = "a")]
    all: bool,
}

#[derive(Options)]
struct RemoteOpts {
    #[options(help = "show help")]
    help: bool,
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
struct CloneOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "repository URL and optional path")]
    args: Vec<String>,
}

#[derive(Options)]
struct PullOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct PushOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "remote name", meta = "REMOTE")]
    remote: Option<String>,

    #[options(help = "branch name", meta = "BRANCH")]
    branch: Option<String>,
}

#[derive(Options)]
struct StashOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "stash action: save, pop, list, clear")]
    action: Option<String>,
}

#[derive(Options)]
struct CommitOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "commit message")]
    message: String,

    #[options(help = "stage all changes", short = "a")]
    all: bool,
}

#[derive(Options)]
struct TagOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "tag name")]
    name: Option<String>,

    #[options(help = "annotated tag message", short = "m", meta = "MSG")]
    message: Option<String>,

    #[options(help = "list all tags", short = "l")]
    list: bool,
}

#[derive(Options)]
struct RebaseOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "branch to rebase onto")]
    branch: String,

    #[options(help = "interactive rebase", short = "i")]
    interactive: bool,
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

    #[options(
        help = "hashing algorithm (argon2/bcrypt)",
        default = "argon2",
        meta = "ALG"
    )]
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
    Install(PackageInstallOpts),

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
struct PackageInstallOpts {
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

    #[options(help = "find files by pattern")]
    Find(FindOpts),

    #[options(help = "show file permissions")]
    Permissions(PermissionsOpts),

    #[options(help = "detect file type")]
    Type(TypeOpts),
}

#[derive(Options)]
struct HashOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "file path")]
    file: String,

    #[options(
        help = "hash algorithm: md5, sha256, all",
        default = "sha256",
        meta = "ALG"
    )]
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
struct FindOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "search pattern (supports wildcards)")]
    pattern: String,

    #[options(help = "directory to search", default = ".", meta = "DIR")]
    directory: String,
}

#[derive(Options)]
struct PermissionsOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "file path")]
    file: String,
}

#[derive(Options)]
struct TypeOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "file path")]
    file: String,
}

#[derive(Options)]
struct EnvOpts {
    #[options(help = "show help for env")]
    help: bool,

    #[options(command)]
    command: Option<EnvCmd>,
}

#[derive(Options)]
enum EnvCmd {
    #[options(help = "list all environment variables")]
    List(ListEnvOpts),

    #[options(help = "get environment variable")]
    Get(GetEnvOpts),

    #[options(help = "set environment variable")]
    Set(SetEnvOpts),
}

#[derive(Options)]
struct ListEnvOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct GetEnvOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "variable name")]
    variable: String,
}

#[derive(Options)]
struct SetEnvOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "variable name and value")]
    args: Vec<String>,
}

#[derive(Options)]
struct TextOpts {
    #[options(help = "show help for text")]
    help: bool,

    #[options(command)]
    command: Option<TextCmd>,
}

#[derive(Options)]
enum TextCmd {
    #[options(help = "search text in file (grep)")]
    Grep(GrepOpts),

    #[options(help = "show first N lines")]
    Head(HeadOpts),

    #[options(help = "show last N lines")]
    Tail(TailOpts),
}

#[derive(Options)]
struct GrepOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "pattern and file path")]
    args: Vec<String>,

    #[options(help = "ignore case", short = "i")]
    ignore_case: bool,
}

#[derive(Options)]
struct HeadOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "file path")]
    file: String,

    #[options(help = "number of lines", short = "n", default = "10", meta = "N")]
    lines: usize,
}

#[derive(Options)]
struct TailOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "file path")]
    file: String,

    #[options(help = "number of lines", short = "n", default = "10", meta = "N")]
    lines: usize,
}

#[derive(Options)]
struct ProcessOpts {
    #[options(help = "show help for process")]
    help: bool,

    #[options(command)]
    command: Option<ProcessCmd>,
}

#[derive(Options)]
enum ProcessCmd {
    #[options(help = "list running processes")]
    List(ProcessListOpts),

    #[options(help = "terminate a process")]
    Kill(KillOpts),

    #[options(help = "show process information")]
    Info(ProcessInfoOpts),

    #[options(help = "show process tree")]
    Tree(ProcessTreeOpts),
}

#[derive(Options)]
struct ProcessListOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(
        help = "number of processes to show",
        short = "n",
        default = "20",
        meta = "N"
    )]
    limit: usize,
}

#[derive(Options)]
struct KillOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "process ID")]
    pid: u32,

    #[options(help = "force kill", short = "f")]
    force: bool,
}

#[derive(Options)]
struct ProcessInfoOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "process ID")]
    pid: u32,
}

#[derive(Options)]
struct ProcessTreeOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct ArchiveOpts {
    #[options(help = "show help for archive")]
    help: bool,

    #[options(command)]
    command: Option<ArchiveCmd>,
}

#[derive(Options)]
enum ArchiveCmd {
    #[options(help = "compress files/directories")]
    Compress(CompressOpts),

    #[options(help = "extract archive")]
    Extract(ExtractOpts),

    #[options(help = "list archive contents")]
    List(ArchiveListOpts),
}

#[derive(Options)]
struct CompressOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "source and output paths")]
    args: Vec<String>,

    #[options(
        help = "format: gzip, tar, tar.gz, zip",
        short = "f",
        default = "tar.gz",
        meta = "FMT"
    )]
    format: String,
}

#[derive(Options)]
struct ExtractOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "archive and destination paths")]
    args: Vec<String>,
}

#[derive(Options)]
struct ArchiveListOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "archive path")]
    archive: String,
}

#[derive(Options)]
struct StringOpts {
    #[options(help = "show help for string")]
    help: bool,

    #[options(command)]
    command: Option<StringCmd>,
}

#[derive(Options)]
enum StringCmd {
    #[options(help = "base64 encode/decode")]
    Base64(Base64Opts),

    #[options(help = "URL encode/decode")]
    UrlEncode(UrlEncodeOpts),

    #[options(help = "hash string")]
    Hash(StringHashOpts),
}

#[derive(Options)]
struct Base64Opts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "input string")]
    input: String,

    #[options(help = "decode instead of encode", short = "d")]
    decode: bool,
}

#[derive(Options)]
struct UrlEncodeOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "input string")]
    input: String,

    #[options(help = "decode instead of encode", short = "d")]
    decode: bool,
}

#[derive(Options)]
struct StringHashOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "input string")]
    input: String,

    #[options(
        help = "hash algorithm: md5, sha256, all",
        default = "sha256",
        meta = "ALG"
    )]
    algorithm: String,
}

#[derive(Options)]
struct HttpOpts {
    #[options(help = "show help for http")]
    help: bool,

    #[options(command)]
    command: Option<HttpCmd>,
}

#[derive(Options)]
enum HttpCmd {
    #[options(help = "HTTP GET request")]
    Get(HttpGetOpts),

    #[options(help = "HTTP POST request")]
    Post(HttpPostOpts),

    #[options(help = "download file")]
    Download(HttpDownloadOpts),

    #[options(help = "HTTP HEAD request")]
    Head(HttpHeadOpts),
}

#[derive(Options)]
struct HttpGetOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "URL to request")]
    url: String,
}

#[derive(Options)]
struct HttpPostOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "URL and request body")]
    args: Vec<String>,

    #[options(help = "content type", default = "application/json", meta = "TYPE")]
    content_type: String,
}

#[derive(Options)]
struct HttpDownloadOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "URL and output file")]
    args: Vec<String>,
}

#[derive(Options)]
struct HttpHeadOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "URL to request")]
    url: String,
}

#[derive(Options)]
struct DataOpts {
    #[options(help = "show help for data")]
    help: bool,

    #[options(command)]
    command: Option<DataCmd>,
}

#[derive(Options)]
enum DataCmd {
    #[options(help = "format or minify JSON")]
    Json(DataJsonOpts),

    #[options(help = "convert YAML to JSON")]
    YamlToJson(DataYamlToJsonOpts),

    #[options(help = "convert JSON to YAML")]
    JsonToYaml(DataJsonToYamlOpts),
}

#[derive(Options)]
struct DataJsonOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "JSON input string")]
    input: String,

    #[options(help = "minify instead of format", short = "m")]
    minify: bool,
}

#[derive(Options)]
struct DataYamlToJsonOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "YAML input string")]
    input: String,
}

#[derive(Options)]
struct DataJsonToYamlOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "JSON input string")]
    input: String,
}

#[derive(Options)]
struct ShellOpts {
    #[options(help = "show help for shell")]
    help: bool,

    #[options(command)]
    command: Option<ShellCmd>,
}

#[derive(Options)]
enum ShellCmd {
    #[options(help = "show shell history")]
    History(HistoryOpts),

    #[options(help = "find command in PATH")]
    Which(WhichOpts),

    #[options(help = "execute a command")]
    Exec(ExecOpts),

    #[options(help = "show PATH variable")]
    Path(PathOpts),

    #[options(help = "list aliases")]
    Alias(AliasOpts),
}

#[derive(Options)]
struct HistoryOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "number of entries to show", default = "50", meta = "N")]
    limit: usize,
}

#[derive(Options)]
struct WhichOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "command to find")]
    command: String,
}

#[derive(Options)]
struct ExecOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "command and arguments")]
    args: Vec<String>,
}

#[derive(Options)]
struct PathOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct AliasOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct UtilsOpts {
    #[options(help = "show help for utils")]
    help: bool,

    #[options(command)]
    command: Option<UtilsCmd>,
}

#[derive(Options)]
enum UtilsCmd {
    #[options(help = "calculator")]
    Calc(CalcOpts),

    #[options(help = "random number generator")]
    Random(RandomOpts),

    #[options(help = "random string generator")]
    RandomString(RandomStringOpts),

    #[options(help = "sleep/delay")]
    Sleep(SleepOpts),

    #[options(help = "show current time")]
    Time(TimeOpts),

    #[options(help = "show time zones")]
    Timezone(TimezoneOpts),

    #[options(help = "show version information")]
    Version(VersionOpts),

    #[options(help = "get configuration value")]
    ConfigGet(ConfigGetOpts),

    #[options(help = "set configuration value")]
    ConfigSet(ConfigSetOpts),

    #[options(help = "list configuration")]
    ConfigList(ConfigListOpts),
}

#[derive(Options)]
struct CalcOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "mathematical expression")]
    expression: String,
}

#[derive(Options)]
struct RandomOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "minimum value", default = "1", meta = "MIN")]
    min: i64,

    #[options(help = "maximum value", default = "100", meta = "MAX")]
    max: i64,

    #[options(help = "number of values to generate", default = "1", meta = "N")]
    count: usize,
}

#[derive(Options)]
struct RandomStringOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "length of string", default = "16", meta = "N")]
    length: usize,

    #[options(
        help = "charset: alpha, numeric, alphanumeric, hex, all",
        default = "alphanumeric",
        meta = "SET"
    )]
    charset: String,
}

#[derive(Options)]
struct SleepOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "seconds to sleep")]
    seconds: u64,
}

#[derive(Options)]
struct TimeOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(help = "show UTC time", short = "u")]
    utc: bool,
}

#[derive(Options)]
struct TimezoneOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct VersionOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct ConfigGetOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "configuration key")]
    key: String,
}

#[derive(Options)]
struct ConfigSetOpts {
    #[options(help = "show help")]
    help: bool,

    #[options(free, help = "key and value")]
    args: Vec<String>,
}

#[derive(Options)]
struct ConfigListOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct InstallOpts {
    #[options(help = "show help")]
    help: bool,
}

#[derive(Options)]
struct UninstallOpts2 {
    #[options(help = "show help")]
    help: bool,
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
                println!("Commands: info, uptime, processes, disk-usage, memory, cpu, load, network-stats, temperature, users, service-list, service-status");
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
                Some(SystemCmd::Load(_)) => {
                    commands::system::load();
                }
                Some(SystemCmd::NetworkStats(_)) => {
                    commands::system::network_stats();
                }
                Some(SystemCmd::Temperature(_)) => {
                    commands::system::temperature();
                }
                Some(SystemCmd::Users(_)) => {
                    commands::system::users();
                }
                Some(SystemCmd::ServiceList(_)) => {
                    commands::system::service_list();
                }
                Some(SystemCmd::ServiceStatus(status_opts)) => {
                    commands::system::service_status(&status_opts.name);
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
                println!("Commands: status, log, diff, branch, remote, switch-account, add-account, list-accounts, whoami, clone, pull, push, stash, commit, tag, rebase");
                return;
            }

            match opts.command {
                Some(GitCmd::Status(_)) => {
                    commands::git::status();
                }
                Some(GitCmd::Log(log_opts)) => {
                    commands::git::log(log_opts.limit);
                }
                Some(GitCmd::Diff(_)) => {
                    commands::git::diff();
                }
                Some(GitCmd::Branch(branch_opts)) => {
                    commands::git::branch(branch_opts.all);
                }
                Some(GitCmd::Remote(_)) => {
                    commands::git::remote();
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
                Some(GitCmd::Clone(clone_opts)) => {
                    if clone_opts.args.is_empty() {
                        eprintln!("Error: clone requires repository URL");
                        eprintln!("Usage: profilecore git clone <url> [path]");
                        process::exit(1);
                    }
                    let path = if clone_opts.args.len() > 1 {
                        Some(clone_opts.args[1].as_str())
                    } else {
                        None
                    };
                    commands::git::clone(&clone_opts.args[0], path);
                }
                Some(GitCmd::Pull(_)) => {
                    commands::git::pull();
                }
                Some(GitCmd::Push(push_opts)) => {
                    commands::git::push(push_opts.remote.as_deref(), push_opts.branch.as_deref());
                }
                Some(GitCmd::Stash(stash_opts)) => {
                    let action = stash_opts.action.as_deref().unwrap_or("save");
                    commands::git::stash(action);
                }
                Some(GitCmd::Commit(commit_opts)) => {
                    commands::git::commit(&commit_opts.message, commit_opts.all);
                }
                Some(GitCmd::Tag(tag_opts)) => {
                    if tag_opts.list {
                        commands::git::tag("", None, true);
                    } else if let Some(name) = &tag_opts.name {
                        commands::git::tag(name, tag_opts.message.as_deref(), false);
                    } else {
                        eprintln!("Error: tag name required (or use --list)");
                        process::exit(1);
                    }
                }
                Some(GitCmd::Rebase(rebase_opts)) => {
                    commands::git::rebase(&rebase_opts.branch, rebase_opts.interactive);
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
                println!("Commands: hash, size, find, permissions, type");
                return;
            }

            match opts.command {
                Some(FileCmd::Hash(hash_opts)) => {
                    commands::file::hash(&hash_opts.file, &hash_opts.algorithm);
                }
                Some(FileCmd::Size(size_opts)) => {
                    commands::file::size(&size_opts.path);
                }
                Some(FileCmd::Find(find_opts)) => {
                    commands::file::find(&find_opts.pattern, &find_opts.directory);
                }
                Some(FileCmd::Permissions(perm_opts)) => {
                    commands::file::permissions(&perm_opts.file);
                }
                Some(FileCmd::Type(type_opts)) => {
                    commands::file::file_type(&type_opts.file);
                }
                None => {
                    eprintln!("Error: No file command specified");
                    process::exit(1);
                }
            }
        }

        Command::Env(opts) => {
            if opts.help {
                println!("Usage: profilecore env <command>");
                println!("Commands: list, get, set");
                return;
            }

            match opts.command {
                Some(EnvCmd::List(_)) => {
                    commands::env::list();
                }
                Some(EnvCmd::Get(get_opts)) => {
                    commands::env::get(&get_opts.variable);
                }
                Some(EnvCmd::Set(set_opts)) => {
                    if set_opts.args.len() < 2 {
                        eprintln!("Error: env set requires variable name and value");
                        eprintln!("Usage: profilecore env set <variable> <value>");
                        process::exit(1);
                    }
                    commands::env::set(&set_opts.args[0], &set_opts.args[1]);
                }
                None => {
                    eprintln!("Error: No env command specified");
                    process::exit(1);
                }
            }
        }

        Command::Text(opts) => {
            if opts.help {
                println!("Usage: profilecore text <command>");
                println!("Commands: grep, head, tail");
                return;
            }

            match opts.command {
                Some(TextCmd::Grep(grep_opts)) => {
                    if grep_opts.args.len() < 2 {
                        eprintln!("Error: grep requires pattern and file path");
                        eprintln!("Usage: profilecore text grep <pattern> <file>");
                        process::exit(1);
                    }
                    commands::text::grep(
                        &grep_opts.args[0],
                        &grep_opts.args[1],
                        grep_opts.ignore_case,
                    );
                }
                Some(TextCmd::Head(head_opts)) => {
                    commands::text::head(&head_opts.file, head_opts.lines);
                }
                Some(TextCmd::Tail(tail_opts)) => {
                    commands::text::tail(&tail_opts.file, tail_opts.lines);
                }
                None => {
                    eprintln!("Error: No text command specified");
                    process::exit(1);
                }
            }
        }

        Command::Process(opts) => {
            if opts.help {
                println!("Usage: profilecore process <command>");
                println!("Commands: list, kill, info, tree");
                return;
            }

            match opts.command {
                Some(ProcessCmd::List(list_opts)) => {
                    commands::process::list(list_opts.limit);
                }
                Some(ProcessCmd::Kill(kill_opts)) => {
                    commands::process::kill(kill_opts.pid, kill_opts.force);
                }
                Some(ProcessCmd::Info(info_opts)) => {
                    commands::process::info(info_opts.pid);
                }
                Some(ProcessCmd::Tree(_)) => {
                    commands::process::tree();
                }
                None => {
                    eprintln!("Error: No process command specified");
                    process::exit(1);
                }
            }
        }

        Command::Archive(opts) => {
            if opts.help {
                println!("Usage: profilecore archive <command>");
                println!("Commands: compress, extract, list");
                return;
            }

            match opts.command {
                Some(ArchiveCmd::Compress(compress_opts)) => {
                    if compress_opts.args.len() < 2 {
                        eprintln!("Error: compress requires source and output paths");
                        eprintln!("Usage: profilecore archive compress <source> <output>");
                        process::exit(1);
                    }
                    commands::archive::compress(
                        &compress_opts.args[0],
                        &compress_opts.args[1],
                        &compress_opts.format,
                    );
                }
                Some(ArchiveCmd::Extract(extract_opts)) => {
                    if extract_opts.args.len() < 2 {
                        eprintln!("Error: extract requires archive and destination paths");
                        eprintln!("Usage: profilecore archive extract <archive> <destination>");
                        process::exit(1);
                    }
                    commands::archive::extract(&extract_opts.args[0], &extract_opts.args[1]);
                }
                Some(ArchiveCmd::List(list_opts)) => {
                    commands::archive::list(&list_opts.archive);
                }
                None => {
                    eprintln!("Error: No archive command specified");
                    process::exit(1);
                }
            }
        }

        Command::String(opts) => {
            if opts.help {
                println!("Usage: profilecore string <command>");
                println!("Commands: base64, url-encode, hash");
                return;
            }

            match opts.command {
                Some(StringCmd::Base64(base64_opts)) => {
                    commands::string::base64_encode_decode(&base64_opts.input, base64_opts.decode);
                }
                Some(StringCmd::UrlEncode(url_opts)) => {
                    commands::string::url_encode_decode(&url_opts.input, url_opts.decode);
                }
                Some(StringCmd::Hash(hash_opts)) => {
                    commands::string::string_hash(&hash_opts.input, &hash_opts.algorithm);
                }
                None => {
                    eprintln!("Error: No string command specified");
                    process::exit(1);
                }
            }
        }

        Command::Http(opts) => {
            if opts.help {
                println!("Usage: profilecore http <command>");
                println!("Commands: get, post, download, head");
                return;
            }

            match opts.command {
                Some(HttpCmd::Get(get_opts)) => {
                    commands::http::get(&get_opts.url, None);
                }
                Some(HttpCmd::Post(post_opts)) => {
                    if post_opts.args.len() < 2 {
                        eprintln!("Error: post requires URL and body");
                        eprintln!("Usage: profilecore http post <url> <body>");
                        process::exit(1);
                    }
                    commands::http::post(
                        &post_opts.args[0],
                        &post_opts.args[1],
                        &post_opts.content_type,
                    );
                }
                Some(HttpCmd::Download(download_opts)) => {
                    if download_opts.args.len() < 2 {
                        eprintln!("Error: download requires URL and output file");
                        eprintln!("Usage: profilecore http download <url> <output>");
                        process::exit(1);
                    }
                    commands::http::download(&download_opts.args[0], &download_opts.args[1]);
                }
                Some(HttpCmd::Head(head_opts)) => {
                    commands::http::head(&head_opts.url);
                }
                None => {
                    eprintln!("Error: No http command specified");
                    process::exit(1);
                }
            }
        }

        Command::Data(opts) => {
            if opts.help {
                println!("Usage: profilecore data <command>");
                println!("Commands: json, yaml-to-json, json-to-yaml");
                return;
            }

            match opts.command {
                Some(DataCmd::Json(json_opts)) => {
                    commands::data::json_format(&json_opts.input, json_opts.minify);
                }
                Some(DataCmd::YamlToJson(yaml_opts)) => {
                    commands::data::yaml_to_json(&yaml_opts.input);
                }
                Some(DataCmd::JsonToYaml(json_opts)) => {
                    commands::data::json_to_yaml(&json_opts.input);
                }
                None => {
                    eprintln!("Error: No data command specified");
                    process::exit(1);
                }
            }
        }

        Command::Shell(opts) => {
            if opts.help {
                println!("Usage: profilecore shell <command>");
                println!("Commands: history, which, exec, path, alias");
                return;
            }

            match opts.command {
                Some(ShellCmd::History(hist_opts)) => {
                    commands::shell::history(Some(hist_opts.limit));
                }
                Some(ShellCmd::Which(which_opts)) => {
                    commands::shell::which_cmd(&which_opts.command);
                }
                Some(ShellCmd::Exec(exec_opts)) => {
                    if exec_opts.args.is_empty() {
                        eprintln!("Error: exec requires a command");
                        eprintln!("Usage: profilecore shell exec <command> [args...]");
                        process::exit(1);
                    }
                    let cmd = &exec_opts.args[0];
                    let args = exec_opts.args[1..].to_vec();
                    commands::shell::exec_cmd(cmd, args);
                }
                Some(ShellCmd::Path(_)) => {
                    commands::shell::env_path();
                }
                Some(ShellCmd::Alias(_)) => {
                    commands::shell::alias_list();
                }
                None => {
                    eprintln!("Error: No shell command specified");
                    process::exit(1);
                }
            }
        }

        Command::Utils(opts) => {
            if opts.help {
                println!("Usage: profilecore utils <command>");
                println!("Commands: calc, random, random-string, sleep, time, timezone, version, config-get, config-set, config-list");
                return;
            }

            match opts.command {
                Some(UtilsCmd::Calc(calc_opts)) => {
                    commands::utils::calculate(&calc_opts.expression);
                }
                Some(UtilsCmd::Random(rand_opts)) => {
                    commands::utils::random_gen(rand_opts.min, rand_opts.max, rand_opts.count);
                }
                Some(UtilsCmd::RandomString(str_opts)) => {
                    commands::utils::random_string(str_opts.length, &str_opts.charset);
                }
                Some(UtilsCmd::Sleep(sleep_opts)) => {
                    commands::utils::sleep_cmd(sleep_opts.seconds);
                }
                Some(UtilsCmd::Time(time_opts)) => {
                    commands::utils::time_now(time_opts.utc);
                }
                Some(UtilsCmd::Timezone(_)) => {
                    commands::utils::time_zones();
                }
                Some(UtilsCmd::Version(_)) => {
                    commands::utils::version_info();
                }
                Some(UtilsCmd::ConfigGet(get_opts)) => {
                    commands::utils::config_get(&get_opts.key);
                }
                Some(UtilsCmd::ConfigSet(set_opts)) => {
                    if set_opts.args.len() < 2 {
                        eprintln!("Error: config-set requires key and value");
                        eprintln!("Usage: profilecore utils config-set <key> <value>");
                        process::exit(1);
                    }
                    commands::utils::config_set(&set_opts.args[0], &set_opts.args[1]);
                }
                Some(UtilsCmd::ConfigList(_)) => {
                    commands::utils::config_list();
                }
                None => {
                    eprintln!("Error: No utils command specified");
                    process::exit(1);
                }
            }
        }

        Command::Install(opts) => {
            if opts.help {
                println!("Usage: profilecore install");
                println!("Interactive installer for ProfileCore");
                println!();
                println!("This will:");
                println!("  - Detect your shell");
                println!("  - Add ProfileCore init code to your shell profile");
                println!("  - Create configuration directories");
                println!("  - Verify the installation");
                return;
            }
            commands::install::run_installer();
        }

        Command::Uninstall(opts) => {
            if opts.help {
                println!("Usage: profilecore uninstall");
                println!("Uninstall ProfileCore from your shell");
                return;
            }
            commands::install::run_uninstaller();
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
    println!("    install             Install ProfileCore to your shell (interactive)");
    println!("    uninstall           Uninstall ProfileCore from your shell");
    println!("    init                Generate shell initialization code");
    println!("    completions         Generate shell completions");
    println!("    system              System information");
    println!("    network             Network utilities");
    println!("    git                 Git operations");
    println!("    docker              Docker operations");
    println!("    security            Security tools");
    println!("    package             Package management");
    println!("    file                File operations");
    println!("    env                 Environment variables");
    println!("    text                Text processing");
    println!("    process             Process management");
    println!("    archive             Archive operations");
    println!("    string              String utilities");
    println!("    http                HTTP utilities");
    println!("    data                Data processing");
    println!("    shell               Shell utilities");
    println!("    utils               Utilities (calc, random, time, config)");
    println!("    uninstall-legacy    Remove v6.0.0 PowerShell modules");
    println!();
    println!("EXAMPLES:");
    println!("    profilecore install            # Interactive installation wizard");
    println!("    profilecore init bash          # Generate bash init code");
    println!("    profilecore system info        # Show system info");
    println!("    profilecore network public-ip  # Get public IP");
    println!("    profilecore git status         # Show git status");
    println!();
    println!("For more help: https://github.com/mythic3011/ProfileCore");
}
