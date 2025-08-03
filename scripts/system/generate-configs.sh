#!/usr/bin/env bash

# Load gum-based logging library
source "$(dirname "$0")/../../support/utils/gum-logger.sh"

log_header "🔧 Generating configs from templates"

# Function to ask for overwrite confirmation
ask_overwrite() {
  local file_path="$1"
  local response
  
  if [[ -f "$file_path" ]]; then
    echo -e "${YELLOW}⚠️  File already exists: $file_path${NC}"
    read -p "Overwrite? [y/N]: " response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
      return 0  # Yes, overwrite
    else
      return 1  # No, don't overwrite
    fi
  fi
  
  return 0  # File doesn't exist, proceed
}

# Function to generate config from template
generate_config() {
  local template_file="$1"
  local env_file="$2"
  local output_file="$3"
  
  if [[ ! -f "$template_file" ]]; then
    echo "❌ Template file not found: $template_file"
    return 1
  fi
  
  if [[ ! -f "$env_file" ]]; then
    echo "⚠️  Environment file not found: $env_file"
    echo "   Please copy $(basename "$env_file").example to $(basename "$env_file") and fill in your details"
    return 1
  fi
  
  echo "📝 Generating $output_file from template..."
  
  # Source the environment file
  source "$env_file"
  
  # Replace placeholders in template
  local content
  content=$(cat "$template_file")
  
  # Replace all {{VARIABLE}} patterns with their values
  content="${content//\{\{GIT_NAME\}\}/$GIT_NAME}"
  content="${content//\{\{GIT_EMAIL\}\}/$GIT_EMAIL}"
  content="${content//\{\{GIT_SIGNING_KEY\}\}/$GIT_SIGNING_KEY}"
  
  # SSH-specific variables (if they exist)
  [[ -n "$SSH_HOST" ]] && content="${content//\{\{SSH_HOST\}\}/$SSH_HOST}"
  [[ -n "$SSH_USER" ]] && content="${content//\{\{SSH_USER\}\}/$SSH_USER}"
  [[ -n "$SSH_PORT" ]] && content="${content//\{\{SSH_PORT\}\}/$SSH_PORT}"
  
  # Write to output file
  echo "$content" > "$output_file"
  echo "✅ Generated $output_file successfully!"
}

# Git configuration is now handled directly by install.sh (not generated)

# Generate SSH connections config
generate_ssh_connections() {
  local template_file="support/templates/.ssh-connections.template"
  local output_dir="stow/shell/.config/env-files"
  local output_file="$output_dir/.ssh-connections"
  
  if [[ ! -f "$template_file" ]]; then
    log_error "SSH connections template not found: $template_file"
    return 1
  fi
  
  # Create directory structure
  mkdir -p "$output_dir"
  
  # Check if file exists and ask for overwrite
  if ! prompt_confirm "File $output_file already exists. Overwrite?" false; then
    log_info "Skipping SSH connections generation (file exists, not overwriting)"
    return 0
  fi
  
  log_info "Generating SSH connections config..."
  
  # Copy template to output location (no variable substitution needed for this template)
  cp "$template_file" "$output_file"
  
  log_success "SSH connections config generated: $output_file"
  log_info "Edit $output_file to add your SSH connections"
  log_info "Then run 'stow -d stow -t \$HOME shell' to deploy"
}

# Generate SSH connections if template exists
if [[ -f "support/templates/.ssh-connections.template" ]]; then
  generate_ssh_connections
fi

echo "✅ Config generation completed!"
