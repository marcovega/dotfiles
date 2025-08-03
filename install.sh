#!/usr/bin/env bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Initial Setup Functions - Smart Configuration Detection

# Function to detect and setup Git configuration
setup_git_config() {
  log_info "Setting up Git configuration..."
  
  # Check if git is already configured properly
  local current_name=$(git config --global user.name 2>/dev/null || echo "")
  local current_email=$(git config --global user.email 2>/dev/null || echo "")
  if [[ "$current_name" != "Your Full Name" && -n "$current_name" && -n "$current_email" && "$current_email" != "your.email@example.com" ]]; then
    log_success "Git already properly configured: $current_name <$current_email>"
    return 0
  fi
  
  # Auto-detect GPG key
  local gpg_key=""
  if command -v gpg >/dev/null 2>&1; then
    gpg_key=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "sec" | head -n1 | cut -d'/' -f2 | cut -d' ' -f1 || echo "")
  fi
  
  # Auto-detect git user info from existing global config
  local git_name=$(git config --global user.name 2>/dev/null || echo "")
  local git_email=$(git config --global user.email 2>/dev/null || echo "")
  
  # Filter out template values
  [[ "$git_name" == "Your Full Name" ]] && git_name=""
  [[ "$git_email" == "your.email@example.com" ]] && git_email=""
  
  # If we have a GPG key but no git info, try to extract from GPG
  if [[ -n "$gpg_key" && (-z "$git_name" || -z "$git_email") ]]; then
    local gpg_info=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "uid" | head -n1 | sed 's/uid.*\] //')
    if [[ -n "$gpg_info" ]]; then
      [[ -z "$git_name" ]] && git_name=$(echo "$gpg_info" | sed 's/ <.*$//')
      [[ -z "$git_email" ]] && git_email=$(echo "$gpg_info" | sed 's/.*<\(.*\)>.*/\1/')
    fi
  fi
  
  # Apply git configuration if we have the info
  if [[ -n "$git_name" && -n "$git_email" ]]; then
    log_info "Auto-detected Git configuration:"
    echo "  Name: $git_name"
    echo "  Email: $git_email"
    [[ -n "$gpg_key" ]] && echo "  GPG Key: $gpg_key"
    
    # Apply git configuration directly
    apply_git_config "$git_name" "$git_email" "$gpg_key"
    
  else
    log_warning "Could not auto-detect Git configuration"
    log_info "Please manually configure git:"
    echo "  git config --global user.name 'Your Full Name'"
    echo "  git config --global user.email 'your.email@example.com'"
    [[ -n "$gpg_key" ]] && echo "  git config --global user.signingkey '$gpg_key'"
    echo "  Then run this installer again"
    exit 1
  fi
}

# Function to check and setup SSH
check_ssh_setup() {
  log_info "Checking SSH setup..."
  
  if [[ -f "$HOME/.ssh/id_ed25519" || -f "$HOME/.ssh/id_rsa" ]]; then
    log_success "SSH keys already exist"
    
    # Ensure SSH agent is running and key is added
    if ! ssh-add -l >/dev/null 2>&1; then
      log_info "Starting SSH agent and adding keys..."
      eval "$(ssh-agent -s)" >/dev/null
      ssh-add ~/.ssh/id_* 2>/dev/null || true
    fi
  else
    log_info "SSH keys will be generated during installation"
  fi
}

# Function to check GPG setup
check_gpg_setup() {
  log_info "Checking GPG setup..."
  
  if gpg --list-secret-keys >/dev/null 2>&1; then
    log_success "GPG keys already exist"
  else
    log_info "GPG keys will be generated during installation"
  fi
}

# Function to apply git configuration directly (no file stowing)
apply_git_config() {
  local name="$1"
  local email="$2" 
  local gpg_key="$3"
  
  log_info "Applying git configuration globally..."
  
  # Ensure git config file exists
  touch "$HOME/.gitconfig"
  
  git config --global user.name "$name"
  git config --global user.email "$email"
  
  if [[ -n "$gpg_key" ]]; then
    git config --global user.signingkey "$gpg_key"
    git config --global commit.gpgsign true
  fi
  
  # Set other recommended git settings
  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global push.default current
  git config --global branch.autosetuprebase always
  
  log_success "Git configuration applied globally"
}

# Function to run initial smart setup
run_initial_setup() {
  log_info "🔧 Running initial smart setup..."
  echo ""
  
  # Create necessary directories
  # Note: stow packages are created as needed by individual scripts
  
  # Run setup functions
  setup_git_config
  check_ssh_setup  
  check_gpg_setup
  
  echo ""
  log_success "✅ Initial setup completed!"
  echo ""
}

# Function to display banner
show_banner() {
  echo -e "${BLUE}"
  echo "┌─────────────────────────────────────┐"
  echo "│         Dotfiles Installer         │"
  echo "│      Idempotent & Modular Setup    │"
  echo "└─────────────────────────────────────┘"
  echo -e "${NC}"
}

