#!/bin/bash

# Git Flow Deploy Function
# Deploys changes from develop to production

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main deploy function
deploy_to_production() {
    info "Starting deployment process..."
    
    # Check if we're in a git repository
    require_git_repository
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        error "There are uncommitted changes. Please commit or stash them before deploying."
        return 1
    fi
    
    # Store current branch
    local current_branch
    current_branch=$(current_branch)
    
    # Ensure develop branch exists
    if ! branch_exists "$DEVELOP_BRANCH"; then
        info "Develop branch '$DEVELOP_BRANCH' not found locally. Fetching from remote..."
        git fetch "$REMOTE" || {
            error "Failed to fetch from remote"
            return 1
        }
        
        if remote_branch_exists "$DEVELOP_BRANCH"; then
            git checkout -b "$DEVELOP_BRANCH" "$REMOTE/$DEVELOP_BRANCH" || {
                error "Failed to create local develop branch"
                return 1
            }
        else
            error "Develop branch '$DEVELOP_BRANCH' does not exist locally or on remote"
            return 1
        fi
    fi
    
    # Switch to develop and pull latest changes
    switch_to_branch "$DEVELOP_BRANCH"
    pull_branch "$DEVELOP_BRANCH"
    
    # Run build if enabled
    if [[ "$RUN_BUILD" == "true" ]]; then
        execute_build || return 1
    fi
    
    # Ensure production branch exists
    if ! branch_exists "$PRODUCTION_BRANCH"; then
        info "Production branch '$PRODUCTION_BRANCH' not found locally. Fetching from remote..."
        if remote_branch_exists "$PRODUCTION_BRANCH"; then
            git checkout -b "$PRODUCTION_BRANCH" "$REMOTE/$PRODUCTION_BRANCH" || {
                error "Failed to create local production branch"
                return 1
            }
        else
            error "Production branch '$PRODUCTION_BRANCH' does not exist locally or on remote"
            return 1
        fi
    fi
    
    # Show deployment summary
    echo
    info "Deployment Summary:"
    echo "  Source: $DEVELOP_BRANCH"
    echo "  Target: $PRODUCTION_BRANCH"
    echo "  Build: $([[ "$RUN_BUILD" == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo "  Remote: $REMOTE"
    echo
    
    # Ask for confirmation
    if ! confirm "Are you sure you want to deploy to production?"; then
        info "Deployment cancelled by user"
        # Switch back to original branch
        switch_to_branch "$current_branch"
        return 0
    fi
    
    # Merge develop into production
    local merge_message="Deploy $(date '+%Y-%m-%d %H:%M:%S')"
    merge_branch "$DEVELOP_BRANCH" "$PRODUCTION_BRANCH" "$merge_message" || return 1
    
    # Push production branch
    push_branch "$PRODUCTION_BRANCH"
    
    # Switch back to develop
    switch_to_branch "$DEVELOP_BRANCH"
    
    # Success message
    success "Deployment completed successfully!"
    info "Changes from $DEVELOP_BRANCH have been deployed to $PRODUCTION_BRANCH"
    
    # If we were on a different branch, switch back
    if [[ "$current_branch" != "$DEVELOP_BRANCH" ]]; then
        info "Switching back to your original branch: $current_branch"
        switch_to_branch "$current_branch"
    fi
}

# Deploy with specific commit message
deploy_with_message() {
    local commit_message="$1"
    info "Starting deployment with custom message..."
    
    # Check if we're in a git repository
    require_git_repository
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        error "There are uncommitted changes. Please commit or stash them before deploying."
        return 1
    fi
    
    # Store current branch
    local current_branch
    current_branch=$(current_branch)
    
    # Ensure develop branch exists and is up to date
    switch_to_branch "$DEVELOP_BRANCH"
    pull_branch "$DEVELOP_BRANCH"
    
    # Run build if enabled
    if [[ "$RUN_BUILD" == "true" ]]; then
        execute_build || return 1
    fi
    
    # Show deployment summary
    echo
    info "Deployment Summary:"
    echo "  Source: $DEVELOP_BRANCH"
    echo "  Target: $PRODUCTION_BRANCH"
    echo "  Message: $commit_message"
    echo "  Build: $([[ "$RUN_BUILD" == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo "  Remote: $REMOTE"
    echo
    
    # Ask for confirmation
    if ! confirm "Are you sure you want to deploy to production?"; then
        info "Deployment cancelled by user"
        switch_to_branch "$current_branch"
        return 0
    fi
    
    # Merge develop into production with custom message
    merge_branch "$DEVELOP_BRANCH" "$PRODUCTION_BRANCH" "$commit_message" || return 1
    
    # Push production branch
    push_branch "$PRODUCTION_BRANCH"
    
    # Switch back to develop
    switch_to_branch "$DEVELOP_BRANCH"
    
    # Success message
    success "Deployment completed successfully!"
    info "Changes from $DEVELOP_BRANCH have been deployed to $PRODUCTION_BRANCH"
    
    # If we were on a different branch, switch back
    if [[ "$current_branch" != "$DEVELOP_BRANCH" ]]; then
        info "Switching back to your original branch: $current_branch"
        switch_to_branch "$current_branch"
    fi
}

# List available deploy commands
show_deploy_help() {
    echo "Git Flow Deploy Commands:"
    echo
    echo "  git flow deploy                     Deploy develop to production"
    echo "  git flow deploy \"message\"           Deploy with custom commit message"
    echo
    echo "Deployment process:"
    echo "  1. Check for uncommitted changes"
    echo "  2. Update develop branch"
    echo "  3. Run build command (if enabled)"
    echo "  4. Ask for confirmation"
    echo "  5. Merge develop -> production"
    echo "  6. Push to remote"
    echo "  7. Return to develop branch"
    echo
    echo "Current configuration:"
    echo "  Develop branch: $DEVELOP_BRANCH"
    echo "  Production branch: $PRODUCTION_BRANCH"
    echo "  Build enabled: $RUN_BUILD"
    echo "  Build command: $BUILD_COMMAND"
    echo "  Remote: $REMOTE"
    echo
    echo "Note: This operation requires a clean working tree"
}
