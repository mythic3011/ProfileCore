//! Interactive installation wizard for ProfileCore
//!
//! Handles:
//! - Shell detection and selection
//! - Multi-shell installation support
//! - Profile file configuration
//! - Configuration directory setup
//! - Installation verification
//! - Clean uninstallation

use crate::utils::{fs_helpers, paths, shell};
use colored::Colorize;
use dialoguer::{theme::ColorfulTheme, MultiSelect, Select};
use std::path::PathBuf;

// ============================================================================
// Constants
// ============================================================================

const VERSION: &str = "v1.0.0";
const BINARY_NAME: &str = "profilecore";

// Box drawing characters
const BOX_TOP: &str = "╔════════════════════════════════════════╗";
const BOX_BOTTOM: &str = "╚════════════════════════════════════════╝";
const BOX_LINE: &str = "║";

// Symbols
const CHECK_MARK: &str = "✓";
const CROSS_MARK: &str = "✗";
const WARNING: &str = "⚠";
const ARROW: &str = "➤";

// ============================================================================
// Types
// ============================================================================

/// Result of a single shell installation
#[derive(Debug)]
struct InstallResult {
    shell: shell::ShellType,
    success: bool,
    skipped: bool,
}

impl InstallResult {
    fn success(shell: shell::ShellType) -> Self {
        Self {
            shell,
            success: true,
            skipped: false,
        }
    }

    fn failed(shell: shell::ShellType) -> Self {
        Self {
            shell,
            success: false,
            skipped: false,
        }
    }

    fn skipped(shell: shell::ShellType) -> Self {
        Self {
            shell,
            success: false,
            skipped: true,
        }
    }
}

/// Installation context containing shared state
struct InstallContext {
    config_dir: PathBuf,
    config_dir_created: bool,
}

impl InstallContext {
    fn new() -> Self {
        Self {
            config_dir: paths::get_config_dir(),
            config_dir_created: false,
        }
    }

    fn ensure_config_dir(&mut self) -> bool {
        if self.config_dir_created {
            return true;
        }

        if fs_helpers::ensure_dir_exists(&self.config_dir).is_ok() {
            println!(
                "{} Created config directory: {}",
                CHECK_MARK.green(),
                self.config_dir.display()
            );
            self.config_dir_created = true;
            true
        } else {
            println!("{} Failed to create config directory", CROSS_MARK.red());
            false
        }
    }
}

// ============================================================================
// Main Installation Flow
// ============================================================================

/// Run the interactive installer
pub fn run_installer() {
    print_header("Installer");

    // Step 1: Detect and validate available shells
    let available_shells = shell::get_available_shells();
    if available_shells.is_empty() {
        print_error("No supported shells found!");
        println!("ProfileCore supports: bash, zsh, fish, powershell");
        return;
    }

    // Step 2: Detect current shell and show info
    let detected_shell = select_initial_shell(&available_shells);
    display_shell_info(&detected_shell, &available_shells);

    // Step 3: Let user select shells to install
    let selected_shells = prompt_shell_selection(&detected_shell, &available_shells);
    if selected_shells.is_empty() {
        print_cancelled();
        return;
    }

    println!();

    // Step 4: Check binary in PATH
    if !check_binary_in_path() {
        return;
    }

    // Step 5: Install for each selected shell
    let mut context = InstallContext::new();
    let results = install_for_shells(&selected_shells, &mut context);

    // Step 6: Report results
    let success_count = results.iter().filter(|r| r.success).count();
    if success_count == 0 {
        println!("{}", "No shells were configured.".yellow());
        return;
    }

    // Step 7: Show success message and verify
    print_success_message(&selected_shells[0], success_count, selected_shells.len());
    verify_installations(&results);
}

// ============================================================================
// Shell Selection
// ============================================================================

/// Select initial shell from available shells
fn select_initial_shell(available: &[shell::ShellType]) -> shell::ShellType {
    let detected = shell::detect_current_shell();
    if available.contains(&detected) {
        detected
    } else {
        available[0].clone()
    }
}

/// Display detected shell and available shells
fn display_shell_info(detected: &shell::ShellType, available: &[shell::ShellType]) {
    println!(
        "{} Detected shell: {}",
        CHECK_MARK,
        detected.as_str().green()
    );

    if available.len() > 1 {
        let shell_names: Vec<String> = available.iter().map(|s| s.as_str().to_string()).collect();
        println!("  Available shells: {}", shell_names.join(", ").dimmed());
    }
    println!();
}

