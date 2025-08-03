#!/usr/bin/env bash

echo "🐚 Setting up Zsh environment..."

# Install oh-my-zsh (idempotent)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "📥 Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "✅ oh-my-zsh installed successfully!"
else
  echo "✓ oh-my-zsh already installed"
fi

# Install zsh plugins (idempotent)
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

echo "🔌 Installing zsh plugins..."

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "📥 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "✓ zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo "📥 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "✓ zsh-syntax-highlighting already installed"
fi

# Install powerlevel10k theme (idempotent)
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  echo "📥 Installing powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  echo "✅ powerlevel10k installed successfully!"
else
  echo "✓ powerlevel10k already installed"
fi

# Set zsh as default shell if not already set
if [[ "$SHELL" != "/usr/bin/zsh" ]] && [[ "$SHELL" != "/bin/zsh" ]]; then
  if command -v zsh >/dev/null 2>&1; then
    echo "🔄 Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "⚠️  Please log out and back in for shell change to take effect"
  fi
else
  echo "✓ zsh already set as default shell"
fi

echo "✅ Zsh setup completed!"
