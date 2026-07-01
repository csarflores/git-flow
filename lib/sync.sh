#!/bin/bash

# Git Flow Sync Function
# Synchronizes branches with remote

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main sync function
sync_repository() {
    info "Starting repository synchronization..."
    
    # Check if we're in a git repository
    require_git_repository
    
    # Store current branch
    local current_branch
    current_branch=$(current_branch)
    
    # Fetch all changes from remote
    info "Fetching all changes from $REMOTE..."
    git fetch "$REMOTE" || {
        error "Failed to fetch from remote $REMOTE"
        return 1
    }
    
    # Sync develop branch
    sync_branch "$DEVELOP_BRANCH"
    
    # Sync production branch
    sync_branch "$PRODUCTION_BRANCH"
    
    # Sync current branch if it's not develop or production
    if [[ "$current_branch" != "$DEVELOP_BRANCH" && "$current_branch" != "$PRODUCTION_BRANCH" ]]; then
        sync_branch "$current_branch"
    fi
    
    success "Repository synchronization completed!"
    info "All branches are now up to date with $REMOTE"
    
    # Return to original branch
    switch_to_branch "$current_branch"
}

# Sync a specific branch
sync_branch() {
    local branch="$1"
    
    if [[ -z "$branch" ]]; then
        error "Branch name is required"
        return 1
    fi
    
    info "Synchronizing branch: $branch"
    
    # Check if branch exists locally
    if ! branch_exists "$branch"; then
        # Try to create from remote if it exists
        if remote_branch_exists "$branch"; then
            info "Creating local branch '$branch' from remote..."
            git checkout -b "$branch" "$REMOTE/$branch" || {
                error "Failed to create local branch '$branch' from remote"
                return 1
            }
        else
            warning "Branch '$branch' does not exist locally or on remote"
            return 0
        fi
    fi
    
    # Switch to branch
    switch_to_branch "$branch"
    
    # Pull latest changes
    if remote_branch_exists "$branch"; then
        pull_branch "$branch"
    else
        warning "Remote branch '$branch' does not exist. Skipping pull."
    fi
}

# Sync specific branches only
sync_specific_branches() {
    local branches=("$@")
    
    if [[ ${#branches[@]} -eq 0 ]]; then
        error "At least one branch name is required"
        return 1
    fi
    
    info "Synchronizing specific branches: ${branches[*]}"
    
    # Fetch all changes from remote
    git fetch "$REMOTE" || {
        error "Failed to fetch from remote $REMOTE"
        return 1
    }
    
    # Store current branch
    local current_branch
    current_branch=$(current_branch)
    
    # Sync each specified branch
    for branch in "${branches[@]}"; do
        sync_branch "$branch"
    done
    
    success "Specific branches synchronization completed!"
    
    # Return to original branch
    switch_to_branch "$current_branch"
}

# Sync only current branch
sync_current_branch() {
    local current_branch
    current_branch=$(current_branch)
    
    info "Synchronizing current branch: $current_branch"
    
    # Fetch changes from remote
    git fetch "$REMOTE" || {
        error "Failed to fetch from remote $REMOTE"
        return 1
    }
    
    # Sync current branch
    sync_branch "$current_branch"
    
    success "Current branch synchronization completed!"
}

# Show sync status
show_sync_status() {
    info "Checking synchronization status..."
    
    # Fetch latest information
    git fetch "$REMOTE" --dry-run 2>/dev/null || {
        error "Failed to fetch from remote $REMOTE"
        return 1
    }
    
    echo
    info "Branch synchronization status:"
    echo
    
    # Check develop branch
    check_branch_status "$DEVELOP_BRANCH"
    
    # Check production branch
    check_branch_status "$PRODUCTION_BRANCH"
    
    # Check current branch if different
    local current_branch
    current_branch=$(current_branch)
    if [[ "$current_branch" != "$DEVELOP_BRANCH" && "$current_branch" != "$PRODUCTION_BRANCH" ]]; then
        check_branch_status "$current_branch"
    fi
}

# Check status of a specific branch
check_branch_status() {
    local branch="$1"
    
    if [[ -z "$branch" ]]; then
        return 1
    fi
    
    echo -n "  $branch: "
    
    if ! branch_exists "$branch"; then
        if remote_branch_exists "$branch"; then
            echo -e "${YELLOW}Not created locally${NC} (available on remote)"
        else
            echo -e "${RED}Does not exist${NC}"
        fi
        return 0
    fi
    
    if ! remote_branch_exists "$branch"; then
        echo -e "${YELLOW}Local only${NC} (not pushed to remote)"
        return 0
    fi
    
    # Check if branch is behind or ahead
    local local_commit
    local remote_commit
    local_commit=$(git rev-parse "$branch")
    remote_commit=$(git rev-parse "$REMOTE/$branch")
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        echo -e "${GREEN}Up to date${NC}"
    elif git merge-base --is-ancestor "$local_commit" "$remote_commit" 2>/dev/null; then
        echo -e "${YELLOW}Behind remote${NC} (pull needed)"
    elif git merge-base --is-ancestor "$remote_commit" "$local_commit" 2>/dev/null; then
        echo -e "${YELLOW}Ahead of remote${NC} (push needed)"
    else
        echo -e "${RED}Diverged${NC} (merge needed)"
    fi
}

# List available sync commands
show_sync_help() {
    echo "Git Flow Sync Commands:"
    echo
    echo "  git flow sync                       Sync develop, production, and current branch"
    echo "  git flow sync <branch1> <branch2>   Sync specific branches"
    echo "  git flow sync --current             Sync only current branch"
    echo "  git flow sync --status              Show synchronization status"
    echo
    echo "Sync process for each branch:"
    echo "  1. Fetch from remote"
    echo "  2. Create local branch if missing (from remote)"
    echo "  3. Switch to branch"
    echo "  4. Pull latest changes"
    echo
    echo "Current configuration:"
    echo "  Develop branch: $DEVELOP_BRANCH"
    echo "  Production branch: $PRODUCTION_BRANCH"
    echo "  Remote: $REMOTE"
    echo
    echo "Examples:"
    echo "  git flow sync                      # Sync main branches"
    echo "  git flow sync feature/login        # Sync specific branch"
    echo "  git flow sync develop main         # Sync multiple branches"
    echo "  git flow sync --current            # Sync current branch only"
}