/// Prompt user to select shells for installation
fn prompt_shell_selection(
    detected: &shell::ShellType,
    available: &[shell::ShellType],
) -> Vec<shell::ShellType> {
    // Single shell case
    if available.len() == 1 {
        return prompt_single_shell(available);
    }

    // Multiple shells case
    prompt_multi_shell_mode(detected, available)
}

/// Handle single shell selection
fn prompt_single_shell(available: &[shell::ShellType]) -> Vec<shell::ShellType> {
    let options = vec![
        format!("{} Yes, install for {}", CHECK_MARK, available[0].as_str()),
        format!("{} No, cancel installation", CROSS_MARK),
    ];

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Proceed with installation?")
        .items(&options)
        .default(0)
        .interact()
        .unwrap_or(1);

    if selection == 0 {
        vec![available[0].clone()]
    } else {
        vec![]
    }
}

/// Handle multi-shell mode selection
fn prompt_multi_shell_mode(
    detected: &shell::ShellType,
    available: &[shell::ShellType],
) -> Vec<shell::ShellType> {
    println!("{}", "Choose installation mode:".bold());
    println!();

    let mode_options = vec![
        format!("{} Install for {} (detected)", ARROW, detected.as_str()),
        format!(
            "{} Install for multiple shells (select with Space, Enter to confirm)",
            ARROW
        ),
        format!("{} Choose a different shell", ARROW),
        format!("{} Cancel installation", CROSS_MARK),
    ];

    let mode_selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Use ↑↓ arrows to navigate, Enter to select")
        .items(&mode_options)
        .default(0)
        .interact()
        .unwrap_or(3);

    println!();

    match mode_selection {
        0 => vec![detected.clone()],
        1 => prompt_multi_select(available, detected),
        2 => prompt_single_select(available, detected),
        _ => vec![],
    }
}

/// Multi-select mode for multiple shells
fn prompt_multi_select(
    available: &[shell::ShellType],
    detected: &shell::ShellType,
) -> Vec<shell::ShellType> {
    let shell_names = create_shell_display_names(available, detected);

    let selections = MultiSelect::with_theme(&ColorfulTheme::default())
        .with_prompt("Use ↑↓ to navigate, Space to select, Enter to confirm")
        .items(&shell_names)
        .interact()
        .unwrap_or_default();

    if selections.is_empty() {
        println!("{}", "No shells selected.".yellow());
        vec![]
    } else {
        selections.iter().map(|&i| available[i].clone()).collect()
    }
}

/// Single select mode for choosing one shell
fn prompt_single_select(
    available: &[shell::ShellType],
    detected: &shell::ShellType,
) -> Vec<shell::ShellType> {
    let shell_names = create_shell_display_names(available, detected);

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Choose your shell (↑↓ arrows, Enter to select)")
        .items(&shell_names)
        .default(0)
        .interact()
        .unwrap_or(0);

    vec![available[selection].clone()]
}

/// Create display names for shells with (detected) marker
fn create_shell_display_names(
    available: &[shell::ShellType],
    detected: &shell::ShellType,
) -> Vec<String> {
    available
        .iter()
        .map(|s| {
            if s == detected {
                format!("{} (detected)", s.as_str())
            } else {
                s.as_str().to_string()
            }
        })
        .collect()
}

// ============================================================================
// Installation Logic
// ============================================================================

/// Check if binary is in PATH and offer auto-configuration
fn check_binary_in_path() -> bool {
    if !fs_helpers::is_in_path(BINARY_NAME) {
        println!(
            "{} Warning: {} binary not found in PATH",
            WARNING.yellow(),
            BINARY_NAME
        );

        // Try to find the binary location
        if let Some(binary_path) = find_binary_location() {
            println!(
                "Found binary at: {}",
                binary_path.display().to_string().cyan()
            );
            println!();

            return offer_path_configuration(&binary_path);
        } else {
            println!("Could not locate {} binary automatically", BINARY_NAME);
            println!();

            return manual_path_prompt();
        }
    } else {
        println!(
            "{} {} binary found in PATH",
            CHECK_MARK.green(),
            BINARY_NAME
        );
        println!();
    }
    true
}

