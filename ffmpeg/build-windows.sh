#!/bin/bash
# Builds the ffmpeg.exe the Windows app ships (x64: Windows on Arm runs it
# too), cross-compiled with MinGW in Docker. Same components as the Mac one
# (versions.sh); TLS comes from Windows (Schannel), threads are Windows' own,
# and it is linked statically: one file, no DLLs.
#
# Usage: packaging/ffmpeg/build-windows.sh   (Docker running; a few minutes)
# Output: dist/cache/ffmpeg-<version>-windows/ffmpeg.exe, with its licence.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RECORDER="$(cd "$HERE/../.." && pwd)"
source "$HERE/versions.sh"

CACHE="$RECORDER/dist/cache"
OUT="$CACHE/ffmpeg-$FFMPEG_VERSION-windows"

if [[ -f "$OUT/ffmpeg.exe" && -z "${FORCE:-}" ]]; then
    echo "==> $OUT/ffmpeg.exe is already built (FORCE=1 rebuilds it)"
    exit 0
fi

TARBALL="$(ffmpeg_source "$CACHE")"

echo "==> Windows build tools image"
docker build -q -t zaply-recorder-windows "$RECORDER/packaging/windows" > /dev/null

echo "==> FFmpeg $FFMPEG_VERSION for Windows x64"
rm -rf "$OUT" && mkdir -p "$OUT"
# The source goes in through standard input and the result comes back the
# same way, so nothing on this Mac has to be shared with the VM.
docker run --rm -i zaply-recorder-windows sh -c '
    set -e
    mkdir /src && cd /src && tar -xJf - --strip-components=1
    ./configure \
        --enable-cross-compile --target-os=mingw32 --arch=x86_64 \
        --cross-prefix=x86_64-w64-mingw32- --pkg-config=pkg-config \
        --extra-ldflags=-static \
        --disable-autodetect --enable-w32threads --enable-schannel \
        "$@" > /tmp/configure.log 2>&1 || { tail -30 /tmp/configure.log >&2; exit 1; }
    make -j"$(nproc)" ffmpeg.exe > /tmp/make.log 2>&1 || { tail -30 /tmp/make.log >&2; exit 1; }
    x86_64-w64-mingw32-strip ffmpeg.exe
    tar -cf - ffmpeg.exe COPYING.LGPLv2.1
' sh "${FFMPEG_COMPONENTS[@]}" < "$TARBALL" | tar -xf - -C "$OUT"
mv "$OUT/COPYING.LGPLv2.1" "$OUT/LICENSE.txt"
ls -lh "$OUT/ffmpeg.exe"
