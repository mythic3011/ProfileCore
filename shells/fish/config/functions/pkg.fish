# MacOS/.config/fish/functions/pkg.fish
# Package management functions for Fish shell

function _get_pkg_manager
    set os (get_os)
    switch $os
        case macos
            if command -v brew &> /dev/null
                echo "brew"
            else
                echo "❌ Error: Homebrew not found. Please install Homebrew." >&2
                return 1
            end
        case linux
            if command -v apt &> /dev/null
                echo "apt"
            else if command -v dnf &> /dev/null
                echo "dnf"
            else if command -v pacman &> /dev/null
                echo "pacman"
            else if command -v zypper &> /dev/null
                echo "zypper"
            else
                echo "❌ Error: No supported Linux package manager found." >&2
                return 1
            end
        case '*'
            echo "❌ Error: Package management not supported on $os." >&2
            return 1
    end
end

function pkg
    if test (count $argv) -eq 0
        echo "Usage: pkg <package_name> [package_name2 ...]"
        return 1
    end

    if test "$argv[1]" = "--help"
        echo "pkg: Install packages using the native package manager."
        echo "Usage: pkg <package_name> [package_name2 ...]"
        return 0
    end

    set pkg_manager (_get_pkg_manager)
    test -z "$pkg_manager"; and return 1

    echo "📦 Installing packages with $pkg_manager..."
    switch $pkg_manager
        case brew
            brew install $argv
        case apt
            sudo apt update && sudo apt install -y $argv
        case dnf
            sudo dnf install -y $argv
        case pacman
            sudo pacman -S --noconfirm $argv
        case zypper
            sudo zypper install -y $argv
    end
end

function pkgs
    if test (count $argv) -eq 0
        echo "Usage: pkgs <search_term>"
        return 1
    end

    if test "$argv[1]" = "--help"
        echo "pkgs: Search for packages."
        return 0
    end

    set pkg_manager (_get_pkg_manager)
    test -z "$pkg_manager"; and return 1

    echo "🔍 Searching for '$argv[1]' with $pkg_manager..."
    switch $pkg_manager
        case brew
            brew search $argv[1]
        case apt
            apt search $argv[1]
        case dnf
            dnf search $argv[1]
        case pacman
            pacman -Ss $argv[1]
        case zypper
            zypper search $argv[1]
    end
end

function pkgu
    if test "$argv[1]" = "--help"
        echo "pkgu: Update all packages."
        return 0
    end

    set os (get_os)
    echo "🔄 Updating packages on $os..."

    switch $os
        case macos
            if command -v brew &> /dev/null
                echo "Updating Homebrew packages..."
                brew update && brew upgrade && brew cleanup
            end
        case linux
            if command -v apt &> /dev/null
                echo "Updating APT packages..."
                sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
            else if command -v dnf &> /dev/null
                echo "Updating DNF packages..."
                sudo dnf update -y && sudo dnf autoremove -y
            else if command -v pacman &> /dev/null
                echo "Updating Pacman packages..."
                sudo pacman -Syu --noconfirm
            end
    end
    echo "✅ Package update complete."
end

