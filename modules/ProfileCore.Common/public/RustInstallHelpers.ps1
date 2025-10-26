# RustInstallHelpers.ps1
# Rust-backed high-performance installation helper functions
# Uses native Rust DLL for network checks, validation, and retry logic

# Check if Rust binary is available (reuse from RustOutputHelpers)
$script:RustHelpersAvailable = $false
$script:RustHelpersType = $null

function Initialize-RustHelpers {
    <#
    .SYNOPSIS
        Initializes the Rust installation helpers module
    .DESCRIPTION
        Attempts to load the Rust binary and create P/Invoke signatures for helper functions.
        Falls back to PowerShell implementation if Rust is unavailable.
    #>
    [CmdletBinding()]
    param()
    
    if ($script:RustHelpersType) {
        return $true  # Already initialized
    }
    
    # Try to find the Rust DLL
    $moduleRoot = Split-Path -Parent $PSScriptRoot
    $parentModule = Split-Path -Parent $moduleRoot
    $rustBinaryPath = Join-Path $parentModule "ProfileCore\rust-binary\bin"
    
    # Determine platform-specific DLL name
    $dllName = if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        "ProfileCore.dll"
    } elseif ($IsMacOS) {
        "libprofilecore_rs.dylib"
    } else {
        "libprofilecore_rs.so"
    }
    
    $dllPath = Join-Path $rustBinaryPath $dllName
    
    if (-not (Test-Path $dllPath)) {
        Write-Verbose "Rust binary not found at $dllPath - using PowerShell fallback"
        return $false
    }
    
    try {
        # Create P/Invoke signatures for Rust helper functions
        $signature = @"
using System;
using System.Runtime.InteropServices;

public class ProfileCoreHelpers {
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern int ProfileTestGitHubConnectivity(int timeout_ms);
    
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern int ProfileTestCommandExists(string command);
    
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr ProfileTestPrerequisites(string commands, string delimiter);
    
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern int ProfileCalculateBackoff(int attempt, int initial_delay_ms);
    
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern int ProfileShouldRetry(int attempt, int max_attempts);
    
    [DllImport("$($dllPath.Replace('\', '\\'))", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.Cdecl)]
    public static extern void FreeString(IntPtr ptr);
}
"@
        
        # Try to add the type (may already exist if module was reloaded)
        if (-not ([System.Management.Automation.PSTypeName]'ProfileCoreHelpers').Type) {
            Add-Type -TypeDefinition $signature -ErrorAction Stop
        }
        
        $script:RustHelpersType = [ProfileCoreHelpers]
        $script:RustHelpersAvailable = $true
        
        Write-Verbose "Rust helpers module initialized successfully"
        return $true
        
    } catch {
        Write-Verbose "Failed to initialize Rust helpers: $_"
        return $false
    }
}

function Get-RustString {
    <#
    .SYNOPSIS
        Helper to convert Rust C string pointer to PowerShell string and free memory
    #>
    param([IntPtr]$Ptr)
    
    if ($Ptr -eq [IntPtr]::Zero) {
        return ""
    }
    
    try {
        $result = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Ptr)
        [ProfileCoreHelpers]::FreeString($Ptr)
        return $result
    } catch {
        Write-Verbose "Failed to read Rust string: $_"
        return ""
    }
}

# ============================================================================
# Rust-Backed Helper Functions
# ============================================================================

function Test-RustGitHubConnectivity {
    <#
    .SYNOPSIS
        Tests GitHub connectivity (Rust-backed)
    .PARAMETER TimeoutMs
        Timeout in milliseconds (default: 5000)
    .EXAMPLE
        Test-RustGitHubConnectivity -TimeoutMs 3000
    #>
    [CmdletBinding()]
    param(
        [int]$TimeoutMs = 5000
    )
    
    # Initialize Rust if needed
    if (-not $script:RustHelpersAvailable) {
        if (-not (Initialize-RustHelpers)) {
            # Fall back to PowerShell version
            return Test-GitHubConnectivity
        }
    }
    
    try {
        $result = [ProfileCoreHelpers]::ProfileTestGitHubConnectivity($TimeoutMs)
        return ($result -eq 1)
    } catch {
        Write-Verbose "Rust GitHub test failed, using fallback: $_"
        return Test-GitHubConnectivity
    }
}

