#!/usr/bin/env bash
#
# bootstrap — curl-installable entry point for the hito provisioning repo
#
# Clones (or updates) the repo to ~/provision and hands off to all.sh. This is
# both the fresh-install path and the update path.
#
# Safe to re-run: an existing clone is fast-forwarded, not re-cloned.
#
# Run it with:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/darribas/hito/main/bootstrap.sh)"
# NOT `curl ... | bash` — piping consumes stdin, so sudo cannot prompt and the
# first privileged command kills the run.

set -euo pipefail

REPO="https://github.com/darribas/hito.git"
PROVISION_DIR="${PROVISION_DIR:-$HOME/provision}"
PROVISION_REF="${PROVISION_REF:-main}"

if [[ "$(id -u)" -eq 0 ]]; then
  echo "Do not run as root. The scripts use sudo inline and expect a real \$HOME." >&2
  exit 1
fi

if [[ ! -f /etc/fedora-release ]]; then
  echo "This does not look like Fedora (/etc/fedora-release missing). Aborting." >&2
  exit 1
fi

if [[ "${XDG_CURRENT_DESKTOP:-}" != *COSMIC* ]]; then
  echo "WARNING: COSMIC not detected — continuing anyway (VM or other session?)." >&2
fi

command -v git >/dev/null || sudo dnf install -y git

if [[ -d "$PROVISION_DIR/.git" ]]; then
  git -C "$PROVISION_DIR" fetch origin
  git -C "$PROVISION_DIR" checkout "$PROVISION_REF"
  git -C "$PROVISION_DIR" pull --ff-only
else
  git clone --branch "$PROVISION_REF" "$REPO" "$PROVISION_DIR"
fi

echo
echo "Provisioning directory: $PROVISION_DIR (ref: $PROVISION_REF)"
echo "About to run $PROVISION_DIR/all.sh — every script in base/ then apps/."
read -r -p "Continue? [y/N] " reply
[[ "$reply" == [yY] ]] || { echo "Aborted."; exit 0; }

exec "$PROVISION_DIR/all.sh"
