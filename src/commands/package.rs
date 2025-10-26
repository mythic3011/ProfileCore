//! Package management (external CLI wrappers)

use colored::Colorize;
use std::process::Command;
use which::which;

pub fn install(package: &str) {
    println!("Installing package: {}", package.cyan());
    
    // Detect OS and use appropriate package manager
    #[cfg(target_os = "windows")]
    {
        if which("winget").is_ok() {
            run_command("winget", &["install", package]);
        } else if which("choco").is_ok() {
            run_command("choco", &["install", package, "-y"]);
        } else {
            eprintln!("{} No package manager found (winget/choco)", "✗".red());
        }
    }
    
    #[cfg(target_os = "macos")]
    {
        if which("brew").is_ok() {
            run_command("brew", &["install", package]);
        } else {
            eprintln!("{} Homebrew not found", "✗".red());
        }
    }
    
    #[cfg(target_os = "linux")]
    {
        if which("apt-get").is_ok() {
            run_command("sudo", &["apt-get", "install", "-y", package]);
        } else if which("dnf").is_ok() {
            run_command("sudo", &["dnf", "install", "-y", package]);
        } else if which("pacman").is_ok() {
            run_command("sudo", &["pacman", "-S", "--noconfirm", package]);
        } else {
            eprintln!("{} No package manager found", "✗".red());
        }
    }
}

fn run_command(cmd: &str, args: &[&str]) {
    match Command::new(cmd).args(args).status() {
        Ok(status) => {
            if status.success() {
                println!("{} Package installed successfully", "✓".green());
            } else {
                eprintln!("{} Installation failed", "✗".red());
            }
        }
        Err(e) => eprintln!("{} Failed to run command: {}", "✗".red(), e),
    }
}

