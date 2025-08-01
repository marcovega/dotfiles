#!/usr/bin/env bash

echo "🔧 Generating configs from templates..."

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
  
  # Write to output file
  echo "$content" > "$output_file"
  echo "✅ Generated $output_file successfully!"
}

# Generate git config if template and env file exist
if [[ -f "configs/git/.gitconfig.template" ]]; then
  generate_config "configs/git/.gitconfig.template" "configs/git/.env.git" "configs/git/.gitconfig"
fi

echo "✅ Config generation completed!"
