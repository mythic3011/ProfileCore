//! Environment variable operations

use colored::Colorize;
use comfy_table::{Table, presets::UTF8_FULL, Cell, Color};
use std::env;

pub fn list() {
    println!("\n{}", "Environment Variables".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let mut vars: Vec<(String, String)> = env::vars().collect();
    vars.sort_by(|a, b| a.0.cmp(&b.0));
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Variable").fg(Color::Cyan),
        Cell::new("Value").fg(Color::Cyan),
    ]);
    
    for (key, value) in vars {
        // Truncate long values
        let display_value = if value.len() > 80 {
            format!("{}...", &value[..77])
        } else {
            value
        };
        
        table.add_row(vec![
            Cell::new(&key),
            Cell::new(&display_value),
        ]);
    }
    
    println!("{}\n", table);
}

pub fn get(variable: &str) {
    println!("\n{} {}", "Environment Variable:".cyan().bold(), variable.yellow());
    println!("{}", "=".repeat(60));
    
    match env::var(variable) {
        Ok(value) => {
            println!("  {}", value.green());
        }
        Err(_) => {
            eprintln!("{} Variable '{}' not found", "✗".red(), variable);
        }
    }
    
    println!();
}

pub fn set(variable: &str, value: &str) {
    env::set_var(variable, value);
    println!("{} Set {} = {}", "✓".green(), variable.cyan(), value.yellow());
    println!("{} Note: This only affects the current process", "!".yellow());
    println!();
}

