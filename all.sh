#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

sudo -v   # cache credentials up front so scripts don't each prompt

for f in base/*/setup.sh apps/*/setup.sh; do
  echo "==> $f"
  bash "$f"
done
