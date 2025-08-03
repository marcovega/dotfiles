#!/usr/bin/env bash

echo "📦 Installing system packages..."

# Function to check if package is installed
is_package_installed() {
  dpkg -l | grep -q "^ii  $1 "
}

# Function to install package if not already installed
install_package() {
  if is_package_installed "$1"; then
    echo "✓ $1 already installed"
  else
    echo "📥 Installing $1..."
    sudo apt install -y "$1"
  fi
}

# Update package list if it's older than 1 day
if [[ ! -f /var/lib/apt/periodic/update-success-stamp ]] || [[ $(find /var/lib/apt/periodic/update-success-stamp -mtime +1) ]]; then
  echo "🔄 Updating package list..."
  sudo apt update
fi

# Install essential packages
packages=(
  "apt-transport-https"
  "unzip"
  "ca-certificates"
  "curl"
  "software-properties-common"
  "git"
  "make"
  "tig"
  "tree"
  "stow"
  "zsh"
  "dnsutils"
  "tmux"
  "jq"
  "fd-find"
  "ripgrep"
  "fzf"
  "build-essential"
)

for package in "${packages[@]}"; do
  install_package "$package"
done

echo "✅ System packages installation completed!"
