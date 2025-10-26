//! Network utility commands

use colored::Colorize;
use std::net::{TcpStream, ToSocketAddrs, IpAddr};
use std::time::Duration;
use comfy_table::{Table, presets::UTF8_FULL, Cell, Color};
use trust_dns_resolver::TokioAsyncResolver;

pub fn public_ip() {
    match get_public_ip() {
        Ok(ip) => println!("{} {}", "✓".green(), ip),
        Err(e) => eprintln!("{} Failed to get public IP: {}", "✗".red(), e),
    }
}

fn get_public_ip() -> anyhow::Result<String> {
    let response = reqwest::blocking::get("https://api.ipify.org")?;
    Ok(response.text()?)
}

pub fn test_port(host: &str, port: u16) {
    println!("Testing {}:{}...", host, port);
    
    let addr = format!("{}:{}", host, port);
    match addr.to_socket_addrs() {
        Ok(mut addrs) => {
            if let Some(addr) = addrs.next() {
                match TcpStream::connect_timeout(&addr, Duration::from_secs(5)) {
                    Ok(_) => println!("{} Port {} is OPEN", "✓".green(), port),
                    Err(_) => println!("{} Port {} is CLOSED", "✗".red(), port),
                }
            } else {
                eprintln!("{} Could not resolve host", "✗".red());
            }
        }
        Err(e) => eprintln!("{} Failed to resolve address: {}", "✗".red(), e),
    }
}

pub fn local_ips() {
    match local_ip_address::local_ip() {
        Ok(ip) => println!("{} Local IP: {}", "✓".green(), ip),
        Err(e) => eprintln!("{} Failed to get local IP: {}", "✗".red(), e),
    }
}

pub fn dns_lookup(domain: &str) {
    // Create a Tokio runtime for async DNS resolution
    let rt = match tokio::runtime::Runtime::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create runtime: {}", "✗".red(), e);
            return;
        }
    };
    
    rt.block_on(async {
        // Create resolver with system config
        let resolver = match TokioAsyncResolver::tokio_from_system_conf() {
            Ok(r) => r,
            Err(e) => {
                eprintln!("{} Failed to create resolver: {}", "✗".red(), e);
                return;
            }
        };
        
        println!("\n{} {}", "DNS Lookup:".cyan().bold(), domain);
        println!("{}", "=".repeat(60));
        
        // A records (IPv4)
        match resolver.ipv4_lookup(domain).await {
            Ok(response) => {
                let mut table = Table::new();
                table.load_preset(UTF8_FULL);
                table.set_header(vec![
                    Cell::new("Type").fg(Color::Cyan),
                    Cell::new("Address").fg(Color::Cyan),
                ]);
                
                for ip in response.iter() {
                    table.add_row(vec![
                        Cell::new("A"),
                        Cell::new(&ip.to_string()).fg(Color::Green),
                    ]);
                }
                
                println!("{}", table);
            }
            Err(_) => println!("{} No A (IPv4) records found", "!".yellow()),
        }
        
        // AAAA records (IPv6)
        match resolver.ipv6_lookup(domain).await {
            Ok(response) => {
                let mut table = Table::new();
                table.load_preset(UTF8_FULL);
                table.set_header(vec![
                    Cell::new("Type").fg(Color::Cyan),
                    Cell::new("Address").fg(Color::Cyan),
                ]);
                
                for ip in response.iter() {
                    table.add_row(vec![
                        Cell::new("AAAA"),
                        Cell::new(&ip.to_string()).fg(Color::Green),
                    ]);
                }
                
                println!("{}", table);
            }
            Err(_) => println!("{} No AAAA (IPv6) records found", "!".yellow()),
        }
        
        // MX records
        match resolver.mx_lookup(domain).await {
            Ok(response) => {
                let mut table = Table::new();
                table.load_preset(UTF8_FULL);
                table.set_header(vec![
                    Cell::new("Type").fg(Color::Cyan),
                    Cell::new("Priority").fg(Color::Cyan),
                    Cell::new("Mail Server").fg(Color::Cyan),
                ]);
                
                for mx in response.iter() {
                    table.add_row(vec![
                        Cell::new("MX"),
                        Cell::new(&mx.preference().to_string()),
                        Cell::new(&mx.exchange().to_string()).fg(Color::Green),
                    ]);
                }
                
                println!("{}", table);
            }
            Err(_) => println!("{} No MX (mail) records found", "!".yellow()),
        }
        
        println!();
    });
}

