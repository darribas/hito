#!/usr/bin/env bash
#
# Ptyxis terminal with zsh + oh-my-zsh
#
# Installs Ptyxis from Flathub, alongside COSMIC Terminal as an equal (neither
# is the default), plus zsh and oh-my-zsh, and gives Ptyxis a default profile
# with the Grass palette that runs /usr/bin/zsh. The login shell stays bash (no
# chsh). The Flatpak has no dconf access, so its settings live in a GSettings
# keyfile inside its sandbox; keyfile here is that file, with a fixed profile
# UUID, so it applies even before Ptyxis has ever been launched.
#
# Safe to re-run: dnf and flatpak are no-ops once installed, oh-my-zsh is only
# installed if ~/.oh-my-zsh is missing (so ~/.zshrc is left alone after the
# first run), and the keyfile is overwritten each time, replacing any Ptyxis
# preferences or profiles changed by hand.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTYXIS_ID="app.devsuite.Ptyxis"

# git: the oh-my-zsh installer clones its repo
sudo dnf install -y zsh git

# --unattended: don't chsh to zsh and don't drop into a zsh shell mid-run
[[ -d ~/.oh-my-zsh ]] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

flatpak install -y --noninteractive flathub "$PTYXIS_ID"

install -D -m 0644 "$HERE/keyfile" "$HOME/.var/app/$PTYXIS_ID/config/glib-2.0/settings/keyfile"
