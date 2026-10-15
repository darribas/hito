#!/usr/bin/env bash
#
# Spotify
#
# Installs the Spotify client from Flathub.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub com.spotify.Client

echo "MANUAL: sign in to Spotify"
