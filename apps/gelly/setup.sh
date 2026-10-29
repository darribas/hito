#!/usr/bin/env bash
#
# Gelly
#
# Installs Gelly, a music player for Jellyfin and Subsonic/Navidrome servers,
# from Flathub.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub io.m51.Gelly

echo "MANUAL: open Gelly, choose Subsonic and sign in to your server"
