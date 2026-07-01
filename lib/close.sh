#!/bin/bash

# Git Flow Close Function
# Closes branches based on their type

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main close function
close_branch() {
    local commit_message="$1"
    local current_branch
    current_branch=$(current_branch)
    
    # Get branch type
    local branch_type
    branch_type=$(get_branch_type "$current_branch")
    
    if [[ "$branch_type" == "unknown" ]]; then
        error "Cannot determine branch type for '$current_branch'"
        error "This command only works with feature/, fix/, release/, or hotfix/ branches"
        return 1
    fi
    
    info "Closing $branch_type branch: $current_branch"
    
    case "$branch_type" in
        feature|fix)
            close_feature_or_fix "$current_branch" "$commit_message"
            ;;
        release)
            close_release "$current_branch"
            ;;
        hotfix)
            close_hotfix "$current_branch" "$commit_message"
            ;;
    esac
}

# Close feature or fix branch
close_feature_or_fix() {
    local branch="$1"
    local commit_message="$2"
    
    info "Processing $branch branch"
    
    # Commit changes if needed
    if [[ -n "$commit_message" ]]; then
        commit_if_needed "$commit_message" || return 1
    elif ! git diff-index --quiet HEAD --; then
        error "There are uncommitted changes. Please provide a commit message or commit changes first."
        return 1
    fi
    
    # Merge to develop
    local merge_message="Merge $branch into $DEVELOP_BRANCH"
    merge_branch "$branch" "$DEVELOP_BRANCH" "$merge_message" || return 1
    
    # Push develop branch
    push_branch "$DEVELOP_BRANCH"
    
    # Delete the branch
    delete_branch "$branch"
    
    # Switch back to develop
    switch_to_branch "$DEVELOP_BRANCH"
    
    success "$branch closed successfully!"
    info "Changes merged to $DEVELOP_BRANCH and branch deleted"
}

# Close release branch
close_release() {
    local branch="$1"
    
    info "Processing release branch: $branch"
    
    # Release branches should not have uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        error "Release branches should not have uncommitted changes"
        return 1
    fi
    
    # Merge to develop
    local merge_message="Merge $branch into $DEVELOP_BRANCH"
    merge_branch "$branch" "$DEVELOP_BRANCH" "$merge_message" || return 1
    
    # Push develop branch
    push_branch "$DEVELOP_BRANCH"
    
    # Delete the branch
    delete_branch "$branch"
    
    # Switch back to develop
    switch_to_branch "$DEVELOP_BRANCH"
    
    success "$branch closed successfully!"
    info "Changes merged to $DEVELOP_BRANCH and branch deleted"
}

# Close hotfix branch
close_hotfix() {
    local branch="$1"
    local commit_message="$2"
    
    info "Processing hotfix branch: $branch"
    
    # Commit changes if needed
    if [[ -n "$commit_message" ]]; then
        commit_if_needed "$commit_message" || return 1
    elif ! git diff-index --quiet HEAD --; then
        error "There are uncommitted changes. Please provide a commit message or commit changes first."
        return 1
    fi
    
    # Merge to production branch
    local production_merge_message="Merge $branch into $PRODUCTION_BRANCH"
    merge_branch "$branch" "$PRODUCTION_BRANCH" "$production_merge_message" || return 1
    
    # Push production branch
    push_branch "$PRODUCTION_BRANCH"
    
    # Merge production back to develop
    local develop_merge_message="Merge $PRODUCTION_BRANCH into $DEVELOP_BRANCH (hotfix: $branch)"
    merge_branch "$PRODUCTION_BRANCH" "$DEVELOP_BRANCH" "$develop_merge_message" || return 1
    
    # Push develop branch
    push_branch "$DEVELOP_BRANCH"
    
    # Delete the hotfix branch
    delete_branch "$branch"
    
    # Switch back to develop
    switch_to_branch "$DEVELOP_BRANCH"
    
    success "$branch closed successfully!"
    info "Changes merged to both $PRODUCTION_BRANCH and $DEVELOP_BRANCH"
}

# List available close commands
show_close_help() {
    echo "Git Flow Close Commands:"
    echo
    echo "  git flow cerrar                      Close current branch automatically"
    echo "  git flow cerrar \"commit message\"     Close current branch with commit message"
    echo
    echo "Behavior by branch type:"
    echo
    echo "  feature/*:"
    echo "    - Commit changes (if message provided)"
    echo "    - Merge to develop"
    echo "    - Push to remote"
    echo "    - Delete branch (local and remote)"
    echo "    - Switch to develop"
    echo
    echo "  fix/*:"
    echo "    - Same as feature/*"
    echo
    echo "  release/*:"
    echo "    - Merge to develop"
    echo "    - Push to remote"
    echo "    - Delete branch (local and remote)"
    echo "    - Switch to develop"
    echo
    echo "  hotfix/*:"
    echo "    - Commit changes (if message provided)"
    echo "    - Merge to production"
    echo "    - Push production to remote"
    echo "    - Merge production to develop"
    echo "    - Push develop to remote"
    echo "    - Delete branch (local and remote)"
    echo "    - Switch to develop"
    echo
    echo "Current configuration:"
    echo "  Develop branch: $DEVELOP_BRANCH"
    echo "  Production branch: $PRODUCTION_BRANCH"
    echo "  Remote: $REMOTE"
}
