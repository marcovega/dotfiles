#!/usr/bin/env bash

# Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "🚀 Setting up LazyGit"

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
  log_success "LazyGit already installed"
  echo "  Version: $(lazygit --version | head -1)"
else
  log_info "Installing LazyGit $LAZYGIT_VERSION..."
  
  # Create temp directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  # Download and install lazygit
  log_info "Downloading LazyGit..."
  if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz" -o lazygit.tar.gz; then
    log_info "Extracting LazyGit..."
    tar -xzf lazygit.tar.gz
    
    if [[ -f "lazygit" ]]; then
      log_info "Installing LazyGit to $LAZYGIT_BINARY..."
      sudo mv lazygit "$LAZYGIT_BINARY"
      sudo chmod +x "$LAZYGIT_BINARY"
      log_success "LazyGit installed successfully!"
    else
      log_error "LazyGit binary not found in archive"
      exit 1
    fi
  else
    log_error "Failed to download LazyGit"
    exit 1
  fi
  
  # Clean up
  cd - > /dev/null
  rm -rf "$TEMP_DIR"
fi

# Verify installation
echo ""
log_info "Verifying LazyGit installation..."
if command -v lazygit >/dev/null 2>&1; then
  log_success "LazyGit is working: $(lazygit --version | head -1)"
else
  log_error "LazyGit installation failed"
  exit 1
fi

log_success "LazyGit setup completed!"
