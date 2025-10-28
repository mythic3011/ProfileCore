//! String utility commands

use base64::{engine::general_purpose, Engine as _};
use colored::Colorize;

pub fn base64_encode_decode(input: &str, decode: bool) {
    if decode {
        println!("\n{} Base64", "Decoding:".cyan().bold());
        println!("{}", "=".repeat(60));

        match general_purpose::STANDARD.decode(input) {
            Ok(decoded_bytes) => match String::from_utf8(decoded_bytes) {
                Ok(decoded_str) => {
                    println!("Input:  {}", input.yellow());
                    println!("Output: {}", decoded_str.green());
                }
                Err(_) => {
                    eprintln!("{} Decoded data is not valid UTF-8", "✗".red());
                }
            },
            Err(e) => {
                eprintln!("{} Decoding failed: {}", "✗".red(), e);
            }
        }
    } else {
        println!("\n{} Base64", "Encoding:".cyan().bold());
        println!("{}", "=".repeat(60));

        let encoded = general_purpose::STANDARD.encode(input);
        println!("Input:  {}", input.yellow());
        println!("Output: {}", encoded.green());
    }

    println!();
}

pub fn url_encode_decode(input: &str, decode: bool) {
    if decode {
        println!("\n{} URL", "Decoding:".cyan().bold());
        println!("{}", "=".repeat(60));

        match urlencoding::decode(input) {
            Ok(decoded) => {
                println!("Input:  {}", input.yellow());
                println!("Output: {}", decoded.green());
            }
            Err(e) => {
                eprintln!("{} Decoding failed: {}", "✗".red(), e);
            }
        }
    } else {
        println!("\n{} URL", "Encoding:".cyan().bold());
        println!("{}", "=".repeat(60));

        let encoded = urlencoding::encode(input);
        println!("Input:  {}", input.yellow());
        println!("Output: {}", encoded.green());
    }

    println!();
}

pub fn string_hash(input: &str, algorithm: &str) {
    println!(
        "\n{} String ({} algorithm)",
        "Hashing:".cyan().bold(),
        algorithm.to_uppercase().yellow()
    );
    println!("{}", "=".repeat(60));

    match algorithm.to_lowercase().as_str() {
        "md5" => {
            let hash = format!("{:x}", md5::compute(input.as_bytes()));
            println!("Input:  {}", input.yellow());
            println!("MD5:    {}", hash.green());
        }
        "sha256" => {
            use sha2::{Digest, Sha256};
            let mut hasher = Sha256::new();
            hasher.update(input.as_bytes());
            let hash = format!("{:x}", hasher.finalize());
            println!("Input:  {}", input.yellow());
            println!("SHA256: {}", hash.green());
        }
        "all" => {
            // MD5
            let md5_hash = format!("{:x}", md5::compute(input.as_bytes()));
            // SHA256
            use sha2::{Digest, Sha256};
            let mut hasher = Sha256::new();
            hasher.update(input.as_bytes());
            let sha256_hash = format!("{:x}", hasher.finalize());

            println!("Input:  {}", input.yellow());
            println!("MD5:    {}", md5_hash.green());
            println!("SHA256: {}", sha256_hash.green());
        }
        _ => {
            eprintln!("{} Unknown algorithm: {}", "✗".red(), algorithm);
            eprintln!("Supported: md5, sha256, all");
        }
    }

    println!();
}
