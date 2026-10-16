#!/usr/bin/env bash
#
# nbpreview
#
# Installs nbpreview, a terminal viewer for Jupyter notebooks, as a uv tool:
# its own isolated environment, with the command in ~/.local/bin. uv comes
# from the Fedora repos.
#
# Pinned to Python 3.12: nbpreview needs Pillow < 11, which has no wheels for
# Fedora 44's Python 3.14 and fails to build from source. Fedora's uv has
# Python downloads set to manual, so 3.12 comes from dnf too.
#
# Safe to re-run: dnf is a no-op once uv and python3.12 are installed, and uv
# tool install is a no-op once nbpreview is installed.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y uv python3.12
uv tool install --python 3.12 nbpreview
