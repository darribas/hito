#!/usr/bin/env bash
#
# Desktop utilities
#
# Installs four small GNOME/COSMIC utilities from Flathub: Disk Usage Analyzer,
# Document Viewer (Papers, made the default for PDFs), Image Viewer (Loupe),
# and Enroll, a front end for recording fingerprints with the system's fprintd
# service (installed here too, since the Flatpak can't provide it).
#
# Safe to re-run: dnf and flatpak are no-ops once installed, and xdg-mime
# rewrites the same default each time.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y fprintd

flatpak install -y --noninteractive flathub \
  org.gnome.baobab \
  org.gnome.Papers \
  org.gnome.Loupe \
  org.cosmic_utils.enroll

xdg-mime default org.gnome.Papers.desktop application/pdf

echo "MANUAL: open Enroll and record a fingerprint"
