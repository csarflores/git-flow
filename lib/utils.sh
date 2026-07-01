#!/bin/bash

# Git Flow Utility Functions
# Reusable functions for git flow operations

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

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
    local default="${2:-$DEFAULT_CONFIRM}"
    
    if [[ "$default" == "true" ]]; then
        read -p "$(echo -e "${YELLOW}$message [Y/n]:${NC} ")" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        fi
    else
        read -p "$(echo -e "${YELLOW}$message [y/N]:${NC} ")" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Git utility functions
require_git_repository() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "This is not a git repository"
        exit 1
    fi
}

require_clean_worktree() {
    if ! git diff-index --quiet HEAD --; then
        error "Working tree is not clean. Please commit or stash your changes first."
        exit 1
    fi
}

current_branch() {
    git rev-parse --abbrev-ref HEAD
}

branch_exists() {
    local branch="$1"
    git show-ref --verify --quiet "refs/heads/$branch"
}

remote_branch_exists() {
    local branch="$1"
    git show-ref --verify --quiet "refs/remotes/$REMOTE/$branch"
}

switch_to_branch() {
    local branch="$1"
    if ! branch_exists "$branch"; then
        error "Branch '$branch' does not exist locally"
        return 1
    fi
    
    if [[ "$(current_branch)" != "$branch" ]]; then
        info "Switching to branch '$branch'"
        git checkout "$branch" || {
            error "Failed to switch to branch '$branch'"
            return 1
        }
    fi
}

pull_branch() {
    local branch="$1"
    info "Pulling latest changes for '$branch' from $REMOTE"
    git pull "$REMOTE" "$branch" || {
        error "Failed to pull branch '$branch' from $REMOTE"
        return 1
    }
}

push_branch() {
    local branch="$1"
    local setup_upstream="${2:-false}"
    
    if [[ "$setup_upstream" == "true" ]]; then
        info "Pushing branch '$branch' to $REMOTE and setting up upstream"
        git push -u "$REMOTE" "$branch" || {
            error "Failed to push branch '$branch' to $REMOTE"
            return 1
        }
    else
        info "Pushing branch '$branch' to $REMOTE"
        git push "$REMOTE" "$branch" || {
            error "Failed to push branch '$branch' to $REMOTE"
            return 1
        }
    fi
}

create_branch() {
    local base_branch="$1"
    local new_branch="$2"
    
    info "Creating branch '$new_branch' from '$base_branch'"
    git checkout -b "$new_branch" "$base_branch" || {
        error "Failed to create branch '$new_branch' from '$base_branch'"
        return 1
    }
}

merge_branch() {
    local source_branch="$1"
    local target_branch="$2"
    local message="${3:-Merge $source_branch into $target_branch}"
    
    info "Merging '$source_branch' into '$target_branch'"
    
    # Ensure we're on the target branch
    switch_to_branch "$target_branch"
    
    # Pull latest changes
    pull_branch "$target_branch"
    
    # Merge the source branch
    git merge --no-ff "$source_branch" -m "$message" || {
        error "Failed to merge '$source_branch' into '$target_branch'"
        error "Please resolve merge conflicts and try again"
        return 1
    }
    
    success "Successfully merged '$source_branch' into '$target_branch'"
}

commit_if_needed() {
    local commit_message="$1"
    
    # Check if there are changes to commit
    if ! git diff-index --quiet HEAD --; then
        info "Found changes to commit"
        git add .
        
        if [[ -z "$commit_message" ]]; then
            error "Commit message is required when there are changes to commit"
            return 1
        fi
        
        git commit -m "$commit_message" || {
            error "Failed to commit changes"
            return 1
        }
        success "Changes committed successfully"
    else
        info "No changes to commit"
    fi
}

delete_branch() {
    local branch="$1"
    local force="${2:-false}"
    
    # Delete local branch
    if branch_exists "$branch"; then
        info "Deleting local branch '$branch'"
        if [[ "$force" == "true" ]]; then
            git branch -D "$branch"
        else
            git branch -d "$branch"
        fi
    fi
    
    # Delete remote branch
    if remote_branch_exists "$branch"; then
        info "Deleting remote branch '$branch' from $REMOTE"
        git push "$REMOTE" --delete "$branch"
    fi
}

get_branch_type() {
    local branch="$1"
    case "$branch" in
        feature/*)
            echo "feature"
            ;;
        fix/*)
            echo "fix"
            ;;
        release/*)
            echo "release"
            ;;
        hotfix/*)
            echo "hotfix"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

validate_branch_name() {
    local branch_type="$1"
    local branch_name="$2"
    
    if [[ -z "$branch_name" ]]; then
        error "Branch name cannot be empty"
        return 1
    fi
    
    # Basic validation - no spaces, no special characters except hyphens and underscores
    if [[ ! "$branch_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "Branch name can only contain letters, numbers, hyphens, and underscores"
        return 1
    fi
    
    return 0
}

execute_build() {
    if [[ "$RUN_BUILD" == "true" ]]; then
        info "Running build command: $BUILD_COMMAND"
        eval "$BUILD_COMMAND" || {
            error "Build failed. Aborting operation."
            return 1
        }
        success "Build completed successfully"
    else
        info "Build is disabled. Skipping build step."
    fi
}

get_project_name() {
    basename "$(git rev-parse --show-toplevel)"
}

# Auto-detect production branch for current project
detect_production_branch() {
    local detected_branch=""
    
    # Check if main exists locally or remotely
    if branch_exists "main" || remote_branch_exists "main"; then
        detected_branch="main"
    fi
    
    # Check if master exists locally or remotely
    if branch_exists "master" || remote_branch_exists "master"; then
        if [[ -n "$detected_branch" ]]; then
            # Both exist, prefer main by default but allow override
            warning "Both 'main' and 'master' branches detected. Using 'main' as production branch."
            warning "You can override this in ~/.git-flow-config with PRODUCTION_BRANCH=\"master\""
        else
            detected_branch="master"
        fi
    fi
    
    # If no production branch found, use default
    if [[ -z "$detected_branch" ]]; then
        detected_branch="$PRODUCTION_BRANCH"
        warning "No production branch detected. Using default: $detected_branch"
        info "You may need to create '$detected_branch' branch first."
    fi
    
    echo "$detected_branch"
}

# Get production branch (auto-detected or configured)
get_production_branch() {
    # Check if user has overridden production branch in config
    local user_config="$HOME/.git-flow-config"
    if [[ -f "$user_config" ]]; then
        local user_branch
        user_branch=$(grep "^PRODUCTION_BRANCH=" "$user_config" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
        if [[ -n "$user_branch" ]]; then
            echo "$user_branch"
            return
        fi
    fi
    
    # Auto-detect
    detect_production_branch
}

get_remote_url() {
    git remote get-url "$REMOTE" 2>/dev/null || echo "No remote configured"
}

get_last_commit() {
    git log -1 --pretty=format:"%h - %s (%cr)" --no-show-signature
}

get_pending_changes() {
    local status
    status=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status" ]]; then
        echo "Yes"
    else
        echo "No"
    fi
}
