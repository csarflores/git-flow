#!/bin/bash

# Git Flow Hotfix Deployment Script
# Automates hotfix deployment to production following Git Flow workflow

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

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

# Confirmation function
confirm() {
    local message="$1"
    read -p "$(echo -e "${YELLOW}$message [Y/n]:${NC} ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    fi
    return 0
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "This is not a git repository"
        exit 1
    fi
}

# Detect production branch
detect_production_branch() {
    local detected_branch=""
    
    # Check if main exists locally or remotely
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null || \
       git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
        detected_branch="main"
    fi
    
    # Check if master exists locally or remotely
    if git show-ref --verify --quiet refs/heads/master 2>/dev/null || \
       git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
        if [[ -n "$detected_branch" ]]; then
            # Both exist, prefer main by default
            warning "Both 'main' and 'master' branches detected. Using 'main' as production branch."
        else
            detected_branch="master"
        fi
    fi
    
    if [[ -z "$detected_branch" ]]; then
        error "No production branch (main/master) found"
        exit 1
    fi
    
    echo "$detected_branch"
}

# Get current branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Check for uncommitted changes
check_clean_worktree() {
    if ! git diff-index --quiet HEAD --; then
        error "Working tree is not clean. Please commit or stash your changes first."
        exit 1
    fi
}

# Main deployment function
deploy_hotfix() {
    local hotfix_branch="$1"
    local production_branch
    production_branch=$(detect_production_branch)
    local current_branch
    current_branch=$(get_current_branch)
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}           ${WHITE}Git Flow Hotfix Deployment${NC}           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    info "Hotfix branch: $hotfix_branch"
    info "Production branch: $production_branch"
    info "Current branch: $current_branch"
    echo
    
    # Check if hotfix branch exists
    if ! git show-ref --verify --quiet refs/heads/"$hotfix_branch" 2>/dev/null; then
        error "Hotfix branch '$hotfix_branch' does not exist locally"
        exit 1
    fi
    
    # Check for uncommitted changes
    check_clean_worktree
    
    # Show deployment plan
    echo -e "${WHITE}Deployment Plan:${NC}"
    echo "  1. Switch to $production_branch"
    echo "  2. Pull latest changes from $production_branch"
    echo "  3. Merge $hotfix_branch into $production_branch"
    echo "  4. Push $production_branch to remote"
    echo "  5. Switch to develop"
    echo "  6. Pull latest changes from develop"
    echo "  7. Merge $production_branch into develop"
    echo "  8. Push develop to remote"
    echo "  9. Delete $hotfix_branch (local and remote)"
    echo
    
    # Confirm deployment
    if ! confirm "Do you want to proceed with this deployment?"; then
        info "Deployment cancelled by user"
        exit 0
    fi
    
    echo
    info "Starting deployment..."
    echo
    
    # Step 1: Switch to production branch
    info "Step 1: Switching to $production_branch"
    git checkout "$production_branch" || {
        error "Failed to switch to $production_branch"
        exit 1
    }
    success "Switched to $production_branch"
    
    # Step 2: Pull latest changes
    info "Step 2: Pulling latest changes from $production_branch"
    git pull origin "$production_branch" || {
        error "Failed to pull $production_branch"
        exit 1
    }
    success "Pulled latest changes from $production_branch"
    
    # Step 3: Merge hotfix to production
    info "Step 3: Merging $hotfix_branch into $production_branch"
    git merge "$hotfix_branch" || {
        error "Failed to merge $hotfix_branch into $production_branch"
        error "Please resolve merge conflicts and try again"
        exit 1
    }
    success "Merged $hotfix_branch into $production_branch"
    
    # Step 4: Push production to remote
    info "Step 4: Pushing $production_branch to remote"
    git push origin "$production_branch" || {
        error "Failed to push $production_branch"
        exit 1
    }
    success "Pushed $production_branch to remote"
    
    # Step 5: Switch to develop
    info "Step 5: Switching to develop"
    git checkout develop || {
        error "Failed to switch to develop"
        exit 1
    }
    success "Switched to develop"
    
    # Step 6: Pull latest changes from develop
    info "Step 6: Pulling latest changes from develop"
    git pull origin develop || {
        error "Failed to pull develop"
        exit 1
    }
    success "Pulled latest changes from develop"
    
    # Step 7: Merge production to develop
    info "Step 7: Merging $production_branch into develop"
    git merge "$production_branch" || {
        error "Failed to merge $production_branch into develop"
        error "Please resolve merge conflicts and try again"
        exit 1
    }
    success "Merged $production_branch into develop"
    
    # Step 8: Push develop to remote
    info "Step 8: Pushing develop to remote"
    git push origin develop || {
        error "Failed to push develop"
        exit 1
    }
    success "Pushed develop to remote"
    
    # Step 9: Delete hotfix branch (local)
    info "Step 9: Deleting $hotfix_branch (local)"
    git branch -d "$hotfix_branch" || {
        warning "Failed to delete local branch $hotfix_branch"
    }
    success "Deleted $hotfix_branch (local)"
    
    # Step 10: Delete hotfix branch (remote)
    info "Step 10: Deleting $hotfix_branch (remote)"
    git push origin --delete "$hotfix_branch" || {
        warning "Failed to delete remote branch $hotfix_branch"
    }
    success "Deleted $hotfix_branch (remote)"
    
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}              ${WHITE}Hotfix Deployment Complete!${NC}              ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    success "Hotfix '$hotfix_branch' has been successfully deployed to production!"
    info "Changes merged to both $production_branch and develop"
    info "You are now on branch: develop"
    echo
}

# Show usage
show_usage() {
    echo "Git Flow Hotfix Deployment Script"
    echo
    echo "Usage:"
    echo "  $0 <hotfix-branch-name>"
    echo
    echo "Example:"
    echo "  $0 hotfix-imagenes-productos"
    echo
    echo "This script will:"
    echo "  1. Detect production branch (main/master)"
    echo "  2. Merge hotfix to production"
    echo "  3. Merge production to develop"
    echo "  4. Clean up hotfix branch"
    echo
}

# Main function
main() {
    local hotfix_branch="${1:-}"
    
    if [[ -z "$hotfix_branch" ]]; then
        # Try to detect current hotfix branch
        local current_branch
        current_branch=$(get_current_branch)
        
        if [[ "$current_branch" == hotfix-* ]]; then
            hotfix_branch="$current_branch"
            info "Auto-detected hotfix branch: $hotfix_branch"
        else
            error "Hotfix branch name is required"
            echo
            show_usage
            exit 1
        fi
    fi
    
    check_git_repo
    deploy_hotfix "$hotfix_branch"
}

# Run main function
main "$@"
