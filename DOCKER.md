# Docker Setup for Chatterbox-TTS-Extended

This project includes Docker support with NVIDIA GPU acceleration and CPU fallback.

## Quick Start

### Option 1: Automatic Setup (Recommended)
```bash
./docker-run.sh
```

This script will:
- Detect if NVIDIA GPU support is available
- Automatically choose the best configuration for your system
- Build and start the appropriate container
- Open the web interface in your browser

### Option 2: Manual Setup

#### For systems with NVIDIA GPU (Windows with RTX 3060):
```bash
# Build and run with GPU support
docker compose --profile gpu up --build

# Or run in detached mode
docker compose --profile gpu up --build -d
```

#### For systems without GPU support (Mac M4):
```bash
# Build and run with CPU-only
docker compose --profile cpu up --build

# Or run in detached mode
docker compose --profile cpu up --build -d
```

## System Requirements

### GPU Mode (Windows RTX 3060)
- Docker Desktop with WSL2 backend
- NVIDIA Container Toolkit installed
- NVIDIA drivers 470.57.02 or newer

### CPU Mode (Mac M4)
- Docker Desktop for Mac
- No additional requirements

## Configuration

The application will be available at: `http://localhost:7860`

### Volumes
- `./outputs` - Generated audio files
- `./settings` - Persistent settings and configurations

### Environment Variables
You can customize the container by setting environment variables in the `docker-compose.yml` file.

## Troubleshooting

### GPU Issues
If GPU mode fails to start:
1. Verify NVIDIA drivers are installed
2. Check Docker can access GPU: `docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi`
3. Fallback to CPU mode: `docker compose --profile cpu up --build`

### Port Conflicts
If port 7860 is already in use, modify the port mapping in `docker-compose.yml`:
```yaml
ports:
  - "8080:7860"  # Change 8080 to your preferred port
```

### Performance
- **GPU mode**: Significantly faster inference, especially for longer texts
- **CPU mode**: Slower but compatible with all systems, suitable for shorter texts

## Stopping the Application

```bash
# Stop and remove containers
docker compose down

# Stop, remove containers, and remove volumes
docker compose down -v
```

## Building Individual Images

If you prefer to build images separately:

```bash
# GPU version
docker build -t chatterbox-tts:gpu -f Dockerfile .

# CPU version  
docker build -t chatterbox-tts:cpu -f Dockerfile.cpu .
```

## Advanced Usage

### Custom Command Line Arguments
You can override the default command to pass custom arguments:

```bash
docker run -p 7860:7860 chatterbox-tts:gpu python Chatter.py --host 0.0.0.0 --port 7860 --share
```

### Development Mode
For development, mount the source code:

```bash
docker run -p 7860:7860 -v $(pwd):/app chatterbox-tts:gpu
```
