//! Uninstall legacy v6.0.0 PowerShell modules

use colored::Colorize;
use std::fs;
use std::path::PathBuf;

pub fn uninstall_legacy() {
    println!("\n{}", "=".repeat(60).cyan());
    println!("{}", "UNINSTALLING LEGACY v6.0.0 MODULES".cyan().bold());
    println!("{}\n", "=".repeat(60).cyan());
    
    let ps_modules = vec![
        "ProfileCore",
        "ProfileCore.Common",
        "ProfileCore.CloudSync",
        "ProfileCore.Security",
    ];
    
    let module_paths = get_powershell_module_paths();
    
    for module in &ps_modules {
        let mut found = false;
        
        for base_path in &module_paths {
            let module_path = base_path.join(module);
            
            if module_path.exists() {
                found = true;
                match fs::remove_dir_all(&module_path) {
                    Ok(_) => println!("{} Removed {}", "✓".green(), module.cyan()),
                    Err(e) => eprintln!("{} Failed to remove {}: {}", "✗".red(), module, e),
                }
            }
        }
        
        if !found {
            println!("{} {} not found (already removed)", "·".blue(), module);
        }
    }
    
    println!("\n{} v6.0.0 modules cleaned up", "✓".green());
    println!("{} Next steps:", "→".cyan());
    println!("  1. Remove PowerShell profile import: Import-Module ProfileCore");
    println!("  2. Add new init: eval \"$(profilecore init bash)\"  # or your shell");
    println!("  3. Restart your shell\n");
}

fn get_powershell_module_paths() -> Vec<PathBuf> {
    let mut paths = Vec::new();
    
    // User modules path
    if let Some(home) = dirs::home_dir() {
        #[cfg(target_os = "windows")]
        {
            paths.push(home.join("Documents").join("PowerShell").join("Modules"));
            paths.push(home.join("Documents").join("WindowsPowerShell").join("Modules"));
        }
        
        #[cfg(not(target_os = "windows"))]
        {
            paths.push(home.join(".local").join("share").join("powershell").join("Modules"));
        }
    }
    
    paths
}

