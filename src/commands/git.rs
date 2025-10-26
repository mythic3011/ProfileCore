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

pub fn log(limit: usize) {
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
    
    // Get HEAD
    let mut revwalk = match repo.revwalk() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create revwalk: {}", "✗".red(), e);
            return;
        }
    };
    
    if let Err(e) = revwalk.push_head() {
        eprintln!("{} Failed to push HEAD: {}", "✗".red(), e);
        return;
    }
    
    println!("\n{}", "Git Log".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let mut count = 0;
    for (index, oid) in revwalk.enumerate() {
        if index >= limit {
            break;
        }
        
        let oid = match oid {
            Ok(o) => o,
            Err(e) => {
                eprintln!("{} Failed to get OID: {}", "✗".red(), e);
                continue;
            }
        };
        
        let commit = match repo.find_commit(oid) {
            Ok(c) => c,
            Err(e) => {
                eprintln!("{} Failed to find commit: {}", "✗".red(), e);
                continue;
            }
        };
        
        let short_id = &oid.to_string()[..7];
        let message = commit.message().unwrap_or("(no message)").lines().next().unwrap_or("");
        let author = commit.author();
        let time = commit.time();
        
        // Convert timestamp to readable format
        let datetime = chrono::DateTime::from_timestamp(time.seconds(), 0)
            .unwrap_or_else(|| chrono::DateTime::from_timestamp(0, 0).unwrap());
        let formatted_time = datetime.format("%Y-%m-%d %H:%M:%S").to_string();
        
        println!("\n{} {}", "commit".yellow(), short_id.cyan());
        println!("Author: {} <{}>", author.name().unwrap_or("?"), author.email().unwrap_or("?"));
        println!("Date:   {}", formatted_time);
        println!("\n    {}", message);
        
        count += 1;
    }
    
    if count == 0 {
        println!("{} No commits found", "!".yellow());
    }
    
    println!();
}

pub fn diff() {
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
    
    println!("\n{}", "Git Diff (Working Tree Changes)".cyan().bold());
    println!("{}", "=".repeat(80));
    
    // Get the diff between HEAD and working directory
    let head_tree = match repo.head() {
        Ok(head) => match head.peel_to_tree() {
            Ok(tree) => Some(tree),
            Err(_) => None,
        },
        Err(_) => None,
    };
    
    let diff = match head_tree {
        Some(tree) => repo.diff_tree_to_workdir_with_index(Some(&tree), None),
        None => repo.diff_tree_to_workdir_with_index(None, None),
    };
    
    let diff = match diff {
        Ok(d) => d,
        Err(e) => {
            eprintln!("{} Failed to get diff: {}", "✗".red(), e);
            return;
        }
    };
    
    let stats = match diff.stats() {
        Ok(s) => s,
        Err(e) => {
            eprintln!("{} Failed to get stats: {}", "✗".red(), e);
            return;
        }
    };
    
    if stats.files_changed() == 0 {
        println!("{} No changes", "✓".green());
    } else {
        println!("\n{} {} file(s) changed, {} insertion(s)(+), {} deletion(s)(-)",
            "📊".to_string(),
            stats.files_changed(),
            stats.insertions(),
            stats.deletions()
        );
        
        // Print file-by-file stats
        diff.print(git2::DiffFormat::NameStatus, |_delta, _hunk, line| {
            let origin = line.origin();
            let content = String::from_utf8_lossy(line.content());
            
            match origin {
                '+' => print!("{}", format!("+ {}", content).green()),
                '-' => print!("{}", format!("- {}", content).red()),
                _ => print!("{}", content),
            }
            true
        }).ok();
    }
    
    println!();
}

pub fn branch(list_all: bool) {
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
    
    println!("\n{}", "Git Branches".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let branches = if list_all {
        repo.branches(Some(git2::BranchType::Local)).ok()
    } else {
        repo.branches(Some(git2::BranchType::Local)).ok()
    };
    
    let branches = match branches {
        Some(b) => b,
        None => {
            eprintln!("{} Failed to list branches", "✗".red());
            return;
        }
    };
    
    // Get current branch
    let head = repo.head().ok();
    let current_branch = head.and_then(|h| h.shorthand().map(|s| s.to_string()));
    
    let mut count = 0;
    for branch_result in branches {
        let (branch, _branch_type) = match branch_result {
            Ok(b) => b,
            Err(e) => {
                eprintln!("{} Error reading branch: {}", "!".yellow(), e);
                continue;
            }
        };
        
        let name = match branch.name() {
            Ok(Some(n)) => n,
            Ok(None) => "(unnamed)",
            Err(_) => "(error)",
        };
        
        let is_current = current_branch.as_deref() == Some(name);
        
        if is_current {
            println!("  {} {}", "*".green().bold(), name.green().bold());
        } else {
            println!("    {}", name);
        }
        
        count += 1;
    }
    
    if count == 0 {
        println!("{} No branches found", "!".yellow());
    }
    
    println!();
}

pub fn remote() {
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
    
    println!("\n{}", "Git Remotes".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let remotes = match repo.remotes() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to get remotes: {}", "✗".red(), e);
            return;
        }
    };
    
    if remotes.is_empty() {
        println!("{} No remotes configured", "!".yellow());
        println!();
        return;
    }
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Name").fg(Color::Cyan),
        Cell::new("URL").fg(Color::Cyan),
    ]);
    
    for remote_name in remotes.iter() {
        let remote_name = match remote_name {
            Some(n) => n,
            None => continue,
        };
        
        let remote = match repo.find_remote(remote_name) {
            Ok(r) => r,
            Err(_) => continue,
        };
        
        let url = remote.url().unwrap_or("(no URL)");
        
        table.add_row(vec![
            Cell::new(remote_name),
            Cell::new(url),
        ]);
    }
    
    println!("{}\n", table);
}

