//! Utility commands (calc, random, sleep, time, config)

use chrono::{Local, Utc};
use colored::Colorize;
use rand::Rng;
use std::time::Duration;

pub fn calculate(expression: &str) {
    println!("\n{} {}", "Calculating:".cyan().bold(), expression.yellow());
    println!("{}", "=".repeat(60));

    // Simple calculator using meval
    match meval::eval_str(expression) {
        Ok(result) => {
            println!("Result: {}", result.to_string().green());
        }
        Err(e) => {
            eprintln!("{} Invalid expression: {}", "✗".red(), e);
            eprintln!("Examples: '2 + 2', '10 * 5', '100 / 4', 'sqrt(16)'");
        }
    }

    println!();
}

pub fn random_gen(min: i64, max: i64, count: usize) {
    println!("\n{}", "Random Number Generator".cyan().bold());
    println!("{}", "=".repeat(60));
    println!(
        "Range: {} to {}",
        min.to_string().cyan(),
        max.to_string().cyan()
    );
    println!("Count: {}\n", count.to_string().cyan());

    let mut rng = rand::thread_rng();

    for i in 0..count {
        let num = rng.gen_range(min..=max);
        println!(
            "{}: {}",
            (i + 1).to_string().cyan(),
            num.to_string().green()
        );
    }

    println!();
}

pub fn random_string(length: usize, charset: &str) {
    println!("\n{}", "Random String Generator".cyan().bold());
    println!("{}", "=".repeat(60));

    let chars = match charset {
        "alpha" => "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "numeric" => "0123456789",
        "alphanumeric" => "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        "hex" => "0123456789abcdef",
        _ => "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()",
    };

    let mut rng = rand::thread_rng();
    let result: String = (0..length)
        .map(|_| {
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    println!("Length: {}", length.to_string().cyan());
    println!("Charset: {}", charset.cyan());
    println!("Result: {}", result.green());
    println!();
}

pub fn sleep_cmd(seconds: u64) {
    println!(
        "\n{} {} seconds...",
        "Sleeping for".cyan().bold(),
        seconds.to_string().yellow()
    );

    std::thread::sleep(Duration::from_secs(seconds));

    println!("{} Awake!", "✓".green());
    println!();
}

pub fn time_now(utc: bool) {
    println!("\n{}", "Current Time".cyan().bold());
    println!("{}", "=".repeat(60));

    if utc {
        let now = Utc::now();
        println!(
            "UTC:         {}",
            now.format("%Y-%m-%d %H:%M:%S %Z").to_string().green()
        );
        println!("ISO 8601:    {}", now.to_rfc3339().cyan());
        println!("Unix:        {}", now.timestamp().to_string().yellow());
    } else {
        let now = Local::now();
        println!(
            "Local:       {}",
            now.format("%Y-%m-%d %H:%M:%S %Z").to_string().green()
        );
        println!("ISO 8601:    {}", now.to_rfc3339().cyan());
        println!("Unix:        {}", now.timestamp().to_string().yellow());
    }

    println!();
}

pub fn time_zones() {
    println!("\n{}", "Time Zones".cyan().bold());
    println!("{}", "=".repeat(60));

    let utc = Utc::now();
    let local = Local::now();

    println!(
        "UTC:         {}",
        utc.format("%H:%M:%S").to_string().green()
    );
    println!(
        "Local:       {} ({})",
        local.format("%H:%M:%S").to_string().green(),
        local.format("%Z").to_string().cyan()
    );
    println!("Offset:      {}", local.offset().to_string().yellow());

    println!();
}

pub fn version_info() {
    println!("\n{}", "ProfileCore Version Information".cyan().bold());
    println!("{}", "=".repeat(60));
    println!("Version:     {}", "1.0.0".green());

    // Get Rust version from environment or default
    let rust_version =
        option_env!("RUSTC_VERSION").unwrap_or(env!("CARGO_PKG_RUST_VERSION", "unknown"));
    println!("Rust:        {}", rust_version);

    // Get target architecture
    let target = if cfg!(target_arch = "x86_64") && cfg!(target_os = "windows") {
        "x86_64-pc-windows-msvc"
    } else if cfg!(target_arch = "x86_64") && cfg!(target_os = "linux") {
        "x86_64-unknown-linux-gnu"
    } else if cfg!(target_arch = "x86_64") && cfg!(target_os = "macos") {
        "x86_64-apple-darwin"
    } else if cfg!(target_arch = "aarch64") && cfg!(target_os = "macos") {
        "aarch64-apple-darwin"
    } else {
        "unknown"
    };
    println!("Target:      {}", target);

    println!(
        "Build:       {} profile",
        if cfg!(debug_assertions) {
            "debug"
        } else {
            "release"
        }
    );
    println!("Features:    {} commands implemented", "97".cyan());
    println!();
    println!(
        "Repository:  {}",
        "https://github.com/mythic3011/ProfileCore".cyan()
    );
    println!("License:     MIT");
    println!();
}

// Config management (simplified - just show concept)
pub fn config_get(key: &str) {
    println!("\n{} {}", "Configuration:".cyan().bold(), key.yellow());
    println!("{}", "=".repeat(60));

    // In a real implementation, this would read from a config file
    match key {
        "version" => println!("Value: {}", "1.0.0".green()),
        "theme" => println!("Value: {}", "default".green()),
        _ => {
            eprintln!("{} Configuration key '{}' not found", "✗".red(), key);
            println!("Available keys: version, theme");
        }
    }

    println!();
}

pub fn config_set(key: &str, value: &str) {
    println!("\n{}", "Setting Configuration".cyan().bold());
    println!("{}", "=".repeat(60));
    println!("Key:   {}", key.cyan());
    println!("Value: {}", value.yellow());

    // In a real implementation, this would write to a config file
    println!(
        "\n{} Configuration would be saved (feature in development)",
        "ℹ".cyan()
    );
    println!();
}

pub fn config_list() {
    println!("\n{}", "Configuration".cyan().bold());
    println!("{}", "=".repeat(60));

    // In a real implementation, this would read from a config file
    println!("version = {}", "1.0.0".green());
    println!("theme = {}", "default".green());

    println!();
}
