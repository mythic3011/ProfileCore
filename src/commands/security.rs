//! Security tools (rustls, argon2, bcrypt, rand, zxcvbn)

use colored::Colorize;
use rand::Rng;
use argon2::{Argon2, PasswordHasher, PasswordVerifier, PasswordHash};
use argon2::password_hash::{SaltString, rand_core::OsRng};
use bcrypt::{hash, verify, DEFAULT_COST};
use zxcvbn::zxcvbn;
use std::net::TcpStream;
use std::io::{Write, Read};
use rustls::{ClientConfig, RootCertStore, ClientConnection, StreamOwned};
use rustls_native_certs::load_native_certs;

pub fn ssl_check(domain: &str) {
    // Parse domain and port
    let (host, port) = if domain.contains(':') {
        let parts: Vec<&str> = domain.split(':').collect();
        (parts[0], parts.get(1).and_then(|p| p.parse().ok()).unwrap_or(443))
    } else {
        (domain, 443)
    };
    
    println!("\n{} {}", "SSL Certificate Check:".cyan().bold(), domain);
    println!("{}", "=".repeat(60));
    
    // Load native root certificates
    let mut root_store = RootCertStore::empty();
    match load_native_certs() {
        Ok(certs) => {
            for cert in certs {
                if let Err(e) = root_store.add(cert) {
                    eprintln!("{} Warning: Failed to add cert: {}", "!".yellow(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Failed to load native certs: {}", "✗".red(), e);
            return;
        }
    }
    
    // Create TLS config
    let config = match ClientConfig::builder()
        .with_root_certificates(root_store)
        .with_no_client_auth()
    {
        config => config,
    };
    
    // Connect
    let server_name = match rustls::pki_types::ServerName::try_from(host.to_string()) {
        Ok(name) => name,
        Err(e) => {
            eprintln!("{} Invalid server name: {}", "✗".red(), e);
            return;
        }
    };
    
    let conn = match ClientConnection::new(std::sync::Arc::new(config), server_name) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("{} Failed to create TLS connection: {}", "✗".red(), e);
            return;
        }
    };
    
    let addr = format!("{}:{}", host, port);
    let sock = match TcpStream::connect(&addr) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("{} Failed to connect to {}: {}", "✗".red(), addr, e);
            return;
        }
    };
    
    let mut tls = StreamOwned::new(conn, sock);
    
    // Send a simple HTTP request to trigger handshake
    let request = format!("GET / HTTP/1.1\r\nHost: {}\r\nConnection: close\r\n\r\n", host);
    if let Err(e) = tls.write_all(request.as_bytes()) {
        eprintln!("{} Failed to write request: {}", "✗".red(), e);
        return;
    }
    
    // Try to read response (will complete handshake)
    let mut response = vec![0; 1024];
    match tls.read(&mut response) {
        Ok(_) => {
            println!("{} TLS handshake successful", "✓".green());
            println!("  Host: {}", host);
            println!("  Port: {}", port);
            println!("  Status: {}", "Valid".green());
        }
        Err(e) => {
            eprintln!("{} Failed to read response: {}", "✗".red(), e);
        }
    }
    
    println!();
}

pub fn gen_password(length: usize) {
    const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
    let mut rng = rand::thread_rng();
    
    let password: String = (0..length)
        .map(|_| {
            let idx = rng.gen_range(0..CHARSET.len());
            CHARSET[idx] as char
        })
        .collect();
    
    println!("{} Generated password ({} chars):", "✓".green(), length);
    println!("  {}", password.cyan());
}

