#!/bin/bash

# Git Flow Status Function
# Shows comprehensive repository status

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main status function
show_status() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "This is not a git repository"
        return 1
    fi
    
    # Get repository information
    local project_name
    local current_branch
    local remote_url
    local last_commit
    local pending_changes
    local branch_type
    
    project_name=$(get_project_name)
    current_branch=$(current_branch)
    remote_url=$(get_remote_url)
    last_commit=$(get_last_commit)
    pending_changes=$(get_pending_changes)
    branch_type=$(get_branch_type "$current_branch")
    
    # Display status header
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}Git Flow Status${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Project Information
    echo -e "${WHITE}📁 Project:${NC} $project_name"
    echo -e "${WHITE}🌐 Repository:${NC} $remote_url"
    echo
    
    # Branch Information
    echo -e "${WHITE}🌿 Current Branch:${NC} $current_branch"
    if [[ "$branch_type" != "unknown" ]]; then
        echo -e "${WHITE}📋 Branch Type:${NC} $branch_type"
    fi
    echo
    
    # Main Branches Status
    echo -e "${WHITE}🔧 Main Branches:${NC}"
    check_main_branch_status "$DEVELOP_BRANCH" "Develop"
    check_main_branch_status "$PRODUCTION_BRANCH" "Production"
    echo
    
    # Working Tree Status
    echo -e "${WHITE}📊 Working Tree:${NC}"
    if [[ "$pending_changes" == "Yes" ]]; then
        echo -e "  ${YELLOW}⚠️  Changes pending${NC}"
        show_pending_changes_summary
    else
        echo -e "  ${GREEN}✅ Clean${NC}"
    fi
    echo
    
    # Last Commit
    echo -e "${WHITE}📝 Last Commit:${NC}"
    echo "  $last_commit"
    echo
    
    # Configuration
    echo -e "${WHITE}⚙️  Configuration:${NC}"
    echo -e "  Build enabled: $([[ "$RUN_BUILD" == "true" ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${RED}No${NC}")"
    echo -e "  Remote: $REMOTE"
    echo
    
    # Branch Summary
    show_branch_summary
    
    # Remote Status
    show_remote_status
    
    echo
    echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
}

# Check status of main branches
check_main_branch_status() {
    local branch="$1"
    local label="$2"
    
    echo -n "  $label ($branch): "
    
    if ! branch_exists "$branch"; then
        if remote_branch_exists "$branch"; then
            echo -e "${YELLOW}⬇️  Available on remote${NC}"
        else
            echo -e "${RED}❌ Not found${NC}"
        fi
        return 0
    fi
    
    if ! remote_branch_exists "$branch"; then
        echo -e "${YELLOW}⬆️  Local only${NC}"
        return 0
    fi
    
    # Check if branch is behind or ahead
    local local_commit
    local remote_commit
    local_commit=$(git rev-parse "$branch")
    remote_commit=$(git rev-parse "$REMOTE/$branch")
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        echo -e "${GREEN}✅ Up to date${NC}"
    elif git merge-base --is-ancestor "$local_commit" "$remote_commit" 2>/dev/null; then
        echo -e "${YELLOW}⬇️  Behind remote${NC}"
    elif git merge-base --is-ancestor "$remote_commit" "$local_commit" 2>/dev/null; then
        echo -e "${YELLOW}⬆️  Ahead of remote${NC}"
    else
        echo -e "${RED}🔄 Diverged${NC}"
    fi
}

# Show pending changes summary
show_pending_changes_summary() {
    local status
    status=$(git status --porcelain 2>/dev/null)
    
    local modified=0
    local added=0
    local deleted=0
    local untracked=0
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            case "${line:0:1}" in
                M) ((modified++)) ;;
                A) ((added++)) ;;
                D) ((deleted++)) ;;
                \?) ((untracked++)) ;;
            esac
        fi
    done <<< "$status"
    
    if [[ $modified -gt 0 ]]; then
        echo -e "    ${YELLOW}Modified: $modified${NC}"
    fi
    if [[ $added -gt 0 ]]; then
        echo -e "    ${GREEN}Added: $added${NC}"
    fi
    if [[ $deleted -gt 0 ]]; then
        echo -e "    ${RED}Deleted: $deleted${NC}"
    fi
    if [[ $untracked -gt 0 ]]; then
        echo -e "    ${BLUE}Untracked: $untracked${NC}"
    fi
}

