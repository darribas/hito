#!/usr/bin/env bash
#
# Docker
#
# Installs Docker Engine from Docker's own Fedora repo (current releases, unlike
# Fedora's moby-engine), with the buildx and compose plugins, starts it on boot,
# and adds the user to the docker group so docker runs without sudo.
#
# Safe to re-run: the repo is only added if its file is missing, dnf is a no-op
# once installed, systemctl enable --now is a no-op once running, and usermod
# -aG leaves an existing membership as it is.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f /etc/yum.repos.d/docker-ce.repo ]] || sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

sudo usermod -aG docker "$USER"

echo "MANUAL: log out and back in so docker works without sudo (new group membership)"
