#!/usr/bin/env bash

echo "🟢 Setting up Node.js environment..."

# Install fnm (Fast Node Manager) if not already installed
if ! command -v fnm >/dev/null 2>&1; then
  echo "📥 Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash
  echo "✅ fnm installed successfully!"
else
  echo "✓ fnm already installed"
fi

# Add fnm to PATH for this session
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi

# Install latest LTS Node.js if no Node.js is installed
if ! command -v node >/dev/null 2>&1; then
  echo "📥 Installing latest LTS Node.js..."
  fnm install --lts
  fnm use lts-latest
  fnm default lts-latest
  echo "✅ Node.js LTS installed and set as default!"
else
  echo "✓ Node.js already installed ($(node --version))"
fi

echo "✅ Node.js environment setup completed!"
