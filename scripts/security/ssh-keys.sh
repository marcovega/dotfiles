#!/usr/bin/env bash

echo "🔐 Setting up SSH keys..."

SSH_DIR="$HOME/.ssh"
KEY_TYPE="ed25519"
KEY_FILE="$SSH_DIR/id_$KEY_TYPE"

# Create .ssh directory if it doesn't exist
if [[ ! -d "$SSH_DIR" ]]; then
  echo "📁 Creating .ssh directory..."
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

# Check if SSH key already exists
if [[ -f "$KEY_FILE" ]]; then
  echo "✓ SSH key already exists: $KEY_FILE"
else
  echo "🔑 Generating new SSH key..."
  
  # Get user email from environment file, git config, or prompt
  EMAIL=""
  
  # Try environment file first
  if [[ -f "configs/git/.env.git" ]]; then
    source "configs/git/.env.git" 2>/dev/null || true
    EMAIL="$GIT_EMAIL"
  fi
  
  # Fallback to git config
  if [[ -z "$EMAIL" ]] && command -v git >/dev/null 2>&1; then
    EMAIL=$(git config --global user.email 2>/dev/null)
  fi
  
  # Last resort: prompt user
  if [[ -z "$EMAIL" ]]; then
    read -p "Enter your email for SSH key: " EMAIL
  fi
  
  # Generate SSH key (will prompt for passphrase)
  echo "📝 You'll be prompted for a passphrase (recommended for security)"
  ssh-keygen -t "$KEY_TYPE" -C "$EMAIL" -f "$KEY_FILE"
  
  echo "✅ SSH key generated successfully!"
fi

# Add key to SSH agent
echo "🔄 Adding SSH key to agent..."

# Start ssh-agent if not running
if ! pgrep -x "ssh-agent" > /dev/null; then
  eval "$(ssh-agent -s)"
fi

# Add key to agent
ssh-add "$KEY_FILE" 2>/dev/null || {
  echo "⚠️  Could not add key to agent automatically"
  echo "   Run: ssh-add $KEY_FILE"
}

# Display public key
echo ""
echo "📋 Your SSH public key (copy this to GitHub/GitLab):"
echo "────────────────────────────────────────────────────"
cat "$KEY_FILE.pub"
echo "────────────────────────────────────────────────────"
echo ""

echo "✅ SSH key setup completed!"