/// Find the location of the profilecore binary
fn find_binary_location() -> Option<PathBuf> {
    // Try current executable location (if running from built binary)
    if let Ok(exe_path) = std::env::current_exe() {
        let exe_dir = exe_path.parent()?;
        let binary_path = exe_dir.join(if cfg!(windows) {
            format!("{}.exe", BINARY_NAME)
        } else {
            BINARY_NAME.to_string()
        });

        if binary_path.exists() {
            return Some(exe_dir.to_path_buf());
        }
    }

    // Try common installation directories
    let common_dirs = if cfg!(windows) {
        vec![
            PathBuf::from(r"C:\Program Files\ProfileCore"),
            PathBuf::from(r"C:\Program Files (x86)\ProfileCore"),
            dirs::home_dir()?.join(".local").join("bin"),
            dirs::home_dir()?.join("bin"),
        ]
    } else {
        vec![
            PathBuf::from("/usr/local/bin"),
            PathBuf::from("/usr/bin"),
            dirs::home_dir()?.join(".local").join("bin"),
            dirs::home_dir()?.join("bin"),
        ]
    };

    for dir in common_dirs {
        let binary_path = dir.join(if cfg!(windows) {
            format!("{}.exe", BINARY_NAME)
        } else {
            BINARY_NAME.to_string()
        });

        if binary_path.exists() {
            return Some(dir);
        }
    }

    None
}

/// Offer to automatically configure PATH
fn offer_path_configuration(binary_dir: &PathBuf) -> bool {
    let options = vec![
        format!("{} Auto-configure PATH (add to shell profile)", ARROW),
        format!("{} Show manual PATH instructions", ARROW),
        "Continue without adding to PATH".to_string(),
        "Cancel installation".to_string(),
    ];

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("How would you like to handle PATH configuration?")
        .items(&options)
        .default(0)
        .interact()
        .unwrap_or(3);

    println!();

    match selection {
        0 => {
            // Auto-configure PATH
            if auto_configure_path(binary_dir) {
                println!("{} PATH configured successfully!", CHECK_MARK.green());
                println!("{} Remember to reload your shell or run:", "ℹ".cyan());
                let detected_shell = shell::detect_current_shell();
                println!("   {}", shell::get_reload_command(&detected_shell).cyan());
                println!();
                true
            } else {
                println!(
                    "{} Auto-configuration failed. Showing manual instructions...",
                    CROSS_MARK.red()
                );
                println!();
                show_manual_path_instructions(binary_dir);
                manual_path_prompt()
            }
        }
        1 => {
            // Show manual instructions
            show_manual_path_instructions(binary_dir);
            manual_path_prompt()
        }
        2 => {
            // Continue anyway
            println!("{} Continuing without PATH configuration", WARNING.yellow());
            println!();
            true
        }
        _ => {
            // Cancel
            print_cancelled();
            false
        }
    }
}

/// Automatically configure PATH by adding to shell profile
fn auto_configure_path(binary_dir: &PathBuf) -> bool {
    let detected_shell = shell::detect_current_shell();
    let profile_path = paths::get_shell_profile_path(&detected_shell);

    // Check if PATH already configured
    if let Ok(content) = std::fs::read_to_string(&profile_path) {
        let dir_str = binary_dir.display().to_string();
        if content.contains(&dir_str) {
            println!("{} PATH already configured in profile", CHECK_MARK.green());
            return true;
        }
    }

    // Backup profile first
    if profile_path.exists() {
        if let Err(e) = fs_helpers::backup_file(&profile_path) {
            println!(
                "{} Warning: Could not backup profile: {}",
                WARNING.yellow(),
                e
            );
        }
    }

    // Generate PATH configuration code
    let path_code = generate_path_config(&detected_shell, binary_dir);

    // Add to profile
    match fs_helpers::append_to_file(&profile_path, &path_code) {
        Ok(_) => {
            println!(
                "{} Added PATH configuration to: {}",
                CHECK_MARK.green(),
                profile_path.display()
            );
            true
        }
        Err(e) => {
            println!("{} Failed to update profile: {}", CROSS_MARK.red(), e);
            false
        }
    }
}

