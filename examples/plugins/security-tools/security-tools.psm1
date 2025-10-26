# security-tools.psm1
# Security Tools Plugin using SOLID architecture

<#
.SYNOPSIS
    Essential security tools plugin
.DESCRIPTION
    Provides SSH key management, file verification, VirusTotal integration,
    and Shodan IP lookup using ProfileCore's SOLID architecture.
#>

class SecurityToolsPlugin : PluginBaseV2 {
    [hashtable]$SecurityConfig
    
    SecurityToolsPlugin([ServiceContainer]$services) : base('security-tools', [version]'1.0.0', $services) {
        $this.Author = "ProfileCore Team"
        $this.Description = "Essential security tools for penetration testing and security analysis"
        $this.SecurityConfig = @{
            DefaultKeyPath = "$HOME/.ssh/id_rsa.pub"
            DefaultHashAlgorithm = 'SHA256'
            EnableVirusTotal = $true
            EnableShodan = $true
        }
    }
    
    [void] OnInitialize() {
        $this.Log("Initializing Security Tools plugin", "Info")
        $this.LoadConfig()
    }
    
    [void] OnLoad() {
        $this.Log("Loading Security Tools plugin", "Info")
        
        # Get configuration manager
        $configManager = $this.GetConfigurationManager()
        
        # Load plugin config
        $savedConfig = $configManager.GetConfig('security-tools')
        if ($savedConfig.Count -gt 0) {
            foreach ($key in $savedConfig.Keys) {
                $this.SecurityConfig[$key] = $savedConfig[$key]
            }
        }
        
        # Register commands
        $this.RegisterCommands()
        
        $this.Log("Security Tools plugin loaded successfully", "Info")
    }
    
    [void] OnUnload() {
        $this.Log("Unloading Security Tools plugin", "Info")
    }
    
