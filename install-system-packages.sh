#!/usr/bin/env bash

echo "Installing system packages..."

sudo apt update && sudo apt install -y \
  apt-transport-https \
  unzip \
  ca-certificates \
  curl \
  software-properties-common \
  git \
  make \
  tig \
  tree \
  stow \
  zsh

echo "System packages installed successfully!" 
