# Dotfiles - Enhanced Stow-Compatible Setup

A completely idempotent, modular dotfiles management system built with **full GNU Stow compatibility**. This enhanced setup provides true stow package isolation, improved organization, and better maintainability while maintaining all existing functionality.

## 🏗️ Architecture Overview

This dotfiles system is built around five core principles:

1. **Full Stow Compatibility** - Pure stow packages with clean separation
2. **Idempotency** - Run multiple times safely without conflicts
3. **Modularity** - Choose exactly what you need via profiles
4. **Security** - Template-based configs for sensitive data
5. **Maintainability** - Clear separation of concerns and enhanced organization

## 📁 Enhanced Directory Structure

```
dotfiles/
├── install.sh                     # Enhanced main installer
├── stow/                          # Pure stow packages → $HOME
│   ├── zsh/                       # Shell configuration
│   │   ├── .zshrc                 # Complete Zsh config with PATH management
│   │   └── .p10k.zsh             # Powerlevel10k theme config
# Git configuration is applied directly via git config --global (not stowed)
│   ├── terminal/                  # Terminal appearance
│   │   └── .dir_colors           # Custom ls colors
│   ├── shell/                     # Shell configuration extensions
│   │   └── .config/env-files/    # Environment configuration files
│   │       ├── .gitkeep          # Directory structure keeper
│   │       └── .ssh-connections  # SSH connections config (generated, gitignored)
│   ├── tmux/                      # tmux configuration (from nikolovlazar)
│   │   └── .config/tmux/
│   │       ├── tmux.conf         # Always latest from nikolovlazar/dotfiles
│   │       ├── switch-catppuccin-theme.sh
│   │       └── hooks/
│   │           └── update-pane-status.sh
│   ├── nvim/                      # Neovim configuration (from nikolovlazar)
│   │   └── .config/nvim/         # Proper XDG structure, latest from nikolovlazar/dotfiles
│   ├── vscode/                    # VSCode configuration (XDG compliant)
│   │   └── .config/Code/User/
│   │       └── settings.json     # VSCode settings
│   └── windows/                   # Windows-specific configs
│       └── AppData/Local/Packages/Microsoft.WindowsSubsystemForLinux_*/LocalState/
│           └── .wslconfig        # WSL configuration
│
├── support/                       # Non-stowed support files
│   ├── templates/                 # Configuration templates
│   │   └── .ssh-connections.template  # SSH connections template (simple examples)
│   ├── examples/                  # Example environment files
│   │   └── (reserved for future examples)
│   ├── data/                      # Application data
│   │   ├── extensions.linux      # VSCode extensions for Linux
│   │   └── extensions.windows    # VSCode extensions for Windows
│   └── utils/                     # Utility scripts
│       ├── ssh-connections.sh    # SSH connection manager utility
│       └── .gitkeep              # Directory structure keeper
│
├── scripts/                       # Installation scripts (enhanced)
│   ├── system/
│   │   ├── packages.sh           # Idempotent package installation
│   │   └── generate-configs.sh   # Enhanced template processor
│   ├── security/
│   │   ├── ssh-keys.sh          # SSH key generation and agent setup
│   │   └── gpg-keys.sh          # GPG key generation and git config
│   ├── development/
│   │   ├── node.sh              # Node.js/fnm setup
│   │   ├── php.sh               # PHP 8.4/Laravel setup
│   │   ├── neovim.sh              # Neovim installation + config from nikolovlazar/dotfiles
│   │   ├── tmux.sh              # Latest config from nikolovlazar/dotfiles → stow/tmux/
│   │   ├── lazygit.sh           # LazyGit installation from GitHub releases
│   │   ├── wordpress-wsl.sh     # WordPress Local WP dependencies for WSL2
│   │   └── vscode.sh            # Enhanced VSCode extensions installer
│   └── shell/
│       └── zsh-setup.sh         # Zsh + Oh My Zsh + plugins
│
└── profiles/                      # Installation profiles (updated for stow packages)
    ├── minimal.conf              # Essential tools only
    ├── development.conf          # Full dev environment
    ├── full.conf                # Everything including PHP
    ├── wordpress.conf           # WordPress development setup
    └── server.conf              # Headless server setup
```

