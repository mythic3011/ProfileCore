//! ProfileCore Rust Module
//! 
//! Shared library for both CLI and FFI (PowerShell).
//! All business logic lives here - CLI and FFI are thin wrappers.
//! 
//! # Architecture
//! - `output`: Formatting and output functions (SHARED)
//! - `helpers`: Installation utilities (SHARED)
//! - `system`: System information (SHARED)
//! - `network`: Network utilities (SHARED)
//! - `platform`: Platform detection (SHARED)
//! - `cmdlets`: FFI exports for PowerShell
//! - `cli`: CLI command handlers (thin wrappers)

// ============================================================================
// SHARED LIBRARY MODULES (used by both CLI and FFI)
// ============================================================================

/// Output formatting functions - SHARED CODE
/// Used by: CLI output commands, FFI exports, prompt rendering
pub mod output;

/// Installation helper functions - SHARED CODE
/// Used by: CLI helper commands, FFI exports, installation scripts
pub mod helpers;

/// System information - SHARED CODE
/// Used by: CLI system commands, FFI exports
pub mod system;

/// Network utilities - SHARED CODE
/// Used by: CLI network commands, FFI exports
pub mod network;

/// Platform detection - SHARED CODE
/// Used by: All modules for cross-platform logic
pub mod platform;

/// Prompt rendering - SHARED CODE
/// Used by: CLI, FFI, shell integration
pub mod prompt;

// ============================================================================
// INTERFACE MODULES (thin wrappers around shared code)
// ============================================================================

/// FFI exports for PowerShell - THIN WRAPPER
/// Calls shared library functions
pub mod cmdlets;

/// CLI command handlers - THIN WRAPPER
/// Calls shared library functions
pub mod cli;

/// Initialize the module (called once by PowerShell)
#[no_mangle]
pub extern "C" fn InitializeModule() -> i32 {
    // Minimal initialization
    // Return 1 for success
    1
}

/// Get module version
#[no_mangle]
pub extern "C" fn GetModuleVersion() -> *mut std::os::raw::c_char {
    use std::ffi::CString;
    let version = CString::new("5.1.0").unwrap();
    version.into_raw()
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_initialize() {
        assert_eq!(InitializeModule(), 1);
    }
    
    #[test]
    fn test_version() {
        let ptr = GetModuleVersion();
        assert!(!ptr.is_null());
        unsafe {
            use std::ffi::CStr;
            let version = CStr::from_ptr(ptr).to_string_lossy();
            assert_eq!(version, "5.1.0");
            let _ = std::ffi::CString::from_raw(ptr);
        }
    }
}
