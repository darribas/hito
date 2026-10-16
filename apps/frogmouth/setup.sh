#!/usr/bin/env bash
#
# frogmouth
#
# Installs frogmouth, a terminal Markdown browser (Textualize), as a uv tool:
# its own isolated environment, with the command in ~/.local/bin. uv comes
# from the Fedora repos.
#
# Pinned to Python 3.12: frogmouth's httpx/httpcore pins crash on start under
# Fedora 44's Python 3.14 ("'typing.Union' object has no attribute
# '__module__'"). Fedora's uv has Python downloads set to manual, so 3.12
# comes from dnf too.
#
# Safe to re-run: dnf is a no-op once uv and python3.12 are installed, and uv
# tool install is a no-op once frogmouth is installed (it replaces an install
# that used a different Python).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y uv python3.12
uv tool install --python 3.12 frogmouth
