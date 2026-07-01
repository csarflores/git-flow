#!/bin/bash

# Git Flow Installation Script
# Automatically installs git-flow as a Git command

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation info
SCRIPT_NAME="git-flow"
VERSION="1.0.0"
INSTALL_DIR="$HOME/.local/bin"
GIT_EXEC_DIR="$HOME/.local/bin"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Output functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running on supported system
check_system() {
    info "Checking system compatibility..."
    
    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        info "Linux detected"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        info "macOS detected"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        info "Windows (Git Bash/Cygwin) detected"
    else
        warning "Unknown system: $OSTYPE"
        warning "Installation may not work correctly"
    fi
    
    # Check bash version
    if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
        error "Bash 4.0 or higher is required"
        error "Current version: $BASH_VERSION"
        exit 1
    fi
    
    # Check git
    if ! command -v git >/dev/null 2>&1; then
        error "Git is not installed or not in PATH"
        exit 1
    fi
    
    success "System compatibility check passed"
}

# Create installation directory
create_install_dir() {
    info "Creating installation directory..."
    
    if [[ ! -d "$INSTALL_DIR" ]]; then
        mkdir -p "$INSTALL_DIR" || {
            error "Failed to create installation directory: $INSTALL_DIR"
            exit 1
        }
        info "Created directory: $INSTALL_DIR"
    fi
}

# Install the main script
install_script() {
    info "Installing git-flow script..."
    
    local source_file="$SCRIPT_DIR/git-flow"
    local target_file="$INSTALL_DIR/git-flow"
    
    if [[ ! -f "$source_file" ]]; then
        error "Source script not found: $source_file"
        exit 1
    fi
    
    # Copy script
    cp "$source_file" "$target_file" || {
        error "Failed to copy script to $target_file"
        exit 1
    }
    
    # Make executable
    chmod +x "$target_file" || {
        error "Failed to make script executable"
        exit 1
    }
    
    success "Script installed to: $target_file"
}

# Install Git integration
install_git_integration() {
    info "Installing Git integration..."
    
    # Create Git exec directory if it doesn't exist
    if [[ ! -d "$GIT_EXEC_DIR" ]]; then
        mkdir -p "$GIT_EXEC_DIR" || {
            error "Failed to create Git exec directory: $GIT_EXEC_DIR"
            exit 1
        }
    fi
    
    # Create symlink for Git to find
    local git_command="$GIT_EXEC_DIR/git-flow"
    
    # Remove existing if exists
    if [[ -L "$git_command" ]] || [[ -f "$git_command" ]]; then
        rm "$git_command" || {
            error "Failed to remove existing git command: $git_command"
            exit 1
        }
    fi
    
    # Create symlink
    ln -s "$INSTALL_DIR/git-flow" "$git_command" || {
        error "Failed to create Git command symlink"
        exit 1
    }
    
    success "Git integration installed"
}

# Update PATH if needed
update_path() {
    info "Checking PATH configuration..."
    
    # Check if INSTALL_DIR is in PATH
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        success "Installation directory is already in PATH"
        return 0
    fi
    
    # Determine shell configuration file
    local shell_config=""
    case "${SHELL##*/}" in
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                shell_config="$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        zsh)
            shell_config="$HOME/.zshrc"
            ;;
        fish)
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        *)
            warning "Unknown shell: $SHELL"
            warning "Please manually add $INSTALL_DIR to your PATH"
            return 0
            ;;
    esac
    
    if [[ -z "$shell_config" ]]; then
        warning "Could not find shell configuration file"
        warning "Please manually add $INSTALL_DIR to your PATH"
        return 0
    fi
    
    # Add to PATH
    local path_entry="export PATH=\"\$PATH:$INSTALL_DIR\""
    
    if ! grep -q "$INSTALL_DIR" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Git Flow CLI" >> "$shell_config"
        echo "$path_entry" >> "$shell_config"
        success "Added $INSTALL_DIR to PATH in $shell_config"
        warning "Please restart your terminal or run: source $shell_config"
    else
        success "PATH already configured in $shell_config"
    fi
}

# Verify installation
verify_installation() {
    info "Verifying installation..."
    
    # Check if script exists and is executable
    if [[ ! -x "$INSTALL_DIR/git-flow" ]]; then
        error "Installation verification failed: script not found or not executable"
        exit 1
    fi
    
    # Test git command
    if command -v git >/dev/null 2>&1; then
        # Try to run git flow --help
        if git flow --help >/dev/null 2>&1; then
            success "Git Flow CLI is working correctly"
        else
            warning "Git Flow CLI installed but may not be in PATH"
            warning "Try: export PATH=\"\$PATH:$INSTALL_DIR\""
        fi
    else
        warning "Git command not available for testing"
    fi
}

# Show post-installation instructions
show_post_install() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                ${WHITE}Installation Complete!${NC}                ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Git Flow CLI v$VERSION has been installed successfully!${NC}"
    echo
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo "1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Verify installation: git flow --help"
    echo "3. Try your first command: git flow status"
    echo
    echo -e "${YELLOW}QUICK START:${NC}"
    echo "  git flow crear feature my-feature    # Create a feature branch"
    echo "  git flow status                      # Check repository status"
    echo "  git flow help                        # Show all commands"
    echo
    echo -e "${YELLOWINSTALLATION LOCATION:${NC}"
    echo "  Script: $INSTALL_DIR/git-flow"
    echo "  Git integration: $GIT_EXEC_DIR/git-flow"
    echo
    echo -e "${YELLOW}UNINSTALL:${NC}"
    echo "  Run: ./uninstall.sh"
    echo
    echo -e "${GREEN}Enjoy using Git Flow CLI! 🚀${NC}"
}

# Main installation function
main() {
    echo -e "${BLUE}Git Flow CLI Installer v$VERSION${NC}"
    echo
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        warning "Running as root is not recommended"
        warning "Installing for user: $USER"
    fi
    
    # Run installation steps
    check_system
    create_install_dir
    install_script
    install_git_integration
    update_path
    verify_installation
    show_post_install
}

# Handle script interruption
trap 'error "Installation interrupted"; exit 1' INT TERM

# Run main function
main "$@"
