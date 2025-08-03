# 🤖 Agent Guidelines for Kito's Dotfiles

This document provides essential guidelines for AI assistants working on this dotfiles repository. Following these rules ensures consistency, maintainability, and compatibility with the existing system architecture.

## 🎯 Core Principles

### 1. **Always Use Gum Functions for Interactivity**

**MANDATORY**: All scripts MUST use the standardized gum functions from `support/utils/gum-logger.sh` for any user interaction or logging.

#### ✅ Correct Usage

```bash
# Source the gum logger first
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

# Use standardized logging functions
log_info "Installing packages..."
log_success "Installation completed!"
log_warning "Some packages might need attention"
log_error "Installation failed"
log_debug "Debug information (only shown if DEBUG=1)"

# Use gum-based interactive prompts
if prompt_confirm "Do you want to install VSCode extensions?"; then
    install_vscode_extensions
fi

# Use gum choosers for options
profile=$(prompt_choose "Select installation profile:" "minimal" "development" "full")

# Use gum input for user data
username=$(prompt_input "Enter your username" "your-username")
```

#### ❌ Incorrect Usage

```bash
# DON'T use raw echo for logging
echo "Installing packages..."

# DON'T use basic read for prompts
read -p "Do you want to continue? (y/n): " answer

# DON'T use select for menus
select option in "option1" "option2"; do
    # ...
done
```

#### Available Gum Functions

- **Logging**: `log_info`, `log_success`, `log_warning`, `log_error`, `log_debug`, `log_progress`
- **Headers**: `log_header`, `log_step`, `log_fatal`
- **Interactive**: `prompt_confirm`, `prompt_choose`, `prompt_input`
- **Visual**: `show_progress`, `show_file_tree`, `show_banner`

### 2. **Maintain Pure Stow Package Structure**

- **Only dotfiles** belong in `stow/` directories
- **No scripts, templates, or utilities** in stow packages
- Each stow package must be **independently deployable**
- Follow **XDG Base Directory specification** where applicable

```bash
# ✅ Correct stow package structure
stow/my-package/
├── .config/my-app/settings.json    # XDG config
├── .my-dotfile                     # Traditional dotfile
└── .local/bin/my-script            # XDG local binaries

# ❌ Incorrect - no non-dotfiles in stow packages
stow/my-package/
├── install.sh                      # Scripts don't belong here
├── README.md                       # Documentation doesn't belong here
└── templates/                      # Templates belong in support/
```

### 3. **Follow Idempotent Design Patterns**

All scripts and operations must be **safely repeatable**:

```bash
# ✅ Always check before installing
if ! command -v tool >/dev/null 2>&1; then
    log_info "Installing tool..."
    install_tool
else
    log_success "tool already installed"
fi

# ✅ Safe stow operations
stow -d stow -t $HOME -D package_name 2>/dev/null || true
stow -d stow -t $HOME -S package_name

# ✅ Check for existing repositories
if [[ ! -f /etc/apt/sources.list.d/repo.list ]]; then
    setup_repository
fi
```

## 📁 Directory Structure Rules

### Location Guidelines

| Content Type             | Location             | Purpose                                    |
| ------------------------ | -------------------- | ------------------------------------------ |
| **Actual dotfiles**      | `stow/`              | Pure stow packages for home directory      |
| **Templates**            | `support/templates/` | Configuration templates with placeholders  |
| **Examples**             | `support/examples/`  | Example configurations                     |
| **Utilities**            | `support/utils/`     | Helper scripts and functions               |
| **Data**                 | `support/data/`      | Application data (extensions, lists, etc.) |
| **Installation scripts** | `scripts/`           | Categorized installation scripts           |
| **Profiles**             | `profiles/`          | Installation profile configurations        |

### When Adding New Components

1. **New Stow Package**: Create in `stow/package-name/`
2. **New Script**: Add to appropriate `scripts/category/`
3. **New Template**: Add to `support/templates/`
4. **New Utility**: Add to `support/utils/`

## 🔧 Script Development Rules

### 1. **Script Structure Template**

```bash
#!/usr/bin/env bash

# Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "📦 Your Script Description"

# Function definitions
function_name() {
    # Implementation
}

# Main execution
log_info "Starting process..."

# Your logic here

log_success "Process completed!"
```

### 2. **Error Handling**

```bash
# Use set -e for exit on error
set -e

# Use log_fatal for critical errors
if [[ ! -f required_file ]]; then
    log_fatal "Required file not found"
fi

# Use proper error checking
if ! command_that_might_fail; then
    log_error "Command failed, but continuing..."
    return 1
fi
```

### 3. **Package Installation Patterns**

