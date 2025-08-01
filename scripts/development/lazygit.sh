#!/usr/bin/env bash

echo "🚀 Setting up LazyGit..."

LAZYGIT_VERSION="v0.44.1"  # You can update this to latest version
LAZYGIT_BINARY="/usr/local/bin/lazygit"

# Function to check if lazygit is installed
check_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Check if lazygit is already installed
if check_lazygit; then
  echo "✓ LazyGit already installed"
  echo "  Version: $(lazygit --version | head -1)"
else
  echo "📥 Installing LazyGit $LAZYGIT_VERSION..."
  
  # Create temp directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Download and install lazygit
  echo "🔄 Downloading LazyGit..."
  if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz" -o lazygit.tar.gz; then
    echo "📦 Extracting LazyGit..."
    tar -xzf lazygit.tar.gz
    
    if [[ -f "lazygit" ]]; then
      echo "📋 Installing LazyGit to $LAZYGIT_BINARY..."
      sudo mv lazygit "$LAZYGIT_BINARY"
      sudo chmod +x "$LAZYGIT_BINARY"
      echo "✅ LazyGit installed successfully!"
    else
      echo "❌ LazyGit binary not found in archive"
      exit 1
    fi
  else
    echo "❌ Failed to download LazyGit"
    exit 1
  fi
  
  # Clean up
  cd - > /dev/null
  rm -rf "$TEMP_DIR"
fi

# Verify installation
echo ""
echo "🔍 Verifying LazyGit installation..."
if command -v lazygit >/dev/null 2>&1; then
  echo "✅ LazyGit is working: $(lazygit --version | head -1)"
else
  echo "❌ LazyGit installation failed"
  exit 1
fi

echo "✅ LazyGit setup completed!"
