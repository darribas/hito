#!/usr/bin/env bash
#
# COSMIC Terminal with zsh + oh-my-zsh
#
# Installs zsh and oh-my-zsh, and gives COSMIC Terminal a default profile that
# runs /usr/bin/zsh. The login shell stays bash (no chsh), so TTYs, SSH
# sessions and scripts are unaffected; terminals get zsh only where a profile
# asks for it (apps/ptyxis does the same for Ptyxis). The profile is a payload in config/, copied into
# ~/.config/cosmic/ like apps/cosmic (see SPEC.md §13).
#
# Safe to re-run: dnf is a no-op once zsh is installed, oh-my-zsh is only
# installed if ~/.oh-my-zsh is missing (so ~/.zshrc is left alone after the
# first run), and rsync overwrites the COSMIC Terminal profiles each time,
# replacing any profiles added by hand in its Profiles dialog.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# git: the oh-my-zsh installer clones its repo
sudo dnf install -y zsh git

# --unattended: don't chsh to zsh and don't drop into a zsh shell mid-run
[[ -d ~/.oh-my-zsh ]] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

rsync -a "$HERE/config/" ~/.config/cosmic/