```bash
# Function to check if package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to install package if not already installed
install_package() {
    if is_package_installed "$1"; then
        log_success "$1 already installed"
    else
        log_info "Installing $1..."
        sudo apt install -y "$1"
    fi
}
```

## 🔐 Security & Privacy Rules

### 1. **Sensitive Data Handling**

- **Never** commit sensitive data to the repository
- Use **templates** with placeholders for configurations containing secrets
- Generate actual configs in user's `~/.config/env-files/` (gitignored)
- Apply git configuration **directly** via `git config --global` commands

### 2. **Template System**

```bash
# ✅ Create templates in support/templates/
# support/templates/.my-config.template
api_key = {{MY_API_KEY}}
username = {{MY_USERNAME}}

# Generate actual config from template
generate_config() {
    local template="$1"
    local env_file="$2"
    local output="$3"

    if [[ -f "$env_file" ]]; then
        envsubst < "$template" > "$output"
    fi
}
```

## 📋 Profile Management Rules

### 1. **Profile Structure**

```bash
# profiles/my-profile.conf
PROFILE_NAME="My Profile"
PROFILE_DESCRIPTION="Description of what this profile includes"

# Scripts to run (in order)
SCRIPTS=(
    "scripts/system/packages.sh"
    "scripts/category/my-script.sh"
)

# Pure stow packages to deploy
CONFIGS=(
    "stow/zsh"
    "stow/my-package"
)
```

### 2. **Profile Categories**

- **minimal**: Essential tools only
- **development**: Full development environment
- **server**: Headless server setup
- **custom**: Special-purpose configurations

## 🧪 Testing & Validation Rules

### 1. **Before Committing**

```bash
# Test stow packages individually
stow -d stow -t /tmp/test_home -n -S package_name  # Dry run

# Validate script syntax
bash -n script_name.sh

# Test idempotency
./script_name.sh  # Run twice, should work both times
```

### 2. **Quality Checklist**

- [ ] Uses gum functions for all interactivity
- [ ] Script is idempotent (safe to run multiple times)
- [ ] Proper error handling with meaningful messages
- [ ] No sensitive data in repository
- [ ] Follows directory structure conventions
- [ ] Stow packages contain only dotfiles
- [ ] XDG compliance where applicable

## 🚀 External Tool Integration Rules

### 1. **Adding New Repositories**

```bash
# Follow the pattern from rust-tools setup
setup_my_repo() {
    if [[ -f /etc/apt/sources.list.d/my-repo.list ]]; then
        log_success "my-repo repository already configured"
        return 0
    fi

    log_info "Setting up my-repo repository..."

    # GPG key setup
    curl -fsSL https://example.com/pubkey.asc | sudo tee -a /usr/share/keyrings/my-repo.asc

    # Repository setup
    curl -fsSL https://example.com/repo.list | sudo tee /etc/apt/sources.list.d/my-repo.list

    sudo apt update
    log_success "my-repo repository configured successfully"
}
```

### 2. **External Configuration Management**

For configurations like tmux and neovim that come from external sources:

- Always fetch the **latest** version
- Place in appropriate `stow/` package structure
- Maintain **XDG compliance**
- Document the **source** in README.md

## 💡 Best Practices

### 1. **Code Style**

- Use **descriptive variable names**
- Add **comments** for complex logic
- **Indent consistently** (2 spaces)
- Use **double brackets** for conditionals: `[[ ]]`
- Quote **all variables**: `"$variable"`

### 2. **User Experience**

- **Progress indicators** for long operations
- **Clear success/error messages**
- **Consistent emoji** usage in logs
- **Graceful fallbacks** when tools aren't available

### 3. **Documentation**

- Update **README.md** when adding major features
- Add **comments** in profile configurations
- Document **required variables** in templates
- Include **usage examples** for utilities

## 🔄 Common Patterns

### Adding a New Development Tool

1. Create script in `scripts/development/tool-name.sh`
2. Use gum logging functions
3. Check for existing installation
4. Add to appropriate profiles
5. Update README.md if significant

### Adding Shell Integration

1. Add initialization to `stow/zsh/.zshrc`
2. Check if tool exists before initializing
3. Use consistent formatting and comments
4. Test across different shell sessions

### Adding Configuration Package

1. Create `stow/package-name/` directory
2. Add dotfiles with proper home structure
3. Test with `stow -n` (dry run)
4. Add to relevant profiles
5. Update documentation

## 🛠️ Development Workflow

1. **Always** source `support/utils/gum-logger.sh` in scripts
2. **Test locally** before committing
3. **Run install.sh** to verify integration
4. **Check idempotency** by running twice
5. **Validate** stow packages deploy correctly

---

**Remember**: This dotfiles system prioritizes consistency, security, and user experience. Always use the established patterns and gum-based UI for the best results! 🎯
