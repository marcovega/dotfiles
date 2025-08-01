#!/usr/bin/env bash

echo "🐘 Setting up PHP development environment..."

# Function to check if PHP version is installed
is_php_installed() {
  command -v php >/dev/null 2>&1 && php -v | grep -q "PHP 8.4"
}

# Add Ondřej Surý's PPA for PHP 8.4 if not already added
if ! grep -q "ondrej/php" /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "📥 Adding PHP 8.4 repository..."
  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt update
else
  echo "✓ PHP 8.4 repository already added"
fi

# Install PHP 8.4 and extensions if not already installed
if ! is_php_installed; then
  echo "📥 Installing PHP 8.4 and Laravel extensions..."
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
  echo "🔄 Setting PHP 8.4 as default..."
  if command -v php8.4 >/dev/null 2>&1; then
    sudo update-alternatives --install /usr/bin/php php /usr/bin/php8.4 84
    sudo update-alternatives --set php /usr/bin/php8.4
  fi
  echo "✅ PHP 8.4 installed and set as default!"
else
  echo "✓ PHP 8.4 already installed"
fi

# Install Composer if not already installed
if ! command -v composer >/dev/null 2>&1; then
  echo "📥 Installing Composer..."
  if command -v php >/dev/null 2>&1; then
    curl -sS https://getcomposer.org/installer | php
    if [[ -f "composer.phar" ]]; then
      sudo mv composer.phar /usr/local/bin/composer
      sudo chmod +x /usr/local/bin/composer
      echo "✅ Composer installed successfully!"
    else
      echo "❌ Error: Composer installation failed"
      exit 1
    fi
  else
    echo "❌ Error: PHP not found, cannot install Composer"
    exit 1
  fi
else
  echo "✓ Composer already installed, updating..."
  sudo composer self-update
fi

# Install Laravel Sail globally if not already installed
if ! composer global show laravel/sail >/dev/null 2>&1; then
  echo "📥 Installing Laravel Sail..."
  if command -v composer >/dev/null 2>&1; then
    composer global require laravel/sail
    echo "✅ Laravel Sail installed successfully!"
  else
    echo "❌ Error: Composer not found, cannot install Laravel Sail"
    exit 1
  fi
else
  echo "✓ Laravel Sail already installed"
fi

# Verify installations
echo ""
echo "🔍 Verifying installations..."
if command -v php >/dev/null 2>&1; then
  echo "✓ PHP: $(php --version | head -n1)"
else
  echo "❌ PHP not found"
fi

if command -v composer >/dev/null 2>&1; then
  echo "✓ Composer: $(composer --version --no-ansi)"
else
  echo "❌ Composer not found"
fi

echo "✅ PHP development environment setup completed!"
