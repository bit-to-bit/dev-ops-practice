#!/bin/bash

set -e

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NO_COLOR} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NO_COLOR} $1"
}

error() {
    echo -e "${RED}[ERROR]${NO_COLOR} $1"
    exit 1
}

if [ "$EUID" -ne 0 ]; then
  error "Please run this script with sudo privileges (e.g., sudo ./install_dev_tools.sh)"
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID=$ID
    CODENAME=$VERSION_CODENAME
else
    error "Cannot detect OS. /etc/os-release not found."
fi

log "Detected OS: $DISTRO_ID ($CODENAME)"

log "Updating package lists..."
apt-get update -qq

if command -v docker >/dev/null 2>&1; then
    warn "Docker already installed: $(docker --version)"
else
    log "Installing Docker prerequisites..."
    apt-get install -y --fix-missing ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    
    rm -f /etc/apt/keyrings/docker.gpg

    log "Adding Docker GPG key for $DISTRO_ID..."
    curl -fsSL "https://download.docker.com/linux/$DISTRO_ID/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    log "Adding Docker repository..."
    echo \
      "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO_ID \
      $CODENAME stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update -qq
    apt-get install -y --fix-missing docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    
    log "Docker installed successfully"
fi

if docker compose version >/dev/null 2>&1; then
    warn "Docker Compose already installed: $(docker compose version)"
else
    log "Ensuring Docker Compose plugin is installed..."
    apt-get install -y --fix-missing docker-compose-plugin
fi

if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    warn "Python 3 already installed: $PYTHON_VERSION"
else
    log "Installing Python 3..."
    apt-get install -y --fix-missing python3
fi

if command -v pip3 >/dev/null 2>&1; then
    warn "Pip3 already installed"
else
    log "Installing Pip3 and venv..."
    apt-get install -y --fix-missing python3-pip python3-venv
    log "Pip3 installed successfully"
fi

if python3 -m django --version >/dev/null 2>&1; then
    DJANGO_VER=$(python3 -m django --version)
    warn "Django already installed globally: $DJANGO_VER"
else
    log "Installing Django globally..."
    
    if pip3 install Django; then
        log "Django installed via standard pip."
    else
        warn "Standard pip install failed (likely due to PEP 668). Trying with --break-system-packages..."
        pip3 install Django --break-system-packages
        log "Django installed with system package override."
    fi
fi

log "All commands completed successfully!"