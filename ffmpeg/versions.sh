# The ffmpeg every package ships. Sourced by the build scripts.

# macOS: built from source by build-macos.sh.
FFMPEG_VERSION=9.0.2
FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz"
FFMPEG_SHA256=8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e

# What every ffmpeg we build has: only FFmpeg's own LGPL code, cut down to
# what the recorder runs (read any provider stream, copy it into MPEG-TS
# segments, save a JPEG thumbnail). Every demuxer and protocol stays, so an
# unusual stream still records; encoders, muxers and filters are only the ones
# the recorder uses, decoders the ones probing and thumbnails need.
FFMPEG_COMPONENTS=(
    --disable-doc --disable-debug --disable-ffplay --disable-ffprobe
    --disable-avdevice --disable-devices
    --disable-encoders --enable-encoder=mjpeg
    --disable-muxers --enable-muxer=segment,mpegts,image2,null
    --disable-filters
    --enable-filter=buffer,buffersink,abuffer,abuffersink,scale,format,null,anull,aformat,aresample,atrim,trim,crop,hflip,vflip,transpose,setpts,asetpts
    --disable-decoders
    --enable-decoder=h264,hevc,mpeg1video,mpeg2video,mpeg4,h263,vc1,vp8,vp9,av1,mjpeg,png,aac,aac_latm,ac3,eac3,mp2,mp3,opus,flac,dca,truehd,mlp,pcm_s16le,pcm_s16be,pcm_bluray,pcm_dvd,dvbsub,dvdsub,pgssub,ccaption,mov_text,subrip,webvtt,ass,ssa,text
)

# ffmpeg_source <cache dir> prints the path of the checked source tarball,
# downloading it when it isn't there. The player engine's build keeps the same
# tarball, so it is reused from there when present.
ffmpeg_source() {
    local cache="$1" file="$1/ffmpeg-$FFMPEG_VERSION.tar.xz"
    local engine
    engine="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/Zaply/ZaplyPlayer/build/ffmpeg-$FFMPEG_VERSION.tar.xz"
    mkdir -p "$cache"
    if [[ ! -f "$file" ]]; then
        if [[ -f "$engine" ]]; then
            cp "$engine" "$file"
        else
            curl -fL --retry 3 -o "$file.part" "$FFMPEG_URL" >&2 && mv "$file.part" "$file"
        fi
    fi
    if [[ "$(shasum -a 256 "$file" | cut -d' ' -f1)" != "$FFMPEG_SHA256" ]]; then
        echo "ffmpeg-$FFMPEG_VERSION.tar.xz doesn't match its checksum" >&2
        rm -f "$file"
        return 1
    fi
    echo "$file"
}
