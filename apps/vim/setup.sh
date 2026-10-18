#!/usr/bin/env bash
#
# Vim and gvim with Catppuccin
#
# Installs Vim for the terminal (vim) and the GUI (gvim), vim-plug, and a
# ~/.vimrc adapted from gds_env with its plugins. The theme is Catppuccin:
# Latte when light, Mocha when dark, following COSMIC's light/dark mode at
# startup. gvim starts without the menu bar and toolbar.
#
# Safe to re-run: dnf is a no-op once installed, ~/.vimrc and plug.vim are
# overwritten each time (so hand edits to ~/.vimrc are lost), and PlugInstall
# only installs plugins that are missing; it does not update existing ones
# (run :PlugUpdate in vim for that).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# vim-X11 provides gvim; git: vim-plug clones the plugins
sudo dnf install -y vim-enhanced vim-X11 git

install -m 0644 "$HERE/vimrc" ~/.vimrc

curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# -es: run headless, without a terminal UI
vim -es -u ~/.vimrc -i NONE +PlugInstall +qall