/// Generate shell-specific PATH configuration code
fn generate_path_config(shell: &shell::ShellType, binary_dir: &PathBuf) -> String {
    let dir_str = binary_dir.display();

    match shell {
        shell::ShellType::Bash | shell::ShellType::Zsh | shell::ShellType::WslBash => {
            format!(
                "\n# ProfileCore PATH - Added by installer\nexport PATH=\"{}:$PATH\"\n",
                dir_str
            )
        }
        shell::ShellType::Fish => {
            format!(
                "\n# ProfileCore PATH - Added by installer\nset -gx PATH {} $PATH\n",
                dir_str
            )
        }
        shell::ShellType::PowerShell => {
            format!(
                "\n# ProfileCore PATH - Added by installer\n$env:PATH = \"{};\" + $env:PATH\n",
                dir_str
            )
        }
    }
}

/// Show manual PATH configuration instructions
fn show_manual_path_instructions(binary_dir: &PathBuf) {
    let dir_str = binary_dir.display();

    println!("{}", "═".repeat(60).cyan());
    println!("{}", "Manual PATH Configuration Instructions".bold());
    println!("{}", "═".repeat(60).cyan());
    println!();

    if cfg!(windows) {
        println!("{}", "Windows (PowerShell):".yellow());
        println!("  1. Open PowerShell as Administrator");
        println!("  2. Run this command:");
        println!(
            "     {}",
            format!(
                "[Environment]::SetEnvironmentVariable('Path', $env:Path + ';{}', 'User')",
                dir_str
            )
            .cyan()
        );
        println!("  3. Restart your terminal");
        println!();

        println!("{}", "Windows (System Settings):".yellow());
        println!("  1. Open 'Environment Variables' in System Properties");
        println!("  2. Edit 'Path' variable");
        println!("  3. Add: {}", dir_str.to_string().cyan());
        println!("  4. Click OK and restart your terminal");
    } else {
        println!("{}", "Unix/Linux/macOS:".yellow());
        println!();
        println!("  Add this line to your shell profile:");
        println!();

        println!("  {}", "For Bash (~/.bashrc or ~/.bash_profile):".dimmed());
        println!(
            "    {}",
            format!("export PATH=\"{}:$PATH\"", dir_str).cyan()
        );
        println!();

        println!("  {}", "For Zsh (~/.zshrc):".dimmed());
        println!(
            "    {}",
            format!("export PATH=\"{}:$PATH\"", dir_str).cyan()
        );
        println!();

        println!("  {}", "For Fish (~/.config/fish/config.fish):".dimmed());
        println!("    {}", format!("set -gx PATH {} $PATH", dir_str).cyan());
        println!();

        println!("  Then reload your shell:");
        println!(
            "    {}",
            "source ~/.bashrc  # or your shell's config file".cyan()
        );
    }

    println!();
    println!("{}", "═".repeat(60).cyan());
    println!();
}

/// Manual prompt for continuing without PATH
fn manual_path_prompt() -> bool {
    let options = vec![
        "Yes, continue with installation",
        "No, I'll configure PATH first",
    ];

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Continue with ProfileCore installation?")
        .items(&options)
        .default(0)
        .interact()
        .unwrap_or(1);

    println!();

    if selection != 0 {
        print_cancelled();
        println!("{}", "Tip: After adding to PATH, run:".dimmed());
        println!("  {}", "profilecore install".cyan());
        println!();
        false
    } else {
        true
    }
}

/// Install ProfileCore for multiple shells
fn install_for_shells(
    shells: &[shell::ShellType],
    context: &mut InstallContext,
) -> Vec<InstallResult> {
    shells
        .iter()
        .map(|shell| install_for_shell(shell, context))
        .collect()
}

/// Install ProfileCore for a single shell
fn install_for_shell(shell: &shell::ShellType, context: &mut InstallContext) -> InstallResult {
    println!(
        "{}",
        format!("Installing for {}...", shell.as_str())
            .bold()
            .cyan()
    );
    println!();

    let profile_path = paths::get_shell_profile_path(shell);
    println!(
        "Profile file: {}",
        profile_path.display().to_string().cyan()
    );
    println!();

    // Check if already installed
    if paths::is_profilecore_installed(&profile_path) {
        if !prompt_reinstall(shell) {
            return InstallResult::skipped(shell.clone());
        }
    }

    // Perform installation steps
    if !backup_profile(&profile_path) {
        return InstallResult::failed(shell.clone());
    }

    if !context.ensure_config_dir() {
        return InstallResult::failed(shell.clone());
    }

    if !add_init_code(shell, &profile_path) {
        return InstallResult::failed(shell.clone());
    }

    println!();
    InstallResult::success(shell.clone())
}

