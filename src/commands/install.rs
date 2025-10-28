//! Interactive installation wizard for ProfileCore
//! 
//! Handles:
//! - Shell detection
//! - Profile file setup
//! - Configuration directory creation
//! - Installation verification

use std::env;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use colored::Colorize;
use dialoguer::{Confirm, Select, theme::ColorfulTheme};

const SHELLS: &[&str] = &["bash", "zsh", "fish", "powershell"];

pub fn run_installer() {
    println!("{}", "╔════════════════════════════════════════╗".cyan());
    println!("{}", "║  ProfileCore v1.0.0 Installer         ║".cyan());
    println!("{}", "╚════════════════════════════════════════╝".cyan());
    println!();
    
    // Step 1: Detect current shell
    let detected_shell = detect_shell();
    println!("✓ Detected shell: {}", detected_shell.green());
    println!();
    
    // Step 2: Ask user to confirm or choose another shell
    let shell = prompt_shell_selection(&detected_shell);
    println!();
    
    // Step 3: Check if profilecore is in PATH
    if !check_in_path() {
        println!("{}", "⚠ Warning: profilecore binary not found in PATH".yellow());
        println!("Please ensure profilecore is installed in a directory included in your PATH");
        println!();
        
        let continue_anyway = Confirm::with_theme(&ColorfulTheme::default())
            .with_prompt("Continue anyway?")
            .default(true)
            .interact()
            .unwrap_or(false);
        
        if !continue_anyway {
            println!("{}", "Installation cancelled.".red());
            return;
        }
        println!();
    } else {
        println!("{}", "✓ profilecore binary found in PATH".green());
        println!();
    }
    
    // Step 4: Get profile file path
    let profile_path = get_profile_path(&shell);
    println!("Profile file: {}", profile_path.display().to_string().cyan());
    println!();
    
    // Step 5: Check if already installed
    if is_already_installed(&profile_path) {
        println!("{}", "ProfileCore is already installed in your shell profile!".yellow());
        println!();
        
        let reinstall = Confirm::with_theme(&ColorfulTheme::default())
            .with_prompt("Do you want to reinstall/update?")
            .default(false)
            .interact()
            .unwrap_or(false);
        
        if !reinstall {
            println!("{}", "Installation cancelled.".yellow());
            verify_installation(&shell);
            return;
        }
        println!();
    }
    
    // Step 6: Backup existing profile
    backup_profile(&profile_path);
    
    // Step 7: Create config directory
    create_config_dir();
    
    // Step 8: Add init code to profile
    add_init_to_profile(&profile_path, &shell);
    
    // Step 9: Success message
    print_success_message(&shell);
    
    // Step 10: Verification
    verify_installation(&shell);
}

fn detect_shell() -> String {
    // Try to detect from SHELL environment variable
    if let Ok(shell_path) = env::var("SHELL") {
        if shell_path.contains("bash") {
            return "bash".to_string();
        } else if shell_path.contains("zsh") {
            return "zsh".to_string();
        } else if shell_path.contains("fish") {
            return "fish".to_string();
        }
    }
    
    // Check for PowerShell on Windows
    if cfg!(windows) {
        if env::var("PSModulePath").is_ok() {
            return "powershell".to_string();
        }
    }
    
    // Default fallback
    if cfg!(windows) {
        "powershell".to_string()
    } else if cfg!(target_os = "macos") {
        "zsh".to_string()
    } else {
        "bash".to_string()
    }
}

fn prompt_shell_selection(detected: &str) -> String {
    let confirmed = Confirm::with_theme(&ColorfulTheme::default())
        .with_prompt(format!("Install for {}?", detected))
        .default(true)
        .interact()
        .unwrap_or(true);
    
    if confirmed {
        return detected.to_string();
    }
    
    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Choose your shell")
        .items(SHELLS)
        .default(0)
        .interact()
        .unwrap_or(0);
    
    SHELLS[selection].to_string()
}

fn check_in_path() -> bool {
    which::which("profilecore").is_ok()
}

