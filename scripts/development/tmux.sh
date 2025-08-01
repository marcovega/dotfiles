#!/usr/bin/env bash

echo "📺 Setting up tmux with nikolovlazar's configuration..."

TMUX_CONFIG_DIR="configs/tmux"
REPO_BASE="https://raw.githubusercontent.com/nikolovlazar/dotfiles/main/.config/tmux"

# Create tmux config directory
mkdir -p "$TMUX_CONFIG_DIR"

# Files to download from nikolovlazar's repo
declare -A tmux_files=(
  ["tmux.conf"]=".tmux.conf"
  ["switch-catppuccin-theme.sh"]="switch-catppuccin-theme.sh"
)

echo "🔄 Downloading latest tmux configuration from nikolovlazar/dotfiles..."

for remote_file in "${!tmux_files[@]}"; do
  local_file="${tmux_files[$remote_file]}"
  echo "📥 Downloading $remote_file → $local_file..."
  
  if curl -fsSL "$REPO_BASE/$remote_file" -o "$TMUX_CONFIG_DIR/$local_file"; then
    echo "✅ Downloaded $local_file"
    
    # Make script executable if it's a shell script
    if [[ "$local_file" == *.sh ]]; then
      chmod +x "$TMUX_CONFIG_DIR/$local_file"
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
echo "✅ tmux configuration setup completed!"
echo "📝 Configuration files downloaded to: $TMUX_CONFIG_DIR"
echo "🔄 This script always downloads the latest version from nikolovlazar's repo"
