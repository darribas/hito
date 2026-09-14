#!/usr/bin/env bash
#
# dnf configuration
#
# Sets three keys in /etc/dnf/dnf.conf so every later dnf call is faster and
# less chatty: parallel downloads, fastest-mirror selection, and assume-yes.
#
# Safe to re-run: each line is appended only if it is not already present.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF=/etc/dnf/dnf.conf

grep -qxF 'max_parallel_downloads=10' "$CONF" || echo 'max_parallel_downloads=10' | sudo tee -a "$CONF" >/dev/null
grep -qxF 'fastestmirror=True'        "$CONF" || echo 'fastestmirror=True'        | sudo tee -a "$CONF" >/dev/null
grep -qxF 'defaultyes=True'           "$CONF" || echo 'defaultyes=True'           | sudo tee -a "$CONF" >/dev/null
