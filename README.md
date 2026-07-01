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

### Quick Install

```bash
# Clone the repository
git clone https://github.com/your-username/git-flow.git
cd git-flow

# Run the installer
./install.sh
```

### Manual Install

1. Copy the `git-flow` script to your PATH
2. Make it executable: `chmod +x git-flow`
3. Ensure the script is accessible as `git flow`

### Verify Installation

```bash
git flow --help
git flow version
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

#### Create Branches

```bash
# Create feature branch
git flow crear feature login-google

# Create fix branch
git flow crear fix error-email

# Create release branch
git flow crear release 2.5.0

# Create hotfix branch
git flow crear hotfix error-pagos
```

#### Close Branches

```bash
# Close current branch (auto-detects type)
git flow cerrar

# Close with custom commit message
git flow cerrar "Complete user authentication"
```

#### Deploy

```bash
# Deploy develop to production
git flow deploy

# Deploy with custom message
git flow deploy "Release v2.1.0"
```

#### Synchronize

```bash
# Sync all main branches
git flow sync

# Sync specific branches
git flow sync feature/login feature/payment

# Sync only current branch
git flow sync --current

# Show sync status
git flow sync --status
```

#### Status

```bash
# Show comprehensive status
git flow status

# Show compact status
git flow status --compact
```

### Utility Commands

```bash
# Show help
git flow help
git flow help crear
git flow help examples

# Show version
git flow version

# Show configuration
git flow config
```

## 🌿 Git Flow Workflow

### Branch Types

- **`develop`**: Main development branch
- **`main`**: Production-ready code
- **`feature/*`**: New features (from develop → develop)
- **`fix/*`**: Bug fixes (from develop → develop)
- **`release/*`**: Release preparation (from develop → develop)
- **`hotfix/*`**: Emergency fixes (from main → main + develop)

### Typical Workflow

1. **Start Feature**: `git flow crear feature user-auth`
2. **Develop**: Make changes, commit, push
3. **Complete**: `git flow cerrar "Add user authentication"`
4. **Deploy**: `git flow deploy "Release v2.1.0"`

### Hotfix Workflow

1. **Create Hotfix**: `git flow crear hotfix security-patch`
2. **Fix Issue**: Make changes, commit
3. **Apply**: `git flow cerrar "Fix security vulnerability"`
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
# Start new feature
git flow crear feature payment-gateway

# Work on feature
git add .
git commit -m "Add payment gateway integration"
git push

# Complete feature
git flow cerrar "Integrate payment gateway"

# Deploy to production
git flow deploy "Release payment gateway"
```

### Bug Fix

```bash
# Create fix branch
git flow crear fix login-validation

# Fix the bug
git add .
git commit -m "Fix login validation error"
git push

# Close fix
git flow cerrar "Fix login validation"
```

### Team Collaboration

```bash
# Sync with team
git flow sync

# Check repository status
git flow status

# Sync specific branches
git flow sync feature/profile feature/settings
```

## 🔧 Advanced Usage

### Environment Variables

Override configuration temporarily:

```bash
GIT_FLOW_DEVELOP_BRANCH="dev" git flow crear feature test
GIT_FLOW_REMOTE="upstream" git flow sync
GIT_FLOW_DEBUG=1 git flow status
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
