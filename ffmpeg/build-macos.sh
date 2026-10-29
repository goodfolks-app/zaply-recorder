#!/bin/bash
# Builds the ffmpeg the Mac app ships, for Apple silicon and Intel in one file.
#
# TLS comes from macOS (Secure Transport); the components are listed in
# versions.sh, the same for every system.
#
# Usage: packaging/ffmpeg/build-macos.sh   (a minute or two)
# Output: dist/cache/ffmpeg-<version>-macos/ffmpeg, with its licence.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RECORDER="$(cd "$HERE/../.." && pwd)"
source "$HERE/versions.sh"

CACHE="$RECORDER/dist/cache"
OUT="$CACHE/ffmpeg-$FFMPEG_VERSION-macos"
MACOS_MIN=13.0
JOBS="$(sysctl -n hw.ncpu)"

if [[ -x "$OUT/ffmpeg" && -z "${FORCE:-}" ]]; then
    echo "==> $OUT/ffmpeg is already built (FORCE=1 rebuilds it)"
    exit 0
fi

TARBALL="$(ffmpeg_source "$CACHE")"

# FFmpeg's configure passes the compiler and the SDK around unquoted, so
# neither may have a space in its path ("Xcode 27.app").
DEV_DIR="${DEVELOPER_DIR:-$(xcode-select -p)}"
if [[ "$DEV_DIR" == *" "* ]]; then
    LINK="/tmp/zaply-recorder-developer-$(id -u)"
    ln -sfn "$DEV_DIR" "$LINK"
    export DEVELOPER_DIR="$LINK"
fi
CC="$(xcrun --sdk macosx -f clang)"
SYSROOT="$(xcrun --sdk macosx --show-sdk-path)"

build() {
    local arch="$1" src="$CACHE/ffmpeg-src-macos-$1"
    local target="$arch-apple-macos$MACOS_MIN"
    rm -rf "$src" && mkdir -p "$src"
    tar -xf "$TARBALL" -C "$src" --strip-components=1
    cd "$src"
    ./configure \
        --enable-cross-compile --target-os=darwin --arch="$arch" \
        --cc="$CC" --as="$CC" \
        --extra-cflags="-target $target -isysroot $SYSROOT -O2" \
        --extra-ldflags="-target $target -isysroot $SYSROOT" \
        --disable-autodetect --enable-securetransport --enable-zlib \
        "${FFMPEG_COMPONENTS[@]}" \
        > "$CACHE/ffmpeg-configure-macos-$arch.log" 2>&1 || {
            echo "configure failed ($arch):"; tail -30 "$CACHE/ffmpeg-configure-macos-$arch.log"; exit 1; }
    make -j"$JOBS" ffmpeg > "$CACHE/ffmpeg-make-macos-$arch.log" 2>&1 || {
        echo "make failed ($arch):"; tail -30 "$CACHE/ffmpeg-make-macos-$arch.log"; exit 1; }
    echo "==> built ffmpeg for $arch"
}

echo "==> FFmpeg $FFMPEG_VERSION for macOS $MACOS_MIN+ (arm64 and x86_64)"
build arm64 &
arm=$!
build x86_64 &
intel=$!
wait $arm
wait $intel

rm -rf "$OUT" && mkdir -p "$OUT"
lipo -create "$CACHE/ffmpeg-src-macos-arm64/ffmpeg" "$CACHE/ffmpeg-src-macos-x86_64/ffmpeg" -output "$OUT/ffmpeg"
cp "$CACHE/ffmpeg-src-macos-arm64/COPYING.LGPLv2.1" "$OUT/LICENSE.txt"
"$OUT/ffmpeg" -hide_banner -buildconf > "$OUT/BUILD.txt"
rm -rf "$CACHE"/ffmpeg-src-macos-*
lipo -info "$OUT/ffmpeg"
ls -lh "$OUT/ffmpeg"
