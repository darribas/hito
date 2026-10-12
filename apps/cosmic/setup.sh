#!/usr/bin/env bash
#
# COSMIC desktop configuration
#
# Applies captured COSMIC settings — dock position, panel layout, autotiling,
# theme colours and light/dark mode — by copying the payload in config/ into
# ~/.config/cosmic/. COSMIC config is treated as a payload, not parsed (see
# SPEC.md §13).
#
# Also sets the wallpaper: wallpaper.jpg is NASA's "Solar Eclipse of the Heart"
# (art002e009573, taken from the Orion spacecraft in April 2026; credit NASA),
# from https://www.nasa.gov/image-detail/amf-art002e009573/. COSMIC stores the
# wallpaper as an absolute path, so that one file is written here with $HOME
# rather than shipped in config/.
#
# Safe to re-run: rsync, install and the heredoc overwrite the managed files
# each time and leave any other COSMIC settings untouched (no --delete).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER="$HOME/.local/share/backgrounds/art002e009573.jpg"

rsync -a "$HERE/config/" ~/.config/cosmic/

install -D -m 0644 "$HERE/wallpaper.jpg" "$WALLPAPER"
mkdir -p ~/.config/cosmic/com.system76.CosmicBackground/v1
cat > ~/.config/cosmic/com.system76.CosmicBackground/v1/all <<EOF
(
    output: "all",
    source: Path("$WALLPAPER"),
    filter_by_theme: true,
    rotation_frequency: 300,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
EOF

echo "MANUAL: log out and back in for the panel, dock and theme to fully apply"