pub fn reverse_dns(ip_str: &str) {
    // Parse IP address
    let ip: IpAddr = match ip_str.parse() {
        Ok(i) => i,
        Err(e) => {
            eprintln!("{} Invalid IP address: {}", "✗".red(), e);
            return;
        }
    };
    
    // Create a Tokio runtime for async DNS resolution
    let rt = match tokio::runtime::Runtime::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create runtime: {}", "✗".red(), e);
            return;
        }
    };
    
    rt.block_on(async {
        // Create resolver with system config
        let resolver = match TokioAsyncResolver::tokio_from_system_conf() {
            Ok(r) => r,
            Err(e) => {
                eprintln!("{} Failed to create resolver: {}", "✗".red(), e);
                return;
            }
        };
        
        println!("\n{} {}", "Reverse DNS:".cyan().bold(), ip);
        println!("{}", "=".repeat(60));
        
        // Perform reverse lookup
        match resolver.reverse_lookup(ip).await {
            Ok(response) => {
                for name in response.iter() {
                    println!("{} {}", "✓".green(), name.to_string());
                }
            }
            Err(e) => {
                eprintln!("{} No PTR records found: {}", "!".yellow(), e);
            }
        }
        
        println!();
    });
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_port_validation() {
        // Test that port numbers are valid u16
        let valid_port: u16 = 80;
        assert!(valid_port > 0);
        
        // Test max port
        let max_port: u16 = 65535;
        assert_eq!(max_port, u16::MAX);
    }
    
    #[test]
    fn test_address_formatting() {
        // Test address string formatting
        let host = "localhost";
        let port: u16 = 8080;
        let addr = format!("{}:{}", host, port);
        assert_eq!(addr, "localhost:8080");
    }
    
    #[test]
    fn test_localhost_resolution() {
        // Test that localhost resolves
        let addr = "localhost:80";
        let result = addr.to_socket_addrs();
        assert!(result.is_ok());
    }
}

pub fn whois(domain: &str) {
    println!("\n{} {}", "WHOIS Lookup:".cyan().bold(), domain);
    println!("{}", "=".repeat(60));
    
    // Check if whois command is available
    if which::which("whois").is_err() {
        eprintln!("{} whois command not found", "✗".red());
        eprintln!("  Install: apt install whois / brew install whois");
        return;
    }
    
    // Execute whois command
    let output = std::process::Command::new("whois")
        .arg(domain)
        .output();
    
    match output {
        Ok(result) => {
            if result.status.success() {
                let stdout = String::from_utf8_lossy(&result.stdout);
                println!("{}", stdout);
            } else {
                let stderr = String::from_utf8_lossy(&result.stderr);
                eprintln!("{} whois failed: {}", "✗".red(), stderr);
            }
        }
        Err(e) => {
            eprintln!("{} Failed to execute whois: {}", "✗".red(), e);
        }
    }
}

pub fn trace(host: &str, max_hops: u32) {
    println!("\n{} {} (max {} hops)", "Traceroute:".cyan().bold(), host, max_hops);
    println!("{}", "=".repeat(60));
    
    // Determine the traceroute command based on OS
    let max_hops_str = max_hops.to_string();
    let (cmd, args) = if cfg!(windows) {
        ("tracert", vec!["-h", max_hops_str.as_str(), host])
    } else {
        ("traceroute", vec!["-m", max_hops_str.as_str(), host])
    };
    
    // Check if command is available
    if which::which(cmd).is_err() {
        eprintln!("{} {} command not found", "✗".red(), cmd);
        if !cfg!(windows) {
            eprintln!("  Install: apt install traceroute / brew install traceroute");
        }
        return;
    }
    
    // Execute traceroute
    let output = std::process::Command::new(cmd)
        .args(&args)
        .output();
    
    match output {
        Ok(result) => {
            if result.status.success() {
                let stdout = String::from_utf8_lossy(&result.stdout);
                println!("{}", stdout);
            } else {
                let stderr = String::from_utf8_lossy(&result.stderr);
                eprintln!("{} {} failed: {}", "✗".red(), cmd, stderr);
            }
        }
        Err(e) => {
            eprintln!("{} Failed to execute {}: {}", "✗".red(), cmd, e);
        }
    }
}

pub fn ping(host: &str, count: u32) {
    println!("\n{} {} ({} packets)", "Ping:".cyan().bold(), host, count);
    println!("{}", "=".repeat(60));
    
    // Determine ping command based on OS
    let count_str = count.to_string();
    let (cmd, args) = if cfg!(windows) {
        ("ping", vec!["-n", count_str.as_str(), host])
    } else {
        ("ping", vec!["-c", count_str.as_str(), host])
    };
    
    // Execute ping
    let output = std::process::Command::new(cmd)
        .args(&args)
        .output();
    
    match output {
        Ok(result) => {
            if result.status.success() {
                let stdout = String::from_utf8_lossy(&result.stdout);
                println!("{}", stdout);
            } else {
                let stderr = String::from_utf8_lossy(&result.stderr);
                eprintln!("{} ping failed: {}", "✗".red(), stderr);
            }
        }
        Err(e) => {
            eprintln!("{} Failed to execute ping: {}", "✗".red(), e);
        }
    }
}

