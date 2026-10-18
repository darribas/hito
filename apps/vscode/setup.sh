#!/usr/bin/env bash
#
# Visual Studio Code
#
# Installs VSCode from Microsoft's RPM repo rather than Flathub: the Flatpak
# can't see Docker, and attaching to local and remote containers is the main
# use here (Bluefin's developer edition does the same). Adds the extensions
# from gds_env's gds_code image plus the Remote Development pack, and seeds
# settings.json with Catppuccin, Latte when the desktop is light and Mocha
# when dark, switching with it.
#
# Safe to re-run: vscode.repo is overwritten, dnf is a no-op once installed,
# installed extensions are skipped, and settings.json is only written if it
# doesn't exist yet, since VSCode rewrites it whenever a setting is changed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo install -m 0644 "$HERE/vscode.repo" /etc/yum.repos.d/vscode.repo
sudo dnf install -y code

for ext in \
    ms-vscode-remote.vscode-remote-extensionpack \
    catppuccin.catppuccin-vsc \
    vscodevim.vim \
    ms-python.python \
    ms-toolsai.jupyter \
    quarto.quarto \
    james-yu.latex-workshop; do
    code --install-extension "$ext"
done

[[ -f ~/.config/Code/User/settings.json ]] || install -D -m 0644 "$HERE/settings.json" ~/.config/Code/User/settings.json
