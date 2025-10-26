//! System information commands (using sysinfo library)

use sysinfo::{System, Disks, Networks, Components};
use comfy_table::{Table, presets::UTF8_FULL, Cell, Color};
use colored::Colorize;

pub fn info(format: Option<&str>) {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    match format {
        Some("json") => print_json(&sys),
        _ => print_table(&sys),
    }
}

fn print_table(sys: &System) {
    println!("\n{}", "=".repeat(60).cyan());
    println!("{}", "SYSTEM INFORMATION".cyan().bold());
    println!("{}\n", "=".repeat(60).cyan());
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    
    // OS Info
    table.add_row(vec![
        Cell::new("OS").fg(Color::Yellow),
        Cell::new(System::name().unwrap_or_else(|| "Unknown".to_string())),
    ]);
    table.add_row(vec![
        Cell::new("OS Version").fg(Color::Yellow),
        Cell::new(System::os_version().unwrap_or_else(|| "Unknown".to_string())),
    ]);
    table.add_row(vec![
        Cell::new("Kernel").fg(Color::Yellow),
        Cell::new(System::kernel_version().unwrap_or_else(|| "Unknown".to_string())),
    ]);
    table.add_row(vec![
        Cell::new("Hostname").fg(Color::Yellow),
        Cell::new(System::host_name().unwrap_or_else(|| "Unknown".to_string())),
    ]);
    
    // CPU Info
    table.add_row(vec![
        Cell::new("CPU Cores").fg(Color::Yellow),
        Cell::new(sys.cpus().len().to_string()),
    ]);
    
    // Memory
    let total_mem_gb = sys.total_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let used_mem_gb = sys.used_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let mem_usage = (used_mem_gb / total_mem_gb * 100.0) as u32;
    
    table.add_row(vec![
        Cell::new("Memory").fg(Color::Yellow),
        Cell::new(format!("{:.2} GB / {:.2} GB ({}%)", used_mem_gb, total_mem_gb, mem_usage)),
    ]);
    
    // Disk Info
    let disks = Disks::new_with_refreshed_list();
    for disk in &disks {
        let total_gb = disk.total_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let avail_gb = disk.available_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let used_gb = total_gb - avail_gb;
        let usage = (used_gb / total_gb * 100.0) as u32;
        
        table.add_row(vec![
            Cell::new(format!("Disk ({})", disk.mount_point().display())).fg(Color::Yellow),
            Cell::new(format!("{:.2} GB / {:.2} GB ({}%)", used_gb, total_gb, usage)),
        ]);
    }
    
    println!("{}\n", table);
}

fn print_json(sys: &System) {
    let json = serde_json::json!({
        "os": System::name().unwrap_or_else(|| "Unknown".to_string()),
        "os_version": System::os_version().unwrap_or_else(|| "Unknown".to_string()),
        "kernel": System::kernel_version().unwrap_or_else(|| "Unknown".to_string()),
        "hostname": System::host_name().unwrap_or_else(|| "Unknown".to_string()),
        "cpu_cores": sys.cpus().len(),
        "total_memory_gb": sys.total_memory() as f64 / 1024.0 / 1024.0 / 1024.0,
        "used_memory_gb": sys.used_memory() as f64 / 1024.0 / 1024.0 / 1024.0,
    });
    
    println!("{}", serde_json::to_string_pretty(&json).unwrap());
}

pub fn uptime() {
    let uptime_secs = System::uptime();
    let days = uptime_secs / 86400;
    let hours = (uptime_secs % 86400) / 3600;
    let minutes = (uptime_secs % 3600) / 60;
    
    println!("\n{}", "System Uptime".cyan().bold());
    println!("{}", "=".repeat(40));
    println!("  {} days, {} hours, {} minutes", days, hours, minutes);
    println!("  ({} seconds total)\n", uptime_secs);
}

