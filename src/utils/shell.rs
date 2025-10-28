//! Shell detection and configuration utilities

use std::env;

/// Supported shell types
#[derive(Debug, Clone, PartialEq)]
pub enum ShellType {
    Bash,
    Zsh,
    Fish,
    PowerShell,
    WslBash,
}

impl ShellType {
    pub fn as_str(&self) -> &str {
        match self {
            ShellType::Bash => "bash",
            ShellType::Zsh => "zsh",
            ShellType::Fish => "fish",
            ShellType::PowerShell => "powershell",
            ShellType::WslBash => "wsl-bash",
        }
    }

    #[allow(dead_code)]
    pub fn from_str(s: &str) -> Option<Self> {
        match s {
            "bash" => Some(ShellType::Bash),
            "zsh" => Some(ShellType::Zsh),
            "fish" => Some(ShellType::Fish),
            "powershell" | "pwsh" => Some(ShellType::PowerShell),
            "wsl-bash" => Some(ShellType::WslBash),
            _ => None,
        }
    }
}

/// Detect the current shell from environment variables
pub fn detect_current_shell() -> ShellType {
    // Try to detect from SHELL environment variable
    if let Ok(shell_path) = env::var("SHELL") {
        if shell_path.contains("bash") {
            return ShellType::Bash;
        } else if shell_path.contains("zsh") {
            return ShellType::Zsh;
        } else if shell_path.contains("fish") {
            return ShellType::Fish;
        }
    }

    // Check for PowerShell on Windows
    if cfg!(windows) {
        if env::var("PSModulePath").is_ok() {
            return ShellType::PowerShell;
        }
    }

    // Default fallback based on OS
    if cfg!(windows) {
        ShellType::PowerShell
    } else if cfg!(target_os = "macos") {
        ShellType::Zsh
    } else {
        ShellType::Bash
    }
}

/// Get list of available shells on the system
pub fn get_available_shells() -> Vec<ShellType> {
    let mut available = Vec::new();

    // On Windows, check for PowerShell and optionally WSL/Git Bash
    #[cfg(windows)]
    {
        // PowerShell is always available on Windows
        available.push(ShellType::PowerShell);

        // Check for Git Bash
        if which::which("bash").is_ok() {
            available.push(ShellType::Bash);
        }

        // Check for WSL
        if which::which("wsl").is_ok() {
            available.push(ShellType::WslBash);
        }
    }

    // On Unix, check which shells are available
    #[cfg(unix)]
    {
        for shell in &[ShellType::Bash, ShellType::Zsh, ShellType::Fish] {
            if which::which(shell.as_str()).is_ok() {
                available.push(shell.clone());
            }
        }
    }

    available
}

/// Generate shell initialization code
pub fn generate_init_code(shell: &ShellType) -> String {
    match shell {
        ShellType::Bash | ShellType::Zsh | ShellType::WslBash => {
            let shell_name = match shell {
                ShellType::WslBash => "bash",
                _ => shell.as_str(),
            };
            format!(
                "\n# ProfileCore v1.0.0 - Added by installer\nif command -v profilecore &> /dev/null; then\n    eval \"$(profilecore init {})\"\nfi\n",
                shell_name
            )
        }
        ShellType::Fish => {
            "\n# ProfileCore v1.0.0 - Added by installer\nif command -v profilecore > /dev/null\n    profilecore init fish | source\nend\n".to_string()
        }
        ShellType::PowerShell => {
            "\n# ProfileCore v1.0.0 - Added by installer\nif (Get-Command profilecore -ErrorAction SilentlyContinue) {\n    profilecore init powershell | Invoke-Expression\n}\n".to_string()
        }
    }
}

/// Get reload command for the shell
pub fn get_reload_command(shell: &ShellType) -> &str {
    match shell {
        ShellType::Bash => "source ~/.bashrc",
        ShellType::Zsh => "source ~/.zshrc",
        ShellType::Fish => "source ~/.config/fish/config.fish",
        ShellType::PowerShell => ". $PROFILE",
        ShellType::WslBash => "source ~/.bashrc (in WSL)",
    }
}

/// Parse shell type from string with validation
///
/// Useful for parsing shell names from command-line arguments or config files.
///
/// # Examples
/// ```
/// let shell = parse_shell_type("bash").unwrap();
/// assert_eq!(shell, ShellType::Bash);
/// ```
pub fn parse_shell_type(shell_str: &str) -> Result<ShellType, String> {
    ShellType::from_str(shell_str).ok_or_else(|| format!("Unknown shell type: '{}'", shell_str))
}

/// Validate if a shell name is supported
///
/// Useful for validating user input before attempting to configure a shell.
pub fn is_supported_shell(shell_str: &str) -> bool {
    ShellType::from_str(shell_str).is_some()
}

/// Get all supported shell names
///
/// Returns a list of all shell identifiers that ProfileCore can configure.
/// Useful for displaying help text or validation messages.
pub fn get_supported_shell_names() -> Vec<&'static str> {
    vec!["bash", "zsh", "fish", "powershell", "pwsh", "wsl-bash"]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_shell_type_conversion() {
        assert_eq!(ShellType::from_str("bash"), Some(ShellType::Bash));
        assert_eq!(ShellType::from_str("zsh"), Some(ShellType::Zsh));
        assert_eq!(
            ShellType::from_str("powershell"),
            Some(ShellType::PowerShell)
        );
        assert_eq!(ShellType::from_str("pwsh"), Some(ShellType::PowerShell));
        assert_eq!(ShellType::from_str("invalid"), None);
    }

    #[test]
    fn test_shell_as_str() {
        assert_eq!(ShellType::Bash.as_str(), "bash");
        assert_eq!(ShellType::PowerShell.as_str(), "powershell");
    }

    #[test]
    fn test_parse_shell_type() {
        assert!(parse_shell_type("bash").is_ok());
        assert!(parse_shell_type("zsh").is_ok());
        assert!(parse_shell_type("invalid").is_err());
    }

    #[test]
    fn test_is_supported_shell() {
        assert!(is_supported_shell("bash"));
        assert!(is_supported_shell("powershell"));
        assert!(!is_supported_shell("cmd"));
        assert!(!is_supported_shell("invalid"));
    }

    #[test]
    fn test_get_supported_shell_names() {
        let names = get_supported_shell_names();
        assert!(names.contains(&"bash"));
        assert!(names.contains(&"zsh"));
        assert!(names.contains(&"powershell"));
    }
}