## 🚀 Quick Start

### Fresh Ubuntu Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Run the installer (automatically installs gum for beautiful UI)
./install.sh
```

### Automatic Setup

The installer now includes **intelligent initial setup** and **beautiful terminal UI** that:

- ✅ **Auto-detects existing GPG keys** and extracts your name/email
- ✅ **Auto-configures git globally** with proper signing
- ✅ **Handles SSH/GPG key generation** if needed
- ✅ **Direct configuration** - no intermediate environment files needed
- ✅ **Beautiful UI** - Powered by [Charm's gum](https://github.com/charmbracelet/gum) for interactive prompts and styled output
- ✅ **Smart fallbacks** - Works with or without gum for maximum compatibility

Simply run:

```bash
./install.sh
```

The installer will automatically:

1. **Install gum** for beautiful terminal UI (if not already available)
2. **Present interactive profile selection** with styled choosers
3. **Show progress** with colored, emoji-enhanced logging
4. **Guide you through** component selection with intuitive prompts

**Manual Configuration** (only if auto-detection fails):

```bash
# Git configuration (if auto-detection fails)
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
git config --global user.signingkey "YOUR_GPG_KEY_ID"

# SSH connections (optional)
./scripts/system/generate-configs.sh  # Generate SSH template
stow -d stow -t $HOME shell           # Deploy config
nano ~/.config/env-files/.ssh-connections  # Add your servers
```

## 🎯 Key Enhancements

### 1. **Beautiful Terminal UI with Gum Integration**

Experience installation with a modern, interactive interface:

- **🎨 Styled Output**: Colored, emoji-enhanced logging with gum's beautiful formatting
- **✨ Interactive Prompts**: Gum-powered confirmation dialogs and choosers
- **📋 Smart Profile Selection**: Visual menu for choosing installation profiles
- **🔄 Progress Indicators**: Clear feedback during installation steps
- **🛡️ Graceful Fallbacks**: Automatically falls back to basic logging if gum unavailable

```bash
# The installer automatically sets up gum and provides:
✅ Success messages in green with checkmarks
ℹ️ Info messages in blue with icons
⚠️ Warnings in yellow with alerts
❌ Errors in red with clear indicators
🎯 Interactive profile chooser
🤔 Yes/No confirmations with visual buttons
```

### 2. **Full GNU Stow Compatibility**

Each package in `stow/` can be managed independently:

```bash
# Install specific packages
stow -d stow -t $HOME zsh terminal

# Install development environment
stow -d stow -t $HOME zsh tmux nvim ssh vscode

# Install everything
stow -d stow -t $HOME */

# Remove specific package
stow -d stow -t $HOME -D nvim

# Replace/update package
stow -d stow -t $HOME -R zsh
```

### 3. **Simplified Configuration System**

- **Templates**: `support/templates/` - Configuration templates with placeholders
- **Git Configuration**: Auto-detected from GPG and applied directly via `git config --global`
- **SSH Configuration**: Utility script + generated config files in `~/.config/env-files/`
- **Environment Files**: Secure, gitignored configs deployed via `stow/shell/`

```bash
# Configuration workflow
./install.sh                          # Auto-detects GPG and applies git config globally
./scripts/system/generate-configs.sh  # Generate SSH connections template
stow -d stow -t $HOME shell           # Deploy shell configs including env-files
# Edit ~/.config/env-files/.ssh-connections to add your servers
# SSH functions (ssh-to, ssh-reload) available via zshrc
```

### 4. **XDG Base Directory Compliance**

- **VSCode**: `~/.config/Code/User/settings.json`
- **Neovim**: `~/.config/nvim/`
- **Proper application data organization**
- **Cross-platform path handling**

### 5. **Enhanced Organization**

- **Pure Stow Packages**: Only actual dotfiles in `stow/`
- **Support Files**: Templates, examples, data, and utilities separated
- **No Mixed Content**: Clean separation of concerns
- **Independent Packages**: Each stow package stands alone

## 📋 Installation Profiles

| Profile         | Description           | Stow Packages                       |
| --------------- | --------------------- | ----------------------------------- |
| **Minimal**     | Essential tools only  | `zsh`, `terminal`                   |
| **Development** | Web development setup | + `shell`, `tmux`, `nvim`, `vscode` |
| **WordPress**   | WordPress development | + `shell`, `tmux`, `nvim`, `vscode` |
| **Full**        | Complete environment  | + `shell`, `tmux`, `nvim`, `vscode` |
| **Server**      | Headless server setup | `zsh`, `terminal`, `shell`          |
| **Custom**      | Interactive selection | Pick & choose                       |

### Enhanced Profile Configuration

Each profile now uses pure stow package references:

```bash
# Example: profiles/development.conf
PROFILE_NAME="Development"
PROFILE_DESCRIPTION="Complete development environment with Node.js, Neovim, tmux, and VSCode"

