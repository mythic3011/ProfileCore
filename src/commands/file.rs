//! File operations

use colored::Colorize;
use std::fs::{self, File};
use std::io::{self, Read};
use std::path::Path;
use sha2::{Sha256, Digest};

pub fn hash(file_path: &str, algorithm: &str) {
    let path = Path::new(file_path);
    
    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }
    
    println!("\n{} {}", "Calculating hash for:".cyan(), file_path.yellow());
    println!("{}", "=".repeat(60));
    
    match algorithm.to_lowercase().as_str() {
        "md5" => {
            match calculate_md5(path) {
                Ok(hash) => println!("  MD5:    {}", hash.green()),
                Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
            }
        }
        "sha256" => {
            match calculate_sha256(path) {
                Ok(hash) => println!("  SHA256: {}", hash.green()),
                Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
            }
        }
        "all" => {
            match calculate_md5(path) {
                Ok(hash) => println!("  MD5:    {}", hash.green()),
                Err(e) => eprintln!("{} MD5 Error: {}", "✗".red(), e),
            }
            match calculate_sha256(path) {
                Ok(hash) => println!("  SHA256: {}", hash.green()),
                Err(e) => eprintln!("{} SHA256 Error: {}", "✗".red(), e),
            }
        }
        _ => {
            eprintln!("{} Unknown algorithm: {}", "✗".red(), algorithm);
            eprintln!("Supported: md5, sha256, all");
        }
    }
    println!();
}

pub fn size(path_str: &str) {
    let path = Path::new(path_str);
    
    if !path.exists() {
        eprintln!("{} Path not found: {}", "✗".red(), path_str);
        return;
    }
    
    println!("\n{} {}", "Size for:".cyan().bold(), path_str.yellow());
    println!("{}", "=".repeat(60));
    
    if path.is_file() {
        match fs::metadata(path) {
            Ok(metadata) => {
                let size = metadata.len();
                println!("  File size: {}", format_size(size).green());
                println!("  Raw bytes: {}", size.to_string().yellow());
            }
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        }
    } else if path.is_dir() {
        match calculate_dir_size(path) {
            Ok((size, file_count)) => {
                println!("  Directory size: {}", format_size(size).green());
                println!("  Total files:    {}", file_count.to_string().yellow());
                println!("  Raw bytes:      {}", size.to_string().cyan());
            }
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        }
    }
    println!();
}

fn calculate_md5(path: &Path) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut hasher = md5::Context::new();
    let mut buffer = [0; 8192];
    
    loop {
        let count = file.read(&mut buffer)?;
        if count == 0 {
            break;
        }
        hasher.consume(&buffer[..count]);
    }
    
    Ok(format!("{:x}", hasher.compute()))
}

fn calculate_sha256(path: &Path) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buffer = [0; 8192];
    
    loop {
        let count = file.read(&mut buffer)?;
        if count == 0 {
            break;
        }
        hasher.update(&buffer[..count]);
    }
    
    Ok(format!("{:x}", hasher.finalize()))
}

fn calculate_dir_size(path: &Path) -> io::Result<(u64, usize)> {
    let mut total_size = 0u64;
    let mut file_count = 0usize;
    
    if path.is_dir() {
        for entry in fs::read_dir(path)? {
            let entry = entry?;
            let metadata = entry.metadata()?;
            
            if metadata.is_file() {
                total_size += metadata.len();
                file_count += 1;
            } else if metadata.is_dir() {
                let (sub_size, sub_count) = calculate_dir_size(&entry.path())?;
                total_size += sub_size;
                file_count += sub_count;
            }
        }
    }
    
    Ok((total_size, file_count))
}

fn format_size(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;
    const TB: u64 = GB * 1024;
    
    if bytes >= TB {
        format!("{:.2} TB", bytes as f64 / TB as f64)
    } else if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} bytes", bytes)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_format_size() {
        assert_eq!(format_size(512), "512 bytes");
        assert_eq!(format_size(1024), "1.00 KB");
        assert_eq!(format_size(1024 * 1024), "1.00 MB");
        assert_eq!(format_size(1024 * 1024 * 1024), "1.00 GB");
    }
}