pub fn processes(limit: usize) {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    println!("\n{}", "Top Processes (by memory)".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let mut processes: Vec<_> = sys.processes().values().collect();
    processes.sort_by(|a, b| b.memory().cmp(&a.memory()));
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("PID").fg(Color::Cyan),
        Cell::new("Name").fg(Color::Cyan),
        Cell::new("Memory (MB)").fg(Color::Cyan),
        Cell::new("CPU %").fg(Color::Cyan),
    ]);
    
    for process in processes.iter().take(limit) {
        let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
        table.add_row(vec![
            Cell::new(process.pid().to_string()),
            Cell::new(process.name().to_string_lossy().to_string()),
            Cell::new(format!("{:.2}", mem_mb)),
            Cell::new(format!("{:.1}", process.cpu_usage())),
        ]);
    }
    
    println!("{}\n", table);
}

pub fn disk_usage() {
    println!("\n{}", "Disk Usage".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let disks = Disks::new_with_refreshed_list();
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Mount Point").fg(Color::Cyan),
        Cell::new("Total").fg(Color::Cyan),
        Cell::new("Used").fg(Color::Cyan),
        Cell::new("Available").fg(Color::Cyan),
        Cell::new("Usage %").fg(Color::Cyan),
        Cell::new("Filesystem").fg(Color::Cyan),
    ]);
    
    for disk in &disks {
        let total_gb = disk.total_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let avail_gb = disk.available_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let used_gb = total_gb - avail_gb;
        let usage = (used_gb / total_gb * 100.0) as u32;
        
        let usage_cell = if usage >= 90 {
            Cell::new(format!("{}%", usage)).fg(Color::Red)
        } else if usage >= 75 {
            Cell::new(format!("{}%", usage)).fg(Color::Yellow)
        } else {
            Cell::new(format!("{}%", usage)).fg(Color::Green)
        };
        
        table.add_row(vec![
            Cell::new(format!("{}", disk.mount_point().display())),
            Cell::new(format!("{:.2} GB", total_gb)),
            Cell::new(format!("{:.2} GB", used_gb)),
            Cell::new(format!("{:.2} GB", avail_gb)),
            usage_cell,
            Cell::new(disk.file_system().to_string_lossy().to_string()),
        ]);
    }
    
    println!("{}\n", table);
}

pub fn memory() {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    println!("\n{}", "Memory Information".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let total_mem_gb = sys.total_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let used_mem_gb = sys.used_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let free_mem_gb = sys.free_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let avail_mem_gb = sys.available_memory() as f64 / 1024.0 / 1024.0 / 1024.0;
    let mem_usage = (used_mem_gb / total_mem_gb * 100.0) as u32;
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    
    table.add_row(vec![
        Cell::new("Total Memory").fg(Color::Yellow),
        Cell::new(format!("{:.2} GB", total_mem_gb)),
    ]);
    table.add_row(vec![
        Cell::new("Used Memory").fg(Color::Yellow),
        Cell::new(format!("{:.2} GB ({}%)", used_mem_gb, mem_usage)),
    ]);
    table.add_row(vec![
        Cell::new("Free Memory").fg(Color::Yellow),
        Cell::new(format!("{:.2} GB", free_mem_gb)),
    ]);
    table.add_row(vec![
        Cell::new("Available Memory").fg(Color::Yellow),
        Cell::new(format!("{:.2} GB", avail_mem_gb)),
    ]);
    
    println!("{}\n", table);
}

pub fn cpu() {
    let mut sys = System::new_all();
    sys.refresh_all();
    std::thread::sleep(std::time::Duration::from_millis(200));
    sys.refresh_cpu_all();
    
    println!("\n{}", "CPU Information".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("CPU").fg(Color::Cyan),
        Cell::new("Usage %").fg(Color::Cyan),
        Cell::new("Frequency (MHz)").fg(Color::Cyan),
        Cell::new("Brand").fg(Color::Cyan),
    ]);
    
    for (i, cpu) in sys.cpus().iter().enumerate() {
        let usage = cpu.cpu_usage();
        let usage_cell = if usage >= 90.0 {
            Cell::new(format!("{:.1}%", usage)).fg(Color::Red)
        } else if usage >= 70.0 {
            Cell::new(format!("{:.1}%", usage)).fg(Color::Yellow)
        } else {
            Cell::new(format!("{:.1}%", usage)).fg(Color::Green)
        };
        
        table.add_row(vec![
            Cell::new(format!("CPU {}", i)),
            usage_cell,
            Cell::new(format!("{}", cpu.frequency())),
            Cell::new(if i == 0 { cpu.brand() } else { "" }),
        ]);
    }
    
    println!("{}\n", table);
    
    // Overall CPU usage
    let total_usage = sys.cpus().iter().map(|cpu| cpu.cpu_usage()).sum::<f32>() / sys.cpus().len() as f32;
    println!("  Average CPU Usage: {:.1}%\n", total_usage);
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_system_info_runs() {
        // Test that system info doesn't panic
        let mut sys = System::new_all();
        sys.refresh_all();
        
        assert!(sys.cpus().len() > 0);
        assert!(sys.total_memory() > 0);
    }
    
    #[test]
    fn test_json_output_valid() {
        // Test that JSON output is valid
        let sys = System::new_all();
        let json = serde_json::json!({
            "os": System::name().unwrap_or_else(|| "Unknown".to_string()),
            "cpu_cores": sys.cpus().len(),
            "total_memory_gb": sys.total_memory() as f64 / 1024.0 / 1024.0 / 1024.0,
        });
        
        // Should serialize without error
        assert!(serde_json::to_string(&json).is_ok());
    }
}

