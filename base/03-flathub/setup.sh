#!/usr/bin/env bash
#
# Flathub
#
# Adds the Flathub remote and removes the filter Fedora applies to it. Fedora
# ships Flathub filtered down to a curated subset, which makes a large chunk of
# apps invisible; --no-filter exposes the full catalogue so later Flatpak
# installs can find them.
#
# Safe to re-run: remote-add uses --if-not-exists and remote-modify is idempotent.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --no-filter flathub
