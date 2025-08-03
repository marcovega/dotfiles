#!/usr/bin/env bash
# 
# Gum-based logging library for dotfiles
# Provides beautiful, consistent terminal UI across all installation scripts
#
# Usage:
#   source support/utils/gum-logger.sh
#   log_info "Installing packages..."
#   log_success "Installation complete!"
#   log_warning "Something might need attention"
#   log_error "Installation failed"
#   log_debug "Debug information"
#

# Check if gum is available, fallback to basic echo if not
if ! command -v gum >/dev/null 2>&1; then
    # Fallback functions if gum is not available
    log_info() { echo -e "\033[0;34mℹ️  $1\033[0m"; }
    log_success() { echo -e "\033[0;32m✅ $1\033[0m"; }
    log_warning() { echo -e "\033[1;33m⚠️  $1\033[0m"; }
    log_error() { echo -e "\033[0;31m❌ $1\033[0m"; }
    log_debug() { echo -e "\033[0;37m🐛 $1\033[0m"; }
    log_progress() { echo -e "\033[0;36m⏳ $1\033[0m"; }
    
    # Interactive prompts fallback
    prompt_confirm() {
        local message="$1"
        local default="${2:-true}"
        
        if [[ "$default" == "true" ]]; then
            read -p "$message (Y/n): " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
        else
            read -p "$message (y/N): " -n 1 -r
            echo ""
            [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
        fi
    }
    
    return 0
fi

# Gum-based logging functions
log_info() {
    gum style --foreground 75 --bold "ℹ️  $1"
}

log_success() {
    gum style --foreground 46 --bold "✅ $1"
}

log_warning() {
    gum style --foreground 214 --bold "⚠️  $1"
}

log_error() {
    gum style --foreground 196 --bold "❌ $1"
}

log_debug() {
    # Only show debug messages if DEBUG=1 is set
    if [[ "${DEBUG:-0}" == "1" ]]; then
        gum style --foreground 242 "🐛 $1"
    fi
}

log_progress() {
    gum style --foreground 51 "⏳ $1"
}

# Enhanced logging with more visual impact
log_header() {
    gum style \
        --foreground 51 \
        --border-foreground 51 \
        --border double \
        --align center \
        --width 80 \
        --margin "1 0" \
        --padding "1 2" \
        "$1"
}

log_step() {
    local step="$1"
    local message="$2"
    gum style --foreground 51 --bold "[$step] $message"
}

# Interactive prompts using gum
prompt_confirm() {
    local message="$1"
    local default="${2:-true}"
    
    if [[ "$default" == "true" ]]; then
        gum confirm "$message" --default=true
    else
        gum confirm "$message" --default=false
    fi
}

prompt_choose() {
    local message="$1"
    shift
    local options=("$@")
    
    gum choose --header="$message" "${options[@]}"
}

prompt_input() {
    local message="$1"
    local placeholder="${2:-}"
    
    if [[ -n "$placeholder" ]]; then
        gum input --placeholder="$placeholder" --prompt="$message: "
    else
        gum input --prompt="$message: "
    fi
}

# Progress bar functions
show_progress() {
    local message="$1"
    local duration="${2:-3}"
    
    echo "$message"
    seq 1 100 | while read -r i; do
        sleep $(echo "scale=2; $duration/100" | bc -l) 2>/dev/null || sleep 0.03
        echo $i
    done | gum progress --scale=100 --show-title="$message"
}

# File operations with nice UI
show_file_tree() {
    local path="${1:-.}"
    gum style --foreground 51 --bold "📁 Directory structure:"
    tree "$path" 2>/dev/null || find "$path" -type d | head -20
}

# Banner/header functions
show_banner() {
    gum style \
        --foreground 51 \
        --border-foreground 51 \
        --border double \
        --align center \
        --width 80 \
        --margin "2 0" \
        --padding "2 4" \
        "🔧 Kito's Dotfiles Installation" \
        "" \
        "Setting up your development environment..."
}

# Error handling
log_fatal() {
    log_error "$1"
    gum style \
        --foreground 196 \
        --border-foreground 196 \
        --border thick \
        --align center \
        --width 60 \
        --margin "1 0" \
        --padding "1 2" \
        "💀 FATAL ERROR" \
        "" \
        "Installation cannot continue" \
        "Please check the error above"
    exit 1
}

# Export functions so they're available when sourced
export -f log_info log_success log_warning log_error log_debug log_progress
export -f log_header log_step log_fatal
export -f prompt_confirm prompt_choose prompt_input show_progress
export -f show_file_tree show_banner
