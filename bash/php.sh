#!/usr/bin/env bash

echo "Setting up PHP development environment..."

# Add Ondřej Surý's PPA for PHP 8.4
echo "Adding PHP 8.4 repository..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.4 and common extensions for Laravel
echo "Installing PHP 8.4 and Laravel extensions..."
sudo apt install -y \
  php8.4 \
  php8.4-cli \
  php8.4-common \
  php8.4-fpm \
  php8.4-mysql \
  php8.4-zip \
  php8.4-gd \
  php8.4-mbstring \
  php8.4-curl \
  php8.4-xml \
  php8.4-bcmath \
  php8.4-tokenizer \
  php8.4-opcache \
  php8.4-redis \
  php8.4-intl \
  php8.4-soap \
  php8.4-xmlrpc \
  php8.4-ldap \
  php8.4-imap \
  php8.4-dev \
  unzip

# Set PHP 8.4 as the default version
echo "Setting PHP 8.4 as default..."
if command -v php8.4 &> /dev/null; then
  sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.4 84
  sudo update-alternatives --set php /usr/bin/php8.4
else
  echo "Warning: PHP 8.4 not found, skipping alternatives setup"
fi

# Install Composer
echo "Installing Composer..."
if [[ ! -f "/usr/local/bin/composer" ]]; then
  if command -v php &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    if [[ -f "composer.phar" ]]; then
      sudo mv composer.phar /usr/local/bin/composer
      sudo chmod +x /usr/local/bin/composer
    else
      echo "Error: Composer installation failed"
      exit 1
    fi
  else
    echo "Error: PHP not found, cannot install Composer"
    exit 1
  fi
else
  echo "Composer already installed, updating..."
  sudo composer self-update
fi

# Install Laravel Sail globally
echo "Installing Laravel Sail..."
if command -v composer &> /dev/null; then
  composer global require laravel/sail
else
  echo "Error: Composer not found, cannot install Laravel Sail"
  exit 1
fi

# Add Composer global bin to PATH if not already present
COMPOSER_BIN='export PATH="$HOME/.config/composer/vendor/bin:$PATH"'
if ! grep -q 'composer/vendor/bin' ~/.zshrc; then
  echo "Adding Composer global bin to PATH..."
  echo "$COMPOSER_BIN" >> ~/.zshrc
else
  echo "Composer global bin already in PATH"
fi

# Create Sail alias for easier access
SAIL_ALIAS='alias sail="[ -f sail ] && sh sail || sh vendor/bin/sail"'
if ! grep -q 'alias sail=' ~/.zshrc; then
  echo "Adding Sail alias..."
  echo "$SAIL_ALIAS" >> ~/.zshrc
else
  echo "Sail alias already configured"
fi

# Verify installations
echo ""
echo "Verifying installations..."
if command -v php &> /dev/null; then
  php --version
else
  echo "Warning: PHP not found"
fi

if command -v composer &> /dev/null; then
  composer --version
else
  echo "Warning: Composer not found"
fi

echo ""
echo "PHP development environment setup completed successfully!"
echo "Laravel Sail is now available via 'sail' command"
echo "Composer global packages are in ~/.config/composer/vendor/bin" 
