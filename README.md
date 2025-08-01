# Dotfiles - Idempotent & Modular Setup

A completely idempotent, modular dotfiles management system built with GNU Stow. This setup can be run multiple times safely on any Ubuntu system and allows for easy dependency management and incremental updates.

## 🏗️ Architecture Overview

This dotfiles system is built around four core principles:

1. **Idempotency** - Run multiple times safely without conflicts
2. **Modularity** - Choose exactly what you need via profiles
3. **Security** - Template-based configs for sensitive data
4. **Maintainability** - Clear separation of concerns and organized structure

## 📁 Directory Structure

```
dotfiles/
├── install.sh                    # Main installer with profile selection
├── scripts/                      # Installation scripts (not stowed)
│   ├── system/
│   │   ├── packages.sh           # Idempotent package installation
│   │   └── generate-configs.sh   # Generate configs from templates
│   ├── security/
│   │   ├── ssh-keys.sh          # SSH key generation and agent setup
│   │   └── gpg-keys.sh          # GPG key generation and git config
│   ├── development/
│   │   ├── node.sh              # Node.js/fnm setup
│   │   ├── php.sh               # PHP 8.4/Laravel setup
│   │   ├── neovim.sh            # Neovim stable installation
│   │   ├── neovim-config.sh     # Latest config from nikolovlazar/dotfiles
│   │   ├── tmux.sh              # Latest config from nikolovlazar/dotfiles
│   │   ├── lazygit.sh           # LazyGit installation from GitHub releases
│   │   ├── wordpress-wsl.sh     # WordPress Local WP dependencies for WSL2
│   │   └── vscode.sh            # VSCode extensions installer
│   └── shell/
│       └── zsh-setup.sh         # Zsh + Oh My Zsh + plugins
│
├── configs/                      # Dotfiles managed by stow
│   ├── shell-zsh/               # Zsh configuration
│   │   ├── .zshrc               # Complete Zsh config with PATH management
│   │   └── .p10k.zsh           # Powerlevel10k theme config
│   ├── git/                     # Git configuration
│   │   ├── .gitconfig.template  # Template with {{PLACEHOLDERS}}
│   │   └── env.git.example      # Example environment file
│   ├── terminal/                # Terminal appearance
│   │   └── .dir_colors         # Custom ls colors
│   ├── tmux/                    # tmux configuration (from nikolovlazar)
│   │   ├── .tmux.conf          # Always latest from nikolovlazar/dotfiles
│   │   └── switch-catppuccin-theme.sh
│   ├── nvim/                    # Neovim configuration (from nikolovlazar)
│   │   └── .config/nvim/        # Always latest from nikolovlazar/dotfiles
│   └── development/             # Development tools
│       ├── .ssh-connections     # SSH connection manager
│       └── .env.ssh-connections.example
│
├── applications/                 # App-specific configs (special handling)
│   ├── vscode/
│   │   ├── settings.json        # VSCode settings
│   │   ├── extensions.linux     # Linux extensions list
│   │   └── extensions.windows   # Windows extensions list
│   └── windows/
│       └── .wslconfig          # WSL configuration
│
└── profiles/                     # Installation profiles
    ├── minimal.conf             # Essential tools only
    ├── development.conf         # Full dev environment
    ├── full.conf               # Everything including PHP
    └── server.conf             # Headless server setup
```

## 🚀 Quick Start

