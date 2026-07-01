#!/bin/bash

# Git Flow Configuration
# All configuration variables are centralized here

# Branch configuration
DEVELOP_BRANCH="develop"
PRODUCTION_BRANCH="main"  # Default, will be auto-detected per project

# Build configuration
RUN_BUILD=true
BUILD_COMMAND="npm ci && npm run build"

# Remote configuration
REMOTE="origin"

# User interaction
DEFAULT_CONFIRM=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Load configuration from user config file if exists
if [[ -f "$HOME/.git-flow-config" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.git-flow-config"
fi
