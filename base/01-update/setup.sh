#!/usr/bin/env bash
#
# System update
#
# Brings the whole system current so later installs build on an up-to-date base.
#
# Safe to re-run: dnf upgrade is a no-op when nothing is out of date.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf upgrade -y
