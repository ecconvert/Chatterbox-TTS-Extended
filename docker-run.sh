#!/bin/bash

# Chatterbox-TTS-Extended Docker Setup Script
# This script helps you run the application with GPU or CPU fallback

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Chatterbox-TTS-Extended Docker Setup${NC}"
echo "========================================"

# Function to check if NVIDIA Docker is available
check_nvidia_docker() {
    if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if Docker Compose supports GPU
check_compose_gpu() {
    if docker compose version >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Create necessary directories
echo -e "${YELLOW}📁 Creating output directories...${NC}"
mkdir -p outputs settings

# Check for NVIDIA GPU support
echo -e "${YELLOW}🔍 Checking for NVIDIA GPU support...${NC}"

if check_nvidia_docker; then
    echo -e "${GREEN}✅ NVIDIA Docker runtime detected!${NC}"
    USE_GPU=true
else
    echo -e "${YELLOW}⚠️  NVIDIA Docker runtime not available, falling back to CPU mode${NC}"
    USE_GPU=false
fi

# Check Docker Compose availability
if ! check_compose_gpu; then
    echo -e "${RED}❌ Docker Compose not found. Please install Docker Compose.${NC}"
    exit 1
fi

# Ask user for preference if GPU is available
if [ "$USE_GPU" = true ]; then
    echo ""
    echo -e "${BLUE}Choose your preferred mode:${NC}"
    echo "1) GPU mode (NVIDIA GPU acceleration)"
    echo "2) CPU mode (compatible with all systems)"
    echo ""
    read -p "Enter your choice (1 or 2, default: 1): " choice
    
    case $choice in
        2)
            USE_GPU=false
            ;;
        *)
            USE_GPU=true
            ;;
    esac
fi

# Build and run the appropriate container
if [ "$USE_GPU" = true ]; then
    echo -e "${GREEN}🚀 Starting Chatterbox-TTS with GPU acceleration...${NC}"
    if docker compose --profile gpu up --build -d; then
        echo -e "${GREEN}✅ GPU container started successfully!${NC}"
    else
        echo -e "${RED}❌ GPU container failed to start. Trying CPU mode as fallback...${NC}"
        USE_GPU=false
        docker compose --profile cpu up --build -d
        echo -e "${GREEN}✅ CPU container started successfully!${NC}"
    fi
else
    echo -e "${BLUE}🚀 Starting Chatterbox-TTS in CPU mode...${NC}"
    if docker compose --profile cpu up --build -d; then
        echo -e "${GREEN}✅ CPU container started successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to start container. Please check the logs with: docker compose logs${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}🎉 Chatterbox-TTS-Extended is now running!${NC}"
echo -e "${BLUE}📱 Access the web interface at: http://localhost:7860${NC}"
echo ""
echo "Useful commands:"
echo "  View logs:    docker compose logs -f"
echo "  Stop:         docker compose down"
echo "  Restart:      docker compose restart"
echo ""

# Wait a moment and try to open the browser (optional)
sleep 3
if command -v open >/dev/null 2>&1; then
    # macOS
    open http://localhost:7860 2>/dev/null || true
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open http://localhost:7860 2>/dev/null || true
fi

echo -e "${YELLOW}💡 Tip: On Mac M4, GPU acceleration is not supported, so CPU mode is recommended.${NC}"
echo -e "${YELLOW}💡 On Windows with RTX 3060, GPU mode will provide significant performance improvements.${NC}"
