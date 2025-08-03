#!/usr/bin/env bash

# Ask user if they want to install extensions
if [[ "${1:-}" != "--auto" ]]; then
  echo "💻 VS Code extensions setup"
  echo ""
  # Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

if ! prompt_confirm "Install/update VS Code extensions?" true; then
    echo ""
    echo "⏭️  Skipping VS Code extensions setup."
    exit 0
  fi
  echo ""
fi

echo "💻 Setting up VS Code extensions..."

# Check if VSCode is installed
if ! command -v code >/dev/null 2>&1; then
  echo "⚠️  VS Code not found. Please install VS Code first."
  echo "   You can install it with: sudo snap install code --classic"
  exit 1
fi

# Function to check if extension is installed
is_extension_installed() {
  code --list-extensions | grep -q "^$1$"
}

# Function to install extension if not already installed
install_extension() {
  if is_extension_installed "$1"; then
    echo "✓ $1 already installed"
  else
    echo "📥 Installing $1..."
    code --install-extension "$1" --force
  fi
}

# Determine which extensions file to use
if [[ -f "support/data/extensions.linux" ]]; then
  EXTENSIONS_FILE="support/data/extensions.linux"
elif [[ -f "applications/vscode/extensions.linux" ]]; then
  EXTENSIONS_FILE="applications/vscode/extensions.linux"
elif [[ -f "vscode/extensions.linux" ]]; then
  EXTENSIONS_FILE="vscode/extensions.linux"
else
  echo "❌ Extensions file not found!"
  exit 1
fi

echo "📋 Installing extensions from $EXTENSIONS_FILE..."
echo ""

# Read extensions file and install each extension
while IFS= read -r extension || [[ -n "$extension" ]]; do
  # Skip empty lines and comments
  [[ -z "$extension" ]] && continue
  [[ "$extension" =~ ^#.*$ ]] && continue
  
  install_extension "$extension"
done < "$EXTENSIONS_FILE"

echo ""
echo "✅ VS Code extensions setup completed!"
