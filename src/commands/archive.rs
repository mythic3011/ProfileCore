//! Archive operations (compress/extract)

use colored::Colorize;
use std::fs::{self, File};
use std::io;
use std::path::Path;
use flate2::Compression;
use flate2::read::GzDecoder;
use flate2::write::GzEncoder;

pub fn compress(source: &str, output: &str, format: &str) {
    let source_path = Path::new(source);
    
    if !source_path.exists() {
        eprintln!("{} Source not found: {}", "✗".red(), source);
        return;
    }
    
    println!("\n{} {} → {}", "Compressing:".cyan().bold(), source.yellow(), output.cyan());
    println!("{}", "=".repeat(60));
    
    let result = match format.to_lowercase().as_str() {
        "gzip" | "gz" => compress_gzip(source_path, output),
        "tar" => compress_tar(source_path, output),
        "tar.gz" | "tgz" => compress_tar_gz(source_path, output),
        "zip" => compress_zip(source_path, output),
        _ => {
            eprintln!("{} Unsupported format: {}", "✗".red(), format);
            eprintln!("Supported: gzip, tar, tar.gz, zip");
            return;
        }
    };
    
    match result {
        Ok(size) => {
            let size_mb = size as f64 / 1024.0 / 1024.0;
            println!("{} Archive created successfully ({:.2} MB)", "✓".green(), size_mb);
        }
        Err(e) => {
            eprintln!("{} Compression failed: {}", "✗".red(), e);
        }
    }
    
    println!();
}

pub fn extract(archive: &str, destination: &str) {
    let archive_path = Path::new(archive);
    
    if !archive_path.exists() {
        eprintln!("{} Archive not found: {}", "✗".red(), archive);
        return;
    }
    
    println!("\n{} {} → {}", "Extracting:".cyan().bold(), archive.yellow(), destination.cyan());
    println!("{}", "=".repeat(60));
    
    // Detect format from extension
    let format = if archive.ends_with(".tar.gz") || archive.ends_with(".tgz") {
        "tar.gz"
    } else if archive.ends_with(".tar") {
        "tar"
    } else if archive.ends_with(".gz") {
        "gzip"
    } else if archive.ends_with(".zip") {
        "zip"
    } else {
        eprintln!("{} Cannot detect archive format from extension", "✗".red());
        return;
    };
    
    let result = match format {
        "gzip" => extract_gzip(archive_path, destination),
        "tar" => extract_tar(archive_path, destination),
        "tar.gz" => extract_tar_gz(archive_path, destination),
        "zip" => extract_zip(archive_path, destination),
        _ => {
            eprintln!("{} Unsupported format", "✗".red());
            return;
        }
    };
    
    match result {
        Ok(count) => {
            println!("{} Extracted {} file(s) successfully", "✓".green(), count);
        }
        Err(e) => {
            eprintln!("{} Extraction failed: {}", "✗".red(), e);
        }
    }
    
    println!();
}

pub fn list(archive: &str) {
    let archive_path = Path::new(archive);
    
    if !archive_path.exists() {
        eprintln!("{} Archive not found: {}", "✗".red(), archive);
        return;
    }
    
    println!("\n{} {}", "Archive Contents:".cyan().bold(), archive.yellow());
    println!("{}", "=".repeat(80));
    
    // Detect format from extension
    let format = if archive.ends_with(".tar.gz") || archive.ends_with(".tgz") {
        "tar.gz"
    } else if archive.ends_with(".tar") {
        "tar"
    } else if archive.ends_with(".zip") {
        "zip"
    } else {
        eprintln!("{} Cannot detect archive format (supported: .tar, .tar.gz, .zip)", "✗".red());
        return;
    };
    
    let result = match format {
        "tar" => list_tar(archive_path),
        "tar.gz" => list_tar_gz(archive_path),
        "zip" => list_zip(archive_path),
        _ => {
            eprintln!("{} Unsupported format", "✗".red());
            return;
        }
    };
    
    match result {
        Ok(count) => {
            println!("\n{} Total: {} file(s)", "✓".green(), count);
        }
        Err(e) => {
            eprintln!("{} Failed to list archive: {}", "✗".red(), e);
        }
    }
    
    println!();
}

// Compression implementations
fn compress_gzip(source: &Path, output: &str) -> io::Result<u64> {
    let input = File::open(source)?;
    let output_file = File::create(output)?;
    let mut encoder = GzEncoder::new(output_file, Compression::default());
    
    let mut reader = io::BufReader::new(input);
    io::copy(&mut reader, &mut encoder)?;
    
    encoder.finish()?;
    let metadata = fs::metadata(output)?;
    Ok(metadata.len())
}

