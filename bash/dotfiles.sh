#!/usr/bin/env bash

echo "Installing dotfiles using stow..."

# stow dotfiles
for dir in *(/); do
  [[ $dir =~ ^(vscode|windows)$ ]] && continue

  if read -q "choice?do you want to symlink $dir using stow? (y/n) "; then
    stow -v -t ~/ -S $dir
    echo " - $dir installed."
  else
    echo " - skipping $dir."
  fi
done

echo "Dotfiles installation completed!" 