/// Prompt user about reinstalling
fn prompt_reinstall(shell: &shell::ShellType) -> bool {
    println!(
        "{}",
        "ProfileCore is already installed in this shell profile!".yellow()
    );
    println!();

    let options = vec!["Yes, reinstall/update", "No, skip this shell"];
    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Do you want to reinstall?")
        .items(&options)
        .default(1)
        .interact()
        .unwrap_or(1);

    if selection != 0 {
        println!("{}", format!("Skipping {}...", shell.as_str()).yellow());
        println!();
        false
    } else {
        println!();
        true
    }
}

/// Backup profile file
fn backup_profile(profile_path: &PathBuf) -> bool {
    if !profile_path.exists() {
        return true;
    }

    match fs_helpers::backup_file(profile_path) {
        Ok(backup_path) => {
            println!(
                "{} Backed up existing profile to: {}",
                CHECK_MARK.green(),
                backup_path.display()
            );
            true
        }
        Err(e) => {
            println!("{} Failed to backup profile: {}", CROSS_MARK.red(), e);
            false
        }
    }
}

/// Add init code to profile
fn add_init_code(shell: &shell::ShellType, profile_path: &PathBuf) -> bool {
    let init_code = shell::generate_init_code(shell);

    match fs_helpers::append_to_file(profile_path, &init_code) {
        Ok(_) => {
            println!(
                "{} Added ProfileCore init to: {}",
                CHECK_MARK.green(),
                profile_path.display()
            );
            true
        }
        Err(e) => {
            println!("{} Failed to add init code: {}", CROSS_MARK.red(), e);
            false
        }
    }
}

// ============================================================================
// Verification
// ============================================================================

/// Verify installations for all shells
fn verify_installations(results: &[InstallResult]) {
    for result in results {
        if result.success {
            verify_installation(&result.shell);
        }
    }
}

/// Verify installation for a single shell
fn verify_installation(shell: &shell::ShellType) {
    println!();
    println!("{}", "═".repeat(50).dimmed());
    println!("{}", "Installation Verification".bold());
    println!("{}", "═".repeat(50).dimmed());
    println!();

    // Check 1: Binary in PATH
    check_status(
        fs_helpers::is_in_path(BINARY_NAME),
        "Binary in PATH",
        "Binary NOT in PATH",
    );

    // Check 2: Profile file exists
    let profile_path = paths::get_shell_profile_path(shell);
    check_status(
        profile_path.exists(),
        &format!("Profile file exists: {}", profile_path.display()),
        &format!("Profile file NOT found: {}", profile_path.display()),
    );

    // Check 3: Init code present
    check_status(
        paths::is_profilecore_installed(&profile_path),
        "Init code added to profile",
        "Init code NOT in profile",
    );

    // Check 4: Config directory
    let config_dir = paths::get_config_dir();
    check_status(
        config_dir.exists(),
        &format!("Config directory exists: {}", config_dir.display()),
        &format!("Config directory NOT found: {}", config_dir.display()),
    );

    println!();
    println!("{}", "═".repeat(50).dimmed());
    println!();
}

/// Check and print status
fn check_status(condition: bool, success_msg: &str, failure_msg: &str) {
    if condition {
        println!("{} {}", CHECK_MARK.green(), success_msg);
    } else {
        println!("{} {}", CROSS_MARK.red(), failure_msg);
    }
}

// ============================================================================
// Uninstaller
// ============================================================================

/// Run the interactive uninstaller
pub fn run_uninstaller() {
    print_header("Uninstaller");

    if !confirm_uninstall() {
        print_cancelled();
        return;
    }

    println!();

    let detected_shell = shell::detect_current_shell();
    let profile_path = paths::get_shell_profile_path(&detected_shell);

    remove_init_code(&profile_path);
    prompt_remove_config();

    print_uninstall_complete();
}

/// Confirm uninstallation
fn confirm_uninstall() -> bool {
    let options = vec!["No, keep ProfileCore", "Yes, uninstall ProfileCore"];

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Are you sure you want to uninstall ProfileCore?")
        .items(&options)
        .default(0)
        .interact()
        .unwrap_or(0);

    selection == 1
}

