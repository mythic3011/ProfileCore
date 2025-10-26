//! Git operations (using git2 library)

use colored::Colorize;
use git2::Repository;
use std::env;
use comfy_table::{Table, presets::UTF8_FULL, Cell, Color};
use crate::config::{GitAccountsConfig, GitAccount};

pub fn status() {
    let current_dir = match env::current_dir() {
        Ok(dir) => dir,
        Err(e) => {
            eprintln!("{} Failed to get current directory: {}", "✗".red(), e);
            return;
        }
    };
    
    let repo = match Repository::discover(&current_dir) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Not a git repository: {}", "✗".red(), e);
            return;
        }
    };
    
    // Get current branch
    let head = match repo.head() {
        Ok(h) => h,
        Err(e) => {
            eprintln!("{} Failed to get HEAD: {}", "✗".red(), e);
            return;
        }
    };
    
    let branch_name = head.shorthand().unwrap_or("(detached)");
    println!("{} On branch: {}", "✓".green(), branch_name.cyan());
    
    // Get status
    let statuses = match repo.statuses(None) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("{} Failed to get status: {}", "✗".red(), e);
            return;
        }
    };
    
    if statuses.is_empty() {
        println!("{} Working tree clean", "✓".green());
    } else {
        println!("\n{} Changes:", "!".yellow());
        for entry in statuses.iter() {
            let status = entry.status();
            let path = entry.path().unwrap_or("?");
            
            if status.is_index_new() || status.is_wt_new() {
                println!("  {} {}", "+".green(), path);
            } else if status.is_index_modified() || status.is_wt_modified() {
                println!("  {} {}", "M".yellow(), path);
            } else if status.is_index_deleted() || status.is_wt_deleted() {
                println!("  {} {}", "D".red(), path);
            }
        }
    }
}

pub fn switch_account(account_name: &str) {
    // Load config
    let config = match GitAccountsConfig::load() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to load config: {}", "✗".red(), e);
            return;
        }
    };
    
    // Find account
    let account = match config.find_account(account_name) {
        Some(a) => a,
        None => {
            eprintln!("{} Account '{}' not found", "✗".red(), account_name);
            println!("  Run: profilecore git list-accounts");
            return;
        }
    };
    
    // Get current repo
    let current_dir = match env::current_dir() {
        Ok(dir) => dir,
        Err(e) => {
            eprintln!("{} Failed to get current directory: {}", "✗".red(), e);
            return;
        }
    };
    
    let repo = match Repository::discover(&current_dir) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Not a git repository: {}", "✗".red(), e);
            return;
        }
    };
    
    // Get repo config
    let mut git_config = match repo.config() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to get git config: {}", "✗".red(), e);
            return;
        }
    };
    
    // Set user.name and user.email
    if let Err(e) = git_config.set_str("user.name", &account.name) {
        eprintln!("{} Failed to set user.name: {}", "✗".red(), e);
        return;
    }
    
    if let Err(e) = git_config.set_str("user.email", &account.email) {
        eprintln!("{} Failed to set user.email: {}", "✗".red(), e);
        return;
    }
    
    // Optionally set signing key
    if let Some(ref key) = account.signing_key {
        if let Err(e) = git_config.set_str("user.signingkey", key) {
            eprintln!("{} Warning: Failed to set signing key: {}", "!".yellow(), e);
        }
    }
    
    println!("{} Switched to account: {}", "✓".green(), account_name.cyan());
    println!("  Name:  {}", account.name);
    println!("  Email: {}", account.email);
    if let Some(ref key) = account.signing_key {
        println!("  Key:   {}", key);
    }
}

pub fn add_account(name: String, email: String, signing_key: Option<String>) {
    let mut config = match GitAccountsConfig::load() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to load config: {}", "✗".red(), e);
            return;
        }
    };
    
    let account = GitAccount {
        name: name.clone(),
        email: email.clone(),
        signing_key,
    };
    
    match config.add_account(account) {
        Ok(_) => {
            println!("{} Added account: {}", "✓".green(), name.cyan());
            println!("  Name:  {}", name);
            println!("  Email: {}", email);
        }
        Err(e) => {
            eprintln!("{} Failed to add account: {}", "✗".red(), e);
        }
    }
}

pub fn list_accounts() {
    let config = match GitAccountsConfig::load() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to load config: {}", "✗".red(), e);
            return;
        }
    };
    
    if config.accounts.is_empty() {
        println!("{} No accounts configured", "!".yellow());
        println!("  Add one: profilecore git add-account <name> <email>");
        return;
    }
    
    // Get current git user (if in a repo)
    let current_email = if let Ok(dir) = env::current_dir() {
        if let Ok(repo) = Repository::discover(&dir) {
            if let Ok(git_config) = repo.config() {
                git_config.get_string("user.email").ok()
            } else {
                None
            }
        } else {
            None
        }
    } else {
        None
    };
    
    println!("\n{}", "Git Accounts".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Name").fg(Color::Cyan),
        Cell::new("Email").fg(Color::Cyan),
        Cell::new("Signing Key").fg(Color::Cyan),
        Cell::new("Active").fg(Color::Cyan),
    ]);
    
    for account in &config.accounts {
        let is_active = current_email.as_deref() == Some(&account.email);
        let active_marker = if is_active { "✓" } else { "" };
        
        table.add_row(vec![
            Cell::new(&account.name),
            Cell::new(&account.email),
            Cell::new(account.signing_key.as_deref().unwrap_or("-")),
            Cell::new(active_marker).fg(if is_active { Color::Green } else { Color::Reset }),
        ]);
    }
    
    println!("{}\n", table);
}

pub fn whoami() {
    let current_dir = match env::current_dir() {
        Ok(dir) => dir,
        Err(e) => {
            eprintln!("{} Failed to get current directory: {}", "✗".red(), e);
            return;
        }
    };
    
    let repo = match Repository::discover(&current_dir) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Not a git repository: {}", "✗".red(), e);
            return;
        }
    };
    
    let git_config = match repo.config() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to get git config: {}", "✗".red(), e);
            return;
        }
    };
    
    let name = git_config.get_string("user.name").unwrap_or_else(|_| "(not set)".to_string());
    let email = git_config.get_string("user.email").unwrap_or_else(|_| "(not set)".to_string());
    let signing_key = git_config.get_string("user.signingkey").ok();
    
    println!("\n{}", "Current Git Identity".cyan().bold());
    println!("{}", "=".repeat(60));
    println!("  Name:  {}", name);
    println!("  Email: {}", email);
    if let Some(key) = signing_key {
        println!("  Key:   {}", key);
    }
    println!();
}

