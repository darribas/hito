#!/usr/bin/env bash
#
# gds_env and gdsa
#
# Clones gds_env into ~/code/gds_env, builds its three images (gds, the base;
# gds_code; gds_agent) with gds_env's own Makefile, and installs the gdsa
# launcher into ~/.local/bin. A fresh build takes about an hour. Needs
# apps/docker, which runs before this (alphabetical); docker commands go
# through `sg docker` so they work in the same run that added the user to the
# docker group, before any re-login.
#
# Ends with a MANUAL note if gdsa has no Ollama endpoint to use (gdsa opencode
# stops without one), or if the one set doesn't answer.
#
# Safe to re-run: an existing clone is left alone (no pull), each image is
# only built if its :latest tag is missing (remove it to rebuild), and
# install_gdsa only re-links gdsa and seeds opencode config that's missing.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GDS_ENV=~/code/gds_env

sudo dnf install -y git make python3

[[ -d "$GDS_ENV/.git" ]] || git clone https://github.com/darribas/gds_env.git "$GDS_ENV"
cd "$GDS_ENV"

# The frontends get image=gds:latest because the Makefile's default base is a
# date-stamped tag (gds:<today>_amd64), which won't exist on a later re-run
sg docker -c "docker image inspect gds:latest"       >/dev/null 2>&1 || sg docker -c "make build"
sg docker -c "docker image inspect gds_code:latest"  >/dev/null 2>&1 || sg docker -c "make build_code image=gds:latest"
sg docker -c "docker image inspect gds_agent:latest" >/dev/null 2>&1 || sg docker -c "make build_agent image=gds:latest"
make install_gdsa

# Same lookup order as gdsa: OLLAMA_HOST, else utils/provider-url.txt
url_file="$GDS_ENV/utils/provider-url.txt"
ollama_host="${OLLAMA_HOST:-$(cat "$url_file" 2>/dev/null || true)}"
if [[ -z "$ollama_host" ]]; then
    echo "MANUAL: gdsa opencode needs an Ollama endpoint. Put it in $url_file as bare host:port, no http://, e.g. echo '192.0.2.10:11434' > $url_file (a Tailscale name such as my-ollama-box:11434 works too). Optional OpenAI-compatible endpoint, same format: $GDS_ENV/utils/openai-provider-url.txt"
elif ! curl -fsS -m 5 -o /dev/null "http://$ollama_host/api/tags"; then
    echo "MANUAL: the Ollama endpoint '$ollama_host' (from OLLAMA_HOST or $url_file) didn't answer. If it's on your tailnet, log in to Tailscale first; otherwise check the address."
fi
