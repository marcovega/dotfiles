#!/usr/bin/env bash

echo "Setting up shell environment..."

# install oh-my-zsh (non-interactive)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "oh-my-zsh installed successfully!"
else
  echo "oh-my-zsh already installed, skipping..."
fi

# install fnm
echo "Installing fnm..."
curl -fsSL https://fnm.vercel.app/install | bash

# inject fnm to .zshrc if missing
FNM_BLOCK='export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"'
if ! grep -q 'fnm env' ~/.zshrc; then
  echo "Adding fnm configuration to .zshrc..."
  echo "$FNM_BLOCK" >> ~/.zshrc
else
  echo "fnm configuration already present in .zshrc"
fi

# install zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

echo "Installing zsh plugins..."
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# install powerlevel10k
echo "Installing powerlevel10k theme..."
[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

echo "Shell setup completed successfully!" 
