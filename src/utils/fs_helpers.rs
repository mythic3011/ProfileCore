//! File system helper utilities

use colored::Colorize;
use std::fs;
use std::path::PathBuf;

/// Create a backup of a file with .bak extension
pub fn backup_file(path: &PathBuf) -> Result<PathBuf, std::io::Error> {
    if !path.exists() {
        return Err(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "File does not exist",
        ));
    }

    let backup_path = path.with_extension("bak");
    fs::copy(path, &backup_path)?;

    Ok(backup_path)
}

/// Create a directory if it doesn't exist
pub fn ensure_dir_exists(path: &PathBuf) -> Result<(), std::io::Error> {
    if !path.exists() {
        fs::create_dir_all(path)?;
    }
    Ok(())
}

/// Append content to a file, creating it if it doesn't exist
pub fn append_to_file(path: &PathBuf, content: &str) -> Result<(), std::io::Error> {
    use std::io::Write;

    // Ensure parent directory exists
    if let Some(parent) = path.parent() {
        ensure_dir_exists(&parent.to_path_buf())?;
    }

    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)?;

    file.write_all(content.as_bytes())?;
    Ok(())
}

/// Check if a binary is in PATH
pub fn is_in_path(binary_name: &str) -> bool {
    which::which(binary_name).is_ok()
}

/// Print a file operation result
pub fn print_file_op_result(operation: &str, path: &PathBuf, success: bool) {
    if success {
        println!("{} {} {}", "✓".green(), operation.green(), path.display());
    } else {
        println!("{} {} {}", "✗".red(), operation.red(), path.display());
    }
}

/// Backup a file and print the result
///
/// Convenience function that backs up a file and displays the operation status.
/// Useful for interactive commands that need user feedback.
pub fn backup_file_verbose(path: &PathBuf) -> Result<PathBuf, std::io::Error> {
    let result = backup_file(path);
    print_file_op_result("Backed up", path, result.is_ok());
    result
}

/// Create directory and print the result
///
/// Convenience function that creates a directory and displays the operation status.
/// Useful for installation or setup commands.
pub fn ensure_dir_exists_verbose(path: &PathBuf) -> Result<(), std::io::Error> {
    let result = ensure_dir_exists(path);
    print_file_op_result("Created directory", path, result.is_ok());
    result
}

/// Append to file and print the result
///
/// Convenience function that appends to a file and displays the operation status.
/// Useful for configuration updates that need user feedback.
pub fn append_to_file_verbose(path: &PathBuf, content: &str) -> Result<(), std::io::Error> {
    let result = append_to_file(path, content);
    print_file_op_result("Updated", path, result.is_ok());
    result
}

/// Check if file exists and print status
///
/// Convenience function for verifying file existence with user feedback.
/// Useful for diagnostic or verification commands.
pub fn check_file_exists(path: &PathBuf) -> bool {
    let exists = path.exists();
    if exists {
        println!("{} File exists: {}", "✓".green(), path.display());
    } else {
        println!("{} File not found: {}", "✗".red(), path.display());
    }
    exists
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::TempDir;

    #[test]
    fn test_backup_file() {
        let temp_dir = TempDir::new().unwrap();
        let file_path = temp_dir.path().join("test.txt");

        // Create a test file
        let mut file = fs::File::create(&file_path).unwrap();
        file.write_all(b"test content").unwrap();
        drop(file);

        // Create backup
        let backup_path = backup_file(&file_path).unwrap();
        assert!(backup_path.exists());
        assert_eq!(fs::read_to_string(&backup_path).unwrap(), "test content");
    }

    #[test]
    fn test_ensure_dir_exists() {
        let temp_dir = TempDir::new().unwrap();
        let new_dir = temp_dir.path().join("new_dir");

        assert!(!new_dir.exists());
        ensure_dir_exists(&new_dir).unwrap();
        assert!(new_dir.exists());
    }

    #[test]
    fn test_append_to_file() {
        let temp_dir = TempDir::new().unwrap();
        let file_path = temp_dir.path().join("test.txt");

        append_to_file(&file_path, "line 1\n").unwrap();
        append_to_file(&file_path, "line 2\n").unwrap();

        let content = fs::read_to_string(&file_path).unwrap();
        assert_eq!(content, "line 1\nline 2\n");
    }
}
