//! Process management commands

use colored::Colorize;
use comfy_table::{Table, presets::UTF8_FULL, Cell, Color};
use sysinfo::{System, Pid};
use std::process::Command as StdCommand;

pub fn list(limit: usize) {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    println!("\n{}", "Running Processes".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let mut processes: Vec<_> = sys.processes().values().collect();
    processes.sort_by_key(|b| std::cmp::Reverse(b.memory()));
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("PID").fg(Color::Cyan),
        Cell::new("Name").fg(Color::Cyan),
        Cell::new("Memory (MB)").fg(Color::Cyan),
        Cell::new("CPU %").fg(Color::Cyan),
        Cell::new("Status").fg(Color::Cyan),
    ]);
    
    for process in processes.iter().take(limit) {
        let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
        let status = format!("{:?}", process.status());
        
        table.add_row(vec![
            Cell::new(process.pid().to_string()),
            Cell::new(process.name().to_string_lossy().to_string()),
            Cell::new(format!("{:.2}", mem_mb)),
            Cell::new(format!("{:.1}", process.cpu_usage())),
            Cell::new(status),
        ]);
    }
    
    println!("{}\n", table);
    println!("Total processes: {}", sys.processes().len());
    println!();
}

pub fn kill(pid: u32, force: bool) {
    println!("\n{} process with PID: {}", "Terminating".yellow(), pid.to_string().cyan());
    
    #[cfg(windows)]
    {
        let pid_str = pid.to_string();
        let args = if force {
            vec!["/F", "/PID", &pid_str]
        } else {
            vec!["/PID", &pid_str]
        };
        
        match StdCommand::new("taskkill").args(&args).status() {
            Ok(status) => {
                if status.success() {
                    println!("{} Process terminated successfully", "✓".green());
                } else {
                    eprintln!("{} Failed to terminate process", "✗".red());
                }
            }
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        }
    }
    
    #[cfg(unix)]
    {
        let signal = if force { "9" } else { "15" };
        let pid_str = pid.to_string();
        
        match StdCommand::new("kill")
            .args(&[format!("-{}", signal), pid_str])
            .status()
        {
            Ok(status) => {
                if status.success() {
                    println!("{} Process terminated successfully", "✓".green());
                } else {
                    eprintln!("{} Failed to terminate process", "✗".red());
                }
            }
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        }
    }
    
    println!();
}

pub fn info(pid_input: u32) {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    let pid = Pid::from_u32(pid_input);
    
    match sys.process(pid) {
        Some(process) => {
            println!("\n{} {}", "Process Information for PID:".cyan().bold(), pid_input.to_string().yellow());
            println!("{}", "=".repeat(60));
            
            println!("  Name:        {}", process.name().to_string_lossy());
            println!("  PID:         {}", process.pid());
            
            if let Some(parent) = process.parent() {
                println!("  Parent PID:  {}", parent);
            }
            
            let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
            println!("  Memory:      {:.2} MB", mem_mb);
            println!("  CPU Usage:   {:.1}%", process.cpu_usage());
            println!("  Status:      {:?}", process.status());
            
            if let Some(exe) = process.exe() {
                println!("  Executable:  {}", exe.display());
            }
            
            if let Some(cwd) = process.cwd() {
                println!("  Working Dir: {}", cwd.display());
            }
            
            println!();
        }
        None => {
            eprintln!("{} Process with PID {} not found", "✗".red(), pid_input);
            println!();
        }
    }
}

pub fn tree() {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    println!("\n{}", "Process Tree (Top Processes)".cyan().bold());
    println!("{}", "=".repeat(80));
    
    // Get root processes (those without parents or with PID 1)
    let mut root_processes: Vec<_> = sys
        .processes()
        .values()
        .filter(|p| p.parent().is_none() || p.parent() == Some(Pid::from_u32(0)))
        .collect();
    
    root_processes.sort_by_key(|p| p.pid());
    
    // Show top 10 root processes and their immediate children
    for process in root_processes.iter().take(10) {
        print_process_tree(process, &sys, 0, 2);
    }
    
    println!();
}

fn print_process_tree(process: &sysinfo::Process, sys: &System, depth: usize, max_depth: usize) {
    if depth > max_depth {
        return;
    }
    
    let indent = "  ".repeat(depth);
    let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
    
    println!(
        "{}├─ {} [PID: {}, Mem: {:.1} MB]",
        indent,
        process.name().to_string_lossy().to_string().cyan(),
        process.pid(),
        mem_mb
    );
    
    // Find and print children
    let children: Vec<_> = sys
        .processes()
        .values()
        .filter(|p| p.parent() == Some(process.pid()))
        .take(3) // Limit children shown
        .collect();
    
    for child in children {
        print_process_tree(child, sys, depth + 1, max_depth);
    }
}

