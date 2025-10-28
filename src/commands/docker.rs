//! Docker operations (using bollard library)

use bollard::container::{ListContainersOptions, StatsOptions};
use bollard::service::ContainerSummary;
use bollard::Docker;
use colored::Colorize;
use comfy_table::{presets::UTF8_FULL, Cell, Color, Table};
use futures::stream::StreamExt;

pub fn ps() {
    // Create a Tokio runtime
    let rt = match tokio::runtime::Runtime::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create runtime: {}", "✗".red(), e);
            return;
        }
    };

    rt.block_on(async {
        // Connect to Docker
        let docker = match Docker::connect_with_local_defaults() {
            Ok(d) => d,
            Err(e) => {
                eprintln!("{} Failed to connect to Docker: {}", "✗".red(), e);
                eprintln!("  Make sure Docker is running");
                return;
            }
        };

        // List containers
        let options = Some(ListContainersOptions::<String> {
            all: true,
            ..Default::default()
        });

        match docker.list_containers(options).await {
            Ok(containers) => {
                if containers.is_empty() {
                    println!("{} No containers found", "!".yellow());
                    return;
                }

                println!("\n{}", "Docker Containers".cyan().bold());
                println!("{}", "=".repeat(80));

                let mut table = Table::new();
                table.load_preset(UTF8_FULL);
                table.set_header(vec![
                    Cell::new("ID").fg(Color::Cyan),
                    Cell::new("Name").fg(Color::Cyan),
                    Cell::new("Image").fg(Color::Cyan),
                    Cell::new("Status").fg(Color::Cyan),
                    Cell::new("Ports").fg(Color::Cyan),
                ]);

                for container in containers {
                    let id = container.id.as_deref().unwrap_or("");
                    let short_id = if id.len() > 12 { &id[..12] } else { id };

                    let name = container
                        .names
                        .as_ref()
                        .and_then(|names| names.first())
                        .map(|n| n.trim_start_matches('/'))
                        .unwrap_or("-");

                    let image = container.image.as_deref().unwrap_or("");
                    let state = container.state.as_deref().unwrap_or("");
                    let status_str = container.status.as_deref().unwrap_or("");

                    let ports = format_ports(&container);

                    let status_cell = match state {
                        "running" => Cell::new(status_str).fg(Color::Green),
                        "exited" => Cell::new(status_str).fg(Color::Red),
                        _ => Cell::new(status_str).fg(Color::Yellow),
                    };

                    table.add_row(vec![
                        Cell::new(short_id),
                        Cell::new(name),
                        Cell::new(image),
                        status_cell,
                        Cell::new(&ports),
                    ]);
                }

                println!("{}\n", table);
            }
            Err(e) => {
                eprintln!("{} Failed to list containers: {}", "✗".red(), e);
            }
        }
    });
}

pub fn stats(container_name: &str) {
    let rt = match tokio::runtime::Runtime::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create runtime: {}", "✗".red(), e);
            return;
        }
    };

    rt.block_on(async {
        let docker = match Docker::connect_with_local_defaults() {
            Ok(d) => d,
            Err(e) => {
                eprintln!("{} Failed to connect to Docker: {}", "✗".red(), e);
                return;
            }
        };

        println!("\n{} {}", "Container Stats:".cyan().bold(), container_name);
        println!("{}", "=".repeat(60));

        let options = Some(StatsOptions {
            stream: false,
            one_shot: true,
        });

        let mut stream = docker.stats(container_name, options);

        if let Some(result) = stream.next().await {
            match result {
                Ok(stats) => {
                    // CPU
                    let cpu_delta = stats.cpu_stats.cpu_usage.total_usage
                        - stats.precpu_stats.cpu_usage.total_usage;
                    let system_delta = stats.cpu_stats.system_cpu_usage.unwrap_or(0)
                        - stats.precpu_stats.system_cpu_usage.unwrap_or(0);
                    let cpu_percent = if system_delta > 0 {
                        (cpu_delta as f64 / system_delta as f64) * 100.0
                    } else {
                        0.0
                    };

                    // Memory
                    let mem_usage = stats.memory_stats.usage.unwrap_or(0) as f64 / 1024.0 / 1024.0;
                    let mem_limit = stats.memory_stats.limit.unwrap_or(0) as f64 / 1024.0 / 1024.0;
                    let mem_percent = if mem_limit > 0.0 {
                        (mem_usage / mem_limit) * 100.0
                    } else {
                        0.0
                    };

                    println!("  CPU Usage:    {:.2}%", cpu_percent);
                    println!(
                        "  Memory Usage: {:.2} MB / {:.2} MB ({:.2}%)",
                        mem_usage, mem_limit, mem_percent
                    );

                    // Network
                    if let Some(networks) = stats.networks {
                        let mut total_rx = 0u64;
                        let mut total_tx = 0u64;
                        for (_, net) in networks {
                            total_rx += net.rx_bytes;
                            total_tx += net.tx_bytes;
                        }
                        println!(
                            "  Network RX:   {:.2} MB",
                            total_rx as f64 / 1024.0 / 1024.0
                        );
                        println!(
                            "  Network TX:   {:.2} MB",
                            total_tx as f64 / 1024.0 / 1024.0
                        );
                    }

                    println!();
                }
                Err(e) => {
                    eprintln!("{} Failed to get stats: {}", "✗".red(), e);
                }
            }
        } else {
            eprintln!("{} Container not found: {}", "✗".red(), container_name);
        }
    });
}

pub fn logs(container_name: &str, lines: usize) {
    let rt = match tokio::runtime::Runtime::new() {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Failed to create runtime: {}", "✗".red(), e);
            return;
        }
    };

    rt.block_on(async {
        let docker = match Docker::connect_with_local_defaults() {
            Ok(d) => d,
            Err(e) => {
                eprintln!("{} Failed to connect to Docker: {}", "✗".red(), e);
                return;
            }
        };

        println!(
            "\n{} {} (last {} lines)",
            "Container Logs:".cyan().bold(),
            container_name,
            lines
        );
        println!("{}", "=".repeat(60));

        let options = Some(bollard::container::LogsOptions::<String> {
            stdout: true,
            stderr: true,
            tail: lines.to_string(),
            ..Default::default()
        });

        let mut stream = docker.logs(container_name, options);

        while let Some(result) = stream.next().await {
            match result {
                Ok(log) => {
                    print!("{}", log);
                }
                Err(e) => {
                    eprintln!("{} Error reading logs: {}", "✗".red(), e);
                    break;
                }
            }
        }

        println!();
    });
}

fn format_ports(container: &ContainerSummary) -> String {
    if let Some(ports) = &container.ports {
        if ports.is_empty() {
            return "-".to_string();
        }

        let formatted: Vec<String> = ports
            .iter()
            .map(|p| match p.public_port {
                Some(public) => format!("{}:{}", public, p.private_port),
                None => format!("{}", p.private_port),
            })
            .collect();

        if formatted.is_empty() {
            "-".to_string()
        } else {
            formatted.join(", ")
        }
    } else {
        "-".to_string()
    }
}