# Function to show available profiles
show_profiles() {
  echo ""
  log_info "Available installation profiles:"
  echo ""
  
  local profiles=(profiles/*.conf)
  local i=1
  
  for profile in "${profiles[@]}"; do
    if [[ -f "$profile" ]]; then
      local profile_name=$(basename "$profile" .conf)
      # Source the profile to get description
      source "$profile"
      echo "  $i) ${PROFILE_NAME} - ${PROFILE_DESCRIPTION}"
      ((i++))
    fi
  done
  
  echo "  $i) Custom - Choose individual components"
  echo ""
}

# Function to run installation scripts
run_scripts() {
  local scripts=("$@")
  
  for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
      log_info "Running $(basename "$script")..."
      chmod +x "$script"
      if ! "$script"; then
        log_error "Failed to run $script"
        exit 1
      fi
    else
      log_warning "Script not found: $script"
    fi
  done
}

# Function to aggressively clean conflicting files
aggressive_cleanup() {
  log_info "Pre-cleaning all potential conflicting files..."
  
  # Remove all known conflicting files (except .gitconfig - managed directly by git)
  rm -f "$HOME/.zshrc" "$HOME/.p10k.zsh" 2>/dev/null || true
  rm -f "$HOME/.dir_colors" 2>/dev/null || true
  rm -rf "$HOME/.config/tmux" 2>/dev/null || true
  rm -f "$HOME/.ssh-connections" 2>/dev/null || true
  rm -rf "$HOME/.config/nvim" 2>/dev/null || true
  rm -rf "$HOME/.config/Code" 2>/dev/null || true
  
  log_info "✅ Pre-cleanup completed - all conflicting files removed"
}

# Function to stow configurations
stow_configs() {
  local configs=("$@")
  
  # Always run aggressive cleanup first
  aggressive_cleanup
  
  log_info "Stowing configurations..."
  
  for config in "${configs[@]}"; do
    if [[ -d "$config" ]]; then
      local config_name=$(basename "$config")
      log_info "Stowing $config_name..."
      
      # All stow packages target $HOME with new structure
      local stow_target="$HOME"
      
      # Remove conflicting files/symlinks before stowing
      case "$config_name" in
        "zsh")
          # Force remove ALL zsh-related files/symlinks
          rm -f "$stow_target/.zshrc" "$stow_target/.p10k.zsh"
          log_info "Force removed .zshrc and .p10k.zsh (if they existed)"
          
          # Double-check they're gone
          if [[ -e "$stow_target/.zshrc" ]] || [[ -e "$stow_target/.p10k.zsh" ]]; then
            log_error "Failed to remove conflicting zsh files!"
            log_error "Please manually run: rm -f ~/.zshrc ~/.p10k.zsh"
            exit 1
          fi
          ;;
# git configuration is managed directly by git commands, not stowed
        "terminal")
          [[ -e "$stow_target/.dir_colors" ]] && rm -f "$stow_target/.dir_colors"
          log_info "Removed conflicting terminal files"
          ;;
        "tmux")
          [[ -e "$stow_target/.config/tmux" ]] && rm -rf "$stow_target/.config/tmux"
          log_info "Removed conflicting tmux files"
          ;;
        "nvim")
          [[ -e "$stow_target/.config/nvim" ]] && rm -rf "$stow_target/.config/nvim"
          log_info "Removed conflicting nvim files"
          ;;
        "ssh")
          [[ -e "$stow_target/.ssh-connections" ]] && rm -f "$stow_target/.ssh-connections"
          log_info "Removed conflicting SSH files"
          ;;
        "vscode")
          [[ -e "$stow_target/.config/Code" ]] && rm -rf "$stow_target/.config/Code"
          log_info "Removed conflicting VSCode files"
          ;;
        "windows")
          # Windows-specific cleanup would happen in Windows environment
          log_info "Windows config will be stowed"
          ;;
      esac
      
      # Unstow first to handle existing configs cleanly
      stow -v -d stow -t "$stow_target" -D "$config_name" 2>/dev/null || true
      
      # Verify cleanup worked for debugging
      if [[ "$config_name" == "zsh" ]]; then
        if [[ -e "$stow_target/.zshrc" ]] || [[ -e "$stow_target/.p10k.zsh" ]]; then
          log_warning "Some zsh files still exist after cleanup:"
          ls -la "$stow_target"/.zshrc "$stow_target"/.p10k.zsh 2>/dev/null || true
        else
          log_info "Cleanup verification: zsh files successfully removed"
        fi
      fi
      
      # Then stow
      if stow -v -d stow -t "$stow_target" -S "$config_name"; then
        log_success "✓ $config_name stowed successfully to $stow_target"
      else
        log_error "Failed to stow $config"
        exit 1
      fi
    else
      log_warning "Config directory not found: $config"
    fi
  done
}

# Function to setup applications (DEPRECATED - now handled by stow)
setup_applications() {
  local applications=("$@")
  
  if [[ ${#applications[@]} -gt 0 ]]; then
    log_info "Applications are now handled by stow packages - skipping special application setup"
    log_info "VSCode configs are now in stow/vscode"
  fi
}

# Function to handle environment files
setup_environment_files() {
  log_info "Checking environment files..."
  
  # SSH connections environment
  if [[ ! -f ".env.ssh" ]] && [[ -f "support/examples/env.ssh.example" ]]; then
    log_info "SSH connections environment file not found (optional)"
    echo "💡 Tip: For SSH shortcuts, copy and customize:"
    echo "   cp support/examples/env.ssh.example .env.ssh"
  fi
}

# Function to run custom installation
run_custom_installation() {
  log_info "Custom installation mode"
  echo ""
  
  # Ask about each component
  local selected_scripts=()
  local selected_configs=()
  local selected_applications=()
  
  # System packages
  if read -p "Install system packages? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/system/packages.sh")
    selected_scripts+=("scripts/system/generate-configs.sh")
  fi
  echo ""
  
  # Security (SSH/GPG keys)
  if read -p "Setup SSH and GPG keys? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/security/ssh-keys.sh")
    selected_scripts+=("scripts/security/gpg-keys.sh")
  fi
  echo ""
  
  # Shell setup
  if read -p "Setup Zsh environment? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/shell/zsh-setup.sh")
    selected_configs+=("stow/zsh")
  fi
  echo ""
  
  # Git
  if read -p "Setup Git configuration? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
# Git configuration is applied automatically during initial setup
  fi
  echo ""
  
  # Terminal colors
  if read -p "Setup terminal colors? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_configs+=("stow/terminal")
  fi
  echo ""
  
  # Node.js
  if read -p "Setup Node.js environment? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/node.sh")
  fi
  echo ""
  
  # PHP
  if read -p "Setup PHP/Laravel environment? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/php.sh")
  fi
  echo ""
  
  # tmux
  if read -p "Setup tmux with nikolovlazar's config? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/tmux.sh")
    selected_configs+=("stow/tmux")
  fi
  echo ""
  
  # Neovim
  if read -p "Setup Neovim with nikolovlazar's config? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/neovim.sh")
    selected_scripts+=("scripts/development/lazygit.sh")
    selected_configs+=("stow/nvim")
  fi
  echo ""
  
  # VSCode
  if read -p "Setup VSCode? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/vscode.sh")
    selected_configs+=("stow/vscode")
  fi
  echo ""
  
  # Development tools
  if read -p "Setup development tools (SSH connections)? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/system/generate-configs.sh")
  fi
  echo ""
  
  # WordPress WSL dependencies
  if read -p "Setup WordPress Local WP dependencies for WSL? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/wordpress-wsl.sh")
  fi
  echo ""
  
  # Run selected components
  if [[ ${#selected_scripts[@]} -gt 0 ]]; then
    run_scripts "${selected_scripts[@]}"
  fi
  
  if [[ ${#selected_configs[@]} -gt 0 ]]; then
    stow_configs "${selected_configs[@]}"
  fi
  
  if [[ ${#selected_applications[@]} -gt 0 ]]; then
    setup_applications "${selected_applications[@]}"
  fi
}

# Main installation function
main() {
  show_banner
  
  # Check if we're in the right directory
  if [[ ! -f "install.sh" ]] || [[ ! -d "profiles" ]]; then
    log_error "Please run this script from the dotfiles directory"
    exit 1
  fi
  
  # Run initial smart setup FIRST
  run_initial_setup
  
  # Check if stow is available
  if ! command -v stow >/dev/null 2>&1; then
    log_warning "GNU Stow not found. Installing system packages first..."
    chmod +x scripts/system/packages.sh
    ./scripts/system/packages.sh
  fi
  
  # Setup environment files
  setup_environment_files
  
  # Show profiles
  show_profiles
  
  # Get user choice
  read -p "Select a profile (number): " choice
  echo ""
  
  # Handle profile selection
  local profiles=(profiles/*.conf)
  local profile_count=${#profiles[@]}
  
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $profile_count ]]; then
    # Load selected profile
    local selected_profile="${profiles[$((choice-1))]}"
    source "$selected_profile"
    
    log_info "Installing profile: $PROFILE_NAME"
    log_info "Description: $PROFILE_DESCRIPTION"
    echo ""
    
    # Run installation
    run_scripts "${SCRIPTS[@]}"
    stow_configs "${CONFIGS[@]}"
    
    if [[ -n "${APPLICATIONS:-}" ]]; then
      setup_applications "${APPLICATIONS[@]}"
    fi
    
  elif [[ $choice -eq $((profile_count + 1)) ]]; then
    # Custom installation
    run_custom_installation
    
  else
    log_error "Invalid selection"
    exit 1
  fi
  
  echo ""
  log_success "🎉 Installation completed successfully!"
  echo ""
  log_info "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. If you're using VS Code, restart it to apply settings"
  echo "  3. If this is your first time, you may need to configure:"
  echo "     - SSH connections: .env.ssh (in project root)"
  echo ""
  log_info "You can run this installer again anytime to add new components!"
}

# Make scripts executable
chmod +x scripts/**/*.sh 2>/dev/null || true

# Run main function
main "$@"
