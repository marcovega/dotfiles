#!/usr/bin/env bash

echo "📝 Setting up Neovim..."

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

echo "✅ Neovim setup completed!"