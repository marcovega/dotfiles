#!/usr/bin/env bash

echo "📝 Setting up Neovim configuration from nikolovlazar's dotfiles..."

NVIM_CONFIG_DIR="configs/nvim"
REPO_BASE="https://raw.githubusercontent.com/nikolovlazar/dotfiles/main/.config/nvim"
TEMP_DIR="/tmp/nvim-config-download"
# Store the original working directory (dotfiles root)
ORIGINAL_DIR="$(pwd)"

# Create nvim config directory
mkdir -p "$NVIM_CONFIG_DIR"

# Clean up any previous temp directory
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "🔄 Downloading latest Neovim configuration from nikolovlazar/dotfiles..."

# Function to download file
download_file() {
  local remote_path="$1"
  local local_path="$2"
  
  echo "📥 Downloading $remote_path..."
  
  # Create directory if needed
  local dir=$(dirname "$local_path")
  mkdir -p "$dir"
  
  if curl -fsSL "$REPO_BASE/$remote_path" -o "$local_path"; then
    echo "✅ Downloaded $remote_path"
    return 0
  else
    echo "❌ Failed to download $remote_path"
    return 1
  fi
}

# Function to download neovim config with correct stow structure
download_nvim_config() {
  echo "🔍 Fetching configuration structure..."
  
  # Create clean structure: configs/nvim/ (will stow to ~/.config/nvim/)
  mkdir -p "configs/nvim"
  
  # Download using git sparse-checkout
  cd "$TEMP_DIR"
  
  if git clone --filter=blob:none --sparse https://github.com/nikolovlazar/dotfiles.git; then
    cd dotfiles
    git sparse-checkout set .config/nvim
    
    # Copy to the correct stow structure: configs/nvim/.config/nvim/
    if [[ -d ".config/nvim" ]]; then
      echo "📋 Copying configuration files..."
      # Create the proper stow directory structure
      mkdir -p "$ORIGINAL_DIR/configs/nvim/.config/"
      # Use the original directory where script was called from
      cp -r .config/nvim "$ORIGINAL_DIR/configs/nvim/.config/"
      echo "✅ Neovim configuration copied successfully"
    else
      echo "❌ nvim config directory not found in repo"
      return 1
    fi
  else
    echo "❌ Failed to clone repository"
    return 1
  fi
}

# Download the configuration
if download_nvim_config; then
  # Clean up temp directory
  rm -rf "$TEMP_DIR"
  
  echo ""
  echo "✅ Neovim configuration setup completed!"
  echo "📁 Configuration files downloaded to: configs/nvim/"
  echo "🔄 This script always downloads the latest version from nikolovlazar's repo"
  echo ""
  echo "📝 Next steps:"
  echo "   1. Make sure Neovim is installed (run scripts/development/neovim.sh)"
  echo "   2. Stow the configuration (will be done by installer profiles)"
  echo "   3. Start nvim and let Lazy.nvim install plugins"
  
else
  echo "❌ Failed to download Neovim configuration"
  rm -rf "$TEMP_DIR"
  exit 1
fi
