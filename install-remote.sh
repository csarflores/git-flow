#!/bin/bash

# Git Flow CLI Remote Installer
# Install directly from GitHub repository

set -euo pipefail

# Configuration
REPO="csarflores/git-flow"
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

# Download main scripts
download_file "$RAW_URL/git-flow" "$TEMP_DIR/git-flow"
download_file "$RAW_URL/git-flow-cli.sh" "$TEMP_DIR/git-flow-cli.sh"
download_file "$RAW_URL/git-aliases.conf" "$TEMP_DIR/git-aliases.conf"

# Download library files
mkdir -p "$TEMP_DIR/lib"
for lib_file in config.sh utils.sh create.sh close.sh deploy.sh sync.sh status.sh init.sh help.sh; do
    download_file "$RAW_URL/lib/$lib_file" "$TEMP_DIR/lib/$lib_file"
done

# Make executable
chmod +x "$TEMP_DIR/git-flow"
chmod +x "$TEMP_DIR/git-flow-cli.sh"

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Install files
cp "$TEMP_DIR/git-flow" "$INSTALL_DIR/git-flow"
cp "$TEMP_DIR/git-flow-cli.sh" "$INSTALL_DIR/git-flow-cli.sh"
cp -r "$TEMP_DIR/lib" "$INSTALL_DIR/"

# Update PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc" 2>/dev/null || true
    warning "Please restart your terminal or run: source ~/.bashrc"
fi

# Configure Git aliases
git config --global alias.crear-feature "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-feature <nombre>'; exit 1; fi; git-flow-cli.sh crear feature \"\$1\"; }; f"
git config --global alias.crear-fix "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-fix <nombre>'; exit 1; fi; git-flow-cli.sh crear fix \"\$1\"; }; f"
git config --global alias.crear-release "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-release <version>'; exit 1; fi; git-flow-cli.sh crear release \"\$1\"; }; f"
git config --global alias.crear-hotfix "!f() { if [ -z \"\$1\" ]; then echo '⚠️ Uso: git crear-hotfix <nombre>'; exit 1; fi; git-flow-cli.sh crear hotfix \"\$1\"; }; f"
git config --global alias.cerrar "!f() { if [ -n \"\$1\" ]; then git-flow-cli.sh cerrar \"\$1\"; else git-flow-cli.sh cerrar; fi; }; f"
git config --global alias.deploy "!f() { if [ -n \"\$1\" ]; then git-flow-cli.sh deploy \"\$1\"; else git-flow-cli.sh deploy; fi; }; f"
git config --global alias.sync "!git-flow-cli.sh sync"
git config --global alias.status-flow "!git-flow-cli.sh status"
git config --global alias.help-flow "!git-flow-cli.sh help"
git config --global alias.init-flow "!git-flow-cli.sh init"

success "Git Flow CLI installed successfully!"
info "Run 'git help-flow' to get started"
