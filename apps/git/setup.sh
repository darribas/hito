#!/usr/bin/env bash
#
# git and the GitHub CLI
#
# Installs git, and gh from GitHub's own RPM repo (current releases; Fedora's
# package trails by a few versions). Logging in and setting a git identity
# need a human and personal details, so they're MANUAL notes, only printed
# when not done yet.
#
# Safe to re-run: the repo is only added if its file is missing, dnf is a no-op
# once installed, and nothing is written to git or gh config.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f /etc/yum.repos.d/gh-cli.repo ]] || sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo

sudo dnf install -y git gh

if ! git config --global user.name >/dev/null || ! git config --global user.email >/dev/null; then
    echo "MANUAL: set your git identity: git config --global user.name 'Your Name' && git config --global user.email 'you@example.com'"
fi
if ! gh auth status >/dev/null 2>&1; then
    echo "MANUAL: log in to GitHub: gh auth login (answer yes to 'Authenticate Git with your GitHub credentials?' so git push uses it too)"
fi
