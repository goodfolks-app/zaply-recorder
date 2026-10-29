#!/bin/sh
# Installs Zaply Recorder on Linux as a systemd service, or updates it to the
# latest version:
#
#   curl -fsSL https://goodfolks-app.github.io/zaply-recorder/install.sh | sudo sh
#
# It downloads the archive for this processor from the latest release on
# github.com/goodfolks-app/zaply-recorder, checks it against the release's
# checksums, and runs the install.sh inside it (which also installs ffmpeg
# from the system's packages). Options go through to that one:
#
#   ... | sudo sh -s -- --uninstall      removes it, keeping data and recordings
#
# ZAPLY_RECORDER_VERSION=1.0.0 picks a version instead of the latest.
set -eu

REPO=goodfolks-app/zaply-recorder

say() { printf '%s\n' "$*"; }
fail() { say "zaply-recorder: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fail "run it as root: curl -fsSL https://goodfolks-app.github.io/zaply-recorder/install.sh | sudo sh"
command -v curl > /dev/null || fail "curl is needed"
command -v tar > /dev/null || fail "tar is needed"

case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    armv7* | armv8l | armhf) arch=armv7 ;;
    *) fail "no Linux build for $(uname -m): try the Docker image, ghcr.io/$REPO" ;;
esac

# The latest release, unless a version is asked for.
if [ -n "${ZAPLY_RECORDER_VERSION:-}" ]; then
    base="https://github.com/$REPO/releases/download/v$ZAPLY_RECORDER_VERSION"
else
    base="https://github.com/$REPO/releases/latest/download"
fi
name="zaply-recorder-linux-$arch.tar.gz"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

say "Downloading Zaply Recorder for $arch…"
curl -fsSL -o "$work/$name" "$base/$name" || fail "couldn't download $base/$name"
if curl -fsSL -o "$work/SHA256SUMS.txt" "$base/SHA256SUMS.txt" && command -v sha256sum > /dev/null; then
    (cd "$work" && grep " $name\$" SHA256SUMS.txt | sha256sum -c - > /dev/null) ||
        fail "$name doesn't match the release's checksum"
fi
tar -xzf "$work/$name" -C "$work"
# The archive holds one folder, named after its version.
installer="$(find "$work" -mindepth 2 -maxdepth 2 -name install.sh | head -n 1)"
[ -n "$installer" ] || fail "$name has no install.sh"
sh "$installer" "$@"
