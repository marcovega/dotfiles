#!/usr/bin/env bash

# Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "📺 Setting up tmux with nikolovlazar's configuration"

# Note: ask_with_default_yes is now handled by prompt_confirm from gum-logger.sh

TMUX_CONFIG_DIR="stow/tmux/.config/tmux"
REPO_BASE="https://raw.githubusercontent.com/nikolovlazar/dotfiles/main/.config/tmux"

# Create tmux config directory
mkdir -p "$TMUX_CONFIG_DIR"

# Files to download from nikolovlazar's repo
declare -A tmux_files=(
  ["tmux.conf"]="tmux.conf"
  ["hooks/update-pane-status.sh"]="hooks/update-pane-status.sh"
  ["switch-catppuccin-theme.sh"]="switch-catppuccin-theme.sh"
)

# Ask if user wants to download/update configuration
  if prompt_confirm "Download/update tmux configuration from nikolovlazar's repository?" true; then
  log_info "Downloading latest tmux configuration from nikolovlazar/dotfiles..."
else
  log_info "Skipping tmux configuration download"
  echo "✅ tmux setup completed (no config changes)"
  exit 0
fi

# Download config files to stow package
for remote_file in "${!tmux_files[@]}"; do
  local_file="${tmux_files[$remote_file]}"
  echo "📥 Downloading config $remote_file → $local_file..."
  
  # Create directory if needed
  dir=$(dirname "$TMUX_CONFIG_DIR/$local_file")
  mkdir -p "$dir"
  
  if curl -fsSL "$REPO_BASE/$remote_file" -o "$TMUX_CONFIG_DIR/$local_file"; then
    echo "✅ Downloaded $local_file"
    
    # Make scripts executable
    if [[ "$local_file" == hooks/* ]] || [[ "$local_file" == *.sh ]]; then
      chmod +x "$TMUX_CONFIG_DIR/$local_file"
      echo "🔧 Made $local_file executable"
    fi
  else
    echo "❌ Failed to download $remote_file"
    exit 1
  fi
done

# Install tmux if not already installed
if ! command -v tmux >/dev/null 2>&1; then
  echo "📦 tmux not found. It should be installed by system packages."
  echo "⚠️  Make sure to run scripts/system/packages.sh first"
else
  echo "✓ tmux is installed: $(tmux -V)"
fi

echo ""
log_success "tmux configuration setup completed!"
log_info "Configuration files downloaded to: $TMUX_CONFIG_DIR"
log_info "Structure: ~/.config/tmux/ (XDG-compliant)"
log_info "Downloaded latest version from nikolovlazar's repo"

# Ask if user wants to reload tmux config
  if prompt_confirm "Reload tmux configuration now?" true; then
  if command -v tmux >/dev/null 2>&1; then
    if tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null; then
      log_success "tmux configuration reloaded!"
    else
      log_warning "Could not reload tmux config (no active session?)"
    fi
  else
    log_warning "tmux not found, skipping reload"
  fi
fi