function Test-RustCommandExists {
    <#
    .SYNOPSIS
        Tests if a command exists (Rust-backed)
    .PARAMETER Command
        Command name to check
    .EXAMPLE
        Test-RustCommandExists "git"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command
    )
    
    if (-not $script:RustHelpersAvailable) {
        if (-not (Initialize-RustHelpers)) {
            # Fall back to PowerShell
            return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
        }
    }
    
    try {
        $result = [ProfileCoreHelpers]::ProfileTestCommandExists($Command)
        return ($result -eq 1)
    } catch {
        Write-Verbose "Rust command test failed, using fallback: $_"
        return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
    }
}

function Test-RustPrerequisites {
    <#
    .SYNOPSIS
        Tests multiple prerequisites (Rust-backed)
    .PARAMETER Commands
        Array of command names to check
    .EXAMPLE
        Test-RustPrerequisites -Commands @("git", "node", "npm")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Commands
    )
    
    if (-not $script:RustHelpersAvailable) {
        if (-not (Initialize-RustHelpers)) {
            # Fall back to PowerShell version
            return Test-Prerequisites -Commands $Commands
        }
    }
    
    try {
        $commandList = $Commands -join ","
        $ptr = [ProfileCoreHelpers]::ProfileTestPrerequisites($commandList, ",")
        $result = Get-RustString -Ptr $ptr
        $parts = $result -split ","
        
        return @{
            Success = [int]$parts[0]
            Total = [int]$parts[1]
        }
    } catch {
        Write-Verbose "Rust prerequisites test failed, using fallback: $_"
        return Test-Prerequisites -Commands $Commands
    }
}

function Invoke-RustWithRetry {
    <#
    .SYNOPSIS
        Executes a script block with retry logic (Rust-backed backoff calculation)
    .PARAMETER ScriptBlock
        The script block to execute
    .PARAMETER MaxAttempts
        Maximum number of attempts (default: 3)
    .PARAMETER InitialDelayMs
        Initial delay in milliseconds (default: 1000)
    .EXAMPLE
        Invoke-RustWithRetry -ScriptBlock { Get-Content "file.txt" } -MaxAttempts 3
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        
        [int]$MaxAttempts = 3,
        [int]$InitialDelayMs = 1000
    )
    
    # Initialize Rust if not already done
    if (-not $script:RustHelpersAvailable) {
        if (-not (Initialize-RustHelpers)) {
            # Fall back to PowerShell version
            return Invoke-WithRetry -ScriptBlock $ScriptBlock -MaxAttempts $MaxAttempts
        }
    }
    
    $attempt = 0
    $lastError = $null
    
    while ($attempt -lt $MaxAttempts) {
        try {
            return & $ScriptBlock
        } catch {
            $lastError = $_
            $attempt++
            
            # Check if should retry (using Rust function)
            $shouldRetry = try {
                [ProfileCoreHelpers]::ProfileShouldRetry($attempt, $MaxAttempts)
            } catch {
                ($attempt -lt $MaxAttempts)
            }
            
            if ($shouldRetry -eq 1 -or $shouldRetry -eq $true) {
                # Calculate backoff delay (using Rust function)
                $delayMs = try {
                    [ProfileCoreHelpers]::ProfileCalculateBackoff($attempt - 1, $InitialDelayMs)
                } catch {
                    $InitialDelayMs * [Math]::Pow(2, $attempt - 1)
                }
                
                Write-Verbose "Attempt $attempt failed, retrying in ${delayMs}ms..."
                Start-Sleep -Milliseconds $delayMs
            }
        }
    }
    
    # All attempts failed
    throw $lastError
}

# Export Rust-backed helper functions
Export-ModuleMember -Function @(
    'Initialize-RustHelpers',
    'Test-RustGitHubConnectivity',
    'Test-RustCommandExists',
    'Test-RustPrerequisites',
    'Invoke-RustWithRetry'
)

