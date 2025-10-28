//! Shell utility commands

use colored::Colorize;
use std::env;
use std::process::Command;

pub fn history(limit: Option<usize>) {
    println!("\n{}", "Shell History".cyan().bold());
    println!("{}", "=".repeat(60));

    // Shell history is typically handled by the shell itself
    // We'll try to read common history files

    let history_file = if cfg!(windows) {
        env::var("USERPROFILE").ok().map(|p| format!("{}\\AppData\\Roaming\\Microsoft\\Windows\\PowerShell\\PSReadLine\\ConsoleHost_history.txt", p))
    } else {
        env::var("HOME")
            .ok()
            .map(|h| format!("{}/.bash_history", h))
    };

    if let Some(path) = history_file {
        match std::fs::read_to_string(&path) {
            Ok(contents) => {
                let lines: Vec<&str> = contents.lines().collect();
                let start = if let Some(lim) = limit {
                    lines.len().saturating_sub(lim)
                } else {
                    lines.len().saturating_sub(50)
                };

                for (i, line) in lines.iter().skip(start).enumerate() {
                    println!("{}: {}", (start + i + 1).to_string().cyan(), line);
                }
            }
            Err(e) => {
                eprintln!("{} Could not read history file: {}", "✗".red(), e);
                println!("History file location: {}", path);
            }
        }
    } else {
        eprintln!("{} Could not determine history file location", "✗".red());
    }

    println!();
}

pub fn which_cmd(command: &str) {
    println!("\n{} {}", "Searching for:".cyan().bold(), command.yellow());
    println!("{}", "=".repeat(60));

    match which::which(command) {
        Ok(path) => {
            println!("{} {}", "✓".green(), path.display());
        }
        Err(_) => {
            eprintln!("{} Command '{}' not found in PATH", "✗".red(), command);
        }
    }

    println!();
}

pub fn exec_cmd(command: &str, args: Vec<String>) {
    println!(
        "\n{} {}",
        "Executing:".cyan().bold(),
        format!("{} {}", command, args.join(" ")).yellow()
    );
    println!("{}", "=".repeat(60));

    match Command::new(command).args(&args).status() {
        Ok(status) => {
            if status.success() {
                println!("\n{} Command completed successfully", "✓".green());
                if let Some(code) = status.code() {
                    println!("Exit code: {}", code);
                }
            } else {
                eprintln!("\n{} Command failed", "✗".red());
                if let Some(code) = status.code() {
                    eprintln!("Exit code: {}", code);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Failed to execute command: {}", "✗".red(), e);
        }
    }

    println!();
}

pub fn env_path() {
    println!("\n{}", "PATH Environment Variable".cyan().bold());
    println!("{}", "=".repeat(80));

    if let Ok(path) = env::var("PATH") {
        let separator = if cfg!(windows) { ';' } else { ':' };

        for (i, entry) in path.split(separator).enumerate() {
            if std::path::Path::new(entry).exists() {
                println!("{}: {} {}", (i + 1).to_string().cyan(), entry, "✓".green());
            } else {
                println!(
                    "{}: {} {}",
                    (i + 1).to_string().cyan(),
                    entry,
                    "(not found)".red()
                );
            }
        }
    } else {
        eprintln!("{} PATH environment variable not found", "✗".red());
    }

    println!();
}

pub fn alias_list() {
    println!("\n{}", "Shell Aliases (ProfileCore Context)".cyan().bold());
    println!("{}", "=".repeat(60));
    println!(
        "{} ProfileCore provides command aliases through shell integration",
        "ℹ".cyan()
    );
    println!(
        "Run: {} to see full command list",
        "profilecore --help".yellow()
    );
    println!("\nCommon aliases:");
    println!("  sysinfo    → system info");
    println!("  netstat    → system network-stats");
    println!("  pubip      → network public-ip");
    println!("  dl         → http download");
    println!();
}
