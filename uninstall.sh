#!/bin/bash

# Git Flow Uninstallation Script
# Completely removes git-flow from the system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation info
SCRIPT_NAME="git-flow"
INSTALL_DIR="$HOME/.local/bin"
GIT_EXEC_DIR="$HOME/.local/bin"

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

# Confirm uninstallation
confirm_uninstall() {
    echo -e "${YELLOW}This will completely remove Git Flow CLI from your system.${NC}"
    echo -e "${YELLOW}The following files will be removed:${NC}"
    echo "  • $INSTALL_DIR/git-flow"
    echo "  • $GIT_EXEC_DIR/git-flow"
    echo
    read -p "$(echo -e "${RED}Are you sure you want to continue? [y/N]:${NC} ")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Uninstallation cancelled by user"
        exit 0
    fi
}

# Remove main script
remove_main_script() {
    info "Removing main script..."
    
    local script_file="$INSTALL_DIR/git-flow"
    
    if [[ -f "$script_file" ]]; then
        rm "$script_file" || {
            error "Failed to remove main script: $script_file"
            return 1
        }
        success "Removed main script: $script_file"
    else
        warning "Main script not found: $script_file"
    fi
}

# Remove Git integration
remove_git_integration() {
    info "Removing Git integration..."
    
    local git_command="$GIT_EXEC_DIR/git-flow"
    
    if [[ -L "$git_command" ]]; then
        rm "$git_command" || {
            error "Failed to remove Git command symlink: $git_command"
            return 1
        }
        success "Removed Git command symlink: $git_command"
    elif [[ -f "$git_command" ]]; then
        rm "$git_command" || {
            error "Failed to remove Git command: $git_command"
            return 1
        }
        success "Removed Git command: $git_command"
    else
        warning "Git command not found: $git_command"
    fi
}

# Clean PATH from shell configurations
clean_path() {
    info "Cleaning PATH from shell configurations..."
    
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.config/fish/config.fish"
    )
    
    local cleaned=0
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Check if config contains our PATH entry
            if grep -q "$INSTALL_DIR" "$config" 2>/dev/null; then
                # Create backup
                local backup_file="${config}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$config" "$backup_file" || {
                    warning "Failed to create backup of $config"
                    continue
                }
                
                # Remove our PATH entry
                if grep -n "$INSTALL_DIR" "$config" | grep -q "export PATH"; then
                    # Remove the export line and the comment line above it if it's ours
                    sed -i.tmp '/# Git Flow CLI/,/export PATH.*'"$INSTALL_DIR"'/d' "$config" && rm "$config.tmp"
                    success "Cleaned PATH from $config"
                    success "Backup saved to: $backup_file"
                    ((cleaned++))
                else
                    rm "$backup_file"
                fi
            fi
        fi
    done
    
    if [[ $cleaned -eq 0 ]]; then
        info "No PATH entries found in shell configurations"
    fi
}

# Remove configuration file
remove_config() {
    info "Checking for configuration file..."
    
    local config_file="$HOME/.git-flow-config"
    
    if [[ -f "$config_file" ]]; then
        echo -e "${YELLOW}Found configuration file: $config_file${NC}"
        read -p "$(echo -e "${YELLOW}Remove configuration file? [y/N]:${NC} ")" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm "$config_file" || {
                error "Failed to remove configuration file: $config_file"
                return 1
            }
            success "Removed configuration file: $config_file"
        else
            info "Configuration file preserved"
        fi
    else
        info "No configuration file found"
    fi
}

# Verify uninstallation
verify_uninstall() {
    info "Verifying uninstallation..."
    
    local remaining_files=()
    
    # Check for remaining files
    if [[ -f "$INSTALL_DIR/git-flow" ]]; then
        remaining_files+=("$INSTALL_DIR/git-flow")
    fi
    
    if [[ -f "$GIT_EXEC_DIR/git-flow" ]] || [[ -L "$GIT_EXEC_DIR/git-flow" ]]; then
        remaining_files+=("$GIT_EXEC_DIR/git-flow")
    fi
    
    if [[ ${#remaining_files[@]} -eq 0 ]]; then
        success "Git Flow CLI has been completely removed"
    else
        warning "Some files could not be removed:"
        for file in "${remaining_files[@]}"; do
            warning "  • $file"
        done
        warning "You may need to remove them manually"
    fi
}

# Show post-uninstall information
show_post_uninstall() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                ${WHITE}Uninstallation Complete!${NC}                ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Git Flow CLI has been removed from your system.${NC}"
    echo
    echo -e "${YELLOW}REMAINING STEPS:${NC}"
    echo "1. Restart your terminal to reload shell configuration"
    echo "2. Verify removal: git flow --help (should fail)"
    echo
    echo -e "${YELLOW}NOTE:${NC}"
    echo "• Your Git repositories and branches are untouched"
    echo "• Only the Git Flow CLI tool has been removed"
    echo "• You can continue using Git normally"
    echo
    echo -e "${YELLOW}FEEDBACK:${NC}"
    echo "Thank you for using Git Flow CLI!"
    echo "If you have any feedback or suggestions, please share them."
    echo
    echo -e "${GREEN}Happy coding! 👋${NC}"
}

# Main uninstallation function
main() {
    echo -e "${BLUE}Git Flow CLI Uninstaller${NC}"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        warning "Running as root"
        warning "Uninstalling for user: $USER"
    fi
    
    # Run uninstallation steps
    confirm_uninstall
    remove_main_script
    remove_git_integration
    clean_path
    remove_config
    verify_uninstall
    show_post_uninstall
}

# Handle script interruption
trap 'error "Uninstallation interrupted"; exit 1' INT TERM

# Run main function
main "$@"
