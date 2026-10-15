#!/usr/bin/env bash
#
# QGIS
#
# Installs the QGIS desktop GIS from Flathub, on the stable branch (the latest
# release, a new one every ~4 months). Flathub also has an lts branch, so the
# branch has to be named: with --noninteractive, flatpak can't ask which one.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub org.qgis.qgis//stable