pub fn load() {
    println!("\n{}", "System Load Average".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let load_avg = System::load_average();
    
    println!("1 minute:  {:.2}", load_avg.one);
    println!("5 minutes: {:.2}", load_avg.five);
    println!("15 minutes: {:.2}", load_avg.fifteen);
    
    println!();
}

pub fn network_stats() {
    let mut sys = System::new_all();
    sys.refresh_all();
    
    println!("\n{}", "Network Statistics".cyan().bold());
    println!("{}", "=".repeat(80));
    
    let networks = sysinfo::Networks::new_with_refreshed_list();
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Interface").fg(Color::Cyan),
        Cell::new("Received (bytes)").fg(Color::Cyan),
        Cell::new("Transmitted (bytes)").fg(Color::Cyan),
        Cell::new("Packets In").fg(Color::Cyan),
        Cell::new("Packets Out").fg(Color::Cyan),
        Cell::new("Errors In").fg(Color::Cyan),
        Cell::new("Errors Out").fg(Color::Cyan),
    ]);
    
    for (interface_name, network) in &networks {
        table.add_row(vec![
            Cell::new(interface_name),
            Cell::new(network.total_received().to_string()),
            Cell::new(network.total_transmitted().to_string()),
            Cell::new(network.total_packets_received().to_string()),
            Cell::new(network.total_packets_transmitted().to_string()),
            Cell::new(network.total_errors_on_received().to_string()),
            Cell::new(network.total_errors_on_transmitted().to_string()),
        ]);
    }
    
    println!("{}\n", table);
}

pub fn temperature() {
    println!("\n{}", "System Temperature Sensors".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let components = sysinfo::Components::new_with_refreshed_list();
    
    if components.is_empty() {
        println!("{} No temperature sensors found", "!".yellow());
        println!("Note: Temperature monitoring may require elevated privileges");
        println!();
        return;
    }
    
    let mut table = Table::new();
    table.load_preset(UTF8_FULL);
    table.set_header(vec![
        Cell::new("Component").fg(Color::Cyan),
        Cell::new("Temperature").fg(Color::Cyan),
        Cell::new("Max").fg(Color::Cyan),
        Cell::new("Critical").fg(Color::Cyan),
    ]);
    
    for component in &components {
        let temp = component.temperature();
        let max = component.max();
        let critical = component.critical();
        
        let temp_cell = if critical.is_some() && temp >= critical.unwrap() {
            Cell::new(format!("{:.1}°C", temp)).fg(Color::Red)
        } else if max > 0.0 && temp >= max * 0.9 {
            Cell::new(format!("{:.1}°C", temp)).fg(Color::Yellow)
        } else {
            Cell::new(format!("{:.1}°C", temp)).fg(Color::Green)
        };
        
        table.add_row(vec![
            Cell::new(component.label().to_string()),
            temp_cell,
            Cell::new(if max > 0.0 { format!("{:.1}°C", max) } else { "N/A".to_string() }),
            Cell::new(if let Some(c) = critical { format!("{:.1}°C", c) } else { "N/A".to_string() }),
        ]);
    }
    
    println!("{}\n", table);
}

