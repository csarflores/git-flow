#!/bin/bash

# Git Flow CLI Remote Installer
# Install directly from GitHub repository

set -euo pipefail

# Configuration
REPO="TU_USERNAME/git-flow-cli"
RAW_URL="https://raw.githubusercontent.com/$REPO/main"
INSTALL_DIR="$HOME/.local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        error "curl or wget is required"
        exit 1
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        error "git is required"
        exit 1
    fi
    
    success "Dependencies check passed"
}

# Download file
download_file() {
    local url="$1"
    local dest="$2"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    else
        wget -q "$url" -O "$dest"
    fi
}

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

info "Downloading Git Flow CLI from GitHub..."

# Download main script
download_file "$RAW_URL/git-flow" "$TEMP_DIR/git-flow"

# Download library files
mkdir -p "$TEMP_DIR/lib"
for lib_file in config.sh utils.sh create.sh close.sh deploy.sh sync.sh status.sh help.sh; do
    download_file "$RAW_URL/lib/$lib_file" "$TEMP_DIR/lib/$lib_file"
done

# Make executable
chmod +x "$TEMP_DIR/git-flow"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Install files
cp "$TEMP_DIR/git-flow" "$INSTALL_DIR/git-flow"
cp -r "$TEMP_DIR/lib" "$INSTALL_DIR/"

# Create Git integration
ln -sf "$INSTALL_DIR/git-flow" "$INSTALL_DIR/git-flow-git"

# Update PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc" 2>/dev/null || true
    warning "Please restart your terminal or run: source ~/.bashrc"
fi

success "Git Flow CLI installed successfully!"
info "Run 'git flow --help' to get started"
