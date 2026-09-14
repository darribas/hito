#!/usr/bin/env bash
#
# COSMIC desktop configuration
#
# Applies captured COSMIC settings — dock position, panel layout, theme colours
# and light/dark mode — by copying the payload in config/ into ~/.config/cosmic/.
# COSMIC config is treated as a payload, not parsed (see SPEC.md §13).
#
# Safe to re-run: rsync overwrites the managed files each time and leaves any
# other COSMIC settings untouched (no --delete).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rsync -a "$HERE/config/" ~/.config/cosmic/

echo "MANUAL: log out and back in for the panel, dock and theme to fully apply"
