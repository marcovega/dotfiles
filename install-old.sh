#!/usr/bin/env bash

echo "Starting dotfiles installation..."
echo "================================"

# Make all scripts executable
chmod +x bash/system-packages.sh
chmod +x bash/shell.sh
chmod +x bash/dotfiles.sh
chmod +x bash/vscode-extensions.sh
chmod +x bash/php.sh

# Run installation scripts
echo "1. Installing system packages..."
./bash/system-packages.sh

echo ""
echo "2. Setting up shell environment..."
./bash/shell.sh

echo ""
echo "3. Installing dotfiles..."
./bash/dotfiles.sh

echo ""
echo "4. Installing VS Code extensions..."
./bash/vscode-extensions.sh

echo ""
echo "5. Setting up PHP development environment..."
./bash/php.sh

echo ""
echo "================================"
echo "Installation completed successfully!"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes." 
