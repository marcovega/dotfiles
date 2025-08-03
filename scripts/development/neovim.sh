#!/usr/bin/env bash

# Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "📝 Setting up Neovim and configuration"

# Note: ask_with_default_yes is now handled by prompt_confirm from gum-logger.sh

NVIM_VERSION_FILE="/opt/nvim/bin/nvim"
NVIM_TARBALL="nvim-linux-x86_64.tar.gz"

# Function to check if neovim is installed and get version
check_neovim() {
  if [[ -f "$NVIM_VERSION_FILE" ]]; then
    return 0
  elif command -v nvim >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Check if neovim is already installed
if check_neovim; then
  echo "✓ Neovim already installed"
  if command -v nvim >/dev/null 2>&1; then
    echo "  Version: $(nvim --version | head -1)"
  fi
else
  echo "📥 Installing latest stable Neovim..."
  
  # Download latest neovim
  echo "🔄 Downloading Neovim..."
  if ! curl -LO "https://github.com/neovim/neovim/releases/latest/download/$NVIM_TARBALL"; then
    echo "❌ Failed to download Neovim"
    exit 1
  fi
  
  # Remove existing installation
  echo "🗑️  Removing existing Neovim installation..."
  sudo rm -rf /opt/nvim
  
  # Extract to /opt
  echo "📦 Extracting Neovim..."
  if ! sudo tar -C /opt -xzf "$NVIM_TARBALL"; then
    echo "❌ Failed to extract Neovim"
    exit 1
  fi
  
  # Move to expected directory structure
  if [[ -d "/opt/nvim-linux-x86_64" ]]; then
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim
  fi
  
  # Clean up tarball
  rm -f "$NVIM_TARBALL"
  
  echo "✅ Neovim installed successfully!"
fi

# Add to PATH if not already there
NVIM_PATH="/opt/nvim/bin"
if [[ -d "$NVIM_PATH" ]] && [[ ":$PATH:" != *":$NVIM_PATH:"* ]]; then
  echo "🔧 Adding Neovim to PATH..."
  
  # Add to current session
  export PATH="$NVIM_PATH:$PATH"
  
  echo "📝 Neovim PATH will be managed by shell configuration"
fi

# Verify installation
echo ""
echo "🔍 Verifying Neovim installation..."
if command -v nvim >/dev/null 2>&1; then
  echo "✅ Neovim is working: $(nvim --version | head -1)"
else
  echo "⚠️  Neovim may not be in PATH. You may need to restart your shell."
  echo "   Or manually add /opt/nvim/bin to your PATH"
fi

# Function to setup Neovim configuration
setup_neovim_config() {
  log_info "Setting up Neovim configuration from nikolovlazar's dotfiles..."
  
  local NVIM_CONFIG_DIR="stow/nvim/.config/nvim"
  local TEMP_DIR="/tmp/nvim-config-download"
  local ORIGINAL_DIR="$(pwd)"
  
  # Create nvim config directory
  mkdir -p "$NVIM_CONFIG_DIR"
  
  # Clean up any previous temp directory
  rm -rf "$TEMP_DIR"
  mkdir -p "$TEMP_DIR"
  
  log_info "Downloading latest Neovim configuration from nikolovlazar/dotfiles..."
  
  # Download using git sparse-checkout
  cd "$TEMP_DIR"
  
  if git clone --filter=blob:none --sparse https://github.com/nikolovlazar/dotfiles.git; then
    cd dotfiles
    git sparse-checkout set .config/nvim
    
    # Copy to the correct stow structure: stow/nvim/.config/nvim/
    if [[ -d ".config/nvim" ]]; then
      log_info "Copying configuration files..."
      # Create the proper stow directory structure
      mkdir -p "$ORIGINAL_DIR/stow/nvim/.config/"
      # Remove existing config and copy new one
      rm -rf "$ORIGINAL_DIR/stow/nvim/.config/nvim"
      cp -r .config/nvim "$ORIGINAL_DIR/stow/nvim/.config/"
      log_success "Neovim configuration downloaded successfully"
      
      log_info "Next steps:"
      echo "   1. Restart Neovim to apply changes"
      echo "   2. Let Lazy.nvim install/update plugins"
    else
      log_error "nvim config directory not found in repo"
      return 1
    fi
  else
    log_error "Failed to clone repository"
    return 1
  fi
  
  # Clean up temp directory
  rm -rf "$TEMP_DIR"
  cd "$ORIGINAL_DIR"
}

# Configuration setup
echo ""
log_info "Neovim binary setup completed!"
echo ""

# Ask about configuration
  if prompt_confirm "Download/update Neovim configuration from nikolovlazar's repository?" true; then
  setup_neovim_config
else
  log_info "Skipping Neovim configuration download"
fi

echo ""
log_success "✅ Neovim setup completed!"
