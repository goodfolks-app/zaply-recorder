# Zaply Recorder

Records live TV and downloads films and series for
[Zaply](https://goodfolks.fr/zaply), on a computer that stays on at home. Your
iPhone, iPad and Apple TV schedule, watch and fetch from it, and a web page
manages it from any browser.

**Download page: https://goodfolks-app.github.io/zaply-recorder/**

iPhones and Apple TVs can't record in the background: the system suspends the
app. Zaply Recorder does the recording at home instead, on a Mac, a Windows
PC, a Linux box or a NAS, so a match or a whole series is recorded with the
phone in your pocket.

- **Record** a channel now, a programme from the TV guide, every airing of a
  show, or a match.
- **Download** films and episodes to your library at home, as the provider's
  own file: every audio and subtitle track.
- **Watch** a recording while it records, from any Zaply device.
- **Respects your line:** never more connections than your provider allows,
  and when the line is busy it records the channel's other copy (HD, FHD, 4K).
- **One file per recording**, in folders Plex, Jellyfin and Emby read as they
  are.
- **Alerts** on your iPhone when a recording is ready or failed.
- **Away from home** through Tailscale, or a forwarded HTTPS port.
- **Only through a VPN**, if you want: it records only while the computer's
  VPN is up.

## Download

Version 1.0.0, from the [latest release](https://github.com/goodfolks-app/zaply-recorder/releases/latest).

| System | Download |
|---|---|
| macOS 14 or later, Apple silicon and Intel | [Zaply-Recorder.dmg](https://github.com/goodfolks-app/zaply-recorder/releases/latest/download/Zaply-Recorder.dmg) |
| Windows 10 and 11, x64 | [Installer](https://github.com/goodfolks-app/zaply-recorder/releases/latest/download/Zaply-Recorder-windows-x64.exe) or [portable zip](https://github.com/goodfolks-app/zaply-recorder/releases/latest/download/Zaply-Recorder-windows-x64-portable.zip) |
| Linux (systemd), amd64, arm64, armv7 | `curl -fsSL https://goodfolks-app.github.io/zaply-recorder/install.sh \| sudo sh` |
| Docker / NAS, amd64 and arm64 | `ghcr.io/goodfolks-app/zaply-recorder:latest` |

Checksums: `SHA256SUMS.txt` in the release.

### macOS

Open the disk image and drag Zaply Recorder to Applications. It lives in the
menu bar; its menu opens the web page, and its settings can open it at login.

### Windows

Run the installer. Windows may warn the first time, because the app isn't
signed yet: **More info ▸ Run anyway**. Zaply Recorder lives in the tray and
starts with Windows. The portable zip runs from any folder, without
installing.

### Linux

```sh
curl -fsSL https://goodfolks-app.github.io/zaply-recorder/install.sh | sudo sh
```

It installs `zaply-recorder` as a systemd service and ffmpeg from your
system's packages. Run it again to update. The log:
`journalctl -u zaply-recorder -f`. To remove it (the recordings stay in
`/var/lib/zaply-recorder`):

```sh
curl -fsSL https://goodfolks-app.github.io/zaply-recorder/install.sh | sudo sh -s -- --uninstall
```

Or download the archive for your processor from the release, extract it and
run `sudo ./install.sh`.

### Docker and NAS

Image `ghcr.io/goodfolks-app/zaply-recorder`, tag `latest` (or a version). It
needs two folders and the host's network:

- `/data`: its settings and list of recordings.
- `/library`: what it records and downloads.
- Host networking, so the Zaply apps find it by themselves. Without it,
  publish ports 9393 and 9394 and type the NAS's address in Zaply.

[docker-compose.yml](docker-compose.yml):

```yaml
services:
  zaply-recorder:
    image: ghcr.io/goodfolks-app/zaply-recorder:latest
    network_mode: host
    volumes:
      - /path/to/zaply/data:/data
      - /path/to/zaply/library:/library
    restart: unless-stopped
```

**TrueNAS SCALE** (24.10 or later): make a dataset for the recordings
(Datasets ▸ Add Dataset; the SMB preset if your computers reach it through a
share). Then Apps ▸ Discover Apps ▸ Custom App: image repository
`ghcr.io/goodfolks-app/zaply-recorder`, tag `latest`; Network: Host Network;
Storage: an **ixVolume** (the dataset TrueNAS creates by itself) mounted at
`/data` for its settings, and a **Host Path** to the recordings' dataset
mounted at `/library`. Install. To update, the app's Update button. Deleting
the app with "Remove ixVolumes" ticked deletes its settings; the recordings
stay.
Every field, step by step: [TRUENAS.md](TRUENAS.md).

## Set it up

1. Open its page, `http://<the computer's address>:9393`, to set a password
   and choose the library folder.
2. In Zaply: **Settings ▸ Zaply Recorder ▸ Set up your recorder**. Zaply finds
   it on your network by itself.
3. Record from a channel, the TV guide or a match; download from a film or an
   episode with **Download to the recorder**.

Recordings and downloads then show in Zaply, under Films and Series, and on
the recorder's page.

## Away from home

- **Tailscale (recommended):** install it on the recorder's computer and on
  your iPhone, then give Zaply the recorder's Tailscale address in Settings ▸
  Zaply Recorder ▸ Address away from home. Nothing is exposed to the
  internet.
- **Port forwarding:** forward the HTTPS port, **9394**, on your router (never
  9393), and give Zaply `https://<your home's public address>:9394`. Zaply
  trusts the recorder's own certificate, learnt at home.

## Help

The [Zaply Discord](https://discord.gg/JZhBVAD5V6), or
[goodfolks.fr/zaply/support](https://goodfolks.fr/zaply/support).

## Licences

Zaply Recorder is made by GOODFOLKS SAS. The Mac and Windows apps include
ffmpeg, built from its unmodified source under the LGPL 2.1; how it is built:
[ffmpeg](ffmpeg). Every package lists what it includes in its `licenses`
folder.

Zaply is a media player. It does not provide, host, index or recommend any
content. Users are solely responsible for the content they access and for
complying with the laws that apply to them.