fn compress_tar(source: &Path, output: &str) -> io::Result<u64> {
    let tar_file = File::create(output)?;
    let mut archive = tar::Builder::new(tar_file);
    
    if source.is_dir() {
        archive.append_dir_all(".", source)?;
    } else {
        archive.append_path(source)?;
    }
    
    archive.finish()?;
    let metadata = fs::metadata(output)?;
    Ok(metadata.len())
}

fn compress_tar_gz(source: &Path, output: &str) -> io::Result<u64> {
    let tar_gz = File::create(output)?;
    let enc = GzEncoder::new(tar_gz, Compression::default());
    let mut archive = tar::Builder::new(enc);
    
    if source.is_dir() {
        archive.append_dir_all(".", source)?;
    } else {
        archive.append_path(source)?;
    }
    
    archive.finish()?;
    let metadata = fs::metadata(output)?;
    Ok(metadata.len())
}

fn compress_zip(source: &Path, output: &str) -> io::Result<u64> {
    let file = File::create(output)?;
    let mut zip = zip::ZipWriter::new(file);
    
    if source.is_file() {
        let options = zip::write::FileOptions::default()
            .compression_method(zip::CompressionMethod::Deflated);
        let name = source.file_name().unwrap().to_string_lossy();
        zip.start_file(name, options)?;
        let mut f = File::open(source)?;
        io::copy(&mut f, &mut zip)?;
    }
    
    zip.finish()?;
    let metadata = fs::metadata(output)?;
    Ok(metadata.len())
}

// Extraction implementations
fn extract_gzip(archive: &Path, destination: &str) -> io::Result<usize> {
    let input = File::open(archive)?;
    let mut decoder = GzDecoder::new(input);
    let mut output = File::create(destination)?;
    
    io::copy(&mut decoder, &mut output)?;
    Ok(1)
}

fn extract_tar(archive: &Path, destination: &str) -> io::Result<usize> {
    let file = File::open(archive)?;
    let mut archive = tar::Archive::new(file);
    
    fs::create_dir_all(destination)?;
    archive.unpack(destination)?;
    
    Ok(archive.entries()?.count())
}

fn extract_tar_gz(archive_path: &Path, destination: &str) -> io::Result<usize> {
    let file = File::open(archive_path)?;
    let decoder = GzDecoder::new(file);
    let mut archive = tar::Archive::new(decoder);
    
    fs::create_dir_all(destination)?;
    let count = archive.entries()?.count();
    
    // Re-open to actually extract (iterator consumes)
    let file2 = File::open(archive_path)?;
    let decoder2 = GzDecoder::new(file2);
    let mut archive2 = tar::Archive::new(decoder2);
    archive2.unpack(destination)?;
    
    Ok(count)
}

fn extract_zip(archive: &Path, destination: &str) -> io::Result<usize> {
    let file = File::open(archive)?;
    let mut archive = zip::ZipArchive::new(file)?;
    
    fs::create_dir_all(destination)?;
    
    for i in 0..archive.len() {
        let mut file = archive.by_index(i)?;
        let outpath = Path::new(destination).join(file.name());
        
        if file.is_dir() {
            fs::create_dir_all(&outpath)?;
        } else {
            if let Some(p) = outpath.parent() {
                fs::create_dir_all(p)?;
            }
            let mut outfile = File::create(&outpath)?;
            io::copy(&mut file, &mut outfile)?;
        }
    }
    
    Ok(archive.len())
}

// Listing implementations
fn list_tar(archive: &Path) -> io::Result<usize> {
    let file = File::open(archive)?;
    let mut archive = tar::Archive::new(file);
    
    let mut count = 0;
    for entry in archive.entries()? {
        let entry = entry?;
        let path = entry.path()?;
        let size = entry.size();
        println!("  {} ({} bytes)", path.display(), size);
        count += 1;
    }
    
    Ok(count)
}

fn list_tar_gz(archive: &Path) -> io::Result<usize> {
    let file = File::open(archive)?;
    let decoder = GzDecoder::new(file);
    let mut archive = tar::Archive::new(decoder);
    
    let mut count = 0;
    for entry in archive.entries()? {
        let entry = entry?;
        let path = entry.path()?;
        let size = entry.size();
        println!("  {} ({} bytes)", path.display(), size);
        count += 1;
    }
    
    Ok(count)
}

fn list_zip(archive: &Path) -> io::Result<usize> {
    let file = File::open(archive)?;
    let mut archive = zip::ZipArchive::new(file)?;
    
    for i in 0..archive.len() {
        let file = archive.by_index(i)?;
        println!("  {} ({} bytes)", file.name(), file.size());
    }
    
    Ok(archive.len())
}