# Show branch summary
show_branch_summary() {
    echo -e "${WHITE}🌲 Branch Summary:${NC}"
    
    # Count branches by type
    local feature_count=0
    local fix_count=0
    local release_count=0
    local hotfix_count=0
    local other_count=0
    
    # Get all local branches
    local branches
    branches=$(git branch --format='%(refname:short)') || return 0
    
    while IFS= read -r branch; do
        if [[ -n "$branch" ]]; then
            case "$branch" in
                feature/*) ((feature_count++)) ;;
                fix/*) ((fix_count++)) ;;
                release/*) ((release_count++)) ;;
                hotfix/*) ((hotfix_count++)) ;;
                develop|main|master) ;; # Skip main branches
                *) ((other_count++)) ;;
            esac
        fi
    done <<< "$branches"
    
    echo -e "  Feature branches: $feature_count"
    echo -e "  Fix branches: $fix_count"
    echo -e "  Release branches: $release_count"
    echo -e "  Hotfix branches: $hotfix_count"
    if [[ $other_count -gt 0 ]]; then
        echo -e "  Other branches: $other_count"
    fi
}

# Show remote status
show_remote_status() {
    echo -e "${WHITE}📡 Remote Status:${NC}"
    
    # Check if remote exists
    if ! git remote | grep -q "^$REMOTE$"; then
        echo -e "  ${RED}❌ Remote '$REMOTE' not configured${NC}"
        return 0
    fi
    
    # Check remote connectivity
    local remote_url
    remote_url=$(git remote get-url "$REMOTE" 2>/dev/null)
    if [[ -n "$remote_url" ]]; then
        echo -e "  ${GREEN}✅ Remote configured: $remote_url${NC}"
        
        # Check if we can reach remote (simple check)
        if git ls-remote --exit-code "$REMOTE" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ Remote reachable${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Remote unreachable${NC}"
        fi
    else
        echo -e "  ${RED}❌ Remote URL not set${NC}"
    fi
}

# Show compact status (for quick view)
show_compact_status() {
    local current_branch
    current_branch=$(current_branch)
    local pending_changes
    pending_changes=$(get_pending_changes)
    
    echo -n "[$current_branch]"
    
    if [[ "$pending_changes" == "Yes" ]]; then
        echo -n " ${YELLOW}*${NC}"
    fi
    
    # Check if current branch is ahead/behind
    if remote_branch_exists "$current_branch"; then
        local local_commit
        local remote_commit
        local_commit=$(git rev-parse "$current_branch")
        remote_commit=$(git rev-parse "$REMOTE/$current_branch")
        
        if [[ "$local_commit" != "$remote_commit" ]]; then
            if git merge-base --is-ancestor "$local_commit" "$remote_commit" 2>/dev/null; then
                echo -n " ${YELLOW}↓${NC}"
            elif git merge-base --is-ancestor "$remote_commit" "$local_commit" 2>/dev/null; then
                echo -n " ${YELLOW}↑${NC}"
            else
                echo -n " ${RED}↕${NC}"
            fi
        fi
    fi
    
    echo
}

# List available status commands
show_status_help() {
    echo "Git Flow Status Commands:"
    echo
    echo "  git flow status          Show comprehensive repository status"
    echo "  git flow status --compact Show compact status (single line)"
    echo
    echo "Status includes:"
    echo "  • Project information"
    echo "  • Current branch and type"
    echo "  • Main branches status (develop, production)"
    echo "  • Working tree status"
    echo "  • Last commit information"
    echo "  • Configuration summary"
    echo "  • Branch summary by type"
    echo "  • Remote connectivity status"
    echo
    echo "Current configuration:"
    echo "  Develop branch: $DEVELOP_BRANCH"
    echo "  Production branch: $PRODUCTION_BRANCH"
    echo "  Remote: $REMOTE"
}