fn get_profile_path(shell: &str) -> PathBuf {
    let home = dirs::home_dir().expect("Could not find home directory");
    
    match shell {
        "bash" => {
            // Prefer .bashrc on Linux, .bash_profile on macOS
            if cfg!(target_os = "macos") {
                home.join(".bash_profile")
            } else {
                home.join(".bashrc")
            }
        }
        "zsh" => home.join(".zshrc"),
        "fish" => home.join(".config/fish/config.fish"),
        "powershell" => {
            // PowerShell profile location
            if cfg!(windows) {
                let docs = dirs::document_dir().expect("Could not find Documents directory");
                docs.join("PowerShell")
                    .join("Microsoft.PowerShell_profile.ps1")
            } else {
                home.join(".config/powershell/profile.ps1")
            }
        }
        _ => panic!("Unsupported shell: {}", shell),
    }
}

fn is_already_installed(profile_path: &PathBuf) -> bool {
    if !profile_path.exists() {
        return false;
    }
    
    if let Ok(content) = fs::read_to_string(profile_path) {
        content.contains("profilecore init")
    } else {
        false
    }
}

fn backup_profile(profile_path: &PathBuf) {
    if !profile_path.exists() {
        return;
    }
    
    let backup_path = profile_path.with_extension("bak");
    if let Err(e) = fs::copy(profile_path, &backup_path) {
        println!("{}: {}", "Warning: Could not backup profile".yellow(), e);
    } else {
        println!("{} {}", "✓ Backed up existing profile to:".green(), backup_path.display());
    }
}

fn create_config_dir() {
    let home = dirs::home_dir().expect("Could not find home directory");
    let config_dir = home.join(".config").join("profilecore");
    
    if let Err(e) = fs::create_dir_all(&config_dir) {
        println!("{}: {}", "Warning: Could not create config directory".yellow(), e);
    } else {
        println!("{} {}", "✓ Created config directory:".green(), config_dir.display());
    }
}

fn add_init_to_profile(profile_path: &PathBuf, shell: &str) {
    // Ensure parent directory exists
    if let Some(parent) = profile_path.parent() {
        let _ = fs::create_dir_all(parent);
    }
    
    let init_code = match shell {
        "bash" | "zsh" => {
            format!(
                "\n# ProfileCore v1.0.0 - Added by installer\nif command -v profilecore &> /dev/null; then\n    eval \"$(profilecore init {})\"\nfi\n",
                shell
            )
        }
        "fish" => {
            "\n# ProfileCore v1.0.0 - Added by installer\nif command -v profilecore > /dev/null\n    profilecore init fish | source\nend\n".to_string()
        }
        "powershell" => {
            "\n# ProfileCore v1.0.0 - Added by installer\nif (Get-Command profilecore -ErrorAction SilentlyContinue) {\n    profilecore init powershell | Invoke-Expression\n}\n".to_string()
        }
        _ => panic!("Unsupported shell: {}", shell),
    };
    
    // Append to profile file
    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(profile_path)
        .expect("Could not open profile file");
    
    if let Err(e) = file.write_all(init_code.as_bytes()) {
        println!("{}: {}", "Error: Could not write to profile".red(), e);
        std::process::exit(1);
    }
    
    println!("{} {}", "✓ Added ProfileCore init to:".green(), profile_path.display());
}

fn print_success_message(shell: &str) {
    println!();
    println!("{}", "╔════════════════════════════════════════╗".green());
    println!("{}", "║  Installation Complete! ✓              ║".green());
    println!("{}", "╚════════════════════════════════════════╝".green());
    println!();
    println!("Next steps:");
    println!();
    
    match shell {
        "bash" => {
            println!("  1. Reload your shell:");
            println!("     {}", "source ~/.bashrc".cyan());
        }
        "zsh" => {
            println!("  1. Reload your shell:");
            println!("     {}", "source ~/.zshrc".cyan());
        }
        "fish" => {
            println!("  1. Reload your shell:");
            println!("     {}", "source ~/.config/fish/config.fish".cyan());
        }
        "powershell" => {
            println!("  1. Reload your shell:");
            println!("     {}", ". $PROFILE".cyan());
        }
        _ => {}
    }
    
    println!();
    println!("  2. Verify installation:");
    println!("     {}", "profilecore --version".cyan());
    println!();
    println!("  3. Try a command:");
    println!("     {}", "profilecore system info".cyan());
    println!("     {} {}", "sysinfo".cyan().italic(), "(using alias)".dimmed());
    println!();
    println!("  4. Get help:");
    println!("     {}", "profilecore --help".cyan());
    println!();
}

