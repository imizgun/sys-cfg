#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR..."

link() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
        echo "  backed up: ${dst}.bak.*"
    fi
    rm -rf "$dst"
    ln -sf "$src" "$dst"
    echo "  linked: $dst"
}

mkdir -p ~/.config

link "$DOTFILES_DIR/niri"         ~/.config/niri
link "$DOTFILES_DIR/alacritty"    ~/.config/alacritty
link "$DOTFILES_DIR/noctalia"     ~/.config/noctalia
link "$DOTFILES_DIR/spotify_player" ~/.config/spotify-player
link "$DOTFILES_DIR/ghostty"      ~/.config/ghostty
link "$DOTFILES_DIR/helix"        ~/.config/helix

echo "Done! Run ./install.sh again if you add new config directories."
