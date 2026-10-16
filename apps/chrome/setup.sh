#!/usr/bin/env bash
#
# Google Chrome
#
# Installs Google Chrome (stable channel) from Flathub. This is Flathub's
# community-maintained wrapper around Google's official build, not a package
# Google publishes itself. PWAs are hosted by Chromium instead (apps/pwas).
#
# Safe to re-run: flatpak install is a no-op once Chrome is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub com.google.Chrome
