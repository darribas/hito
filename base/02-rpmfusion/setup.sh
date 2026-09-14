#!/usr/bin/env bash
#
# RPM Fusion + multimedia codecs
#
# Enables the RPM Fusion free and nonfree repos for the running Fedora release,
# then replaces Fedora's stripped-down ffmpeg-free with the full ffmpeg and
# pulls in the multimedia codecs Fedora omits for patent reasons. Without this,
# a lot of web video and many media files will not play.
#
# Safe to re-run: the release RPMs no-op once installed, the swap is guarded by
# an rpm -q check, and the group update is a no-op when already current.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# swap only if the full ffmpeg is not already in place, so re-runs are no-ops
rpm -q ffmpeg >/dev/null 2>&1 || sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
