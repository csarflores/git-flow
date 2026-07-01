#!/bin/bash

# Git Flow Create Function
# Creates new branches based on type

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main create function
create_branch() {
    local branch_type="$1"
    local branch_name="$2"
    
    # Validate inputs
    if [[ -z "$branch_type" ]]; then
        error "Branch type is required (feature, fix, release, hotfix)"
        return 1
    fi
    
    if [[ -z "$branch_name" ]]; then
        error "Branch name is required"
        return 1
    fi
    
    # Validate branch type
    case "$branch_type" in
        feature|fix|release|hotfix)
            ;;
        *)
            error "Invalid branch type. Must be one of: feature, fix, release, hotfix"
            return 1
            ;;
    esac
    
    # Validate branch name
    validate_branch_name "$branch_type" "$branch_name" || return 1
    
    # Construct full branch name
    local full_branch_name="$branch_type/$branch_name"
    
    # Check if branch already exists
    if branch_exists "$full_branch_name"; then
        error "Branch '$full_branch_name' already exists locally"
        return 1
    fi
    
    if remote_branch_exists "$full_branch_name"; then
        error "Branch '$full_branch_name' already exists on remote"
        return 1
    fi
    
    # Determine base branch
    local base_branch
    case "$branch_type" in
        feature|fix|release)
            base_branch="$DEVELOP_BRANCH"
            ;;
        hotfix)
            base_branch=$(get_production_branch)
            ;;
    esac
    
    # Ensure base branch exists locally
    if ! branch_exists "$base_branch"; then
        info "Base branch '$base_branch' not found locally. Fetching from remote..."
        git fetch "$REMOTE" || {
            error "Failed to fetch from remote"
            return 1
        }
        
        # Try to create local branch tracking remote
        if remote_branch_exists "$base_branch"; then
            git checkout -b "$base_branch" "$REMOTE/$base_branch" || {
                error "Failed to create local branch '$base_branch' tracking remote"
                return 1
            }
        else
            error "Base branch '$base_branch' does not exist locally or on remote"
            return 1
        fi
    fi
    
    # Switch to base branch and pull latest changes
    switch_to_branch "$base_branch"
    pull_branch "$base_branch"
    
    # Create new branch
    git checkout -b "$full_branch_name" || {
        error "Failed to create branch '$full_branch_name' from '$base_branch'"
        return 1
    }
    
    # Push new branch to remote and set up upstream
    push_branch "$full_branch_name" true
    
    # Success message
    success "Branch '$full_branch_name' created successfully!"
    info "You are now on branch: $(current_branch)"
    echo
    info "Next steps:"
    echo "  1. Make your changes"
    echo "  2. Commit your changes"
    echo "  3. Push your changes: git push"
    echo "  4. When ready, close the branch: git flow cerrar"
}

# Feature creation
create_feature() {
    local feature_name="$1"
    create_branch "feature" "$feature_name"
}

# Fix creation
create_fix() {
    local fix_name="$1"
    create_branch "fix" "$fix_name"
}

# Release creation
create_release() {
    local release_name="$1"
    create_branch "release" "$release_name"
}

# Hotfix creation
create_hotfix() {
    local hotfix_name="$1"
    create_branch "hotfix" "$hotfix_name"
}

# List available create commands
show_create_help() {
    echo "Git Flow Create Commands:"
    echo
    echo "  git flow crear feature <name>     Create a new feature branch from develop"
    echo "  git flow crear fix <name>         Create a new fix branch from develop"
    echo "  git flow crear release <version>  Create a new release branch from develop"
    echo "  git flow crear hotfix <name>      Create a new hotfix branch from main"
    echo
    echo "Examples:"
    echo "  git flow crear feature login-google"
    echo "  git flow crear fix error-email"
    echo "  git flow crear release 2.5.0"
    echo "  git flow crear hotfix error-pagos"
    echo
    echo "Current configuration:"
    echo "  Develop branch: $DEVELOP_BRANCH"
    echo "  Production branch: $PRODUCTION_BRANCH"
    echo "  Remote: $REMOTE"
}
