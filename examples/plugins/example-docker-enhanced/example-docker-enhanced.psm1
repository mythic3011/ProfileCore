# example-docker-enhanced.psm1
# Enhanced Docker plugin demonstrating SOLID architecture

<#
.SYNOPSIS
    Enhanced Docker management plugin using new ProfileCore architecture
.DESCRIPTION
    Demonstrates:
    - Plugin base class inheritance
    - Dependency injection
    - Command provider capability
    - Configuration provider capability
    - Service usage
#>

# Plugin implementation using new architecture
class DockerEnhancedPlugin : PluginBaseV2 {
    [hashtable]$DockerConfig
    
    DockerEnhancedPlugin([ServiceContainer]$services) : base('example-docker-enhanced', [version]'1.0.0', $services) {
        $this.Author = "ProfileCore Team"
        $this.Description = "Enhanced Docker management with SOLID architecture"
        $this.DockerConfig = @{
            DefaultComposeFile = 'docker-compose.yml'
            AutoCleanup = $true
            LogRetention = 7
        }
    }
    
    [void] OnInitialize() {
        $this.Log("Initializing Docker Enhanced plugin", "Info")
        $this.LoadConfig()
    }
    
    [void] OnLoad() {
        $this.Log("Loading Docker Enhanced plugin", "Info")
        
        # Get services via dependency injection
        $configManager = $this.GetConfigurationManager()
        
        # Load plugin config from configuration manager
        $savedConfig = $configManager.GetConfig('docker-enhanced')
        if ($savedConfig.Count -gt 0) {
            foreach ($key in $savedConfig.Keys) {
                $this.DockerConfig[$key] = $savedConfig[$key]
            }
        }
        
        # Register command capability
        $this.RegisterCommands()
        
        # Register configuration capability if needed
        $this.RegisterConfigCapability()
        
        $this.Log("Docker Enhanced plugin loaded successfully", "Info")
    }
    
    [void] OnUnload() {
        $this.Log("Unloading Docker Enhanced plugin", "Info")
        
        # Cleanup if needed
        if ($this.DockerConfig['AutoCleanup']) {
            $this.Log("Running auto-cleanup", "Info")
        }
    }
    
    [void] RegisterCommands() {
        $cmdCapability = [CommandProviderCapability]::new()
        
        # Register docker-health command
        $cmdCapability.RegisterCommand('docker-health', {
            param($params)
            
            Write-Host "`n🐳 Docker Health Check" -ForegroundColor Cyan
            Write-Host "=" * 50
            
            # Check Docker daemon
            try {
                $dockerInfo = docker info --format '{{json .}}' | ConvertFrom-Json
                Write-Host "✅ Docker daemon is running" -ForegroundColor Green
                Write-Host "   Containers: $($dockerInfo.Containers)" -ForegroundColor Gray
                Write-Host "   Images: $($dockerInfo.Images)" -ForegroundColor Gray
                Write-Host "   Server Version: $($dockerInfo.ServerVersion)" -ForegroundColor Gray
            }
            catch {
                Write-Host "❌ Docker daemon is not running" -ForegroundColor Red
                return
            }
            
            # Check Docker Compose
            if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
                $composeVersion = docker-compose --version
                Write-Host "✅ Docker Compose: $composeVersion" -ForegroundColor Green
            }
            else {
                Write-Host "⚠️  Docker Compose not installed" -ForegroundColor Yellow
            }
            
            # Resource usage
            Write-Host "`n📊 Resource Usage:" -ForegroundColor Cyan
            docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })
        
        # Register docker-cleanup-smart command
        $cmdCapability.RegisterCommand('docker-cleanup-smart', {
            param($params)
            
            Write-Host "`n🧹 Smart Docker Cleanup" -ForegroundColor Cyan
            Write-Host "=" * 50
            
            # Stop old containers (older than 7 days)
            Write-Host "`n📦 Stopping old containers..." -ForegroundColor Yellow
            $cutoffDate = (Get-Date).AddDays(-7)
            docker ps -a --format '{{.ID}}|{{.CreatedAt}}' | ForEach-Object {
                $parts = $_ -split '\|'
                $id = $parts[0]
                $created = $parts[1]
                
                if ([datetime]$created -lt $cutoffDate) {
                    Write-Host "  Stopping container: $id" -ForegroundColor Gray
                    docker stop $id 2>&1 | Out-Null
                }
            }
            
            # Remove stopped containers
            Write-Host "`n🗑️  Removing stopped containers..." -ForegroundColor Yellow
            docker container prune -f
            
            # Remove unused images
            Write-Host "`n🖼️  Removing unused images..." -ForegroundColor Yellow
            docker image prune -a -f --filter "until=168h"
            
            # Remove unused volumes
            Write-Host "`n💾 Removing unused volumes..." -ForegroundColor Yellow
            docker volume prune -f
            
            # Remove unused networks
            Write-Host "`n🌐 Removing unused networks..." -ForegroundColor Yellow
            docker network prune -f
            
            Write-Host "`n✅ Cleanup completed!" -ForegroundColor Green
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })
        
