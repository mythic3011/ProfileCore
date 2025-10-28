//! Text processing commands

use colored::Colorize;
use regex::Regex;
use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::path::Path;

pub fn grep(pattern: &str, file_path: &str, ignore_case: bool) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    let file = match File::open(path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{} Failed to open file: {}", "✗".red(), e);
            return;
        }
    };

    let regex_pattern = if ignore_case {
        format!("(?i){}", pattern)
    } else {
        pattern.to_string()
    };

    let re = match Regex::new(&regex_pattern) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("{} Invalid regex pattern: {}", "✗".red(), e);
            return;
        }
    };

    println!(
        "\n{} {} in {}",
        "Searching for:".cyan().bold(),
        pattern.yellow(),
        file_path.cyan()
    );
    println!("{}", "=".repeat(80));

    let reader = BufReader::new(file);
    let mut match_count = 0;

    for (line_num, line_result) in reader.lines().enumerate() {
        let line = match line_result {
            Ok(l) => l,
            Err(_) => continue,
        };

        if re.is_match(&line) {
            println!(
                "{}: {}",
                format!("{}", line_num + 1).cyan(),
                highlight_matches(&line, &re)
            );
            match_count += 1;
        }
    }

    if match_count == 0 {
        println!("{} No matches found", "!".yellow());
    } else {
        println!("\n{} Found {} match(es)", "✓".green(), match_count);
    }
    println!();
}

fn highlight_matches(line: &str, re: &Regex) -> String {
    let mut result = line.to_string();
    let matches: Vec<_> = re.find_iter(line).collect();

    // Highlight from end to start to maintain indices
    for m in matches.iter().rev() {
        let start = m.start();
        let end = m.end();
        let matched = &line[start..end];
        result.replace_range(start..end, &matched.yellow().to_string());
    }

    result
}

pub fn head(file_path: &str, lines: usize) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    let file = match File::open(path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{} Failed to open file: {}", "✗".red(), e);
            return;
        }
    };

    println!(
        "\n{} {} (first {} lines)",
        "File:".cyan().bold(),
        file_path.yellow(),
        lines
    );
    println!("{}", "=".repeat(80));

    let reader = BufReader::new(file);

    for (idx, line_result) in reader.lines().enumerate() {
        if idx >= lines {
            break;
        }

        match line_result {
            Ok(line) => println!("{}", line),
            Err(e) => {
                eprintln!("{} Error reading line: {}", "✗".red(), e);
                break;
            }
        }
    }

    println!();
}

pub fn tail(file_path: &str, lines: usize) {
    let path = Path::new(file_path);

    if !path.exists() {
        eprintln!("{} File not found: {}", "✗".red(), file_path);
        return;
    }

    let file = match File::open(path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{} Failed to open file: {}", "✗".red(), e);
            return;
        }
    };

    println!(
        "\n{} {} (last {} lines)",
        "File:".cyan().bold(),
        file_path.yellow(),
        lines
    );
    println!("{}", "=".repeat(80));

    let reader = BufReader::new(file);
    let all_lines: Result<Vec<String>, io::Error> = reader.lines().collect();

    match all_lines {
        Ok(lines_vec) => {
            let start_index = lines_vec.len().saturating_sub(lines);
            for line in &lines_vec[start_index..] {
                println!("{}", line);
            }
        }
        Err(e) => {
            eprintln!("{} Error reading file: {}", "✗".red(), e);
        }
    }

    println!();
}
