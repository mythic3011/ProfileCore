//! Package management (external CLI wrappers)

use colored::Colorize;
use std::process::{Command, Stdio};
use which::which;

pub fn install(package: &str) {
    println!("Installing package: {}", package.cyan());
    detect_and_run("install", Some(package));
}

pub fn list() {
    println!("\n{}", "Installed Packages".cyan().bold());
    println!("{}", "=".repeat(60));
    detect_and_run("list", None);
}

pub fn search(query: &str) {
    println!("\n{} {}", "Searching for:".cyan(), query.yellow());
    println!("{}", "=".repeat(60));
    detect_and_run("search", Some(query));
}

pub fn update() {
    println!("{}", "Updating package lists...".cyan());
    detect_and_run("update", None);
}

pub fn upgrade(package: &str) {
    println!("Upgrading package: {}", package.cyan());
    detect_and_run("upgrade", Some(package));
}

pub fn remove(package: &str) {
    println!("Removing package: {}", package.cyan());
    detect_and_run("remove", Some(package));
}

pub fn info(package: &str) {
    println!("\n{} {}", "Package Info:".cyan().bold(), package.yellow());
    println!("{}", "=".repeat(60));
    detect_and_run("info", Some(package));
}

fn detect_and_run(operation: &str, target: Option<&str>) {
    #[cfg(target_os = "windows")]
    {
        if which("winget").is_ok() {
            match operation {
                "install" => run_command("winget", &["install", target.unwrap()]),
                "list" => run_command("winget", &["list"]),
                "search" => run_command("winget", &["search", target.unwrap()]),
                "update" => run_command("winget", &["update", "--all"]),
                "upgrade" => run_command("winget", &["upgrade", target.unwrap()]),
                "remove" => run_command("winget", &["uninstall", target.unwrap()]),
                "info" => run_command("winget", &["show", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else if which("choco").is_ok() {
            match operation {
                "install" => run_command("choco", &["install", target.unwrap(), "-y"]),
                "list" => run_command("choco", &["list", "--local-only"]),
                "search" => run_command("choco", &["search", target.unwrap()]),
                "update" => run_command("choco", &["upgrade", "all", "-y"]),
                "upgrade" => run_command("choco", &["upgrade", target.unwrap(), "-y"]),
                "remove" => run_command("choco", &["uninstall", target.unwrap(), "-y"]),
                "info" => run_command("choco", &["info", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else {
            eprintln!("{} No package manager found (winget/choco)", "✗".red());
        }
    }
    
    #[cfg(target_os = "macos")]
    {
        if which("brew").is_ok() {
            match operation {
                "install" => run_command("brew", &["install", target.unwrap()]),
                "list" => run_command("brew", &["list"]),
                "search" => run_command("brew", &["search", target.unwrap()]),
                "update" => run_command("brew", &["update"]),
                "upgrade" => run_command("brew", &["upgrade", target.unwrap()]),
                "remove" => run_command("brew", &["uninstall", target.unwrap()]),
                "info" => run_command("brew", &["info", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else {
            eprintln!("{} Homebrew not found", "✗".red());
        }
    }
    
    #[cfg(target_os = "linux")]
    {
        if which("apt-get").is_ok() {
            match operation {
                "install" => run_command("sudo", &["apt-get", "install", "-y", target.unwrap()]),
                "list" => run_command("apt", &["list", "--installed"]),
                "search" => run_command("apt-cache", &["search", target.unwrap()]),
                "update" => run_command("sudo", &["apt-get", "update"]),
                "upgrade" => run_command("sudo", &["apt-get", "install", "--only-upgrade", target.unwrap()]),
                "remove" => run_command("sudo", &["apt-get", "remove", "-y", target.unwrap()]),
                "info" => run_command("apt-cache", &["show", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else if which("dnf").is_ok() {
            match operation {
                "install" => run_command("sudo", &["dnf", "install", "-y", target.unwrap()]),
                "list" => run_command("dnf", &["list", "installed"]),
                "search" => run_command("dnf", &["search", target.unwrap()]),
                "update" => run_command("sudo", &["dnf", "check-update"]),
                "upgrade" => run_command("sudo", &["dnf", "upgrade", "-y", target.unwrap()]),
                "remove" => run_command("sudo", &["dnf", "remove", "-y", target.unwrap()]),
                "info" => run_command("dnf", &["info", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else if which("pacman").is_ok() {
            match operation {
                "install" => run_command("sudo", &["pacman", "-S", "--noconfirm", target.unwrap()]),
                "list" => run_command("pacman", &["-Q"]),
                "search" => run_command("pacman", &["-Ss", target.unwrap()]),
                "update" => run_command("sudo", &["pacman", "-Sy"]),
                "upgrade" => run_command("sudo", &["pacman", "-S", "--noconfirm", target.unwrap()]),
                "remove" => run_command("sudo", &["pacman", "-R", "--noconfirm", target.unwrap()]),
                "info" => run_command("pacman", &["-Si", target.unwrap()]),
                _ => eprintln!("{} Unknown operation", "✗".red()),
            }
        } else {
            eprintln!("{} No package manager found", "✗".red());
        }
    }
}

fn run_command(cmd: &str, args: &[&str]) {
    let output = Command::new(cmd)
        .args(args)
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status();
    
    match output {
        Ok(status) => {
            if !status.success() {
                eprintln!("\n{} Command failed with exit code: {:?}", "✗".red(), status.code());
            }
        }
        Err(e) => eprintln!("{} Failed to run command: {}", "✗".red(), e),
    }
}