fn verify_installation(shell: &str) {
    println!();
    println!("{}", "═".repeat(50).dimmed());
    println!("{}", "Installation Verification".bold());
    println!("{}", "═".repeat(50).dimmed());
    println!();
    
    // Check 1: Binary in PATH
    if check_in_path() {
        println!("{} Binary in PATH", "✓".green());
    } else {
        println!("{} Binary NOT in PATH", "✗".red());
    }
    
    // Check 2: Profile file exists
    let profile_path = get_profile_path(shell);
    if profile_path.exists() {
        println!("{} Profile file exists: {}", "✓".green(), profile_path.display());
    } else {
        println!("{} Profile file NOT found: {}", "✗".red(), profile_path.display());
    }
    
    // Check 3: Init code present
    if is_already_installed(&profile_path) {
        println!("{} Init code added to profile", "✓".green());
    } else {
        println!("{} Init code NOT in profile", "✗".red());
    }
    
    // Check 4: Config directory
    let home = dirs::home_dir().expect("Could not find home directory");
    let config_dir = home.join(".config").join("profilecore");
    if config_dir.exists() {
        println!("{} Config directory exists: {}", "✓".green(), config_dir.display());
    } else {
        println!("{} Config directory created at: {}", "✓".green(), config_dir.display());
    }
    
    println!();
    println!("{}", "═".repeat(50).dimmed());
    println!();
}

// Uninstall functionality
pub fn run_uninstaller() {
    println!("{}", "╔════════════════════════════════════════╗".yellow());
    println!("{}", "║  ProfileCore v1.0.0 Uninstaller       ║".yellow());
    println!("{}", "╚════════════════════════════════════════╝".yellow());
    println!();
    
    let confirmed = Confirm::with_theme(&ColorfulTheme::default())
        .with_prompt("Are you sure you want to uninstall ProfileCore?")
        .default(false)
        .interact()
        .unwrap_or(false);
    
    if !confirmed {
        println!("{}", "Uninstall cancelled.".yellow());
        return;
    }
    
    println!();
    
    // Detect shell
    let detected_shell = detect_shell();
    let profile_path = get_profile_path(&detected_shell);
    
    // Remove init code from profile
    if profile_path.exists() {
        if let Ok(content) = fs::read_to_string(&profile_path) {
            let lines: Vec<&str> = content.lines().collect();
            let mut new_lines = Vec::new();
            let mut skip_until_end = false;
            
            for line in lines {
                if line.contains("ProfileCore v1.0.0 - Added by installer") {
                    skip_until_end = true;
                    continue;
                }
                
                if skip_until_end {
                    if line.trim().is_empty() || (!line.starts_with('#') && !line.starts_with("if") && !line.starts_with("eval") && !line.ends_with("fi") && !line.ends_with("end") && !line.ends_with("}")) {
                        skip_until_end = false;
                    } else {
                        continue;
                    }
                }
                
                new_lines.push(line);
            }
            
            if let Err(e) = fs::write(&profile_path, new_lines.join("\n")) {
                println!("{}: {}", "Error removing init code".red(), e);
            } else {
                println!("{} Removed init code from profile", "✓".green());
            }
        }
    }
    
    // Offer to remove config directory
    let home = dirs::home_dir().expect("Could not find home directory");
    let config_dir = home.join(".config").join("profilecore");
    
    if config_dir.exists() {
        let remove_config = Confirm::with_theme(&ColorfulTheme::default())
            .with_prompt("Also remove configuration directory?")
            .default(false)
            .interact()
            .unwrap_or(false);
        
        if remove_config {
            if let Err(e) = fs::remove_dir_all(&config_dir) {
                println!("{}: {}", "Error removing config directory".red(), e);
            } else {
                println!("{} Removed config directory", "✓".green());
            }
        }
    }
    
    println!();
    println!("{}", "╔════════════════════════════════════════╗".green());
    println!("{}", "║  Uninstall Complete! ✓                 ║".green());
    println!("{}", "╚════════════════════════════════════════╝".green());
    println!();
    println!("ProfileCore has been removed from your shell configuration.");
    println!();
    println!("To completely remove ProfileCore:");
    println!("  1. Delete the binary from your PATH");
    println!("  2. Restart your shell");
    println!();
}

