#!/bin/bash

# Git Flow Help Function
# Comprehensive help system

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./utils.sh
source "$SCRIPT_DIR/utils.sh"

# Main help function
show_help() {
    local topic="$1"
    
    if [[ -z "$topic" ]]; then
        show_general_help
    else
        case "$topic" in
            crear|create)
                show_create_help
                ;;
            cerrar|close)
                show_close_help
                ;;
            deploy|desplegar)
                show_deploy_help
                ;;
            sync|sincronizar)
                show_sync_help
                ;;
            status|estado)
                show_status_help
                ;;
            config|configuracion)
                show_config_help
                ;;
            install|instalar)
                show_install_help
                ;;
            examples|ejemplos)
                show_examples
                ;;
            workflow|flujo)
                show_workflow_help
                ;;
            troubleshooting|problemas)
                show_troubleshooting
                ;;
            *)
                error "Unknown help topic: $topic"
                echo
                show_general_help
                return 1
                ;;
        esac
    fi
}

# General help
show_general_help() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}Git Flow CLI Tool${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}A professional Git Flow workflow automation tool${NC}"
    echo
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  git flow <command> [options] [arguments]"
    echo
    echo -e "${YELLOW}CORE COMMANDS:${NC}"
    echo "  crear <type> <name>      Create a new branch (feature, fix, release, hotfix)"
    echo "  cerrar [message]         Close current branch and merge to target"
    echo "  deploy [message]         Deploy develop to production"
    echo "  sync [branches...]       Synchronize branches with remote"
    echo "  status                   Show repository status"
    echo
    echo -e "${YELLOW}UTILITY COMMANDS:${NC}"
    echo "  help [topic]             Show help for specific topic"
    echo "  version                  Show version information"
    echo "  config                   Show current configuration"
    echo
    echo -e "${YELLOW}HELP TOPICS:${NC}"
    echo "  crear                    Branch creation help"
    echo "  cerrar                   Branch closing help"
    echo "  deploy                   Deployment help"
    echo "  sync                     Synchronization help"
    echo "  status                   Status command help"
    echo "  config                   Configuration help"
    echo "  examples                 Usage examples"
    echo "  workflow                 Git Flow workflow explanation"
    echo "  troubleshooting          Common issues and solutions"
    echo
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  git flow crear feature login-google"
    echo "  git flow cerrar \"Fix login validation\""
    echo "  git flow deploy \"Release v2.1.0\""
    echo "  git flow sync"
    echo "  git flow status"
    echo
    echo -e "${YELLOW}GETTING STARTED:${NC}"
    echo "  1. Ensure you're in a Git repository"
    echo "  2. Run 'git flow status' to see current state"
    echo "  3. Create your first feature: 'git flow crear feature my-feature'"
    echo "  4. Work on your changes and commit"
    echo "  5. Close the branch: 'git flow cerrar'"
    echo
    echo -e "${YELLOW}CONFIGURATION:${NC}"
    echo "  • Develop branch: $DEVELOP_BRANCH"
    echo "  • Production branch: $PRODUCTION_BRANCH"
    echo "  • Remote: $REMOTE"
    echo "  • Build enabled: $RUN_BUILD"
    echo
    echo "For detailed help on any command, use: git flow help <topic>"
}

# Configuration help
show_config_help() {
    echo -e "${WHITE}Git Flow Configuration${NC}"
    echo
    echo -e "${YELLOW}CURRENT CONFIGURATION:${NC}"
    echo "  DEVELOP_BRANCH=\"$DEVELOP_BRANCH\""
    echo "  PRODUCTION_BRANCH=\"$PRODUCTION_BRANCH\""
    echo "  RUN_BUILD=$RUN_BUILD"
    echo "  BUILD_COMMAND=\"$BUILD_COMMAND\""
    echo "  REMOTE=\"$REMOTE\""
    echo "  DEFAULT_CONFIRM=$DEFAULT_CONFIRM"
    echo
    echo -e "${YELLOW}CUSTOM CONFIGURATION:${NC}"
    echo "You can override configuration by creating ~/.git-flow-config"
    echo
    echo "Example ~/.git-flow-config:"
    echo "  # Custom branch names"
    echo "  DEVELOP_BRANCH=\"dev\""
    echo "  PRODUCTION_BRANCH=\"master\""
    echo
    echo "  # Custom build settings"
    echo "  RUN_BUILD=false"
    echo "  BUILD_COMMAND=\"yarn build && yarn test\""
    echo
    echo "  # Custom remote"
    echo "  REMOTE=\"upstream\""
    echo
    echo "  # Default confirmation behavior"
    echo "  DEFAULT_CONFIRM=false"
    echo
    echo -e "${YELLOW}ENVIRONMENT VARIABLES:${NC}"
    echo "You can also use environment variables:"
    echo "  GIT_FLOW_DEVELOP_BRANCH=\"dev\" git flow crear feature test"
    echo "  GIT_FLOW_REMOTE=\"upstream\" git flow sync"
}

