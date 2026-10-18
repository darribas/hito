#!/usr/bin/env bash
#
# Tailscale
#
# Installs Tailscale from its own Fedora repo, starts tailscaled on boot, and
# makes the user its operator so tailscale commands work without sudo. Logging
# in opens a browser, so it's a MANUAL note, printed only when not logged in.
#
# Safe to re-run: the repo is only added if its file is missing, dnf is a no-op
# once installed, systemctl enable --now is a no-op once running, and setting
# the operator again leaves it as it is.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f /etc/yum.repos.d/tailscale.repo ]] || sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

sudo dnf install -y tailscale

sudo systemctl enable --now tailscaled

sudo tailscale set --operator="$USER"

tailscale status >/dev/null 2>&1 || echo "MANUAL: log in to Tailscale: tailscale up (opens a browser link)"
