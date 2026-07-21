# Dotfiles

Personal dotfiles for **macOS** (daily driver) and **Linux** (occasional use).

## Layout

Configs are split into shared and OS-specific folders:

| Path | Applies to | Symlinked to |
|------|-----------|--------------|
| `common/nvim/` | both | `~/.config/nvim` |
| `macos/zshrc` | macOS | `~/.zshrc` |
| `macos/ghostty/config` | macOS | `~/.config/ghostty/config` |
| `linux/zshrc` | Linux | `~/.zshrc` |
| `linux/kitty/` | Linux | `~/.config/kitty` |
| `linux/wezterm.lua` | Linux | `~/.wezterm.lua` |

The two shells differ on purpose: macOS uses **oh-my-zsh + spaceship**, Linux uses
**zinit + oh-my-posh**. Neovim is shared across both.

## Install

```sh
git clone git@github.com:e-lopezc/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` detects the OS with `uname` and symlinks the shared + matching
OS-specific configs into place. Any existing real file at a target path is backed
up to `<path>.bak` first. Since the installed configs are symlinks, edits made in
this repo take effect immediately — no reinstall needed.
