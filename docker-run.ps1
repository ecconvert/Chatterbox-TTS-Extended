# Chatterbox-TTS-Extended Docker Setup Script for Windows
# This script helps you run the application with GPU or CPU fallback

$ErrorActionPreference = "Stop"

# Colors for output
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Blue"

Write-Host "🚀 Chatterbox-TTS-Extended Docker Setup" -ForegroundColor $BLUE
Write-Host "========================================"

# Function to check if NVIDIA Docker is available
function Test-NvidiaDocker {
    try {
        docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi 2>$null | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check if Docker Compose is available
function Test-DockerCompose {
    try {
        docker compose version 2>$null | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Create necessary directories
Write-Host "📁 Creating output directories..." -ForegroundColor $YELLOW
if (!(Test-Path "outputs")) { New-Item -ItemType Directory -Path "outputs" }
if (!(Test-Path "settings")) { New-Item -ItemType Directory -Path "settings" }

# Check for NVIDIA GPU support
Write-Host "🔍 Checking for NVIDIA GPU support..." -ForegroundColor $YELLOW

if (Test-NvidiaDocker) {
    Write-Host "✅ NVIDIA Docker runtime detected!" -ForegroundColor $GREEN
    $UseGPU = $true
} else {
    Write-Host "⚠️  NVIDIA Docker runtime not available, falling back to CPU mode" -ForegroundColor $YELLOW
    $UseGPU = $false
}

# Check Docker Compose availability
if (!(Test-DockerCompose)) {
    Write-Host "❌ Docker Compose not found. Please install Docker Compose." -ForegroundColor $RED
    exit 1
}

# Ask user for preference if GPU is available
if ($UseGPU) {
    Write-Host ""
    Write-Host "Choose your preferred mode:" -ForegroundColor $BLUE
    Write-Host "1) GPU mode (NVIDIA GPU acceleration)"
    Write-Host "2) CPU mode (compatible with all systems)"
    Write-Host ""
    $choice = Read-Host "Enter your choice (1 or 2, default: 1)"
    
    switch ($choice) {
        "2" { $UseGPU = $false }
        default { $UseGPU = $true }
    }
}

# Build and run the appropriate container
if ($UseGPU) {
    Write-Host "🚀 Starting Chatterbox-TTS with GPU acceleration..." -ForegroundColor $GREEN
    try {
        docker compose --profile gpu up --build -d
        Write-Host "✅ GPU container started successfully!" -ForegroundColor $GREEN
    }
    catch {
        Write-Host "❌ GPU container failed to start. Trying CPU mode as fallback..." -ForegroundColor $RED
        $UseGPU = $false
        docker compose --profile cpu up --build -d
        Write-Host "✅ CPU container started successfully!" -ForegroundColor $GREEN
    }
} else {
    Write-Host "🚀 Starting Chatterbox-TTS in CPU mode..." -ForegroundColor $BLUE
    try {
        docker compose --profile cpu up --build -d
        Write-Host "✅ CPU container started successfully!" -ForegroundColor $GREEN
    }
    catch {
        Write-Host "❌ Failed to start container. Please check the logs with: docker compose logs" -ForegroundColor $RED
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 Chatterbox-TTS-Extended is now running!" -ForegroundColor $GREEN
Write-Host "📱 Access the web interface at: http://localhost:7860" -ForegroundColor $BLUE
Write-Host ""
Write-Host "Useful commands:"
Write-Host "  View logs:    docker compose logs -f"
Write-Host "  Stop:         docker compose down"
Write-Host "  Restart:      docker compose restart"
Write-Host ""

# Wait a moment and try to open the browser
Start-Sleep 3
try {
    Start-Process "http://localhost:7860"
} catch {
    # Ignore errors if browser doesn't open
}

Write-Host "💡 Tip: On Windows with RTX 3060, GPU mode will provide significant performance improvements." -ForegroundColor $YELLOW
