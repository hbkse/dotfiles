#!/bin/bash

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> EDIT HERE FOR NEW FILES
# Dotfile mappings: "source_file:destination_path"
DOTFILES=(
    ".zshrc:~/.zshrc"
    ".zprofile:~/.zprofile"
    ".gitconfig:~/.gitconfig"
    "alacritty.toml:~/.config/alacritty/alacritty.toml"
    "yabairc:~/.config/yabai/yabairc"
    "skhdrc:~/.config/skhd/skhdrc"
)

# Check if running from script directory
if [ "$(pwd)" != "$SCRIPT_DIR" ]; then
    echo "❌ Please run this script from the dotfiles directory"
    echo "Run: cd $SCRIPT_DIR && ./$(basename "$0")"
    exit 1
fi

echo "Syncing dotfiles..."

for mapping in "${DOTFILES[@]}"; do
    source_file="${mapping%%:*}"
    dest_path="${mapping##*:}"
    
    # Expand ~ to home directory
    dest_path="${dest_path/#~/$HOME}"
    
    source_full="$SCRIPT_DIR/$source_file"
    
    # Create destination directory if needed
    mkdir -p "$(dirname "$dest_path")"
    
    # Copy file
    if [ -f "$source_full" ]; then
        cp "$source_full" "$dest_path"
        echo "✅ $source_file -> $dest_path"
    else
        echo "❌ $source_file (not found)"
    fi
done

echo "✅ sync.sh done!"