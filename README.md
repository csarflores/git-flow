# Git Flow CLI

A professional Git Flow workflow automation tool that simplifies branch management and deployment processes.

## 🚀 Features

- **Professional CLI**: Clean, intuitive command-line interface similar to GitHub CLI
- **Modular Architecture**: Clean, maintainable code with separate modules for each function
- **Automatic Branch Management**: Create, merge, and clean up branches automatically
- **Smart Deployment**: Build verification and production deployment with confirmation
- **Comprehensive Status**: Detailed repository status with visual indicators
- **Cross-Platform**: Works on Linux, macOS, and Windows (Git Bash)
- **Easy Installation**: One-command installation with automatic PATH setup
- **Configurable**: Customize branches, build commands, and behavior

## 📋 Requirements

- **Git** (version 2.0 or higher)
- **Bash** (version 4.0 or higher)
- **Basic Unix tools** (grep, sed, awk)

## 🔧 Installation

### Windows (Recommended)

```cmd
# Clone the repository
git clone https://github.com/csarflores/git-flow.git
cd git-flow

# Run the Windows installer
install-windows.cmd
```

Then restart Git Bash.

### macOS / Linux

```bash
# Clone the repository
git clone https://github.com/csarflores/git-flow.git
cd git-flow

# Run the installer
./install.sh
```

### Verify Installation

```bash
git help-flow
git status-flow
```

## ⚙️ Configuration

Create `~/.git-flow-config` to customize settings:

```bash
# Branch configuration
DEVELOP_BRANCH="develop"
PRODUCTION_BRANCH="main"

# Build configuration
RUN_BUILD=true
BUILD_COMMAND="npm ci && npm run build"

# Remote configuration
REMOTE="origin"

# User interaction
DEFAULT_CONFIRM=true
```

## 📚 Commands

### Core Commands

#### Initialize Git Flow in a Project

```bash
# Run inside any project (new or existing)
git init-flow
```

#### Create Branches

```bash
# Create feature branch
git crear-feature login-google

# Create fix branch
git crear-fix error-email

# Create release branch
git crear-release 2.5.0

# Create hotfix branch
git crear-hotfix error-pagos
```

#### Close Branches

```bash
# Close current branch (auto-detects type)
git cerrar

# Close with custom commit message
git cerrar "Complete user authentication"
```

#### Deploy

```bash
# Deploy develop to production
git deploy

# Deploy with custom message
git deploy "Release v2.1.0"
```

#### Synchronize

```bash
# Sync all main branches
git sync

# Show sync status
git sync --status
```

#### Status

```bash
# Show comprehensive status
git status-flow

# Show compact status
git status-flow --compact
```

### Utility Commands

```bash
# Show help
git help-flow
git help-flow crear
git help-flow examples

# Show version
git help-flow version
```

## 🌿 Git Flow Workflow

### Branch Types

- **`develop`**: Main development branch
- **`main` or `master`**: Production-ready code (auto-detected per project)
- **`feature/*`**: New features (from develop → develop)
- **`fix/*`**: Bug fixes (from develop → develop)
- **`release/*`**: Release preparation (from develop → develop)
- **`hotfix/*`**: Emergency fixes (from production → production + develop)

### Typical Workflow

1. **Initialize**: `git init-flow`
2. **Start Feature**: `git crear-feature user-auth`
3. **Develop**: Make changes, commit, push
4. **Complete**: `git cerrar "Add user authentication"`
5. **Deploy**: `git deploy "Release v2.1.0"`

### Hotfix Workflow

1. **Create Hotfix**: `git crear-hotfix security-patch`
2. **Fix Issue**: Make changes, commit
3. **Apply**: `git cerrar "Fix security vulnerability"`
4. **Deploy**: Automatically deployed to production

## 📊 Status Display

The `git flow status` command shows:

- 📁 Project information
- 🌿 Current branch and type
- 🔧 Main branches status (develop, production)
- 📊 Working tree status
- 📝 Last commit information
- ⚙️ Configuration summary
- 🌲 Branch summary by type
- 📡 Remote connectivity status

## 🎨 Examples

### Daily Development

```bash
# Initialize project (run once)
git init-flow

# Start new feature
git crear-feature payment-gateway

# Work on feature
git add .
git commit -m "Add payment gateway integration"
git push

# Complete feature
git cerrar "Integrate payment gateway"

# Deploy to production
git deploy "Release payment gateway"
```

### Bug Fix

```bash
# Create fix branch
git crear-fix login-validation

# Fix the bug
git add .
git commit -m "Fix login validation error"
git push

# Close fix
git cerrar "Fix login validation"
```

### Team Collaboration

```bash
# Sync with team
git sync

# Check repository status
git status-flow
```

## 🔧 Advanced Usage

### Environment Variables

Override configuration temporarily:

```bash
GIT_FLOW_DEVELOP_BRANCH="dev" git crear-feature test
GIT_FLOW_REMOTE="upstream" git sync
GIT_FLOW_DEBUG=1 git status-flow
```

### Build Integration

Configure automatic builds:

```bash
# In ~/.git-flow-config
RUN_BUILD=true
BUILD_COMMAND="npm ci && npm run build && npm test"
```

### Custom Branch Names

```bash
# Use different main branch names
DEVELOP_BRANCH="dev"
PRODUCTION_BRANCH="master"
```

## 🛠️ Troubleshooting

### Common Issues

**"Not a git repository"**
- Ensure you're in a Git repository directory

**"Working tree is not clean"**
- Commit or stash your changes first

**"Branch already exists"**
- Choose a different branch name or delete existing branch

**"Failed to pull from remote"**
- Check internet connection and remote URL

**"Merge conflicts"**
- Resolve conflicts manually, then continue

### Debug Mode

Enable debug output:

```bash
GIT_FLOW_DEBUG=1 git flow <command>
```

### Recovery Commands

```bash
# Reset to clean state
git reset --hard HEAD

# Clean untracked files
git clean -fd

# Abort merge
git merge --abort

# Stash changes
git stash
```

## 🔄 Uninstallation

```bash
# Run the uninstaller
./uninstall.sh
```

This removes:
- The git-flow script
- Git integration
- PATH configuration
- Configuration file (optional)

## 📁 Project Structure

```
git-flow/
├── git-flow              # Main executable script
├── install.sh            # Installation script
├── uninstall.sh          # Uninstallation script
├── README.md             # This documentation
├── LICENSE               # MIT License
└── lib/                  # Library modules
    ├── config.sh         # Configuration variables
    ├── utils.sh          # Utility functions
    ├── create.sh         # Branch creation logic
    ├── close.sh          # Branch closing logic
    ├── deploy.sh         # Deployment logic
    ├── sync.sh           # Synchronization logic
    ├── status.sh         # Status display logic
    └── help.sh           # Help system
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git flow crear feature your-feature`
3. Make your changes
4. Add tests if applicable
5. Commit your changes: `git flow cerrar "Add your feature"`
6. Push and create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Vincent Driessen's Git Flow model
- Built with best practices for Bash scripting
- Compatible with ShellCheck for code quality

## 📞 Support

- **Documentation**: `git flow help`
- **Examples**: `git flow help examples`
- **Troubleshooting**: `git flow help troubleshooting`
- **Issues**: Create an issue on GitHub

## 🚀 Quick Start

```bash
# Install
./install.sh

# Verify
git flow --help

# Start your first feature
git flow crear feature my-awesome-feature

# Check status
git flow status

# Get help
git flow help
```

Enjoy using Git Flow CLI! 🎉
