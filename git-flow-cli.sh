#!/bin/bash

# Git Flow CLI - Main entry point
# This script is called by Git alias

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load all library files
source "$LIB_DIR/config.sh"
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/create.sh"
source "$LIB_DIR/close.sh"
source "$LIB_DIR/deploy.sh"
source "$LIB_DIR/sync.sh"
source "$LIB_DIR/status.sh"
source "$LIB_DIR/init.sh"
source "$LIB_DIR/help.sh"

# Version
VERSION="1.0.0"

# Debug mode
if [[ "${GIT_FLOW_DEBUG:-}" == "1" ]]; then
    set -x
fi

# Main function
main() {
    local command="${1:-}"
    local arg1="${2:-}"
    local arg2="${3:-}"
    
    # Handle case where no command is provided
    if [[ -z "$command" ]]; then
        show_help
        return 0
    fi
    
    # Handle help flags
    case "$command" in
        -h|--help|help)
            show_help "$arg1"
            return 0
            ;;
        -v|--version|version)
            echo "Git Flow CLI v$VERSION"
            return 0
            ;;
    esac
    
    # Process commands
    case "$command" in
        crear|create)
            handle_create_command "$arg1" "$arg2"
            ;;
        cerrar|close)
            handle_close_command "$arg1"
            ;;
        deploy|desplegar)
            handle_deploy_command "$arg1"
            ;;
        sync|sincronizar)
            handle_sync_command "$arg1" "$@"
            ;;
        status|estado)
            handle_status_command "$arg1"
            ;;
        config|configuracion)
            show_config_help
            ;;
        init|inicializar)
            init_git_flow
            ;;
        *)
            error "Unknown command: $command"
            echo
            show_help
            return 1
            ;;
    esac
}

# Handle create command
handle_create_command() {
    local branch_type="$1"
    local branch_name="$2"
    
    if [[ -z "$branch_type" ]]; then
        show_create_help
        return 1
    fi
    
    if [[ -z "$branch_name" ]]; then
        error "Branch name is required"
        echo
        show_create_help
        return 1
    fi
    
    case "$branch_type" in
        feature)
            create_feature "$branch_name"
            ;;
        fix)
            create_fix "$branch_name"
            ;;
        release)
            create_release "$branch_name"
            ;;
        hotfix)
            create_hotfix "$branch_name"
            ;;
        *)
            error "Invalid branch type: $branch_type"
            echo "Valid types are: feature, fix, release, hotfix"
            return 1
            ;;
    esac
}

# Handle close command
handle_close_command() {
    local commit_message="$1"
    close_branch "$commit_message"
}

# Handle deploy command
handle_deploy_command() {
    local commit_message="$1"
    if [[ -n "$commit_message" ]]; then
        deploy_with_message "$commit_message"
    else
        deploy_to_production
    fi
}

# Handle sync command
handle_sync_command() {
    local first_arg="$1"
    
    if [[ "$first_arg" == "--current" ]]; then
        sync_current_branch
    elif [[ "$first_arg" == "--status" ]]; then
        show_sync_status
    elif [[ -z "$first_arg" ]]; then
        sync_repository
    else
        sync_specific_branches "$@"
    fi
}

# Handle status command
handle_status_command() {
    local option="$1"
    
    if [[ "$option" == "--compact" ]]; then
        show_compact_status
    else
        show_status
    fi
}

# Script entry point
main "$@"
