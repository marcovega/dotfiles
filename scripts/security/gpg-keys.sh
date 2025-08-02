#!/usr/bin/env bash

echo "🔐 Setting up GPG keys..."

GPG_DIR="$HOME/.gnupg"
PUBLIC_KEY_FILE="gpg-public-key.txt"

# Create secure directory structure
if [[ ! -d "$GPG_DIR" ]]; then
  echo "📁 Creating GPG directory..."
  mkdir -p "$GPG_DIR"
  chmod 700 "$GPG_DIR"
fi

# Check if GPG key already exists
if gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q "sec"; then
  echo "✓ GPG key already exists"
  
  # Get existing key ID
  KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "sec" | head -1 | sed 's/.*\/\([A-F0-9]\{16\}\).*/\1/')
  
else
  echo "🔑 Generating new GPG key..."
  
  # Get user details from environment file, git config, or prompt
  NAME=""
  EMAIL=""
  
  # Try environment file first
  if [[ -f "configs/git/.env.git" ]]; then
    source "configs/git/.env.git" 2>/dev/null || true
    NAME="$GIT_NAME"
    EMAIL="$GIT_EMAIL"
  fi
  
  # Fallback to git config
  if [[ -z "$NAME" ]] && command -v git >/dev/null 2>&1; then
    NAME=$(git config --global user.name 2>/dev/null)
  fi
  if [[ -z "$EMAIL" ]] && command -v git >/dev/null 2>&1; then
    EMAIL=$(git config --global user.email 2>/dev/null)
  fi
  
  # Last resort: prompt user
  if [[ -z "$NAME" ]]; then
    read -p "Enter your full name: " NAME
  fi
  if [[ -z "$EMAIL" ]]; then
    read -p "Enter your email: " EMAIL
  fi
  
  # Generate GPG key with interactive password prompt
  echo "📝 You'll be prompted for a passphrase (recommended for security)"
  echo "🔐 This passphrase will protect your GPG private key"
  
  cat > /tmp/gpg-gen-key << EOF
%echo Generating GPG key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0
%commit
%echo Done
EOF

  gpg --generate-key /tmp/gpg-gen-key
  rm -f /tmp/gpg-gen-key
  
  # Get the newly generated key ID
  KEY_ID=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "sec" | head -1 | sed 's/.*\/\([A-F0-9]\{16\}\).*/\1/')
  
  echo "✅ GPG key generated successfully!"
fi

# Export public key to git-ignored file
if [[ -n "$KEY_ID" ]]; then
  echo "📄 Exporting public key..."
  gpg --armor --export "$KEY_ID" > "$PUBLIC_KEY_FILE"
  echo "✅ Public key exported to $PUBLIC_KEY_FILE"
  
  echo ""
  echo "📋 Your GPG key ID: $KEY_ID"
  echo "📋 Public key location: $PWD/$PUBLIC_KEY_FILE"
  echo ""
  echo "🔧 To configure git to use this key:"
  echo "   git config --global user.signingkey $KEY_ID"
  echo "   git config --global commit.gpgsign true"
  echo ""
  
  # Configure git if git config exists
  if command -v git >/dev/null 2>&1; then
    git config --global user.signingkey "$KEY_ID"
    git config --global commit.gpgsign true
    echo "✅ Git configured to use GPG key for signing"
  fi
  
else
  echo "❌ Could not determine GPG key ID"
  exit 1
fi

echo "✅ GPG key setup completed!"
