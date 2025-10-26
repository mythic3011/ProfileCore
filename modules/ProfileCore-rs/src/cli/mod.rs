//! CLI Module - Thin Wrappers Around Shared Library
//! 
//! All CLI commands are thin wrappers that parse arguments and call
//! shared library functions from `output`, `helpers`, `system`, `network`.
//! 
//! NO business logic should be here - only argument parsing and routing.

pub mod init;
pub mod completions;
pub mod commands;
pub mod interactive;

// Re-export command enums for main.rs
pub use commands::{OutputCmd, HelperCmd, SystemCmd, NetworkCmd};