# Installation help
show_install_help() {
    echo -e "${WHITE}Git Flow Installation${NC}"
    echo
    echo -e "${YELLOW}AUTOMATIC INSTALLATION:${NC}"
    echo "  ./install.sh"
    echo
    echo -e "${YELLOW}MANUAL INSTALLATION:${NC}"
    echo "  1. Clone or download this repository"
    echo "  2. Run: ./install.sh"
    echo "  3. Verify: git flow --help"
    echo
    echo -e "${YELLOW}REQUIREMENTS:${NC}"
    echo "  • Git (version 2.0 or higher)"
    echo "  • Bash (version 4.0 or higher)"
    echo "  • Basic Unix tools (grep, sed, awk)"
    echo
    echo -e "${YELLOW}COMPATIBILITY:${NC}"
    echo "  • Linux (Ubuntu, Debian, CentOS, Arch, etc.)"
    echo "  • macOS (10.14 or higher)"
    echo "  • Windows (Git Bash, WSL, Cygwin)"
    echo
    echo -e "${YELLOW}UNINSTALLATION:${NC}"
    echo "  ./uninstall.sh"
    echo
    echo -e "${YELLOW}INSTALLATION LOCATION:${NC}"
    echo "  The script installs to ~/.local/bin/ by default"
    echo "  This location is automatically added to your PATH if needed"
}

# Usage examples
show_examples() {
    echo -e "${WHITE}Git Flow Usage Examples${NC}"
    echo
    echo -e "${YELLOW}DAILY WORKFLOW:${NC}"
    echo
    echo "1. Start a new feature:"
    echo "   ${CYAN}git flow crear feature user-authentication${NC}"
    echo "   → Creates feature/user-authentication from develop"
    echo
    echo "2. Work on your feature:"
    echo "   ${CYAN}# Make changes...${NC}"
    echo "   ${CYAN}git add .${NC}"
    echo "   ${CYAN}git commit -m \"Add user authentication\"${NC}"
    echo "   ${CYAN}git push${NC}"
    echo
    echo "3. Finish the feature:"
    echo "   ${CYAN}git flow cerrar \"Complete user authentication\"${NC}"
    echo "   → Merges to develop, deletes branch, returns to develop"
    echo
    echo -e "${YELLOW}BUG FIXES:${NC}"
    echo
    echo "1. Create a fix branch:"
    echo "   ${CYAN}git flow crear fix login-validation${NC}"
    echo "   → Creates fix/login-validation from develop"
    echo
    echo "2. Fix and close:"
    echo "   ${CYAN}# Fix the bug...${NC}"
    echo "   ${CYAN}git flow cerrar \"Fix login validation error\"${NC}"
    echo "   → Merges to develop, deletes branch"
    echo
    echo -e "${YELLOW}RELEASES:${NC}"
    echo
    echo "1. Create release branch:"
    echo "   ${CYAN}git flow crear release v2.1.0${NC}"
    echo "   → Creates release/v2.1.0 from develop"
    echo
    echo "2. Finalize release:"
    echo "   ${CYAN}git flow cerrar${NC}"
    echo "   → Merges to develop, deletes branch"
    echo
    echo "3. Deploy to production:"
    echo "   ${CYAN}git flow deploy \"Release v2.1.0\"${NC}"
    echo "   → Merges develop to production"
    echo
    echo -e "${YELLOW}HOTFIXES:${NC}"
    echo
    echo "1. Create hotfix:"
    echo "   ${CYAN}git flow crear hotfix critical-security-patch${NC}"
    echo "   → Creates hotfix from production"
    echo
    echo "2. Apply hotfix:"
    echo "   ${CYAN}# Fix the critical issue...${NC}"
    echo "   ${CYAN}git flow cerrar \"Fix critical security vulnerability\"${NC}"
    echo "   → Merges to production AND develop"
    echo
    echo -e "${YELLOW}TEAM COLLABORATION:${NC}"
    echo
    echo "1. Sync all branches:"
    echo "   ${CYAN}git flow sync${NC}"
    echo "   → Updates develop, production, and current branch"
    echo
    echo "2. Check status:"
    echo "   ${CYAN}git flow status${NC}"
    echo "   → Shows comprehensive repository status"
    echo
    echo "3. Sync specific branches:"
    echo "   ${CYAN}git flow sync feature/login feature/payment${NC}"
    echo "   → Updates only specified branches"
}

