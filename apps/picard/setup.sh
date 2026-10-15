#!/usr/bin/env bash
#
# MusicBrainz Picard
#
# Installs MusicBrainz Picard, the music tagger, from Flathub.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub org.musicbrainz.Picard
