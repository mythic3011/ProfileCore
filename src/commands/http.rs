//! HTTP utility commands

use colored::Colorize;
use reqwest::blocking::Client;
use std::fs::File;

pub fn get(url: &str, headers: Option<Vec<(String, String)>>) {
    println!("\n{} {}", "HTTP GET:".cyan().bold(), url.yellow());
    println!("{}", "=".repeat(80));

    let client = Client::new();
    let mut request = client.get(url);

    if let Some(hdrs) = headers {
        for (key, value) in hdrs {
            request = request.header(&key, &value);
        }
    }

    match request.send() {
        Ok(response) => {
            println!(
                "Status: {} {}",
                response.status().as_u16().to_string().green(),
                response.status().canonical_reason().unwrap_or("")
            );
            println!("\n{}", "Headers:".cyan());
            for (name, value) in response.headers() {
                println!("  {}: {}", name, value.to_str().unwrap_or("(binary)"));
            }

            println!("\n{}", "Body:".cyan());
            match response.text() {
                Ok(body) => {
                    if body.len() > 2000 {
                        println!("{}", &body[..2000]);
                        println!("\n... (truncated, {} total bytes)", body.len());
                    } else {
                        println!("{}", body);
                    }
                }
                Err(e) => {
                    eprintln!("{} Failed to read response body: {}", "✗".red(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Request failed: {}", "✗".red(), e);
        }
    }

    println!();
}

pub fn post(url: &str, body: &str, content_type: &str) {
    println!("\n{} {}", "HTTP POST:".cyan().bold(), url.yellow());
    println!("{}", "=".repeat(80));
    println!("Content-Type: {}", content_type.cyan());
    println!("Body length: {} bytes", body.len());

    let client = Client::new();
    let request = client
        .post(url)
        .header("Content-Type", content_type)
        .body(body.to_string());

    match request.send() {
        Ok(response) => {
            println!(
                "\nStatus: {} {}",
                response.status().as_u16().to_string().green(),
                response.status().canonical_reason().unwrap_or("")
            );
            println!("\n{}", "Headers:".cyan());
            for (name, value) in response.headers() {
                println!("  {}: {}", name, value.to_str().unwrap_or("(binary)"));
            }

            println!("\n{}", "Response Body:".cyan());
            match response.text() {
                Ok(body) => {
                    if body.len() > 2000 {
                        println!("{}", &body[..2000]);
                        println!("\n... (truncated, {} total bytes)", body.len());
                    } else {
                        println!("{}", body);
                    }
                }
                Err(e) => {
                    eprintln!("{} Failed to read response body: {}", "✗".red(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Request failed: {}", "✗".red(), e);
        }
    }

    println!();
}

pub fn download(url: &str, output: &str) {
    println!("\n{} {}", "Downloading:".cyan().bold(), url.yellow());
    println!("Output: {}", output.cyan());
    println!("{}", "=".repeat(60));

    let client = Client::new();

    match client.get(url).send() {
        Ok(mut response) => {
            if !response.status().is_success() {
                eprintln!(
                    "{} HTTP {} {}",
                    "✗".red(),
                    response.status().as_u16(),
                    response.status().canonical_reason().unwrap_or("")
                );
                return;
            }

            match File::create(output) {
                Ok(mut file) => match response.copy_to(&mut file) {
                    Ok(bytes) => {
                        let size_mb = bytes as f64 / 1024.0 / 1024.0;
                        println!("{} Downloaded successfully", "✓".green());
                        println!("Size: {:.2} MB ({} bytes)", size_mb, bytes);
                    }
                    Err(e) => {
                        eprintln!("{} Failed to write file: {}", "✗".red(), e);
                    }
                },
                Err(e) => {
                    eprintln!("{} Failed to create output file: {}", "✗".red(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Download failed: {}", "✗".red(), e);
        }
    }

    println!();
}

pub fn head(url: &str) {
    println!("\n{} {}", "HTTP HEAD:".cyan().bold(), url.yellow());
    println!("{}", "=".repeat(80));

    let client = Client::new();

    match client.head(url).send() {
        Ok(response) => {
            println!(
                "Status: {} {}",
                response.status().as_u16().to_string().green(),
                response.status().canonical_reason().unwrap_or("")
            );
            println!("\n{}", "Headers:".cyan());
            for (name, value) in response.headers() {
                println!("  {}: {}", name, value.to_str().unwrap_or("(binary)"));
            }
        }
        Err(e) => {
            eprintln!("{} Request failed: {}", "✗".red(), e);
        }
    }

    println!();
}