# Scripts to run (unchanged)
SCRIPTS=(
  "scripts/system/packages.sh"
  "scripts/system/generate-configs.sh"
  "scripts/shell/zsh-setup.sh"
  "scripts/security/ssh-keys.sh"
  "scripts/security/gpg-keys.sh"
  "scripts/development/node.sh"
  "scripts/development/neovim.sh"

  "scripts/development/tmux.sh"
  "scripts/development/lazygit.sh"
  "scripts/development/vscode.sh"
)

# Pure stow packages (enhanced)
CONFIGS=(
  "stow/zsh"
  "stow/terminal"
  "stow/shell"
  "stow/tmux"
  "stow/nvim"
  "stow/vscode"
)
# Note: Git configuration is applied directly via git config --global
```

## 🔐 Enhanced Security Features

### Direct Git Configuration

Git configuration is now handled directly without intermediate files:

- **Auto-Detection**: Extracts name/email from existing GPG keys
- **Direct Application**: Uses `git config --global` commands immediately
- **No Intermediate Files**: No `.env.git` files needed
- **Secure**: No sensitive data in plain text files

### SSH Connection System

SSH connections use a utility script + config file approach:

- **Utility**: `support/utils/ssh-connections.sh` - Functions for `ssh-to`, `ssh-reload`, tab completion
- **Template**: `support/templates/.ssh-connections.template` - Simple examples (localhost, etc.)
- **Config**: `~/.config/env-files/.ssh-connections` - User's actual connections (gitignored)
- **Integration**: Sourced automatically via `.zshrc`, deployed via `stow/shell/`

### SSH Key & GPG Management

- **SSH Keys**: ed25519 generation with agent integration
- **GPG Keys**: 4096-bit RSA for commit signing
- **Automation**: Batch generation with git integration
- **Idempotency**: Detects and preserves existing keys

## 🔄 Always Up-to-Date External Configurations

### tmux Configuration

- **Source**: [nikolovlazar/dotfiles](https://github.com/nikolovlazar/dotfiles/tree/main/.config/tmux)
- **Target**: `stow/tmux/.config/tmux/` (XDG-compliant)
- **Structure**: Matches nikolovlazar's repo structure with hooks and utilities
- **Update Method**: Downloads latest on every run

### Neovim Configuration

- **Source**: [nikolovlazar/dotfiles](https://github.com/nikolovlazar/dotfiles/tree/main/.config/nvim)
- **Target**: `stow/nvim/.config/nvim/`
- **Method**: Git sparse-checkout with proper XDG structure
- **Features**: Complete LazyVim setup with modern plugins

## 🔧 Core Components

### Enhanced Template Generation

- **Location**: `scripts/system/generate-configs.sh`
- **Function**: Processes templates from `support/templates/` using environment files
- **Output**: Places generated configs in appropriate `stow/` packages
- **Variables**: Supports Git, SSH, and custom placeholder expansion

### Development Tools Setup

#### VSCode Integration

- **Extensions**: Platform-specific lists in `support/data/extensions.{linux,windows}`
- **Settings**: XDG-compliant deployment via `stow/vscode/.config/Code/User/`
- **Cross-Platform**: Automatic platform detection

#### External Configuration Management

- **tmux**: Auto-downloads latest config to `stow/tmux/`
- **Neovim**: Sparse-checkout to `stow/nvim/.config/nvim/`
- **Utilities**: Theme switchers and tools to `support/utils/`

### System Package Management

- **Idempotent Installation**: Checks existing packages before installation
- **Neovim Dependencies**: fd-find, ripgrep, build-essential
- **Development Tools**: Node.js (via fnm), PHP 8.4, Composer, LazyGit
- **Shell Environment**: Zsh, Oh My Zsh, plugins, Powerlevel10k

## 🔄 Enhanced Idempotency

Every component is designed for safe repeated execution:

### Stow Operations

```bash
# Enhanced stowing with conflict resolution
stow -d stow -t $HOME -D package_name 2>/dev/null || true  # Unstow first
stow -d stow -t $HOME -S package_name                     # Then stow
```

### Template Generation

- Checks for environment files before processing
- Skips generation if environment files missing
- Overwrites existing generated configs safely

### Development Tools

- **Detection**: Uses `command -v` and version checking
- **Updates**: Handles existing installations gracefully
- **Extensions**: Checks installed VSCode extensions before installing

## 🛠️ Adding New Components

### Adding New Stow Packages

1. **Create package directory**:

   ```bash
   mkdir -p stow/my-new-package
   ```

2. **Add configuration files**:

   ```bash
   # Add dotfiles with proper home structure
   stow/my-new-package/.my-config
   stow/my-new-package/.config/my-app/settings.json
   ```

3. **Update profiles**:

   ```bash
   # Add to desired profiles' CONFIGS array
   CONFIGS=(
     # ... existing packages ...
     "stow/my-new-package"
   )
   ```

4. **Test deployment**:
   ```bash
   stow -d stow -t $HOME my-new-package
   ```

### Adding Templates

1. **Create template**:

   ```bash
   # support/templates/.my-config.template
   api_key = {{MY_API_KEY}}
   username = {{MY_USERNAME}}
   ```

2. **Create example**:

   ```bash
   # support/examples/env.my-config.example
   MY_API_KEY=your_api_key_here
   MY_USERNAME=your_username_here
   ```

3. **Update generator**:
   ```bash
   # Add to scripts/system/generate-configs.sh
   if [[ -f "support/templates/.my-config.template" ]]; then
     mkdir -p "stow/my-package"
     generate_config "support/templates/.my-config.template" ".env.my-config" "stow/my-package/.my-config"
   fi
   ```

## 🔐 Security & Privacy

### Gitignored Files

```gitignore
# Generated SSH connections config (contains sensitive data)
stow/shell/.config/env-files/.ssh-connections

