//! File operations

use colored::Colorize;
use regex;
use sha2::{Digest, Sha256};
use std::fs::{self, File};
use std::io::{self, Read};
use std::path::Path;

pub fn hash(file_path: &str, algorithm: &str) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    println!(
        "\n{} {}",
        "Calculating hash for:".cyan(),
        file_path.yellow()
    );
    println!("{}", "=".repeat(60));

    match algorithm.to_lowercase().as_str() {
        "md5" => match calculate_md5(path) {
            Ok(hash) => println!("  MD5:    {}", hash.green()),
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        },
        "sha256" => match calculate_sha256(path) {
            Ok(hash) => println!("  SHA256: {}", hash.green()),
            Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
        },
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

pub fn find(pattern: &str, directory: &str) {
    let path = Path::new(directory);

    if !path.exists() {
        eprintln!("{} Directory not found: {}", "✗".red(), directory);
        return;
    }

    println!(
        "\n{} {} in {}",
        "Searching for:".cyan().bold(),
        pattern.yellow(),
        directory.cyan()
    );
    println!("{}", "=".repeat(80));

    let regex_pattern = match regex::Regex::new(&format!("(?i){}", pattern.replace("*", ".*"))) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Invalid pattern: {}", "✗".red(), e);
            return;
        }
    };

    let mut count = 0;
    find_recursive(path, &regex_pattern, &mut count);

    if count == 0 {
        println!("{} No files found matching pattern", "!".yellow());
    } else {
        println!("\n{} Found {} file(s)", "✓".green(), count);
    }
    println!();
}

fn find_recursive(path: &Path, pattern: &regex::Regex, count: &mut usize) {
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.flatten() {
            let entry_path = entry.path();
            let file_name = entry_path
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or("");

            if pattern.is_match(file_name) {
                println!("  {}", entry_path.display());
                *count += 1;
            }

            if entry_path.is_dir() {
                find_recursive(&entry_path, pattern, count);
            }
        }
    }
}

pub fn permissions(file_path: &str) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    println!(
        "\n{} {}",
        "Permissions for:".cyan().bold(),
        file_path.yellow()
    );
    println!("{}", "=".repeat(60));

    match fs::metadata(path) {
        Ok(metadata) => {
            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                let mode = metadata.permissions().mode();
                let user = (mode >> 6) & 0o7;
                let group = (mode >> 3) & 0o7;
                let other = mode & 0o7;

                println!("  Octal:  {:o}", mode & 0o777);
                println!(
                    "  User:   {} (read: {}, write: {}, execute: {})",
                    user,
                    (user & 0o4) != 0,
                    (user & 0o2) != 0,
                    (user & 0o1) != 0
                );
                println!(
                    "  Group:  {} (read: {}, write: {}, execute: {})",
                    group,
                    (group & 0o4) != 0,
                    (group & 0o2) != 0,
                    (group & 0o1) != 0
                );
                println!(
                    "  Other:  {} (read: {}, write: {}, execute: {})",
                    other,
                    (other & 0o4) != 0,
                    (other & 0o2) != 0,
                    (other & 0o1) != 0
                );
            }

            #[cfg(windows)]
            {
                let perms = metadata.permissions();
                println!("  Read-only: {}", perms.readonly());
            }

            println!("  Is directory: {}", metadata.is_dir());
            println!("  Is file: {}", metadata.is_file());
        }
        Err(e) => eprintln!("{} Error: {}", "✗".red(), e),
    }

    println!();
}

pub fn file_type(file_path: &str) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    println!(
        "\n{} {}",
        "File Type for:".cyan().bold(),
        file_path.yellow()
    );
    println!("{}", "=".repeat(60));

    // Get extension-based type
    let extension = path
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("(no extension)");

    let mime_type = match extension.to_lowercase().as_str() {
        "txt" => "text/plain",
        "md" => "text/markdown",
        "json" => "application/json",
        "xml" => "application/xml",
        "html" | "htm" => "text/html",
        "css" => "text/css",
        "js" => "application/javascript",
        "ts" => "application/typescript",
        "rs" => "text/x-rust",
        "py" => "text/x-python",
        "sh" | "bash" => "application/x-sh",
        "ps1" => "application/x-powershell",
        "zip" => "application/zip",
        "tar" => "application/x-tar",
        "gz" => "application/gzip",
        "pdf" => "application/pdf",
        "jpg" | "jpeg" => "image/jpeg",
        "png" => "image/png",
        "gif" => "image/gif",
        "svg" => "image/svg+xml",
        "mp3" => "audio/mpeg",
        "mp4" => "video/mp4",
        "exe" => "application/x-msdownload",
        "dll" => "application/x-msdownload",
        "so" => "application/x-sharedlib",
        "dylib" => "application/x-sharedlib",
        _ => "application/octet-stream",
    };

    println!("  Extension: {}", extension.cyan());
    println!("  MIME Type: {}", mime_type.green());

    // Check if text file by reading first few bytes
    if let Ok(mut file) = File::open(path) {
        let mut buffer = [0u8; 512];
        if let Ok(n) = file.read(&mut buffer) {
            let is_text = buffer[..n]
                .iter()
                .all(|&b| b.is_ascii() || b == b'\n' || b == b'\r' || b == b'\t');
            println!(
                "  Appears to be: {}",
                if is_text {
                    "Text".green()
                } else {
                    "Binary".yellow()
                }
            );
        }
    }

    println!();
}
