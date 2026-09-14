#!/usr/bin/env bash
#
# Zen browser
#
# Installs Zen from Flathub, applies the user.js prefs, and grants the
# filesystem access it needs for downloads.
#
# Safe to re-run: user.js is overwritten each time. Anything Zen keeps in
# SQLite (workspaces, sidebar layout) is NOT managed here.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZEN_ID="app.zen_browser.zen"

flatpak install -y --noninteractive flathub "$ZEN_ID"
flatpak override --user --filesystem=~/Downloads "$ZEN_ID"

PROFILE=$(find "$HOME/.var/app/$ZEN_ID/.zen" -maxdepth 1 -name '*.Default*' -type d 2>/dev/null | head -1)
if [[ -z "$PROFILE" ]]; then
  echo "No Zen profile yet — launch Zen once, then re-run this script." >&2
  exit 1
fi

install -m 0644 "$HERE/user.js" "$PROFILE/user.js"

echo "MANUAL: sign in to Zen sync"
