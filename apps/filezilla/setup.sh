#!/usr/bin/env bash
#
# FileZilla
#
# Installs FileZilla, the FTP/SFTP client, from Flathub.
#
# Safe to re-run: flatpak install is a no-op once it is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

flatpak install -y --noninteractive flathub org.filezillaproject.Filezilla
