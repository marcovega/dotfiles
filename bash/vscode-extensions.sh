#!/usr/bin/env bash

echo "Installing VS Code extensions..."

NEWLINE=$'\n'

# vscode ext install
if read -q "choice?${NEWLINE}do you want to install the visual studio code extensions listed below?${NEWLINE}$(cat vscode/extensions.linux)?${NEWLINE}(y/n): "; then
  echo $NEWLINE

  cat vscode/extensions.linux | while read extension || [[ -n $extension ]]; do
    code --install-extension $extension --force
  done
  echo "VS Code extensions installed successfully!"
else
  echo " skipping."
fi 
