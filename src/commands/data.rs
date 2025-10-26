//! Data processing commands (JSON, YAML, CSV)

use colored::Colorize;
use serde_json::Value as JsonValue;
use serde_yaml::Value as YamlValue;

pub fn json_format(input: &str, minify: bool) {
    println!("\n{}", "JSON Processing".cyan().bold());
    println!("{}", "=".repeat(60));
    
    match serde_json::from_str::<JsonValue>(input) {
        Ok(value) => {
            if minify {
                match serde_json::to_string(&value) {
                    Ok(minified) => {
                        println!("{}", "Minified:".green());
                        println!("{}", minified);
                    }
                    Err(e) => {
                        eprintln!("{} Failed to minify: {}", "✗".red(), e);
                    }
                }
            } else {
                match serde_json::to_string_pretty(&value) {
                    Ok(formatted) => {
                        println!("{}", "Formatted:".green());
                        println!("{}", formatted);
                    }
                    Err(e) => {
                        eprintln!("{} Failed to format: {}", "✗".red(), e);
                    }
                }
            }
        }
        Err(e) => {
            eprintln!("{} Invalid JSON: {}", "✗".red(), e);
        }
    }
    
    println!();
}

pub fn yaml_to_json(input: &str) {
    println!("\n{}", "YAML → JSON Conversion".cyan().bold());
    println!("{}", "=".repeat(60));
    
    match serde_yaml::from_str::<YamlValue>(input) {
        Ok(yaml_value) => {
            // Convert YAML value to JSON value
            match serde_json::to_value(&yaml_value) {
                Ok(json_value) => {
                    match serde_json::to_string_pretty(&json_value) {
                        Ok(json_str) => {
                            println!("{}", "JSON Output:".green());
                            println!("{}", json_str);
                        }
                        Err(e) => {
                            eprintln!("{} Failed to serialize JSON: {}", "✗".red(), e);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("{} Failed to convert to JSON: {}", "✗".red(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Invalid YAML: {}", "✗".red(), e);
        }
    }
    
    println!();
}

pub fn json_to_yaml(input: &str) {
    println!("\n{}", "JSON → YAML Conversion".cyan().bold());
    println!("{}", "=".repeat(60));
    
    match serde_json::from_str::<JsonValue>(input) {
        Ok(json_value) => {
            // Convert JSON value to YAML value
            match serde_yaml::to_value(&json_value) {
                Ok(yaml_value) => {
                    match serde_yaml::to_string(&yaml_value) {
                        Ok(yaml_str) => {
                            println!("{}", "YAML Output:".green());
                            println!("{}", yaml_str);
                        }
                        Err(e) => {
                            eprintln!("{} Failed to serialize YAML: {}", "✗".red(), e);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("{} Failed to convert to YAML: {}", "✗".red(), e);
                }
            }
        }
        Err(e) => {
            eprintln!("{} Invalid JSON: {}", "✗".red(), e);
        }
    }
    
    println!();
}