### Fresh Ubuntu Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Run the installer
./install.sh
```

### First-Time Setup

1. **Git Configuration** (Required)
   ```bash
   cp configs/git/env.git.example configs/git/.env.git
   nano configs/git/.env.git  # Fill in your details
   ```

2. **SSH Connections** (Optional)
   ```bash
   cp configs/development/.env.ssh-connections.example configs/development/.env.ssh-connections
   nano configs/development/.env.ssh-connections  # Add your servers
   ```

3. **Run Installer**
   ```bash
   ./install.sh
   ```

## 📋 Installation Profiles

| Profile | Description | Includes |
|---------|-------------|----------|
| **Minimal** | Essential tools only | Zsh + Git + Terminal colors + SSH/GPG keys |
| **Development** | Web development setup | + Node.js + Neovim + tmux + VSCode |
| **WordPress** | WordPress development setup | + PHP/Laravel + WordPress WSL dependencies |
| **Full** | Complete development environment | Everything including PHP/Laravel |
| **Server** | Headless server setup | Essential tools + SSH/GPG keys |
| **Custom** | Interactive component selection | Pick & choose |

### Profile Configuration

Each profile is defined in `profiles/*.conf` with three arrays:

```bash
# Example: profiles/development.conf
PROFILE_NAME="Development"
PROFILE_DESCRIPTION="Complete development environment with Node.js and VSCode"

SCRIPTS=(
  "scripts/system/packages.sh"
  "scripts/system/generate-configs.sh"
  "scripts/shell/zsh-setup.sh"
  "scripts/development/node.sh"
  "scripts/development/vscode.sh"
)

CONFIGS=(
  "configs/shell-zsh"
  "configs/git" 
  "configs/terminal"
  "configs/development"
)

APPLICATIONS=(
  "applications/vscode"
)
```

## 🔐 Security Features

### SSH Key Management
- **Location**: `scripts/security/ssh-keys.sh`
- **Function**: Generates ed25519 SSH keys if none exist, adds to SSH agent
- **Features**: 
  - Uses modern ed25519 cryptography
  - Automatically starts SSH agent if needed
  - Displays public key for easy copying to GitHub/GitLab
  - Idempotent - won't overwrite existing keys

### GPG Key Management
- **Location**: `scripts/security/gpg-keys.sh`
- **Function**: Generates 4096-bit RSA GPG keys for git commit signing
- **Features**:
  - Automatically configures git to use the key for signing
  - Exports public key to gitignored file for sharing
  - Uses batch generation for automation
  - Idempotent - detects existing keys

## 🔄 Always Up-to-Date Configurations

### tmux Configuration
- **Source**: [nikolovlazar/dotfiles](https://github.com/nikolovlazar/dotfiles/tree/main/.config/tmux)
- **Update Method**: Downloads latest configuration on every run
- **Files**: `tmux.conf`, `switch-catppuccin-theme.sh`
- **Features**: Modern tmux setup with Catppuccin theme support

### Neovim Configuration  
- **Source**: [nikolovlazar/dotfiles](https://github.com/nikolovlazar/dotfiles/tree/main/.config/nvim)
- **Update Method**: Git sparse-checkout to get latest configuration
- **Features**: Complete LazyVim setup with modern plugins and themes
- **Installation**: Automatically installs latest stable Neovim from GitHub releases

## 🔧 Core Components

### System Packages
- **Location**: `scripts/system/packages.sh`
- **Function**: Installs essential system packages
- **Packages**: git, stow, zsh, tmux, curl, tree, jq, fd-find, ripgrep, fzf, build-essential, etc.
- **Neovim Dependencies**: fd-find (file finding), ripgrep (text search), build-essential (compilation)
- **Fuzzy Finding**: fzf with shell integration (Ctrl+R history, Ctrl+T files, Alt+C directories)
- **Idempotency**: Checks if packages are already installed

### Shell Environment
- **Location**: `scripts/shell/zsh-setup.sh`
- **Function**: Sets up Zsh with Oh My Zsh and plugins
- **Includes**: 
  - Oh My Zsh framework
  - zsh-autosuggestions plugin
  - zsh-syntax-highlighting plugin  
  - Powerlevel10k theme
- **Idempotency**: Skips installation if already present

### Development Tools

#### Node.js Environment
- **Location**: `scripts/development/node.sh`
- **Function**: Installs fnm (Fast Node Manager) and latest LTS Node.js
- **Features**: Automatic version management with `.nvmrc` support

#### PHP Development
- **Location**: `scripts/development/php.sh` 
- **Function**: Complete PHP 8.4 + Laravel development environment
- **Includes**: PHP 8.4, Composer, Laravel Sail
- **Extensions**: All Laravel-required PHP extensions

#### VSCode Setup
- **Location**: `scripts/development/vscode.sh`
- **Function**: Installs VSCode extensions from platform-specific lists
- **Lists**: `applications/vscode/extensions.{linux,windows}`

#### LazyGit Setup
- **Location**: `scripts/development/lazygit.sh`
- **Function**: Installs LazyGit from GitHub releases (not in Ubuntu repos)
- **Features**: Git TUI used by Neovim configuration
- **Version**: Automatically installs pinned stable version

#### WordPress WSL Dependencies
- **Location**: `scripts/development/wordpress-wsl.sh`
- **Function**: Installs all dependencies for Local WP to work in WSL2/Ubuntu
- **Source**: Based on [Medium article](https://medium.com/@echernicky/setting-up-a-local-wp-wsl-ubuntu-environment-9e7bdc6e9dbd)
- **Dependencies**: libtinfo5, libncurses5, libaio1, libnss3-tools, libasound2t64, libnuma1, policykit-1, libgbm-dev, xdg-utils, wslu
- **Features**: 
  - Automatic WSL detection (only runs in WSL environments)
  - Browser integration setup for opening sites from WSL
  - Idempotent installation of all required packages
  - Comprehensive setup instructions for Local WP

### Configuration Management

#### Template System
Sensitive configurations use templates with environment file substitution:

```bash
# configs/git/.gitconfig.template
[user]
  name = {{GIT_NAME}}
  email = {{GIT_EMAIL}}
  signingkey = {{GIT_SIGNING_KEY}}
```

#### Environment Files
- **Purpose**: Store sensitive data outside of git
- **Pattern**: `*.example` files are committed, actual `.*` files are gitignored
- **Usage**: Copy example, fill in details, templates are populated automatically

## 🔄 Idempotency Features

Every component is designed to be run multiple times safely:

### Package Installation
- Checks if packages are already installed before attempting installation
- Uses `dpkg -l` to verify package status

### Development Tools
- **fnm**: Checks if already installed via `command -v fnm`
- **Node.js**: Only installs if no Node.js is present
- **PHP**: Checks for PHP 8.4 specifically
- **Composer**: Updates if already present, installs if missing
- **VSCode Extensions**: Uses `code --list-extensions` to check existing

### Stow Operations
- Unstows before stowing to handle conflicts cleanly
- Safe to re-run even with existing symlinks

### Shell Configuration
- Oh My Zsh: Checks for `~/.oh-my-zsh` directory
- Plugins: Checks for plugin directories before cloning
- Theme: Checks for Powerlevel10k directory

## 🛠️ Adding New Dependencies

### Adding System Packages
1. Edit `scripts/system/packages.sh`
2. Add package to the `packages` array
3. Run `./install.sh` - completely safe!

Example:
```bash
packages=(
  # ... existing packages ...
  "htop"        # Add new package
  "neofetch"    # Add another
)
```

### Adding New Development Tools
1. Create new script in `scripts/development/`
2. Make it idempotent (check before installing)
3. Add to desired profiles
4. Test by running installer

### Adding New Configurations
1. Add dotfiles to appropriate `configs/` subdirectory
2. Add directory to profile `CONFIGS` array
3. Use templates for sensitive data

## 🔐 Security & Privacy

### Gitignored Files
```gitignore
# SSH connections (contains sensitive IPs and usernames)
configs/development/.env.ssh-connections

# Git configuration (contains personal details)  
configs/git/.env.git

# GPG public key (contains personal details)
gpg-public-key.txt
```

### Template Variables
- `{{GIT_NAME}}` - Your full name
- `{{GIT_EMAIL}}` - Your email address  
- `{{GIT_SIGNING_KEY}}` - Your GPG signing key

### Best Practices
- Never commit actual environment files
- Always provide `.example` files with placeholder data
- Use descriptive variable names in templates
- Document required environment variables

## 🧪 Testing & Validation

### Testing New Components
1. Test individual scripts in isolation
2. Test profile installation on clean system
3. Verify idempotency by running twice
4. Check for conflicts with existing configurations

### Validation Checklist
- [ ] Scripts are executable (`chmod +x`)
- [ ] Idempotency checks are present
- [ ] Error handling is implemented
- [ ] Success/failure messages are clear
- [ ] No hardcoded paths or sensitive data

## 🎯 Environment-Specific Features

### WSL/Windows Support
- Windows-specific configurations in `applications/windows/`
- WSL config file management
- Platform-specific extension lists for VSCode

### Server Optimizations
- Minimal profile excludes GUI applications
- Headless-friendly package selection
- Optional components clearly marked

## 📝 Configuration Files Reference

### Shell Configuration (`.zshrc`)
- **Location**: `configs/shell-zsh/.zshrc`
- **Features**: 
  - Powerlevel10k theme integration
  - fnm (Node.js) PATH management
  - Neovim (/opt/nvim/bin) PATH management
  - Composer global bin PATH
  - Laravel Sail alias
  - fzf shell integration (Ctrl+R, Ctrl+T, Alt+C)
  - SSH connections integration
  - Plugin configuration

### Git Configuration
- **Template**: `configs/git/.gitconfig.template`
- **Features**:
  - GPG signing enabled
  - Default branch: main
  - Rebase on pull
  - Auto-setup rebase for branches

### SSH Connections
- **Location**: `configs/development/.ssh-connections`
- **Features**:
  - Environment file-based configuration
  - Alias generation for quick connections
  - Support for custom SSH options

## 🤝 Contributing

### Adding New Profiles
1. Create new `.conf` file in `profiles/`
2. Define `PROFILE_NAME`, `PROFILE_DESCRIPTION`
3. Specify `SCRIPTS`, `CONFIGS`, and optionally `APPLICATIONS` arrays
4. Test thoroughly

### Adding New Scripts
1. Follow the established patterns for idempotency
2. Use consistent logging (`log_info`, `log_success`, etc.)
3. Handle errors gracefully
4. Document any environment requirements

### Improving Existing Components
1. Maintain backward compatibility
2. Preserve idempotency
3. Update documentation
4. Test across different Ubuntu versions

## 🚨 Troubleshooting

### Common Issues

**Stow Conflicts**
```bash
# Manual unstow before fixing
stow -D configs/shell-zsh
# Fix conflicts, then re-stow
stow -S configs/shell-zsh
```

**Missing Environment Files**
```bash
# Git config
cp configs/git/env.git.example configs/git/.env.git
# Edit with your details

# SSH connections (optional)
cp configs/development/.env.ssh-connections.example configs/development/.env.ssh-connections
```

**Permission Issues**
```bash
# Make scripts executable
chmod +x scripts/**/*.sh
```

### Getting Help
1. Check the installer output for specific error messages
2. Verify environment files are properly configured
3. Ensure you're running from the dotfiles directory
4. Check individual script execution with bash -x

---

## 📊 System Requirements

- **OS**: Ubuntu 20.04+ (may work on other Debian-based systems)
- **Dependencies**: None (installer will install required packages)
- **Disk Space**: ~500MB for full installation with all development tools
- **Network**: Internet connection required for downloading packages and tools

This dotfiles system represents a complete, production-ready solution for managing development environments across multiple machines and installations. The modular, idempotent design ensures reliability while the template system maintains security for public repositories.