# Workflow explanation
show_workflow_help() {
    echo -e "${WHITE}Git Flow Workflow${NC}"
    echo
    echo -e "${YELLOW}BRANCH TYPES:${NC}"
    echo
    echo -e "${GREEN}• develop${NC}"
    echo "  Main development branch"
    echo "  All features and fixes merge here"
    echo "  Never directly deployed to production"
    echo
    echo -e "${GREEN}• main/production${NC}"
    echo "  Production-ready code"
    echo "  Only receives merges from releases and hotfixes"
    echo "  Always deployable"
    echo
    echo -e "${GREEN}• feature/*${NC}"
    echo "  New features and functionality"
    echo "  Created from develop"
    echo "  Merged back to develop when complete"
    echo
    echo -e "${GREEN}• fix/*${NC}"
    echo "  Bug fixes and corrections"
    echo "  Created from develop"
    echo "  Merged back to develop when complete"
    echo
    echo -e "${GREEN}• release/*${NC}"
    echo "  Release preparation"
    echo "  Created from develop"
    echo "  Merged to develop (no code changes, just preparation)"
    echo
    echo -e "${GREEN}• hotfix/*${NC}"
    echo "  Emergency fixes for production"
    echo "  Created from production"
    echo "  Merged to production AND develop"
    echo
    echo -e "${YELLOW}TYPICAL WORKFLOW:${NC}"
    echo
    echo "1. ${CYAN}Setup${NC}: Initialize develop and main branches"
    echo "2. ${CYAN}Develop${NC}: Create features from develop branch"
    echo "3. ${CYAN}Test${NC}: Features are tested on develop"
    echo "4. ${CYAN}Release${NC}: Create release branch from develop"
    echo "5. ${CYAN}Deploy${NC}: Merge release to production"
    echo "6. ${CYAN}Maintain${NC}: Use hotfixes for production issues"
    echo
    echo -e "${YELLOW}BEST PRACTICES:${NC}"
    echo "  • Always pull latest changes before creating branches"
    echo "  • Keep branches focused and small"
    echo "  • Write descriptive commit messages"
    echo "  • Test features before merging to develop"
    echo "  • Use hotfixes only for production emergencies"
    echo "  • Regularly sync with remote repository"
}

# Troubleshooting
show_troubleshooting() {
    echo -e "${WHITE}Git Flow Troubleshooting${NC}"
    echo
    echo -e "${YELLOW}COMMON ISSUES:${NC}"
    echo
    echo -e "${RED}❌ \"Not a git repository\"${NC}"
    echo "  Cause: You're not in a Git repository"
    echo "  Solution: cd to your project directory"
    echo
    echo -e "${RED}❌ \"Working tree is not clean\"${NC}"
    echo "  Cause: You have uncommitted changes"
    echo "  Solution: Commit or stash your changes first"
    echo
    echo -e "${RED}❌ \"Branch already exists\"${NC}"
    echo "  Cause: Branch name conflict"
    echo "  Solution: Choose a different name or delete existing branch"
    echo
    echo -e "${RED}❌ \"Failed to pull from remote\"${NC}"
    echo "  Cause: Network issues or remote not accessible"
    echo "  Solution: Check internet connection and remote URL"
    echo
    echo -e "${RED}❌ \"Merge conflicts\"${NC}"
    echo "  Cause: Branch has diverged from target"
    echo "  Solution: Resolve conflicts manually, then continue"
    echo
    echo -e "${YELLOW}DEBUG MODE:${NC}"
    echo "  Run with debug information:"
    echo "  ${CYAN}GIT_FLOW_DEBUG=1 git flow <command>${NC}"
    echo
    echo -e "${YELLOW}GET HELP:${NC}"
    echo "  • Check status: git flow status"
    echo "  • Sync branches: git flow sync"
    echo "  • Get help: git flow help <topic>"
    echo "  • Report issues: Create GitHub issue"
    echo
    echo -e "${YELLOW}RECOVERY COMMANDS:${NC}"
    echo "  • Reset to clean state: git reset --hard HEAD"
    echo "  • Clean untracked files: git clean -fd"
    echo "  • Abort merge: git merge --abort"
    echo "  • Stash changes: git stash"
}
