#!/bin/bash

# ==========================================
# Arch Linux Dotfiles Provisioner
# Author: SA Shreyass
# Description: Idempotent setup for Niri, Waybar, and Kitty
# ==========================================

# --- Configuration ---
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
# List the exact folder names you have inside ~/dotfiles
TARGETS=("niri" "waybar" "alacritty" "fastfetch" "mpv")

# --- Colors for Logging ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

ensure_dir() {
    if [ ! -d "$1" ]; then
        log_info "Creating directory: $1"
        mkdir -p "$1"
    fi
}

# --- Core Logic ---
link_config() {
    local app=$1
    local source="$DOTFILES_DIR/$app"
    local target="$CONFIG_DIR/$app"

    # 1. Check if the source actually exists in your dotfiles folder
    if [ ! -e "$source" ]; then
        log_warn "Source config for $app not found at $source. Skipping."
        return
    fi

    # 2. Check current state of the target
    if [ -L "$target" ]; then
        # It's already a symlink. Check where it points.
        local current_link
        current_link=$(readlink -f "$target")
        if [ "$current_link" == "$source" ]; then
            log_success "$app is already correctly linked."
            return
        else
            log_warn "Relinking $app (was pointing to $current_link)"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        # It exists but is a real file/folder (not a link). BACK IT UP.
        local backup_name="${target}.backup.$(date +%s)"
        log_warn "Found existing config for $app. Backing up to $backup_name"
        mv "$target" "$backup_name"
    fi

    # 3. Create the Symlink
    ln -s "$source" "$target"
    log_success "Linked $source -> $target"
}

# --- Main Execution ---
main() {
    clear
    echo -e "${BLUE}=== Starting Dotfiles Setup ===${NC}"
    
    # Ensure .config exists
    ensure_dir "$CONFIG_DIR"

    # Loop through all targets
    for app in "${TARGETS[@]}"; do
        link_config "$app"
    done

    echo -e "${BLUE}=== Setup Complete ===${NC}"
    echo "You may need to restart Niri or logout for changes to take effect."
}

main