# Public keys (contain personal details)
github-public-keys.txt

# Any local customizations
local/
```

### Template Variables

- **SSH**: `{{SSH_HOST}}`, `{{SSH_USER}}`, `{{SSH_PORT}}`
- **Custom**: Add your own variables to templates and generation script

**Note**: Git configuration is now handled directly via `git config --global` commands, no template variables needed.

### Best Practices

- Always provide `.example` files for sensitive configurations
- Use descriptive placeholder names in templates
- Keep environment files in project root (gitignored)
- Document required variables in template comments

## 🧪 Testing & Validation

### Testing Stow Packages

```bash
# Test individual packages
stow -d stow -t $HOME -n -S package_name  # Dry run (-n flag)
stow -d stow -t $HOME -v -S package_name  # Verbose output

# Test conflicts
stow -d stow -t $HOME -S package_name 2>&1 | grep -i conflict
```

### Validation Checklist

- [ ] ✅ All files in `stow/` packages are actual dotfiles
- [ ] ✅ Templates are in `support/templates/`
- [ ] ✅ Examples are in `support/examples/`
- [ ] ✅ Data files are in `support/data/`
- [ ] ✅ Each stow package can be deployed independently
- [ ] ✅ XDG directory structure is correct
- [ ] ✅ No mixed content in stow packages

## 🎯 Cross-Platform Support

### Windows/WSL Integration

- **WSL Config**: Platform-specific configurations handled automatically
- **Platform Detection**: Automatic Windows package inclusion
- **Extensions**: Platform-specific VSCode extension lists

### Server Optimization

- **Minimal Profile**: Excludes GUI applications
- **Headless Support**: No desktop-specific configurations
- **Essential Tools**: Focus on shell, git, and SSH tools

## 📝 Configuration Files Reference

### Enhanced Shell Configuration

- **Location**: `stow/zsh/.zshrc`
- **Deployment**: `stow -d stow -t $HOME zsh`
- **Features**: Powerlevel10k, fnm, Neovim paths, fzf integration, SSH connections

### Configuration Management

- **Git Config**: Auto-detected from GPG keys and applied directly via `git config --global`
- **SSH Connections**: Utility script + config in `~/.config/env-files/.ssh-connections`
- **Public Keys**: Both SSH and GPG keys exported to `github-public-keys.txt` with copy tags
- **Deployment**: Shell package via `stow -d stow -t $HOME shell`, Git applied directly

## 🚨 Enhanced Troubleshooting

### Stow Conflicts

```bash
# Check for conflicts
stow -d stow -t $HOME -n -S package_name