/// Remove init code from profile
fn remove_init_code(profile_path: &PathBuf) {
    if !profile_path.exists() {
        return;
    }

    let Ok(content) = std::fs::read_to_string(profile_path) else {
        println!("{} Failed to read profile file", CROSS_MARK.red());
        return;
    };

    let cleaned = remove_profilecore_section(&content);

    match std::fs::write(profile_path, cleaned) {
        Ok(_) => println!("{} Removed init code from profile", CHECK_MARK.green()),
        Err(e) => println!("{} Error removing init code: {}", CROSS_MARK.red(), e),
    }
}

/// Remove ProfileCore section from profile content
fn remove_profilecore_section(content: &str) -> String {
    let lines: Vec<&str> = content.lines().collect();
    let mut new_lines = Vec::new();
    let mut skip_block = false;

    for line in lines {
        if line.contains(&format!("ProfileCore {} - Added by installer", VERSION)) {
            skip_block = true;
            continue;
        }

        if skip_block {
            // End of ProfileCore block detection
            if line.trim().is_empty()
                || (!line.starts_with('#')
                    && !line.starts_with("if")
                    && !line.starts_with("eval")
                    && !line.starts_with("    ")
                    && !line.ends_with("fi")
                    && !line.ends_with("end")
                    && !line.ends_with("}"))
            {
                skip_block = false;
            } else {
                continue;
            }
        }

        new_lines.push(line);
    }

    new_lines.join("\n")
}

/// Prompt to remove config directory
fn prompt_remove_config() {
    let config_dir = paths::get_config_dir();

    if !config_dir.exists() {
        return;
    }

    let options = vec![
        "No, keep configuration files",
        "Yes, remove configuration directory",
    ];

    let selection = Select::with_theme(&ColorfulTheme::default())
        .with_prompt("Also remove configuration directory?")
        .items(&options)
        .default(0)
        .interact()
        .unwrap_or(0);

    if selection == 1 {
        match std::fs::remove_dir_all(&config_dir) {
            Ok(_) => println!("{} Removed config directory", CHECK_MARK.green()),
            Err(e) => println!(
                "{} Error removing config directory: {}",
                CROSS_MARK.red(),
                e
            ),
        }
    }
}

// ============================================================================
// UI Helpers
// ============================================================================

/// Print header with title
fn print_header(title: &str) {
    println!("{}", BOX_TOP.cyan());
    println!(
        "{} ProfileCore {} {:<18} {}",
        BOX_LINE.cyan(),
        VERSION,
        title,
        BOX_LINE.cyan()
    );
    println!("{}", BOX_BOTTOM.cyan());
    println!();
}

/// Print success message
fn print_success_message(
    primary_shell: &shell::ShellType,
    installed_count: usize,
    total_count: usize,
) {
    println!();
    println!("{}", BOX_TOP.green());
    println!(
        "{}  Installation Complete! {:<14} {}",
        BOX_LINE.green(),
        CHECK_MARK,
        BOX_LINE.green()
    );
    println!("{}", BOX_BOTTOM.green());
    println!();

    if installed_count < total_count {
        println!(
            "{}",
            format!(
                "Installed for {} out of {} selected shells",
                installed_count, total_count
            )
            .yellow()
        );
        println!();
    }

    println!("Next steps:");
    println!();
    println!("  1. Reload your shell:");
    println!("     {}", shell::get_reload_command(primary_shell).cyan());
    println!();
    println!("  2. Verify installation:");
    println!("     {}", "profilecore --version".cyan());
    println!();
    println!("  3. Try a command:");
    println!("     {}", "profilecore system info".cyan());
    println!(
        "     {} {}",
        "sysinfo".cyan().italic(),
        "(using alias)".dimmed()
    );
    println!();
    println!("  4. Get help:");
    println!("     {}", "profilecore --help".cyan());
    println!();
}

/// Print uninstall complete message
fn print_uninstall_complete() {
    println!();
    println!("{}", BOX_TOP.green());
    println!(
        "{}  Uninstall Complete! {:<15} {}",
        BOX_LINE.green(),
        CHECK_MARK,
        BOX_LINE.green()
    );
    println!("{}", BOX_BOTTOM.green());
    println!();
    println!("ProfileCore has been removed from your shell configuration.");
    println!();
    println!("To completely remove ProfileCore:");
    println!("  1. Delete the binary from your PATH");
    println!("  2. Restart your shell");
    println!();
}

/// Print cancelled message
fn print_cancelled() {
    println!("{}", "Installation cancelled.".yellow());
}

/// Print error message
fn print_error(message: &str) {
    println!("{} {}", CROSS_MARK.red(), message);
}
