# MacOS/.config/fish/functions/get_os.fish
# OS Detection for Fish shell

function get_os
    switch (uname -s)
        case Darwin
            echo "macos"
        case Linux
            echo "linux"
        case 'CYGWIN*' 'MINGW*' 'MSYS*'
            echo "windows"
        case '*'
            echo "unknown"
    end
end

function is_macos
    test (get_os) = "macos"
end

function is_linux
    test (get_os) = "linux"
end

function is_windows
    test (get_os) = "windows"
end

function get_arch
    switch (uname -m)
        case arm64 aarch64
            echo "arm64"
        case x86_64 amd64
            echo "x86_64"
        case i686 i386
            echo "x86"
        case '*'
            echo "unknown"
    end
end

function is_apple_silicon
    is_macos; and test (get_arch) = "arm64"
end

function get_macos_version
    if is_macos
        sw_vers -productVersion
    end
end

function get_linux_distro
    if is_linux
        if test -f /etc/os-release
            grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"'
        else if test -f /etc/lsb-release
            grep -E '^DISTRIB_ID=' /etc/lsb-release | cut -d= -f2
        else if test -f /etc/redhat-release
            cat /etc/redhat-release | awk '{print $1}'
        else
            echo "unknown_linux"
        end
    end
end

function show_os_info
    set os (get_os)
    set arch (get_arch)
    
    echo "Operating System: $os"
    echo "Architecture: $arch"
    
    if is_macos
        echo "macOS Version: "(get_macos_version)
        if is_apple_silicon
            echo "Apple Silicon: Yes"
        else
            echo "Apple Silicon: No"
        end
    else if is_linux
        echo "Linux Distribution: "(get_linux_distro)
    end
end

