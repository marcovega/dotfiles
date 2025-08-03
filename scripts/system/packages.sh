#!/usr/bin/env bash

# Load gum-based logging library  
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "📦 Installing system packages"

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

# Function to setup gum repository and install gum
setup_gum() {
  if command -v gum >/dev/null 2>&1; then
    log_success "gum already installed"
    return 0
  fi
  
  log_info "Setting up Charm's gum for beautiful terminal UI..."
  
  # Create keyring directory
  sudo mkdir -p /etc/apt/keyrings
  
  # Add Charm's GPG key
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  
  # Add Charm's repository
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  
  # Update package list to include Charm's repo
  sudo apt update
  
  # Install gum
  log_info "Installing gum..."
  sudo apt install -y gum
  
  if command -v gum >/dev/null 2>&1; then
    log_success "gum installed successfully"
  else
    log_error "Failed to install gum"
    return 1
  fi
}

# Function to setup rust-tools repository
setup_rust_tools() {
  # Check if rust-tools repo is already added
  if [[ -f /etc/apt/sources.list.d/rust-tools.list ]]; then
    log_success "rust-tools repository already configured"
    return 0
  fi
  
  log_info "Setting up rust-tools repository for modern CLI tools..."
  
  # Create keyring directory
  sudo mkdir -p /usr/share/keyrings
  
  # Add rust-tools GPG key
  curl -fsSL https://apt.cli.rs/pubkey.asc | sudo tee -a /usr/share/keyrings/rust-tools.asc
  
  # Add rust-tools repository
  curl -fsSL https://apt.cli.rs/rust-tools.list | sudo tee /etc/apt/sources.list.d/rust-tools.list
  
  # Update package list to include rust-tools repo
  sudo apt update
  
  log_success "rust-tools repository configured successfully"
}

# Update package list if it's older than 1 day
if [[ ! -f /var/lib/apt/periodic/update-success-stamp ]] || [[ $(find /var/lib/apt/periodic/update-success-stamp -mtime +1) ]]; then
  echo "🔄 Updating package list..."
  sudo apt update
fi

# Install gum first (needed for better UI)
setup_gum

# Setup rust-tools repository (for modern CLI tools)
setup_rust_tools

# Install essential packages
packages=(
  "apt-transport-https"
  "unzip"
  "ca-certificates"
  "curl"
  "software-properties-common"
  "git"
  "make"
  "tig"
  "tree"
  "stow"
  "zsh"
  "dnsutils"
  "tmux"
  "jq"
  "fd-find"
  "ripgrep"
  "fzf"
  "build-essential"
  "zoxide"
)

for package in "${packages[@]}"; do
  install_package "$package"
done

log_success "System packages installation completed!"