pub fn check_password(password: &str) {
    println!("\n{}", "Password Strength Analysis".cyan().bold());
    println!("{}", "=".repeat(60));
    
    let estimate = zxcvbn(password, &[]);
    
    let (score_num, score_label, score_color) = match estimate.score() {
        zxcvbn::Score::Zero => (0, "Very Weak", "red"),
        zxcvbn::Score::One => (1, "Weak", "red"),
        zxcvbn::Score::Two => (2, "Fair", "yellow"),
        zxcvbn::Score::Three => (3, "Strong", "green"),
        zxcvbn::Score::Four => (4, "Very Strong", "green"),
        _ => (0, "Unknown", "reset"),
    };
    
    println!("  Password: {}", "*".repeat(password.len()));
    print!("  Score: {} (", score_num);
    match score_color {
        "red" => print!("{}", score_label.red()),
        "yellow" => print!("{}", score_label.yellow()),
        "green" => print!("{}", score_label.green()),
        _ => print!("{}", score_label),
    }
    println!(")");

    
    if let Some(feedback) = estimate.feedback() {
        if let Some(warning) = feedback.warning() {
            println!("  Warning: {}", warning.to_string().yellow());
        }
        
        if !feedback.suggestions().is_empty() {
            println!("\n  Suggestions:");
            for suggestion in feedback.suggestions() {
                println!("    • {}", suggestion);
            }
        }
    }
    
    println!();
}

pub fn hash_password(password: &str, algorithm: &str) {
    println!("\n{} {}", "Password Hashing:".cyan().bold(), algorithm.to_uppercase());
    println!("{}", "=".repeat(60));
    
    match algorithm.to_lowercase().as_str() {
        "argon2" => {
            let salt = SaltString::generate(&mut OsRng);
            let argon2 = Argon2::default();
            
            match argon2.hash_password(password.as_bytes(), &salt) {
                Ok(hash) => {
                    println!("{} Hash generated successfully", "✓".green());
                    println!("  Algorithm: {}", "Argon2id".cyan());
                    println!("  Hash: {}", hash.to_string());
                    
                    // Verify
                    let hash_string = hash.to_string();
                    let parsed_hash = PasswordHash::new(&hash_string).unwrap();
                    if argon2.verify_password(password.as_bytes(), &parsed_hash).is_ok() {
                        println!("  Verification: {}", "✓ Success".green());
                    }
                }
                Err(e) => {
                    eprintln!("{} Hashing failed: {}", "✗".red(), e);
                }
            }
        }
        "bcrypt" => {
            match hash(password, DEFAULT_COST) {
                Ok(hash_str) => {
                    println!("{} Hash generated successfully", "✓".green());
                    println!("  Algorithm: {}", "bcrypt".cyan());
                    println!("  Hash: {}", hash_str);
                    
                    // Verify
                    if verify(password, &hash_str).unwrap_or(false) {
                        println!("  Verification: {}", "✓ Success".green());
                    }
                }
                Err(e) => {
                    eprintln!("{} Hashing failed: {}", "✗".red(), e);
                }
            }
        }
        _ => {
            eprintln!("{} Unknown algorithm: {}", "✗".red(), algorithm);
            println!("  Supported: argon2, bcrypt");
        }
    }
    
    println!();
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_password_length() {
        // Test that generated passwords have correct length
        const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        let mut rng = rand::thread_rng();
        
        for length in [8, 16, 20, 32] {
            let password: String = (0..length)
                .map(|_| {
                    let idx = rng.gen_range(0..CHARSET.len());
                    CHARSET[idx] as char
                })
                .collect();
            
            assert_eq!(password.len(), length);
        }
    }
    
    #[test]
    fn test_password_charset() {
        // Test that generated passwords only contain valid characters
        const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        let valid_chars: Vec<char> = CHARSET.iter().map(|&b| b as char).collect();
        
        let mut rng = rand::thread_rng();
        let password: String = (0..20)
            .map(|_| {
                let idx = rng.gen_range(0..CHARSET.len());
                CHARSET[idx] as char
            })
            .collect();
        
        for c in password.chars() {
            assert!(valid_chars.contains(&c), "Invalid character in password: {}", c);
        }
    }
    
    #[test]
    fn test_password_randomness() {
        // Test that two generated passwords are different
        const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        let mut rng = rand::thread_rng();
        
        let mut gen_pass = || -> String {
            (0..20)
                .map(|_| {
                    let idx = rng.gen_range(0..CHARSET.len());
                    CHARSET[idx] as char
                })
                .collect()
        };
        
        let pass1 = gen_pass();
        let pass2 = gen_pass();
        
        // With 20 chars from 68-char charset, collision is extremely unlikely
        assert_ne!(pass1, pass2);
    }
}

