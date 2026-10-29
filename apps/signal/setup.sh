#!/usr/bin/env bash
#
# Signal
#
# Installs Signal Desktop, the messenger, from Flathub.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub org.signal.Signal

echo "MANUAL: link Signal to your phone (scan the QR code from Settings > Linked devices)"
