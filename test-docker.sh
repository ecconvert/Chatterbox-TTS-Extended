#!/bin/bash

# Test script to verify Docker setup
echo "🧪 Testing Chatterbox-TTS-Extended Docker Setup"
echo "==============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available"
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Check for NVIDIA Docker support
echo "🔍 Checking NVIDIA Docker support..."
if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA Docker runtime is available"
    HAS_GPU=true
else
    echo "⚠️  NVIDIA Docker runtime not available (this is normal on Mac)"
    HAS_GPU=false
fi

# Test building the appropriate image
echo "🏗️  Testing Docker image build..."

if [ "$HAS_GPU" = true ]; then
    echo "Building GPU image..."
    if docker build -t chatterbox-test:gpu -f Dockerfile . &> /dev/null; then
        echo "✅ GPU image built successfully"
        docker rmi chatterbox-test:gpu &> /dev/null
    else
        echo "❌ Failed to build GPU image"
    fi
fi

echo "Building CPU image..."
if docker build -t chatterbox-test:cpu -f Dockerfile.cpu . &> /dev/null; then
    echo "✅ CPU image built successfully"
    docker rmi chatterbox-test:cpu &> /dev/null
else
    echo "❌ Failed to build CPU image"
fi

echo ""
echo "🎉 Docker setup test completed!"
echo ""
echo "Next steps:"
echo "1. Run: ./docker-run.sh"
echo "2. Open: http://localhost:7860"
echo ""
if [ "$HAS_GPU" = true ]; then
    echo "💡 Your system supports GPU acceleration!"
else
    echo "💡 Your system will use CPU mode (great for Mac M4)"
fi
