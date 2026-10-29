# How Zaply Recorder's ffmpeg is built

The Mac and Windows apps include ffmpeg as a separate program, built from
FFmpeg's unmodified source under the LGPL 2.1 or later
(`COPYING.LGPLv2.1` in the source, `licenses/ffmpeg.txt` in each package).
These are the scripts that build it:

- `versions.sh`: the version, the source tarball and its checksum, and the
  components every build has: FFmpeg's own LGPL code only, cut down to what
  the recorder runs.
- `build-macos.sh`: Apple silicon and Intel in one file, TLS from macOS.
- `build-windows.sh`: x64, cross-compiled with MinGW in Docker, TLS from
  Windows.

The Linux packages and the Docker image use the system's ffmpeg instead
(Alpine's, in the image).
