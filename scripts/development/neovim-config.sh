#!/usr/bin/env bash

echo "📝 Setting up Neovim configuration from nikolovlazar's dotfiles..."

NVIM_CONFIG_DIR="configs/nvim"
REPO_BASE="https://raw.githubusercontent.com/nikolovlazar/dotfiles/main/.config/nvim"
TEMP_DIR="/tmp/nvim-config-download"

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

# Function to download directory recursively via GitHub API
download_nvim_config() {
  echo "🔍 Fetching configuration structure..."
  
  # Download the entire nvim config using git sparse-checkout (more reliable)
  cd "$TEMP_DIR"
  
  if git clone --filter=blob:none --sparse https://github.com/nikolovlazar/dotfiles.git; then
    cd dotfiles
    git sparse-checkout set .config/nvim
    
    # Copy to our config directory
    if [[ -d ".config/nvim" ]]; then
      echo "📋 Copying configuration files..."
      cp -r .config/nvim/* "$NVIM_CONFIG_DIR/"
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
  
  # Make sure we have the right structure for stow
  echo "🔧 Preparing configuration for stow..."
  
  # The files should be in configs/nvim/ and will be stowed to ~/.config/nvim/
  # We need to create the .config/nvim structure in our configs directory
  mkdir -p "configs/nvim/.config/nvim"
  
  # Move files to the correct stow structure
  if [[ -d "$NVIM_CONFIG_DIR" ]] && [[ "$(ls -A $NVIM_CONFIG_DIR 2>/dev/null)" ]]; then
    # If there are files directly in configs/nvim, move them to the .config/nvim subdirectory
    find "$NVIM_CONFIG_DIR" -maxdepth 1 -type f -exec mv {} "configs/nvim/.config/nvim/" \;
    find "$NVIM_CONFIG_DIR" -maxdepth 1 -type d ! -name ".config" ! -path "$NVIM_CONFIG_DIR" -exec mv {} "configs/nvim/.config/nvim/" \;
  fi
  
  echo ""
  echo "✅ Neovim configuration setup completed!"
  echo "📁 Configuration files downloaded to: configs/nvim/.config/nvim/"
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
