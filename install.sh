#!/usr/bin/env sh
# install.sh — symlink dotfiles for the current OS.
#
# Shared configs (common/) are linked on every machine; OS-specific configs
# come from macos/ or linux/ depending on `uname`. Any existing *real* file
# or directory at a target path is backed up to "<path>.bak" before linking,
# so nothing is silently overwritten. Because targets are symlinks, edits made
# in this repo are live immediately.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
    src="$1"
    dest="$2"
    if [ ! -e "$src" ]; then
        echo "skip (missing source): $src"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.bak"
        echo "backup: $dest -> $dest.bak"
    fi
    ln -sfn "$src" "$dest"
    echo "link:   $dest -> $src"
}

# --- shared (all machines) ---
link "$DIR/common/nvim"      "$HOME/.config/nvim"
link "$DIR/devbox/bin/devbox" "$HOME/.local/bin/devbox"

# --- OS-specific ---
case "$(uname -s)" in
    Darwin)
        link "$DIR/macos/zshrc"          "$HOME/.zshrc"
        link "$DIR/macos/ghostty/config" "$HOME/.config/ghostty/config"
        ;;
    Linux)
        link "$DIR/linux/zshrc"       "$HOME/.zshrc"
        link "$DIR/linux/kitty"       "$HOME/.config/kitty"
        link "$DIR/linux/wezterm.lua" "$HOME/.wezterm.lua"
        ;;
    *)
        echo "unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac

echo "done."