    [void] RegisterCommands() {
        $cmdCapability = [CommandProviderCapability]::new()
        
        # SSH Copy ID Command
        $cmdCapability.RegisterCommand('Copy-SshId', {
            param($params)
            
            $userAtMachine = $params.UserAtMachine
            $keyPath = if ($params.KeyPath) { $params.KeyPath } else { "$HOME/.ssh/id_rsa.pub" }
            $sshArgs = $params.SshArgs
            
            if (-not (Test-Path $keyPath)) {
                Write-Error "ERROR: failed to open ID file '$keyPath': No such file"
                return
            }
            
            Write-Host "🔑 Copying SSH key to $userAtMachine..." -ForegroundColor Cyan
            
            try {
                $keyContent = Get-Content $keyPath -Raw
                $command = "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys"
                
                if ($sshArgs) {
                    echo $keyContent | & ssh $sshArgs $userAtMachine $command
                } else {
                    echo $keyContent | & ssh $userAtMachine $command
                }
                
                Write-Host "✅ SSH key copied successfully" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to copy SSH key: $_"
            }
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })
        
        # File Hash Verification Command
        $cmdCapability.RegisterCommand('Test-FileHash', {
            param($params)
            
            $filePath = if ($params.FilePath) { $params.FilePath } else { Read-Host -Prompt 'Enter file path' }
            $expectedHash = if ($params.ExpectedHash) { $params.ExpectedHash } else { Read-Host -Prompt 'Enter expected hash' }
            $algorithm = if ($params.Algorithm) { $params.Algorithm } else { 'SHA256' }
            
            if (-not (Test-Path $filePath -PathType Leaf)) {
                Write-Host "❌ File not found: $filePath" -ForegroundColor Red
                return @{ Valid = $false; Error = "File not found" }
            }
            
            Write-Host "`n🔍 Verifying file hash..." -ForegroundColor Cyan
            Write-Host "File: $filePath" -ForegroundColor Gray
            Write-Host "Algorithm: $algorithm" -ForegroundColor Gray
            
            try {
                $fileHash = Get-FileHash -Path $filePath -Algorithm $algorithm | Select-Object -ExpandProperty Hash
                
                Write-Host "`nCalculated Hash:" -ForegroundColor Yellow
                Write-Host $fileHash -ForegroundColor White
                Write-Host "`nExpected Hash:" -ForegroundColor Yellow
                Write-Host $expectedHash -ForegroundColor White
                
                if ($fileHash -eq $expectedHash) {
                    Write-Host "`n✅ File hash matches!" -ForegroundColor Green
                    return @{ Valid = $true; Hash = $fileHash; Algorithm = $algorithm }
                } else {
                    Write-Host "`n❌ File hash mismatch!" -ForegroundColor Red
                    return @{ Valid = $false; Hash = $fileHash; Expected = $expectedHash; Algorithm = $algorithm }
                }
            }
            catch {
                Write-Error "Failed to verify hash: $_"
                return @{ Valid = $false; Error = $_.Exception.Message }
            }
        }, @{
            EnableCache = $false
            RequiresElevation = $false
            ValidationRules = @{
                Algorithm = { param($v) $v -in @('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512') }
            }
        })
        
        # VirusTotal File Check Command
        $cmdCapability.RegisterCommand('Test-FileOnVirusTotal', {
            param($params)
            
            $filePath = if ($params.FilePath) { $params.FilePath } else { Read-Host -Prompt 'Enter file path' }
            
            # Get API key from configuration manager
            $configManager = [ServiceLocator]::Get('ConfigurationManager')
            $apiKey = $configManager.GetValue('secrets', 'VIRUSTOTAL_API', $env:PWSH_VIRUSTOTAL_API)
            
            if (-not $apiKey) {
                Write-Warning "VirusTotal API key not found."
                Write-Host "Set it in ~/.config/shell-profile/secrets.json:" -ForegroundColor Yellow
                Write-Host '  { "VIRUSTOTAL_API": "your-api-key" }' -ForegroundColor Gray
                Write-Host "Or set environment variable: PWSH_VIRUSTOTAL_API" -ForegroundColor Yellow
                return @{ Success = $false; Error = "API key not configured" }
            }
            
            if (-not (Test-Path $filePath -PathType Leaf)) {
                Write-Host "❌ File not found: $filePath" -ForegroundColor Red
                return @{ Success = $false; Error = "File not found" }
            }
            
            Write-Host "`n🛡️  Checking file on VirusTotal..." -ForegroundColor Cyan
            Write-Host "File: $filePath" -ForegroundColor Gray
            
            try {
                $fileHash = Get-FileHash -Path $filePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
                Write-Host "SHA256: $fileHash" -ForegroundColor Gray
                
                $url = "https://www.virustotal.com/api/v3/files/$fileHash"
                $headers = @{ 'x-apikey' = $apiKey }
                
                Write-Host "`nQuerying VirusTotal..." -ForegroundColor Yellow
                $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
                
                $stats = $response.data.attributes.last_analysis_stats
                $malicious = $stats.malicious
                $suspicious = $stats.suspicious
                $undetected = $stats.undetected
                $harmless = $stats.harmless
                
                Write-Host "`n📊 Analysis Results:" -ForegroundColor Cyan
                Write-Host "  Malicious:  $malicious" -ForegroundColor $(if ($malicious -gt 0) { 'Red' } else { 'Green' })
                Write-Host "  Suspicious: $suspicious" -ForegroundColor $(if ($suspicious -gt 0) { 'Yellow' } else { 'Green' })
                Write-Host "  Undetected: $undetected" -ForegroundColor Gray
                Write-Host "  Harmless:   $harmless" -ForegroundColor Green
                
                if ($malicious -eq 0 -and $suspicious -eq 0) {
                    Write-Host "`n✅ File appears safe" -ForegroundColor Green
                } elseif ($malicious -gt 0) {
                    Write-Host "`n⚠️  WARNING: $malicious engines detected threats!" -ForegroundColor Red
                } else {
                    Write-Host "`n⚠️  $suspicious engines marked as suspicious" -ForegroundColor Yellow
                }
                
                Write-Host "`n🔗 Full report: https://www.virustotal.com/gui/file/$fileHash" -ForegroundColor Cyan
                
                return @{
                    Success = $true
                    Hash = $fileHash
                    Malicious = $malicious
                    Suspicious = $suspicious
                    Safe = ($malicious -eq 0 -and $suspicious -eq 0)
                    Url = "https://www.virustotal.com/gui/file/$fileHash"
                }
            }
            catch {
                if ($_.Exception.Message -match '404') {
                    Write-Host "`n⚠️  File not found in VirusTotal database" -ForegroundColor Yellow
                    Write-Host "You may need to upload it first" -ForegroundColor Gray
                    return @{ Success = $false; Error = "File not in database" }
                }
                Write-Error "VirusTotal check failed: $_"
                return @{ Success = $false; Error = $_.Exception.Message }
            }
        }, @{
            EnableCache = $true
            RequiresElevation = $false
        })
        
        # Shodan IP Lookup Command
        $cmdCapability.RegisterCommand('Get-ShodanIPInfo', {
            param($params)
            
            $ipAddress = if ($params.IPAddress) { $params.IPAddress } else { Read-Host -Prompt 'Enter IP address' }
            
            # Get API key from configuration manager
            $configManager = [ServiceLocator]::Get('ConfigurationManager')
            $apiKey = $configManager.GetValue('secrets', 'SHODAN_API', $env:PWSH_SHODAN_API)
            
            if (-not $apiKey) {
                Write-Warning "Shodan API key not found."
                Write-Host "Set it in ~/.config/shell-profile/secrets.json:" -ForegroundColor Yellow
                Write-Host '  { "SHODAN_API": "your-api-key" }' -ForegroundColor Gray
                Write-Host "Or set environment variable: PWSH_SHODAN_API" -ForegroundColor Yellow
                return @{ Success = $false; Error = "API key not configured" }
            }
            
            Write-Host "`n🌐 Querying Shodan for IP: $ipAddress" -ForegroundColor Cyan
            
            try {
                $url = "https://api.shodan.io/shodan/host/$ipAddress?key=$apiKey"
                $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
                
                Write-Host "`n📋 IP Information:" -ForegroundColor Cyan
                Write-Host "  IP Address:    $($response.ip_str)" -ForegroundColor White
                Write-Host "  Organization:  $($response.org)" -ForegroundColor Gray
                Write-Host "  ISP:           $($response.isp)" -ForegroundColor Gray
                Write-Host "  Country:       $($response.country_name) ($($response.country_code))" -ForegroundColor Gray
                Write-Host "  City:          $($response.city)" -ForegroundColor Gray
                
                Write-Host "`n🔌 Open Ports:" -ForegroundColor Yellow
                if ($response.ports) {
                    $response.ports | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
                } else {
                    Write-Host "  None detected" -ForegroundColor Gray
                }
                
                Write-Host "`n🏷️  Tags:" -ForegroundColor Yellow
                if ($response.tags) {
                    $response.tags | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
                } else {
                    Write-Host "  None" -ForegroundColor Gray
                }
                
                if ($response.vulns) {
                    Write-Host "`n⚠️  Known Vulnerabilities:" -ForegroundColor Red
                    $response.vulns | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
                }
                
                Write-Host "`n🔗 Full report: https://www.shodan.io/host/$ipAddress" -ForegroundColor Cyan
                
                return @{
                    Success = $true
                    IP = $response.ip_str
                    Organization = $response.org
                    Country = $response.country_name
                    Ports = $response.ports
                    Vulnerabilities = $response.vulns
                }
            }
            catch {
                if ($_.Exception.Message -match '404') {
                    Write-Host "`n⚠️  No information available for this IP" -ForegroundColor Yellow
                    return @{ Success = $false; Error = "IP not in database" }
                }
                Write-Error "Shodan lookup failed: $_"
                return @{ Success = $false; Error = $_.Exception.Message }
            }
        }, @{
            EnableCache = $true
            RequiresElevation = $false
        })
        
        # Register the capability
        $this.RegisterCapability('CommandProvider', $cmdCapability)
    }
}

