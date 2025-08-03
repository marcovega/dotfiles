#!/usr/bin/env bash

echo "🔗 Setting up WordPress Local WP dependencies for WSL2/Ubuntu..."

# Check if we're running in WSL
if [[ ! -f /proc/version ]] || ! grep -q "microsoft\|WSL" /proc/version; then
  echo "⚠️  This script is designed for WSL2/Ubuntu environments"
  echo "   Skipping WordPress WSL setup..."
  exit 0
fi

echo "✓ Running in WSL environment"

# Check WSL version (should be WSL2 for best performance)
if grep -q "WSL2" /proc/version 2>/dev/null; then
  echo "✓ WSL2 detected - optimal for Local WP"
elif grep -q "WSL" /proc/version 2>/dev/null; then
  echo "⚠️  WSL1 detected - consider upgrading to WSL2 for better performance"
  echo "   Run from Windows PowerShell: wsl --set-version Ubuntu 2"
else
  echo "ℹ️  Could not determine WSL version, proceeding anyway"
fi

# Function to check if package is installed
is_package_installed() {
  dpkg -l | grep -q "^ii  $1 "
}

# Function to download and install .deb package
install_deb_package() {
  local url="$1"
  local package_name="$2"
  local deb_file="$3"
  
  if is_package_installed "$package_name"; then
    echo "✓ $package_name already installed"
    return 0
  fi
  
  echo "📥 Downloading $package_name..."
  if curl -fsSL "$url" -o "$deb_file"; then
    echo "📦 Installing $package_name..."
    if sudo dpkg -i "$deb_file"; then
      echo "✅ $package_name installed successfully"
      rm -f "$deb_file"
      return 0
    else
      echo "❌ Failed to install $package_name"
      rm -f "$deb_file"
      return 1
    fi
  else
    echo "❌ Failed to download $package_name from URL"
    echo "🔄 Trying to install from Ubuntu repositories..."
    if install_apt_package "$package_name"; then
      echo "✅ $package_name installed from repositories"
      return 0
    else
      echo "❌ $package_name not available in repositories either"
      return 1
    fi
  fi
}

# Function to install apt package
install_apt_package() {
  local package="$1"
  
  if is_package_installed "$package"; then
    echo "✓ $package already installed"
  else
    echo "📥 Installing $package..."
    if sudo apt install -y "$package"; then
      echo "✅ $package installed successfully"
    else
      echo "❌ Failed to install $package"
      return 1
    fi
  fi
}

# Update package list
echo "🔄 Updating package list..."
sudo apt update

echo "📦 Installing Local WP dependencies..."

# 1. Install libtinfo5
echo "🔧 Installing libtinfo5..."
install_deb_package \
  "http://launchpadlibrarian.net/648013231/libtinfo5_6.4-2_amd64.deb" \
  "libtinfo5" \
  "libtinfo5_6.4-2_amd64.deb"

# 2. Install libncurses5  
echo "🔧 Installing libncurses5..."
install_deb_package \
  "http://launchpadlibrarian.net/648013227/libncurses5_6.4-2_amd64.deb" \
  "libncurses5" \
  "libncurses5_6.4-2_amd64.deb"

# 3. Install libaio1
echo "🔧 Installing libaio1..."
install_deb_package \
  "http://launchpadlibrarian.net/646633572/libaio1_0.3.113-4_amd64.deb" \
  "libaio1" \
  "libaio1_0.3.113-4_amd64.deb"

# 4. Install remaining packages via apt
echo "🔧 Installing remaining dependencies via apt..."

# Handle potential dependency issues
sudo apt --fix-broken install -y || true

# Install packages
packages=(
  "libnss3-tools"      # Security certificates and cryptographic operations
  "libnuma1"           # Memory allocation across processors  
  "policykit-1"        # System-wide policies and permissions
  "libgbm-dev"         # Graphics buffer management
  "xdg-utils"          # Desktop environment interaction
  "wslu"               # Windows-Linux integration for WSL
)

for package in "${packages[@]}"; do
  install_apt_package "$package"
done

# Handle audio library (try new name first, then old name)
echo "🔧 Installing audio library..."
if ! install_apt_package "libasound2t64"; then
  echo "📝 Trying older package name..."
  install_apt_package "libasound2"
fi

# Configure WSL browser integration
echo "🌐 Configuring WSL browser integration..."

# Register default Windows browser for WSL
if command -v wslview >/dev/null 2>&1; then
  echo "✓ wslview available for browser integration"
  
  # Try common browsers in order of preference
  BROWSERS=(
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
    "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
    "C:\\Program Files\\Mozilla Firefox\\firefox.exe"
    "C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe"
    "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe"
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
  )
  
  BROWSER_FOUND=false
  for browser_path in "${BROWSERS[@]}"; do
    if [[ -f "$(wslpath -u "$browser_path")" ]]; then
      wslview -r "$(wslpath -au "$browser_path")" 2>/dev/null || true
      BROWSER_NAME=$(basename "$browser_path" .exe)
      echo "✅ $BROWSER_NAME registered as default browser"
      BROWSER_FOUND=true
      break
    fi
  done
  
  if [[ "$BROWSER_FOUND" == "false" ]]; then
    echo "⚠️  No common browsers found. You may need to manually register your browser:"
    echo "   wslview -r \$(wslpath -au 'C:\\Path\\To\\Your\\Browser.exe')"
  fi
else
  echo "❌ wslview not available for browser integration"
fi

# Verification step
echo "🔍 Verifying installations..."
MISSING_PACKAGES=()

# Check critical packages
CRITICAL_PACKAGES=("libnss3-tools" "xdg-utils" "wslu" "libgbm-dev")
for package in "${CRITICAL_PACKAGES[@]}"; do
  if ! is_package_installed "$package"; then
    MISSING_PACKAGES+=("$package")
  fi
done

if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
  echo "⚠️  Some packages may not have installed correctly: ${MISSING_PACKAGES[*]}"
  echo "   Try: sudo apt --fix-broken install"
else
  echo "✓ All critical packages verified"
fi

echo ""
echo "✅ WordPress Local WP WSL dependencies setup completed!"
echo ""
echo "📝 Next steps for Local WP:"
echo "   1. Download Local WP .deb from: https://github.com/getflywheel/local-releases"
echo "   2. Copy .deb file to WSL: explorer.exe . (then drag & drop)"
echo "   3. Install: sudo dpkg -i local-*.deb"
echo "   4. Run Local WP and set Router mode to 'localhost' in Preferences > Advanced"
echo ""
echo "🔧 Troubleshooting tips:"
echo "   • If Local WP fails to start: sudo local --no-sandbox"
echo "   • If you get errors creating sites, restart WSL: wsl --shutdown (from Windows)"
echo "   • If browser doesn't open sites: manually register browser with wslview"
echo "   • Check Local WP logs in ~/.local/share/Local/logs/"
echo ""
echo "🌐 Reference: https://medium.com/@echernicky/setting-up-a-local-wp-wsl-ubuntu-environment-9e7bdc6e9dbd"
