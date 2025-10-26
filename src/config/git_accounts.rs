//! Git account management with TOML config

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GitAccount {
    pub name: String,
    pub email: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub signing_key: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct GitAccountsConfig {
    #[serde(default)]
    pub accounts: Vec<GitAccount>,
}

impl GitAccountsConfig {
    pub fn load() -> Result<Self> {
        let path = Self::config_path()?;
        
        if !path.exists() {
            return Ok(Self {
                accounts: Vec::new(),
            });
        }
        
        let contents = fs::read_to_string(&path)
            .with_context(|| format!("Failed to read config from {}", path.display()))?;
        
        toml::from_str(&contents)
            .with_context(|| format!("Failed to parse config from {}", path.display()))
    }
    
    pub fn save(&self) -> Result<()> {
        let path = Self::config_path()?;
        
        // Ensure parent directory exists
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)
                .with_context(|| format!("Failed to create config directory: {}", parent.display()))?;
        }
        
        let contents = toml::to_string_pretty(self)
            .context("Failed to serialize config")?;
        
        fs::write(&path, contents)
            .with_context(|| format!("Failed to write config to {}", path.display()))?;
        
        Ok(())
    }
    
    pub fn add_account(&mut self, account: GitAccount) -> Result<()> {
        // Check for duplicate
        if self.accounts.iter().any(|a| a.name == account.name) {
            anyhow::bail!("Account '{}' already exists", account.name);
        }
        
        self.accounts.push(account);
        self.save()?;
        Ok(())
    }
    
    pub fn find_account(&self, name: &str) -> Option<&GitAccount> {
        self.accounts.iter().find(|a| a.name == name)
    }
    
    pub fn remove_account(&mut self, name: &str) -> Result<()> {
        let original_len = self.accounts.len();
        self.accounts.retain(|a| a.name != name);
        
        if self.accounts.len() == original_len {
            anyhow::bail!("Account '{}' not found", name);
        }
        
        self.save()?;
        Ok(())
    }
    
    fn config_path() -> Result<PathBuf> {
        let config_dir = dirs::config_dir()
            .context("Failed to determine config directory")?;
        
        Ok(config_dir.join("profilecore").join("git-accounts.toml"))
    }
}