# Manual conflict resolution
stow -d stow -t $HOME -D package_name  # Unstow
rm $HOME/.conflicting-file             # Remove conflict
stow -d stow -t $HOME -S package_name  # Restow

# Force adoption (use with caution)
stow -d stow -t $HOME --adopt -S package_name
```

### Git Configuration Issues

```bash
# Manual git configuration if auto-detection fails
git config --global user.name "Your Full Name"
git config --global user.email "your.email@example.com"
git config --global user.signingkey "YOUR_GPG_KEY_ID"
git config --global commit.gpgsign true

# Check current git configuration
git config --global --list | grep user
```

### SSH Connection Setup

```bash
# Generate SSH connections template
./scripts/system/generate-configs.sh  # Creates template in stow/shell/.config/env-files/
stow -d stow -t $HOME shell           # Deploy to ~/.config/env-files/
nano ~/.config/env-files/.ssh-connections  # Edit to add your servers

# Usage (automatically available after sourcing .zshrc)
ssh-to localhost                      # Connect to defined servers
ssh-to                               # List all available connections
ssh-reload                           # Reload connections after editing
```

### Template Generation Issues

```bash
# Check template processing
bash -x ./scripts/system/generate-configs.sh

# Verify SSH connections file
cat ~/.config/env-files/.ssh-connections  # Check content
```

### Stow Package Verification

```bash
# Check package structure
find stow/package_name -type f

# Test stow simulation
stow -d stow -t /tmp/test_home -n -S package_name
```

## 📊 System Requirements

- **OS**: Ubuntu 20.04+ (tested on Ubuntu 22.04/24.04)
- **Dependencies**: None (installer automatically installs required packages including `stow` and `gum`)
- **Disk Space**: ~500MB for full installation
- **Network**: Internet connection for external configs and packages
- **Terminal**: Any modern terminal (enhanced experience with color support)

## 🎯 Benefits Summary

### For Users

- **Beautiful Interface**: Modern, interactive terminal UI powered by gum
- **True Stow Compatibility**: Standard GNU Stow commands work perfectly
- **Enhanced Security**: Template system prevents credential exposure
- **Better Organization**: Clear separation of configs, templates, and data
- **Cross-Platform**: Proper Windows and Linux support
- **Intuitive Experience**: Visual prompts and clear progress indicators

### For Developers/AI

- **Clear Structure**: Well-defined purposes for each directory
- **Easy Extension**: Adding new packages follows established patterns
- **Maintainable**: Template system and idempotent scripts
- **Testable**: Each stow package can be tested independently

This enhanced dotfiles system provides a production-ready solution with true GNU Stow compatibility, improved security through templates, better organization for long-term maintainability, and a beautiful terminal interface powered by gum. The modular design ensures reliability while supporting both simple and complex development environments with an intuitive, modern user experience.