        # Register docker-compose-wizard command
        $cmdCapability.RegisterCommand('docker-compose-wizard', {
            param($params)
            
            Write-Host "`n🧙 Docker Compose Wizard" -ForegroundColor Cyan
            Write-Host "=" * 50
            
            $serviceName = Read-Host "`nEnter service name"
            $image = Read-Host "Enter Docker image (e.g., nginx:latest)"
            $port = Read-Host "Enter port mapping (e.g., 8080:80)"
            
            $composeContent = @"
version: '3.8'

services:
  $serviceName`:
    image: $image
    container_name: $serviceName
    ports:
      - "$port"
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
"@
            
            $filename = "docker-compose-$serviceName.yml"
            $composeContent | Out-File $filename -Encoding UTF8
            
            Write-Host "`n✅ Created: $filename" -ForegroundColor Green
            Write-Host "`n📝 To start: docker-compose -f $filename up -d" -ForegroundColor Cyan
        }, @{
            EnableCache = $false
            RequiresElevation = $false
        })
        
        $this.RegisterCapability('CommandProvider', $cmdCapability)
    }
    
    [void] RegisterConfigCapability() {
        # Custom config provider for Docker-specific settings
        # This demonstrates how plugins can extend configuration
        $this.Log("Configuration capability registered", "Debug")
    }
    
    [hashtable] GetDockerStats() {
        $stats = @{
            Containers = 0
            Running = 0
            Stopped = 0
            Images = 0
            Volumes = 0
        }
        
        try {
            $containerList = docker ps -a --format '{{.State}}' 2>$null
            $stats.Containers = $containerList.Count
            $stats.Running = ($containerList | Where-Object { $_ -eq 'running' }).Count
            $stats.Stopped = $stats.Containers - $stats.Running
            
            $stats.Images = (docker images -q 2>$null).Count
            $stats.Volumes = (docker volume ls -q 2>$null).Count
        }
        catch {
            $this.Log("Failed to get Docker stats: $_", "Error")
        }
        
        return $stats
    }
}

# Global variable to hold plugin instance
$script:DockerEnhancedPluginInstance = $null

# Initialize function (called by plugin system)
function Initialize-example-docker-enhanced {
    param([ServiceContainer]$Services)
    
    # Create plugin instance with dependency injection
    $script:DockerEnhancedPluginInstance = [DockerEnhancedPlugin]::new($Services)
    $script:DockerEnhancedPluginInstance.OnInitialize()
    $script:DockerEnhancedPluginInstance.OnLoad()
    
    # Export commands
    $cmdCapability = $script:DockerEnhancedPluginInstance.GetCapability('CommandProvider')
    if ($cmdCapability) {
        foreach ($cmd in $cmdCapability.Commands.Keys) {
            $handler = $cmdCapability.Commands[$cmd].Handler
            
            # Create function dynamically
            $functionName = $cmd -replace '-', ''
            New-Item -Path "Function:\global:$cmd" -Value $handler -Force | Out-Null
        }
    }
    
    return $script:DockerEnhancedPluginInstance
}

# Unload function
function Unload-example-docker-enhanced {
    if ($script:DockerEnhancedPluginInstance) {
        $script:DockerEnhancedPluginInstance.OnUnload()
        
        # Remove exported commands
        $cmdCapability = $script:DockerEnhancedPluginInstance.GetCapability('CommandProvider')
        if ($cmdCapability) {
            foreach ($cmd in $cmdCapability.Commands.Keys) {
                Remove-Item -Path "Function:\global:$cmd" -ErrorAction SilentlyContinue
            }
        }
        
        $script:DockerEnhancedPluginInstance = $null
    }
}

# Export module members
Export-ModuleMember -Function @('Initialize-example-docker-enhanced', 'Unload-example-docker-enhanced')

