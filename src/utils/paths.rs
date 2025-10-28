//! Path utilities for shell profiles and configuration

use crate::utils::shell::ShellType;
use std::path::PathBuf;

/// Get the shell profile file path for a given shell
pub fn get_shell_profile_path(shell: &ShellType) -> PathBuf {
    let home = dirs::home_dir().expect("Could not find home directory");

    match shell {
        ShellType::Bash => {
            // Prefer .bashrc on Linux, .bash_profile on macOS
            if cfg!(target_os = "macos") {
                home.join(".bash_profile")
            } else {
                home.join(".bashrc")
            }
        }
        ShellType::Zsh => home.join(".zshrc"),
        ShellType::Fish => home.join(".config/fish/config.fish"),
        ShellType::PowerShell => {
            // PowerShell profile location
            if cfg!(windows) {
                let docs = dirs::document_dir().expect("Could not find Documents directory");
                docs.join("PowerShell")
                    .join("Microsoft.PowerShell_profile.ps1")
            } else {
                home.join(".config/powershell/profile.ps1")
            }
        }
        ShellType::WslBash => {
            // For WSL, use the Windows .bashrc path
            home.join(".bashrc")
        }
    }
}

/// Get the ProfileCore configuration directory
pub fn get_config_dir() -> PathBuf {
    let home = dirs::home_dir().expect("Could not find home directory");
    home.join(".config").join("profilecore")
}

/// Check if ProfileCore is installed in a profile
pub fn is_profilecore_installed(profile_path: &PathBuf) -> bool {
    if !profile_path.exists() {
        return false;
    }

    if let Ok(content) = std::fs::read_to_string(profile_path) {
        content.contains("profilecore init")
    } else {
        false
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_config_dir() {
        let config_dir = get_config_dir();
        assert!(config_dir.to_string_lossy().contains("profilecore"));
    }
}
