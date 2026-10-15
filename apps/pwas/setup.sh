#!/usr/bin/env bash
#
# Progressive Web Apps (PWAs) via Chromium
#
# Installs Chromium from the Fedora repos as the host for web apps, and drops
# a Chromium policy (pwas.json, WebAppInstallForceList) that makes it install
# each listed URL as an app in its own window, with a launcher entry and no
# desktop icon. Chromium installs them the next time it starts. The rpm, not
# the Flatpak: Flatpak Chromium/Chrome PWAs don't get their own dock icons on
# Wayland. To add or remove an app, edit pwas.json and re-run.
#
# Known limits: Chromium shows "Managed by your organization" because of the
# policy, and force-installed apps can't be removed from inside Chromium. The
# dock and launcher show each app's own icon, but COSMIC's window switcher
# shows a generic one. Two URLs from the same web app (e.g. Outlook mail and
# Outlook calendar) install as the same app under the same name, so list each
# web app once.
#
# Safe to re-run: dnf is a no-op once Chromium is installed, and the policy
# file is overwritten each time.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y chromium
sudo install -D -m 0644 "$HERE/pwas.json" /etc/chromium/policies/managed/hito-pwas.json

echo "MANUAL: start Chromium once so it installs the PWAs"
