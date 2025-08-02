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

# Function to stow configurations
stow_configs() {
  local configs=("$@")
  
  log_info "Stowing configurations..."
  
  for config in "${configs[@]}"; do
    if [[ -d "$config" ]]; then
      local config_name=$(basename "$config")
      log_info "Stowing $config_name..."
      
      # Determine stow target based on config type
      local stow_target="$HOME"
      # Handle special configs with custom stow targets
      if [[ "$config_name" == "nvim" ]]; then
        stow_target="$HOME/.config/nvim"
        mkdir -p "$stow_target"
      elif [[ "$config_name" == "tmux" ]]; then
        stow_target="$HOME/.config/tmux"
        mkdir -p "$stow_target"
      fi
      
      # Remove conflicting files before stowing
      case "$config_name" in
        "shell-zsh")
          [[ -f "$stow_target/.zshrc" ]] && rm -f "$stow_target/.zshrc"
          [[ -f "$stow_target/.p10k.zsh" ]] && rm -f "$stow_target/.p10k.zsh"
          log_info "Removed conflicting shell files"
          ;;
        "git")
          [[ -f "$stow_target/.gitconfig" ]] && rm -f "$stow_target/.gitconfig"
          log_info "Removed conflicting git files"
          ;;
        "terminal")
          [[ -f "$stow_target/.dir_colors" ]] && rm -f "$stow_target/.dir_colors"
          log_info "Removed conflicting terminal files"
          ;;
        "tmux")
          # Clean up the entire target directory for tmux
          rm -rf "$stow_target"/*
          log_info "Removed conflicting tmux files"
          ;;
        "nvim")
          # Clean up the entire target directory for nvim
          rm -rf "$stow_target"/*
          log_info "Removed conflicting nvim files"
          ;;
        "development")
          [[ -f "$stow_target/.env.ssh-connections" ]] && rm -f "$stow_target/.env.ssh-connections"
          [[ -f "$stow_target/.env.ssh-connections.example" ]] && rm -f "$stow_target/.env.ssh-connections.example"
          log_info "Removed conflicting development files"
          ;;
      esac
      
      # Unstow first to handle existing configs cleanly
      stow -v -d configs -t "$stow_target" -D "$config_name" 2>/dev/null || true
      
      # Then stow
      if stow -v -d configs -t "$stow_target" -S "$config_name"; then
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

# Function to setup applications
setup_applications() {
  local applications=("$@")
  
  for app in "${applications[@]}"; do
    if [[ -d "$app" ]]; then
      log_info "Setting up $(basename "$app")..."
      
      case "$(basename "$app")" in
        "vscode")
          # Copy VSCode settings
          if [[ -f "$app/settings.json" ]]; then
            local vscode_dir="$HOME/.config/Code/User"
            mkdir -p "$vscode_dir"
            cp "$app/settings.json" "$vscode_dir/"
            log_success "✓ VSCode settings copied"
          fi
          ;;
        "windows")
          # Copy Windows/WSL configs
          if [[ -f "$app/.wslconfig" ]]; then
            cp "$app/.wslconfig" "$HOME/"
            log_success "✓ WSL config copied"
          fi
          ;;
      esac
    fi
  done
}

# Function to handle environment files
setup_environment_files() {
  log_info "Checking environment files..."
  
  # Git environment (informational only - don't block)
  if [[ ! -f "configs/git/.env.git" ]] && [[ -f "configs/git/env.git.example" ]]; then
    log_info "Git environment file not found - will prompt for details during key generation"
    echo "💡 Tip: You can pre-configure git details by copying:"
    echo "   cp configs/git/env.git.example configs/git/.env.git"
    echo "   nano configs/git/.env.git"
  else
    log_info "✓ Git environment file found"
  fi
  
  # SSH connections environment
  if [[ ! -f "configs/development/.env.ssh-connections" ]] && [[ -f "configs/development/.env.ssh-connections.example" ]]; then
    log_info "SSH connections environment file not found (optional)"
    echo "💡 Tip: For SSH shortcuts, copy and customize:"
    echo "   cp configs/development/.env.ssh-connections.example configs/development/.env.ssh-connections"
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
    selected_configs+=("configs/shell-zsh")
  fi
  echo ""
  
  # Git
  if read -p "Setup Git configuration? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_configs+=("configs/git")
  fi
  echo ""
  
  # Terminal colors
  if read -p "Setup terminal colors? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_configs+=("configs/terminal")
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
    selected_configs+=("configs/tmux")
  fi
  echo ""
  
  # Neovim
  if read -p "Setup Neovim with nikolovlazar's config? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/neovim.sh")
    selected_scripts+=("scripts/development/neovim-config.sh")
    selected_scripts+=("scripts/development/lazygit.sh")
    selected_configs+=("configs/nvim")
  fi
  echo ""
  
  # VSCode
  if read -p "Setup VSCode? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_scripts+=("scripts/development/vscode.sh")
    selected_applications+=("applications/vscode")
  fi
  echo ""
  
  # Development tools
  if read -p "Setup development tools (SSH connections)? (y/n): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    selected_configs+=("configs/development")
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
  
  # Check if stow is available
  if ! command -v stow >/dev/null 2>&1; then
    log_warning "GNU Stow not found. Installing system packages first..."
    chmod +x scripts/system/packages.sh
    ./scripts/system/packages.sh
  fi
  
  # Setup environment files first
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
  echo "     - Git: configs/git/.env.git"
  echo "     - SSH connections: configs/development/.env.ssh-connections"
  echo ""
  log_info "You can run this installer again anytime to add new components!"
}

# Make scripts executable
chmod +x scripts/**/*.sh 2>/dev/null || true

# Run main function
main "$@"