# Global plugin instance
$script:SecurityToolsPluginInstance = $null

# Initialize function
function Initialize-SecurityTools {
    param([ServiceContainer]$Services)
    
    $script:SecurityToolsPluginInstance = [SecurityToolsPlugin]::new($Services)
    $script:SecurityToolsPluginInstance.OnInitialize()
    $script:SecurityToolsPluginInstance.OnLoad()
    
    # Export commands as global functions
    $cmdCapability = $script:SecurityToolsPluginInstance.GetCapability('CommandProvider')
    if ($cmdCapability) {
        # SSH Copy ID
        New-Item -Path "Function:\global:Copy-SshId" -Value {
            param(
                [Parameter(Position=0)]
                [string]$UserAtMachine,
                
                [Parameter(Position=1)]
                $SshArgs,
                
                [Parameter()]
                [string]$KeyPath
            )
            
            $params = @{
                UserAtMachine = $UserAtMachine
                SshArgs = $SshArgs
                KeyPath = $KeyPath
            }
            
            & $cmdCapability.Commands['Copy-SshId'].Handler $params
        } -Force | Out-Null
        
        Set-Alias -Name 'ssh-copy-id' -Value 'Copy-SshId' -Scope Global -Force
        
        # File Hash Verification
        New-Item -Path "Function:\global:Test-FileHash" -Value {
            param(
                [Parameter(Position=0)]
                [string]$FilePath,
                
                [Parameter(Position=1)]
                [string]$ExpectedHash,
                
                [Parameter()]
                [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
                [string]$Algorithm = 'SHA256'
            )
            
            $params = @{
                FilePath = $FilePath
                ExpectedHash = $ExpectedHash
                Algorithm = $Algorithm
            }
            
            & $cmdCapability.Commands['Test-FileHash'].Handler $params
        } -Force | Out-Null
        
        # VirusTotal
        New-Item -Path "Function:\global:Test-FileOnVirusTotal" -Value {
            param(
                [Parameter(Position=0)]
                [string]$FilePath
            )
            
            $params = @{ FilePath = $FilePath }
            & $cmdCapability.Commands['Test-FileOnVirusTotal'].Handler $params
        } -Force | Out-Null
        
        # Shodan
        New-Item -Path "Function:\global:Get-ShodanIPInfo" -Value {
            param(
                [Parameter(Position=0)]
                [string]$IPAddress
            )
            
            $params = @{ IPAddress = $IPAddress }
            & $cmdCapability.Commands['Get-ShodanIPInfo'].Handler $params
        } -Force | Out-Null
        
        Set-Alias -Name 'Check-IPonShodan' -Value 'Get-ShodanIPInfo' -Scope Global -Force
    }
    
    return $script:SecurityToolsPluginInstance
}

# Unload function
function Unload-SecurityTools {
    if ($script:SecurityToolsPluginInstance) {
        $script:SecurityToolsPluginInstance.OnUnload()
        
        # Remove exported functions and aliases
        Remove-Item -Path "Function:\global:Copy-SshId" -ErrorAction SilentlyContinue
        Remove-Item -Path "Function:\global:Test-FileHash" -ErrorAction SilentlyContinue
        Remove-Item -Path "Function:\global:Test-FileOnVirusTotal" -ErrorAction SilentlyContinue
        Remove-Item -Path "Function:\global:Get-ShodanIPInfo" -ErrorAction SilentlyContinue
        Remove-Item -Path "Alias:\global:ssh-copy-id" -ErrorAction SilentlyContinue
        Remove-Item -Path "Alias:\global:Check-IPonShodan" -ErrorAction SilentlyContinue
        
        $script:SecurityToolsPluginInstance = $null
    }
}

Export-ModuleMember -Function @('Initialize-SecurityTools', 'Unload-SecurityTools')

