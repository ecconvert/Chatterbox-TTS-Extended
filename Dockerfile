# Use NVIDIA CUDA runtime as base image for GPU support
ARG BASE_IMAGE=nvidia/cuda:11.8-runtime-ubuntu22.04
FROM ${BASE_IMAGE}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3.10-venv \
    python3-pip \
    ffmpeg \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a symbolic link for python
RUN ln -sf /usr/bin/python3.10 /usr/bin/python

# Set working directory
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt requirements.base.with.versions.txt requirements_frozen.txt ./

# Create virtual environment and install Python dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

# Install PyTorch with CUDA support first
RUN pip install torch==2.7.0 torchaudio==2.7.0 --extra-index-url https://download.pytorch.org/whl/cu118

# Install other requirements
RUN pip install -r requirements.base.with.versions.txt

# Copy the application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/outputs /app/settings

# Expose the port that Gradio uses
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7860 || exit 1

# Default command - run with public access enabled
CMD ["python", "Chatter.py", "--host", "0.0.0.0", "--port", "7860"]
