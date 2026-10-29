#!/usr/bin/env bash
#
# Obsidian
#
# Installs Obsidian, the notes app, from Flathub. The vault, plugins and look
# all arrive through Obsidian Sync, which needs a manual sign-in.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub md.obsidian.Obsidian

echo "MANUAL: open Obsidian, sign in to Sync and connect the vault. Before the first sync, turn on every switch under Settings > Sync > Vault configuration sync (they're per device), then turn off restricted mode under Community plugins"
